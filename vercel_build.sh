#!/bin/bash
set -e

echo "🚀 Start Flutter web build on Vercel..."

# Step 1. 下載 Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Step 2. 顯示版本
flutter --version

# Step 3. 安裝依賴
echo "📦 Running flutter pub get..."
flutter pub get

# Step 4. 建置 Web 版本
echo "🏗️ Building Flutter web release..."
flutter build web --release

# Step 5. 顯示目錄內容（方便你在 Vercel log 驗證）
echo "📂 Build output files:"
ls -al build/web

echo "✅ Flutter Web build completed!"