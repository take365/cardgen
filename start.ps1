param(
  [int]$Port = 8080
)

# Keep file ASCII-only; decode Japanese messages from Base64 to avoid mojibake on PS 5.1.
function J([string]$b64, [ConsoleColor]$Color = 'Gray') {
  $s = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64))
  Write-Host $s -ForegroundColor $Color
}
function JP([string]$b64prefix, [string]$suffix, [ConsoleColor]$Color = 'Gray') {
  $p = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64prefix))
  Write-Host ($p + $suffix) -ForegroundColor $Color
}

try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}

$Root = if (Test-Path (Join-Path $PSScriptRoot 'docs')) { Join-Path $PSScriptRoot 'docs' } else { Join-Path $PSScriptRoot 'public' }
try {
  # Generate manifest on start for convenience (docs を優先)
  & "$PSScriptRoot/gen_manifest.ps1" -AssetsRoot (Join-Path $Root 'assets') -OutFile (Join-Path $Root 'assets/manifest.json') | Out-Null
} catch {}
if (-not (Test-Path $Root)) {
  # "[!] public ディレクトリが見つかりません: "
  JP 'WyFdIHB1YmxpYyDjg4fjgqPjg6zjgq/jg4jjg6rjgYzopovjgaTjgYvjgorjgb7jgZvjgpM6IA==' $Root 'Red'
  exit 1
}

# "[+] ローカルサーバ起動: " then URL
JP 'WytdIOODreODvOOCq+ODq+OCteODvOODkOi1t+WLlTog' "http://localhost:$Port" 'Cyan'
# "    ルート: " then path
JP '44Or44O844OIOiA=' " $Root"
# "    優先順: Python > Docker"
J '5YSq5YWI6aCGOiBQeXRob24gPiBEb2NrZXI='

# Open browser first
Start-Process "http://localhost:$Port" | Out-Null

function Have($name) { Get-Command $name -ErrorAction SilentlyContinue | ForEach-Object { $_ } }

# 1) py (Python launcher)
if (Have 'py') {
  # "[i] Python launcher (py) を使用します。"
  J 'W2ldIFB5dGhvbiBsYXVuY2hlciAocHkpIOOCkuS9v+eUqOOBl+OBvuOBmeOAgg=='
  Push-Location $Root
  try {
    & py -3 -m http.server $Port --bind 127.0.0.1
    exit $LASTEXITCODE
  } finally {
    Pop-Location
  }
}

# 2) python
if (Have 'python') {
  # "[i] python を使用します。"
  J 'W2ldIHB5dGhvbiDjgpLkvb/nlKjjgZfjgb7jgZnjgII='
  Push-Location $Root
  try {
    & python -m http.server $Port --bind 127.0.0.1
    exit $LASTEXITCODE
  } finally {
    Pop-Location
  }
}

# 3) Docker
if (Have 'docker') {
  # "[i] Python が見つからないため Docker で起動します。"
  J 'W2ldIFB5dGhvbiDjgYzopovjgaTjgYvjgonjgarjgYTjgZ/jgoEgRG9ja2VyIOOBp+i1t+WLleOBl+OBvuOBmeOAgg=='
  & docker build -t cardgen-mvp $PSScriptRoot
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  & docker run --rm -p $Port`:8080 cardgen-mvp
  exit $LASTEXITCODE
}

# "[!] Python 3 または Docker が必要です。いずれかをインストールして再実行してください。"
J 'WyFdIFB5dGhvbiAzIOOBvuOBn+OBryBEb2NrZXIg44GM5b+F6KaB44Gn44GZ44CC44GE44Ga44KM44GL44KS44Kk44Oz44K544OI44O844Or44GX44Gm5YaN5a6f6KGM44GX44Gm44GP44Gg44GV44GE44CC' 'Yellow'
exit 1
