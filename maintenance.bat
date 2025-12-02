@echo off
:: maintenance.bat
:: Expected to be located in the same folder as:
::   clean_c_drive.bat
::   move_downloads_to_D.bat

set SCRIPT_DIR=%~dp0
set "ARGS=%*"

echo [INFO] Running C: drive cleanup (forwarding args: %ARGS%) ...
call "%SCRIPT_DIR%clean_c_drive.bat" %ARGS%

echo [INFO] Checking and handling Downloads -> D: move (use /move to enable)...
for %%A in (%ARGS%) do (
	if /I "%%~A"=="/move" (
		call "%SCRIPT_DIR%move_downloads_to_D.bat"
	)
)

echo [DONE] Maintenance completed.
pause
