#!/bin/bash
set -e

echo "🚀 Start Flutter build for Web"

# 1️⃣ 安裝 flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# 2️⃣ 檢查 flutter 版本
flutter --version

# 3️⃣ 取得依賴
flutter pub get

# 4️⃣ 建置 Web 版本
flutter build web --release

echo "✅ Flutter Web build completed!"
