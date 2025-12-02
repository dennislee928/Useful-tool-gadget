@echo off
:: compress_heavy_dirs.bat
:: 對 DevData 底下幾個重資料夾啟用 NTFS 壓縮

set BASE_DST=D:\DevData

set DIRS=%BASE_DST%\containers %BASE_DST%\.espressif %BASE_DST%\go %BASE_DST%\.cursor %BASE_DST%\esp

echo [INFO] 將對下列資料夾啟用 NTFS 壓縮 (compact /c /s)：
for %%D in (%DIRS%) do (
  echo   %%D
)

echo.
echo 這會稍微增加 CPU 使用量、略微降低 I/O，但可以省空間。
echo 不確定請按 Ctrl+C 取消；確定請按任意鍵繼續...
pause >nul

for %%D in (%DIRS%) do (
  if exist "%%D" (
    echo.
    echo [STEP] 壓縮 "%%D" ...
    compact /c /s:"%%D" /i
  ) else (
    echo.
    echo [SKIP] "%%D" 不存在，略過。
  )
)

echo.
echo [DONE] 壓縮流程完成。
pause
