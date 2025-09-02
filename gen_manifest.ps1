param(
  [string]$AssetsRoot = "public/assets",
  [string]$OutFile = "public/assets/manifest.json"
)

function Collect($predicate) {
  Get-ChildItem -Recurse -File $AssetsRoot | Where-Object {
    $_.Extension -match '\.(png|jpg|jpeg|webp)$' -and (& $predicate $_)
  } | ForEach-Object {
    $p = $_.FullName.Replace((Resolve-Path 'public').Path + [IO.Path]::DirectorySeparatorChar, '')
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

$obj = [ordered]@{
  backgrounds = $backgrounds
  frames = $frames
  icons = $icons
  items = $items
}

$json = $obj | ConvertTo-Json -Depth 3
New-Item -Force -ItemType Directory (Split-Path $OutFile) | Out-Null
Set-Content -LiteralPath $OutFile -Value $json -Encoding UTF8
Write-Host "Wrote $OutFile"
