# 0. 前往下載點並下載Gemini.dmg
https://gemini.google/mac/
# 1. 掛載磁碟映像檔
hdiutil attach ~/Downloads/Gemini.dmg

# 2. 將 App 複製到應用程式資料夾 (這一步會正式安裝)
sudo cp -R /Volumes/Gemini/Gemini.app /Applications/

# 3. 卸載虛擬磁碟
hdiutil detach /Volumes/Gemini
