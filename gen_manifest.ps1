param(
  [string]$AssetsRoot = "public/assets",
  [string]$OutFile = "public/assets/manifest.json"
)

function Collect($predicate) {
  $rootPath = (Resolve-Path (Split-Path -Path $AssetsRoot -Parent)).Path + [IO.Path]::DirectorySeparatorChar
  Get-ChildItem -Recurse -File $AssetsRoot | Where-Object {
    $_.Extension -match '\.(png|jpg|jpeg|webp)$' -and (& $predicate $_)
  } | ForEach-Object {
    $p = $_.FullName.Replace($rootPath, '')
    $p -replace '\\','/'
  }
}

$backgrounds = @()
$backgrounds += Collect({ param($f) $f.FullName -match '[/\\]裏面[/\\]' })
$backgrounds += Collect({ param($f) $f.FullName -match '[/\\]backgrounds?[/\\]' })

$frames = @()
$frames += Collect({ param($f) $f.FullName -match '[/\\]枠[/\\]' })
$frames += Collect({ param($f) $f.FullName -match '[/\\]frames?[/\\]' })

$icons = @()
$icons += Collect({ param($f) $f.FullName -match '[/\\]剣[/\\]' })
$icons += Collect({ param($f) $f.FullName -match '[/\\]icons[/\\]' })
$icons += Collect({ param($f) $f.FullName -match '[/\\]icon[/\\]' })

$items = @()
$items += Collect({ param($f) $f.FullName -match '[/\\]items[/\\]' })

function WithThumb($relPath) {
  # Try assets/_thumbs/<relPath> (prefer .webp), else return the string
  $p = $relPath
  $thumbWebp = ($p -replace '^assets/', 'assets/_thumbs/') -replace '\.(png|jpg|jpeg|webp)$', '.webp'
  $thumbSame = ($p -replace '^assets/', 'assets/_thumbs/')
  $dir = Split-Path -Parent $AssetsRoot
  $thumbWebpFs = Join-Path $dir $thumbWebp
  $thumbSameFs = Join-Path $dir $thumbSame
  if (Test-Path $thumbWebpFs) { return @{ src = $p; thumb = $thumbWebp } }
  elseif (Test-Path $thumbSameFs) { return @{ src = $p; thumb = $thumbSame } }
  else { return $p }
}

$obj = [ordered]@{
  backgrounds = @($backgrounds | ForEach-Object { WithThumb $_ })
  frames      = @($frames      | ForEach-Object { WithThumb $_ })
  icons       = @($icons       | ForEach-Object { WithThumb $_ })
  items       = @($items       | ForEach-Object { WithThumb $_ })
}

$json = $obj | ConvertTo-Json -Depth 3
New-Item -Force -ItemType Directory (Split-Path $OutFile) | Out-Null
Set-Content -LiteralPath $OutFile -Value $json -Encoding UTF8
Write-Host "Wrote $OutFile"
