#!/bin/bash

# =================================================================
# 腳本名稱: install_gemini.sh
# 功能: 自動掛載 DMG 並將 App 安裝至應用程式資料夾
# =================================================================

# 1. 設定變數
DMG_PATH="$HOME/Downloads/Gemini.dmg"
APP_NAME="Gemini.app"
TARGET_DIR="/Applications"

# 檢查檔案是否存在
if [[ ! -f "$DMG_PATH" ]]; then
    echo "[-] 錯誤: 在 $DMG_PATH 找不到映像檔。"
    exit 1
fi

echo "[+] 準備安裝 $APP_NAME..."

# 2. 掛載磁碟映像檔
# -noverify: 跳過校驗以防止 Operation timed out
# -nobrowse: 不在 Finder 中顯示，保持桌面乾淨
echo "[+] 正在掛載映像檔 (跳過校驗)..."
MOUNT_INFO=$(hdiutil attach -noverify -nobrowse "$DMG_PATH" | tail -n 1)

# 使用 awk 提取最後一欄的掛載路徑
MOUNT_DIR=$(echo "$MOUNT_INFO" | awk -F'\t' '{print $NF}' | xargs)

if [[ -z "$MOUNT_DIR" || ! -d "$MOUNT_DIR" ]]; then
    echo "[-] 錯誤: 掛載失敗或無法取得掛載路徑。"
    exit 1
fi

echo "[+] 成功掛載至: $MOUNT_DIR"

# 3. 複製 App 至 /Applications
echo "[+] 正在複製 $APP_NAME 到 $TARGET_DIR..."
if [[ -d "$MOUNT_DIR/$APP_NAME" ]]; then
    sudo cp -R "$MOUNT_DIR/$APP_NAME" "$TARGET_DIR/"
    
    # 修正權限（可選，確保所有使用者皆可執行）
    sudo chown -R root:wheel "$TARGET_DIR/$APP_NAME"
    echo "[+] 安裝完成！"
else
    echo "[-] 錯誤: 在掛載點中找不到 $APP_NAME。"
fi

# 4. 卸載虛擬磁碟
echo "[+] 正在卸載 $MOUNT_DIR..."
hdiutil detach "$MOUNT_DIR" -force

echo "[*] 程序結束。"
