#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-1.0.0}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DISPLAY_NAME="PDF Convert Anything"
DMG_NAME="PDF-Convert-Anything-v$VERSION.dmg"
DMG_ROOT="$ROOT_DIR/dist/dmgroot"
DMG_PATH="$ROOT_DIR/dist/$DMG_NAME"

"$ROOT_DIR/script/generate_icon.sh" >/dev/null
APP_BUNDLE="$("$ROOT_DIR/script/stage_app.sh" release)"

rm -rf "$DMG_ROOT" "$DMG_PATH"
mkdir -p "$DMG_ROOT"
cp -R "$APP_BUNDLE" "$DMG_ROOT/$APP_DISPLAY_NAME.app"
ln -s /Applications "$DMG_ROOT/Applications"

hdiutil create \
  -volname "$APP_DISPLAY_NAME" \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

codesign -dv "$APP_BUNDLE" >/dev/null 2>&1 || true
spctl -a -vv "$APP_BUNDLE" >/dev/null 2>&1 || true

echo "$DMG_PATH"
