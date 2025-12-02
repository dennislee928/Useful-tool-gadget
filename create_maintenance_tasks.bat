@echo off
:: create_maintenance_tasks.bat
:: 依需求修改 SCRIPT_PATH 與排程時間

set SCRIPT_PATH=D:\scripts\maintenance.bat

if not exist "%SCRIPT_PATH%" (
  echo [ERROR] 找不到 maintenance.bat: %SCRIPT_PATH%
  echo 請先確認路徑再執行本腳本。
  goto :EOF
)

echo [INFO] 建立「每週 C/D 維護」排程工作...

schtasks /Create ^
  /TN "Local_C_D_Maintenance" ^
  /TR "\"%SCRIPT_PATH%\"" ^
  /SC WEEKLY ^
  /D SUN ^
  /ST 03:00 ^
  /RL HIGHEST ^
  /F

if errorlevel 1 (
  echo [ERROR] 建立排程失敗，請到 工作排程程式(Task Scheduler) 檢查。
) else (
  echo [DONE] 已建立排程工作 Local_C_D_Maintenance 。
  echo        可以在「工作排程程式」裡修改時間或停用。
)

pause
