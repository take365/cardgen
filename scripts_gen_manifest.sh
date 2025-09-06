set -euo pipefail

# ルート判定: docs があれば優先、なければ public
root_dir="${1:-}"
if [ -z "$root_dir" ]; then
  if [ -d docs ]; then root_dir="docs"; else root_dir="public"; fi
fi

assets_dir="$root_dir/assets"
out="$assets_dir/manifest.json"
backgrounds=()
frames=()
icons=()
items=()
while IFS= read -r -d '' f; do
  p="${f#${root_dir}/}"
  case "$p" in
    assets/*枠*/*) frames+=("$p") ;;
    assets/*剣*/*) icons+=("$p") ;;
    assets/*裏面*/*) backgrounds+=("$p") ;;
    assets/backgrounds/*) backgrounds+=("$p") ;;
    assets/background/*) backgrounds+=("$p") ;;
    assets/frames/*) frames+=("$p") ;;
    assets/frame/*) frames+=("$p") ;;
    assets/icons/*) icons+=("$p") ;;
    assets/icon/*) icons+=("$p") ;;
    assets/items/*) items+=("$p") ;;
  esac
done < <(find "$assets_dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -not -path "*/_thumbs/*" -print0)
# emit JSON
emit_array() {
  local -n arr=$1
  local out=""
  for i in "${!arr[@]}"; do
    local p="${arr[$i]}"
    local thumb=""
    # try to find a thumb under assets/_thumbs/ same relative path; prefer .webp then same ext
    local rel_no_assets="${p#assets/}"
    local base_ext="${p##*.}"
    local thumb_webp="assets/_thumbs/${rel_no_assets%.*}.webp"
    local thumb_same="assets/_thumbs/${rel_no_assets}"
    if [ -f "$root_dir/$thumb_webp" ]; then thumb="$thumb_webp"; elif [ -f "$root_dir/$thumb_same" ]; then thumb="$thumb_same"; fi
    local sep=",
"
    [ "$i" -eq 0 ] && sep=""
    if [ -n "$thumb" ]; then
      local qsrc=$(printf '%s' "$p" | sed 's/\\/\\\\/g; s/"/\\"/g')
      local qth=$(printf '%s' "$thumb" | sed 's/\\/\\\\/g; s/"/\\"/g')
      out+="$sep    { \"src\": \"$qsrc\", \"thumb\": \"$qth\" }"
    else
      local q=$(printf '%s' "$p" | sed 's/\\/\\\\/g; s/"/\\"/g')
      out+="$sep    \"$q\""
    fi
  done
  printf '%s' "$out"
}

json='{
  "backgrounds": [
'
json+="$(emit_array backgrounds)"
json+="
  ],
  \"frames\": [
"
json+="$(emit_array frames)"
json+="
  ],
  \"icons\": [
"
json+="$(emit_array icons)"
json+="
  ],
  \"items\": [
"
json+="$(emit_array items)"
json+="
  ]
}
"
mkdir -p "$assets_dir"
printf '%s' "$json" > "$out"
echo "Wrote $out"
