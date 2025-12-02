@echo off
:: clean_c_drive.bat - safer, deeper cleanup for C:
:: Run as Administrator (right-click -> Run as administrator)

echo [INFO] This script will clean TEMP, Windows Update cache, Prefetch, Recycle Bin, thumbnail cache, Delivery Optimization cache, and other temp files.
echo [INFO] Some steps are "deep clean" and may modify system files or remove large data. Please confirm before proceeding.
echo.

:: 檢查是否為系統管理員
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo [ERROR] This script must be run with Administrator privileges. Please re-run as administrator.
  pause
  exit /b 1
)

:: 參數解析: 支援 /quiet /deep /no-resetbase /no-restorepoint
set "QUIET=0"
set "DEEP=0"
set "NORESETBASE=0"
set "NORESTOREPOINT=0"
for %%A in (%*) do (
  if /I "%%~A"=="/quiet" set "QUIET=1"
  if /I "%%~A"=="/deep" set "DEEP=1"
  if /I "%%~A"=="/no-resetbase" set "NORESETBASE=1"
  if /I "%%~A"=="/no-restorepoint" set "NORESTOREPOINT=1"
)

if %QUIET%==0 (
  choice /M "Continue with cleanup? (It's recommended to close other applications)"
  if errorlevel 2 goto :eof
)

:: 建立 log
set "_now=%DATE%_%TIME%"
set "_now=%_now::=-%"
set "_now=%_now:/=-%"
set "LOG=%TEMP%\clean_c_drive_log_%_now%.txt"
echo Clean run started at %DATE% %TIME% > "%LOG%"

:: 紀錄執行前磁碟空間
for /f "tokens=3" %%D in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace ^| findstr /R /V "FreeSpace"') do set "BEFORE_FREE=%%D"
echo FreeSpaceBeforeBytes=%BEFORE_FREE% >> "%LOG%"

:: 1) 使用者 TEMP (每個使用者)
echo [STEP] Cleaning all users' Temp folders... >> "%LOG%"
echo [STEP] Cleaning all users' Temp folders...
for /d %%u in (C:\Users\*) do (
  if exist "%%u\AppData\Local\Temp" (
    echo   - 清除 %%u\AppData\Local\Temp >> "%LOG%"
    del /f /s /q "%%u\AppData\Local\Temp\*" 2>> "%LOG%"
    for /d %%i in ("%%u\AppData\Local\Temp\*") do rd /s /q "%%i" 2>> "%LOG%"
  )
)

:: 2) Windows TEMP
echo [STEP] Cleaning C:\Windows\Temp ... >> "%LOG%"
echo [STEP] Cleaning C:\Windows\Temp ...
if exist "C:\Windows\Temp" (
  del /f /s /q "C:\Windows\Temp\*" 2>> "%LOG%"
  for /d %%i in ("C:\Windows\Temp\*") do rd /s /q "%%i" 2>> "%LOG%"
)

:: 3) Windows Update / SoftwareDistribution
echo [STEP] Stopping Windows Update related services (wuauserv, bits, cryptsvc, DoSvc) ... >> "%LOG%"
echo [STEP] Stopping Windows Update related services (wuauserv, bits, cryptsvc, DoSvc) ...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop cryptsvc >nul 2>&1
net stop DoSvc >nul 2>&1

echo [STEP] Cleaning C:\Windows\SoftwareDistribution\Download ... >> "%LOG%"
echo [STEP] Cleaning C:\Windows\SoftwareDistribution\Download ...
if exist "C:\Windows\SoftwareDistribution\Download" (
  del /f /s /q "C:\Windows\SoftwareDistribution\Download\*" 2>> "%LOG%"
  for /d %%i in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%i" 2>> "%LOG%"
)

