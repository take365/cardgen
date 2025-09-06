#!/usr/bin/env bash
set -euo pipefail

# Generate lightweight thumbnails under docs/assets/_thumbs mirroring docs/assets
# Requirements: ImageMagick `magick` or `convert`

root_dir="${1:-docs}"
assets_dir="$root_dir/assets"
thumbs_root="$assets_dir/_thumbs"
size="256" # longest side

if command -v magick >/dev/null 2>&1; then
  IM_CMD=(magick)
elif command -v convert >/dev/null 2>&1; then
  IM_CMD=(convert)
else
  echo "ImageMagick not found. Please install 'magick' or 'convert'." >&2
  exit 1
fi

echo "Generating thumbnails into: $thumbs_root (max ${size}px)"
while IFS= read -r -d '' f; do
  rel="${f#${assets_dir}/}"
  case "$rel" in
    _thumbs/*) continue;;
  esac
  out="$thumbs_root/${rel%.*}.webp"
  mkdir -p "$(dirname "$out")"
  # Skip if newer exists
  if [ -f "$out" ] && [ "$out" -nt "$f" ]; then
    continue
  fi
  # Resize keeping aspect, set webp quality
  "${IM_CMD[@]}" "$f" -resize "${size}x${size}>" -quality 80 -define webp:method=6 "$out"
  echo "thumb: $rel -> ${out#$assets_dir/}"
done < <(find "$assets_dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print0)

echo "Done. Now re-run: bash scripts_gen_manifest.sh $root_dir"

