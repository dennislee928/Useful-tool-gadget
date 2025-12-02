@echo off
:: compress_heavy_dirs.bat
:: Enable NTFS compression on several heavy folders under DevData

set BASE_DST=D:\DevData

set DIRS=%BASE_DST%\containers %BASE_DST%\.espressif %BASE_DST%\go %BASE_DST%\.cursor %BASE_DST%\esp

echo [INFO] The following folders will have NTFS compression enabled (compact /c /s):
for %%D in (%DIRS%) do (
  echo   %%D
)

echo.
echo This may slightly increase CPU usage and mildly impact I/O, but can save disk space.
echo If unsure, press Ctrl+C to cancel; otherwise press any key to continue...
pause >nul

for %%D in (%DIRS%) do (
  if exist "%%D" (
    echo.
    echo [STEP] Compressing "%%D" ...
    compact /c /s:"%%D" /i
  ) else (
    echo.
    echo [SKIP] "%%D" does not exist, skipping.
  )
)

echo.
echo [DONE] Compression completed.
pause
