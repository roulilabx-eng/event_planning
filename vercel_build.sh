#!/bin/bash
set -e
echo "🚀 Start Flutter build for Web"

git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

flutter --version
flutter pub get
flutter build web --release --base-href "/"

echo "✅ Flutter Web build completed!"
