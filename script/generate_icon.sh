#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICON_PACKAGE="$ROOT_DIR/icon.icon"
ICON_JSON="$ICON_PACKAGE/icon.json"
ICONSET_DIR="$ROOT_DIR/build/AppIcon.iconset"
THUMB_DIR="$ROOT_DIR/build/icon-source"
RESOURCES_DIR="$ROOT_DIR/Resources"

rm -rf "$ICONSET_DIR" "$THUMB_DIR"
mkdir -p "$ICONSET_DIR" "$THUMB_DIR" "$RESOURCES_DIR"

if [[ ! -f "$ICON_JSON" ]]; then
  echo "missing icon.icon/icon.json" >&2
  exit 1
fi

IMAGE_NAME="$(plutil -extract groups.0.layers.0.image-name raw -o - "$ICON_JSON")"
SOURCE_IMAGE="$ICON_PACKAGE/Assets/$IMAGE_NAME"
SCALED_PNG="$THUMB_DIR/AppIconScaled.png"
SOURCE_PNG="$THUMB_DIR/AppIconSource.png"

if [[ ! -f "$SOURCE_IMAGE" ]]; then
  echo "missing icon source image: $SOURCE_IMAGE" >&2
  exit 1
fi

sips -s format png -Z 1024 "$SOURCE_IMAGE" --out "$SCALED_PNG" >/dev/null 2>&1
sips -p 1024 1024 --padColor FFFFFF "$SCALED_PNG" --out "$SOURCE_PNG" >/dev/null 2>&1

sips -s format png -z 16 16 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null 2>&1
sips -s format png -z 32 32 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null 2>&1
sips -s format png -z 32 32 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null 2>&1
sips -s format png -z 64 64 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null 2>&1
sips -s format png -z 128 128 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null 2>&1
sips -s format png -z 256 256 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null 2>&1
sips -s format png -z 256 256 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null 2>&1
sips -s format png -z 512 512 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null 2>&1
sips -s format png -z 512 512 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null 2>&1
sips -s format png -z 1024 1024 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null 2>&1

iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
echo "$RESOURCES_DIR/AppIcon.icns"
