@echo off
:: clean_c_drive.bat - safe-ish cleanup for C:
:: 請用系統管理員身分執行

echo [INFO] 將清理 TEMP / Windows Update 快取 / Prefetch / 回收筒 等暫存檔。
echo [INFO] 若不確定，請按 Ctrl+C 取消。
pause

:: 1) 使用者 TEMP
echo [STEP] 清理使用者 TEMP (%TEMP%) ...
if exist "%TEMP%" (
  del /f /s /q "%TEMP%\*" 2>nul
  for /d %%i in ("%TEMP%\*") do rd /s /q "%%i" 2>nul
)

:: 2) Windows TEMP
echo [STEP] 清理 C:\Windows\Temp ...
if exist "C:\Windows\Temp" (
  del /f /s /q "C:\Windows\Temp\*" 2>nul
  for /d %%i in ("C:\Windows\Temp\*") do rd /s /q "%%i" 2>nul
)

:: 3) Windows Update 快取
echo [STEP] 停止 Windows Update 相關服務...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1

echo [STEP] 清理 C:\Windows\SoftwareDistribution\Download ...
if exist "C:\Windows\SoftwareDistribution\Download" (
  del /f /s /q "C:\Windows\SoftwareDistribution\Download\*" 2>nul
  for /d %%i in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%i" 2>nul
)

echo [STEP] 重新啟動 Windows Update 服務...
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

:: 4) Prefetch
echo [STEP] 清理 C:\Windows\Prefetch ...
if exist "C:\Windows\Prefetch" (
  del /f /s /q "C:\Windows\Prefetch\*" 2>nul
)

:: 5) 回收筒
echo [STEP] 清空所有磁碟的資源回收筒 ...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

:: 6) 錯誤報告暫存
echo [STEP] 清理錯誤回報暫存 ...
if exist "C:\ProgramData\Microsoft\Windows\WER\ReportQueue" (
  del /f /s /q "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" 2>nul
  for /d %%i in ("C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*") do rd /s /q "%%i" 2>nul
)

echo [DONE] C 槽暫存清理完成。建議重新開機一次。
pause
