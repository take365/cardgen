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
done < <(find "$assets_dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print0)
# emit JSON
json='{
  "backgrounds": [
'
for i in "${!backgrounds[@]}"; do
  q=$(printf '%s' "${backgrounds[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')
  sep=",
"
  [ "$i" -eq 0 ] && sep=""
  json+="$sep    \"$q\""

done
json+="
  ],
  \"frames\": [
"
for i in "${!frames[@]}"; do
  q=$(printf '%s' "${frames[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')
  sep=",
"
  [ "$i" -eq 0 ] && sep=""
  json+="$sep    \"$q\""

done
json+="
  ],
  \"icons\": [
"
for i in "${!icons[@]}"; do
  q=$(printf '%s' "${icons[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')
  sep=",
"
  [ "$i" -eq 0 ] && sep=""
  json+="$sep    \"$q\""

done
json+="
  ],
  \"items\": [
"
for i in "${!items[@]}"; do
  q=$(printf '%s' "${items[$i]}" | sed 's/\\/\\\\/g; s/"/\\"/g')
  sep=",
"
  [ "$i" -eq 0 ] && sep=""
  json+="$sep    \"$q\""

done
json+="
  ]
}
"
mkdir -p "$assets_dir"
printf '%s' "$json" > "$out"
echo "Wrote $out"