:: 清除 Delivery Optimization cache
echo [STEP] Cleaning Delivery Optimization cache (C:\ProgramData\Microsoft\DeliveryOptimization) ... >> "%LOG%"
echo [STEP] Cleaning Delivery Optimization cache (C:\ProgramData\Microsoft\DeliveryOptimization) ...
if exist "C:\ProgramData\Microsoft\DeliveryOptimization" (
  del /f /s /q "C:\ProgramData\Microsoft\DeliveryOptimization\*" 2>> "%LOG%"
  for /d %%i in ("C:\ProgramData\Microsoft\DeliveryOptimization\*") do rd /s /q "%%i" 2>> "%LOG%"
)

:: 4) Prefetch
echo [STEP] Cleaning C:\Windows\Prefetch ... >> "%LOG%"
echo [STEP] Cleaning C:\Windows\Prefetch ...
if exist "C:\Windows\Prefetch" (
  del /f /s /q "C:\Windows\Prefetch\*" 2>> "%LOG%"
)

:: 5) 回收筒
echo [STEP] Emptying Recycle Bin on all drives ... >> "%LOG%"
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" 2>> "%LOG%"
echo [STEP] Emptying Recycle Bin on all drives ...

:: 6) 錯誤報告暫存
echo [STEP] Cleaning Windows Error Reporting temporary files ... >> "%LOG%"
echo [STEP] Cleaning Windows Error Reporting temporary files ...
if exist "C:\ProgramData\Microsoft\Windows\WER\ReportQueue" (
  del /f /s /q "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" 2>> "%LOG%"
  for /d %%i in ("C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*") do rd /s /q "%%i" 2>> "%LOG%"
)

:: 更深入的清理由 /deep 參數控制，或在互動模式下詢問
if %DEEP%==0 (
  if %QUIET%==1 (
    set "DO_DEEP=0"
  ) else (
    choice /M "Perform deep cleanup? (will remove catroot2, thumbnail/icon cache, wsreset, flushdns, DISM StartComponentCleanup)"
    if errorlevel 2 (
      set "DO_DEEP=0"
    ) else (
      set "DO_DEEP=1"
    )
  )
) else (
  set "DO_DEEP=1"
)

if "%DO_DEEP%"=="0" goto :RESTART_SERVICES

echo [DEEP] Stopping cryptsvc to allow Catroot2 cleanup ... >> "%LOG%"
echo [DEEP] Stopping cryptsvc to allow Catroot2 cleanup ...
net stop cryptsvc >nul 2>&1
if exist "C:\Windows\System32\catroot2" (
  echo   - 刪除 Catroot2 內容 >> "%LOG%"
  del /f /s /q "C:\Windows\System32\catroot2\*" 2>> "%LOG%"
  for /d %%i in ("C:\Windows\System32\catroot2\*") do rd /s /q "%%i" 2>> "%LOG%"
)

echo [DEEP] Clearing thumbnail and icon caches... >> "%LOG%"
echo [DEEP] Clearing thumbnail and icon caches...
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" 2>> "%LOG%"
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\iconcache_*.db" 2>> "%LOG%"
del /f /q "%LocalAppData%\IconCache.db" 2>> "%LOG%"

echo [DEEP] Resetting Microsoft Store cache (wsreset) ... >> "%LOG%"
echo [DEEP] Resetting Microsoft Store cache (wsreset) ...
start /wait wsreset.exe >nul 2>> "%LOG%"

echo [DEEP] Flushing DNS cache ... >> "%LOG%"
echo [DEEP] Flushing DNS cache ...
ipconfig /flushdns >> "%LOG%" 2>&1

:: 建議執行 DISM StartComponentCleanup
if %QUIET%==1 (
  set "DO_DISM=1"
) else (
  choice /M "Run DISM /Online /Cleanup-Image /StartComponentCleanup? (may take several minutes)"
  if errorlevel 2 (
    set "DO_DISM=0"
  ) else (
    set "DO_DISM=1"
  )
)
if "%DO_DISM%"=="1" (
  echo   - 執行 DISM StartComponentCleanup (可能需幾分鐘) >> "%LOG%"
  DISM /Online /Cleanup-Image /StartComponentCleanup >> "%LOG%" 2>&1
) else (
  echo   - 跳過 DISM >> "%LOG%"
)

