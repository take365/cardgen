param(
  [string]$AssetsRoot = "docs/assets",
  [int]$MaxSize = 256
)

function Have($name) { Get-Command $name -ErrorAction SilentlyContinue | ForEach-Object { $_ } }

$ThumbsRoot = Join-Path $AssetsRoot "_thumbs"
New-Item -Force -ItemType Directory $ThumbsRoot | Out-Null

$magick = Have 'magick'
$convert = if (-not $magick) { Have 'convert' } else { $null }
if (-not $magick -and -not $convert) {
  Write-Host "ImageMagick (magick/convert) が見つかりません。インストールしてください。" -ForegroundColor Yellow
  exit 1
}

Get-ChildItem -Recurse -File $AssetsRoot | Where-Object {
  $_.FullName -notmatch "[/\\]_thumbs[/\\]" -and $_.Extension -match '\.(png|jpg|jpeg|webp)$'
} | ForEach-Object {
  $rel = $_.FullName.Substring((Split-Path -Parent $AssetsRoot).Length + 1) -replace '\\','/'
  $out = Join-Path $ThumbsRoot (([IO.Path]::ChangeExtension($rel.Substring(7), 'webp'))) # drop 'assets/'
  New-Item -Force -ItemType Directory (Split-Path $out) | Out-Null
  if (Test-Path $out -and ((Get-Item $out).LastWriteTimeUtc -ge $_.LastWriteTimeUtc)) { return }
  if ($magick) {
    & magick $_.FullName -resize "${MaxSize}x${MaxSize}>" -quality 80 -define webp:method=6 $out
  } else {
    & convert $_.FullName -resize "${MaxSize}x${MaxSize}>" -quality 80 $out
  }
  Write-Host ("thumb: {0} -> {1}" -f $rel, ($out.Substring((Split-Path -Parent $AssetsRoot).Length + 1) -replace '\\','/'))
}

Write-Host "Done. 次にマニフェスト再生成: ./gen_manifest.ps1 -AssetsRoot $AssetsRoot -OutFile $(Join-Path $AssetsRoot 'manifest.json')" -ForegroundColor Cyan

