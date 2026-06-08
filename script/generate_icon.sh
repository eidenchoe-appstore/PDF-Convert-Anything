#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SVG_PATH="$ROOT_DIR/icon.svg"
ICONSET_DIR="$ROOT_DIR/build/AppIcon.iconset"
THUMB_DIR="$ROOT_DIR/build/icon-source"
RESOURCES_DIR="$ROOT_DIR/Resources"

rm -rf "$ICONSET_DIR" "$THUMB_DIR"
mkdir -p "$ICONSET_DIR" "$THUMB_DIR" "$RESOURCES_DIR"

qlmanage -t -s 1024 -o "$THUMB_DIR" "$SVG_PATH" >/dev/null 2>&1
SOURCE_PNG="$THUMB_DIR/$(basename "$SVG_PATH").png"

if [[ ! -f "$SOURCE_PNG" ]]; then
  echo "failed to render icon.svg" >&2
  exit 1
fi

sips -s format png -z 16 16 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
sips -s format png -z 32 32 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
sips -s format png -z 32 32 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips -s format png -z 64 64 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips -s format png -z 128 128 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips -s format png -z 256 256 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips -s format png -z 256 256 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
sips -s format png -z 512 512 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
sips -s format png -z 512 512 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
sips -s format png -z 1024 1024 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null

iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
echo "$RESOURCES_DIR/AppIcon.icns"
