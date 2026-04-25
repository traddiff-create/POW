#!/bin/bash
# Check iOS/Android parity — scans for model names in KMP commonMain
# and verifies matching usage in iOS Features/ and Android ui/
# Usage: ./scripts/check-parity.sh

set -e

COMMON="shared/src/commonMain/kotlin/com/hackathon/models"
IOS="ios/Hackathon/Features"
ANDROID="android/src/main/kotlin/com/hackathon/ui"

echo "=== KMP Models ==="
find "$COMMON" -name "*.kt" -not -name ".gitkeep" | while read f; do
    model=$(basename "$f" .kt)
    echo -n "  $model — iOS: "
    grep -rl "$model" "$IOS" 2>/dev/null | wc -l | tr -d ' '
    echo -n " refs | Android: "
    grep -rl "$model" "$ANDROID" 2>/dev/null | wc -l | tr -d ' '
    echo " refs"
done

echo ""
echo "=== Parity Checklist ==="
echo "Review docs/parity-checklist.md for manual feature tracking"
