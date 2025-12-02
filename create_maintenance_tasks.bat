@echo off
:: create_maintenance_tasks.bat
:: Adjust SCRIPT_PATH and schedule time as needed

set SCRIPT_PATH=%~dp0maintenance.bat

if not exist "%SCRIPT_PATH%" (
  echo [ERROR] maintenance.bat not found: %SCRIPT_PATH%
  echo Please verify the path before running this script.
  goto :EOF
)

echo [INFO] Creating weekly C/D maintenance scheduled task...

:: Default to run with /quiet /deep; modify SCHEDULE_ARGS to change behavior or include /move
set SCHEDULE_ARGS=/quiet /deep
schtasks /Create ^
  /TN "Local_C_D_Maintenance" ^
  /TR "\"%SCRIPT_PATH%\" %SCHEDULE_ARGS%" ^
  /SC WEEKLY ^
  /D SUN ^
  /ST 03:00 ^
  /RL HIGHEST ^
  /F

if errorlevel 1 (
  echo [ERROR] Failed to create scheduled task. Please check Task Scheduler.
) else (
  echo [DONE] Scheduled task Local_C_D_Maintenance created.
  echo        You can adjust the time or disable it in Task Scheduler.
)

pause
