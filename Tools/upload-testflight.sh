#!/bin/bash
# Archive + upload Helix TV to App Store Connect (TestFlight) from the Mac mini.
#   tools/upload-testflight.sh tvos|ios
# Needs Xcode signed in to the Market Mavens LLC team. Runs with the SYSTEM PATH ONLY: Xcode's packaging step
# shells out to rsync, and Homebrew's rsync 3.x on PATH breaks it ("exportArchive Copy failed").
set -eu
P="${1:?tvos|ios}"
case "$P" in
  tvos) SCHEME="Swiftfin tvOS"; DEST="generic/platform=tvOS" ;;
  ios)  SCHEME="Swiftfin";      DEST="generic/platform=iOS" ;;
  *) echo "tvos|ios"; exit 1 ;;
esac
HERE="$(cd "$(dirname "$0")/.." && pwd)"
DAY="$(date +%F)"; ARCH="$HOME/Library/Developer/Xcode/Archives/$DAY/HelixTV-$P-$(date +%H%M).xcarchive"
OPTS="$HOME/.helixtv/export/ExportOptions.plist"   # method app-store-connect, destination upload, team GYWYUZLMZN
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
xcodebuild -project "$HERE/Swiftfin.xcodeproj" -scheme "$SCHEME" -destination "$DEST" -archivePath "$ARCH" \
  -skipPackageUpdates -skipMacroValidation -allowProvisioningUpdates archive | grep -E "error:|ARCHIVE (SUCCEEDED|FAILED)"
xcodebuild -exportArchive -archivePath "$ARCH" -exportOptionsPlist "$OPTS" -exportPath "$HOME/.helixtv/export/$P-$DAY" \
  -allowProvisioningUpdates | grep -E "error:|Upload succeeded|EXPORT (SUCCEEDED|FAILED)"
