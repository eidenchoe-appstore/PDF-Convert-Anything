#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICON_PACKAGE="$ROOT_DIR/icon.icon"
ICTOOL="/Applications/Icon Composer.app/Contents/Executables/ictool"
ICONSET_DIR="$ROOT_DIR/build/AppIcon.iconset"
RESOURCES_DIR="$ROOT_DIR/Resources"

rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR" "$RESOURCES_DIR"

if [[ ! -d "$ICON_PACKAGE" ]]; then
  echo "missing icon.icon" >&2
  exit 1
fi

if [[ ! -x "$ICTOOL" ]]; then
  echo "missing Icon Composer ictool: $ICTOOL" >&2
  exit 1
fi

render_icon() {
  local points="$1"
  local scale="$2"
  local output="$3"

  "$ICTOOL" "$ICON_PACKAGE" \
    --export-image \
    --output-file "$output" \
    --platform macOS \
    --rendition Default \
    --width "$points" \
    --height "$points" \
    --scale "$scale" >/dev/null
}

render_icon 16 1 "$ICONSET_DIR/icon_16x16.png"
render_icon 16 2 "$ICONSET_DIR/icon_16x16@2x.png"
render_icon 32 1 "$ICONSET_DIR/icon_32x32.png"
render_icon 32 2 "$ICONSET_DIR/icon_32x32@2x.png"
render_icon 128 1 "$ICONSET_DIR/icon_128x128.png"
render_icon 128 2 "$ICONSET_DIR/icon_128x128@2x.png"
render_icon 256 1 "$ICONSET_DIR/icon_256x256.png"
render_icon 256 2 "$ICONSET_DIR/icon_256x256@2x.png"
render_icon 512 1 "$ICONSET_DIR/icon_512x512.png"
render_icon 512 2 "$ICONSET_DIR/icon_512x512@2x.png"

iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
echo "$RESOURCES_DIR/AppIcon.icns"
