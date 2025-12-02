@echo off
setlocal ENABLEDELAYEDEXPANSION

:: move_libraries_to_D.bat
:: 將使用者常用資料夾移到 D:\UserData\%USERNAME% 並建立 junction

if not exist "D:\" (
  echo [ERROR] 找不到 D: 槽，請確認後再執行。
  goto :EOF
)

set USERDIR=%USERPROFILE%
set BASE_DST=D:\UserData\%USERNAME%

echo [INFO] 本腳本會搬移下列資料夾到 D 槽並建立 junction：
echo   Desktop, Documents, Downloads, Pictures, Music, Videos
echo.
echo 來源根目錄: %USERDIR%
echo 目的根目錄: %BASE_DST%
echo.
echo 請確認：
echo   1. 這些資料夾內沒有正在使用中的檔案（播放、下載、編輯）。
echo   2. 你已備份重要資料（以防萬一）。
echo.
echo 若不確定，請按 Ctrl+C 取消；按任意鍵繼續...
pause >nul

if not exist "%BASE_DST%" (
  mkdir "%BASE_DST%"
)

:: 需要處理的資料夾列表
set FOLDERS=Desktop Documents Downloads Pictures Music Videos

for %%F in (%FOLDERS%) do (
  call :ProcessFolder "%%F"
)

echo.
echo [DONE] 所有目標資料夾處理完成。
echo 建議重新登入或重開機一次，讓系統完全套用新位置。
pause
goto :EOF


:ProcessFolder
set FNAME=%~1
set FNAME=%FNAME:"=%

set SRC=%USERDIR%\%FNAME%
set DST=%BASE_DST%\%FNAME%

echo.
echo ================================
echo [FOLDER] %FNAME%
echo   SRC: %SRC%
echo   DST: %DST%
echo ================================

:: 如果來源不存在就略過
if not exist "%SRC%" (
  echo [SKIP] 來源不存在，略過。
  goto :EOF
)

:: 如果已經是 junction / reparse point，就略過
fsutil reparsepoint query "%SRC%" >nul 2>&1
if %errorlevel%==0 (
  echo [SKIP] 已是 junction / reparse point，略過。
  goto :EOF
)

:: 建立目的端資料夾
if not exist "%DST%" (
  echo [STEP] 建立目的端資料夾 %DST% ...
  mkdir "%DST%"
)

echo [STEP] 使用 ROBOCOPY 搬移檔案到 D 槽 ...
robocopy "%SRC%" "%DST%" /MOVE /E /COPYALL
if errorlevel 8 (
  echo [ERROR] ROBOCOPY 發生錯誤 (errorlevel >= 8)，請檢查上方輸出。
  echo         本資料夾請先手動確認後再執行。
  goto :EOF
)

echo [STEP] 移除原始資料夾 (如果還存在)...
rd "%SRC%" 2>nul

echo [STEP] 建立 junction...
mklink /J "%SRC%" "%DST%"
if errorlevel 1 (
  echo [WARN] 建立 junction 失敗，但檔案已在: %DST%
  echo        你可以稍後手動建立連結：
  echo        mklink /J "%SRC%" "%DST%"
) else (
  echo [OK] %FNAME% 已移到 D 槽並建立 junction。
)

goto :EOF
