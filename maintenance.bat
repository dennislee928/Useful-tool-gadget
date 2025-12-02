@echo off
:: maintenance.bat
:: 同一個資料夾內應有:
::   clean_c_drive.bat
::   move_downloads_to_D.bat

set SCRIPT_DIR=%~dp0

echo [INFO] 執行 C 槽清理...
call "%SCRIPT_DIR%clean_c_drive.bat"

echo [INFO] 檢查並處理 Downloads -> D 槽的搬移...
call "%SCRIPT_DIR%move_downloads_to_D.bat"

echo [DONE] 本次維護完成。
pause
