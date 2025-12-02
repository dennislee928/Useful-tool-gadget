@echo off
setlocal

:: move_downloads_to_D.bat
:: 將 C:\Users\%USERNAME%\Downloads -> D:\UserData\%USERNAME%\Downloads
:: 並在原位置建立 junction，之後路徑不變但實體在 D 槽

if not exist "D:\" (
  echo [ERROR] 找不到 D: 槽，請確認後再執行。
  goto :EOF
)

set USERDIR=%USERPROFILE%
set SRC=%USERDIR%\Downloads
set DST=D:\UserData\%USERNAME%\Downloads

echo [INFO] 本腳本將「搬移」你的 Downloads 目錄：
echo   來源: %SRC%
echo   目的: %DST%
echo   並在原位置建立 junction。
echo.
echo 請確認目前沒有正在下載的檔案、也沒有打開 Downloads 裡面的檔案。
echo 若不確定，請按 Ctrl+C 取消，否則按任意鍵繼續...
pause >nul

if not exist "%SRC%" (
  echo [ERROR] 找不到來源資料夾: %SRC%
  goto :EOF
)

:: 若已經是 reparse point / junction，就不再處理
fsutil reparsepoint query "%SRC%" >nul 2>&1
if %errorlevel%==0 (
  echo [INFO] Downloads 已經是 junction / reparse point，無需再處理。
  goto :EOF
)

:: 建立目的端目錄
if not exist "D:\UserData" mkdir "D:\UserData"
if not exist "D:\UserData\%USERNAME%" mkdir "D:\UserData\%USERNAME%"
if not exist "%DST%" mkdir "%DST%"

echo [STEP] 使用 ROBOCOPY 搬移檔案到 D 槽 ...
robocopy "%SRC%" "%DST%" /MOVE /E /COPYALL
if errorlevel 8 (
  echo [ERROR] ROBOCOPY 發生錯誤 (errorlevel >= 8)，請檢查上方輸出。
  goto :EOF
)

echo [STEP] 移除原始 Downloads 資料夾...
rd "%SRC%" 2>nul

echo [STEP] 建立 junction...
mklink /J "%SRC%" "%DST%"
if errorlevel 1 (
  echo [WARN] 建立 junction 失敗，但檔案已在: %DST%
  echo        你可以手動在檔案總管改「Downloads」位置或重新建立連結。
  goto :EOF
)

echo [DONE] 已將 Downloads 移到 D 槽並建立 junction。
echo       之後存到 Downloads，實際會落在 %DST% 。
pause
