#!/bin/bash

# Step 1. 下載 Flutter SDK
echo "Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable

# Step 2. 設定 Flutter 路徑
export PATH="$PATH:`pwd`/flutter/bin"

# Step 3. 驗證版本
flutter --version

# Step 4. 取得套件
flutter pub get

# Step 5. 建置 Web release 版本
flutter build web --release

echo "✅ Flutter Web build completed!"