:: 可選的更破壞性：ResetBase (會讓已安裝更新無法移除)
if %NORESETBASE%==1 (
  echo   - NORESETBASE 參數指定，跳過 ResetBase >> "%LOG%"
) else (
  if %QUIET%==1 (
    set "DO_RESETBASE=0"
  ) else (
    choice /M "Perform DISM /ResetBase? (irreversible: will remove older components to save space)"
    if errorlevel 2 (
      set "DO_RESETBASE=0"
    ) else (
      set "DO_RESETBASE=1"
    )
  )
  if "%DO_RESETBASE%"=="1" (
    echo   - 執行 DISM /ResetBase >> "%LOG%"
    DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase >> "%LOG%" 2>&1
  ) else (
    echo   - 未執行 ResetBase >> "%LOG%"
  )
)

:: 可選：關閉休眠並刪除 hiberfil.sys
if %QUIET%==1 (
  set "DO_HIBER=0"
) else (
  choice /M "Disable hibernation (powercfg -h off) and remove hiberfil.sys? (will lose hibernation capability)"
  if errorlevel 2 (
    set "DO_HIBER=0"
  ) else (
    set "DO_HIBER=1"
  )
)
if "%DO_HIBER%"=="1" (
  echo   - 關閉休眠並移除 hiberfil.sys >> "%LOG%"
  powercfg -h off >> "%LOG%" 2>&1
) else (
  echo   - 未移除休眠檔 >> "%LOG%"
)

:: 可選：清除事件日誌 (危險：會喪失系統日誌)
if %QUIET%==1 (
  set "DO_CLEAR_EVENTS=0"
) else (
  choice /M "Clear all Windows event logs? (WARNING: irreversibly removes logs)"
  if errorlevel 2 (
    set "DO_CLEAR_EVENTS=0"
  ) else (
    set "DO_CLEAR_EVENTS=1"
  )
)
if "%DO_CLEAR_EVENTS%"=="1" (
  echo   - 清除事件日誌 >> "%LOG%"
  for /f "tokens=*" %%l in ('wevtutil el') do wevtutil cl "%%l" 1>> "%LOG%" 2>&1
) else (
  echo   - 未清除事件日誌 >> "%LOG%"
)

:: 自動建立系統還原點（除非指定 /no-restorepoint 或系統不支援）
if %NORESTOREPOINT%==0 (
  echo [STEP] Attempting to create a system restore point... >> "%LOG%"
  powershell -NoProfile -Command "if (Get-ComputerRestorePoint -ErrorAction SilentlyContinue) { Checkpoint-Computer -Description 'PreCleanup' -RestorePointType 'MODIFY_SETTINGS' } else { Write-Output 'Restore points not supported or disabled' }" >> "%LOG%" 2>&1
) else (
  echo [STEP] NORESTOREPOINT 指定，跳過建立系統還原點 >> "%LOG%"
)

:RESTART_SERVICES
echo [STEP] Restarting services that were stopped... >> "%LOG%"
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
net start cryptsvc >nul 2>&1
net start DoSvc >nul 2>&1

:: 紀錄執行後磁碟空間
for /f "tokens=3" %%D in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace ^| findstr /R /V "FreeSpace"') do set "AFTER_FREE=%%D"
echo FreeSpaceAfterBytes=%AFTER_FREE% >> "%LOG%"
set /a FREED_BYTES=%AFTER_FREE% - %BEFORE_FREE% 2>nul || set FREED_BYTES=0
echo FreedBytes=%FREED_BYTES% >> "%LOG%"

echo [DONE] Advanced C: drive cleanup complete. A reboot is recommended. >> "%LOG%"
echo Log file: %LOG%
if %QUIET%==0 pause
