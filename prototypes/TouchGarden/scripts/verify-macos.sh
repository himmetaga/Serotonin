#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "iOS doğrulaması macOS ve tam Xcode gerektirir." >&2
  exit 1
fi

prototype_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$prototype_dir"

command -v xcodegen >/dev/null || {
  echo "XcodeGen 2.46.0+ gerekli. Kurulum: https://github.com/yonaskolb/XcodeGen" >&2
  exit 1
}
xcodebuild -version
xcodegen --version
xcrun swift test --package-path Core
xcodegen generate --spec project.yml
xcodebuild -project Serotonin.xcodeproj -scheme Serotonin \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build

echo "Swift testleri ve simülatör derlemesi başarılı. Fiziksel iPhone oynanış testi ayrıca gerekli."
