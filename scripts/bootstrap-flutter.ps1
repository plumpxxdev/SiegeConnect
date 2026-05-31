$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$scaffold = Join-Path $root ".flutter_scaffold"
$localFlutter = Join-Path $root ".tools\flutter\bin\flutter.bat"
$localDart = Join-Path $root ".tools\flutter\bin\dart.bat"
Set-Location $root
$env:GIT_CONFIG_COUNT = "1"
$env:GIT_CONFIG_KEY_0 = "safe.directory"
$env:GIT_CONFIG_VALUE_0 = ((Join-Path $root ".tools\flutter") -replace "\\", "/")

if (Test-Path $localFlutter) {
  $flutter = $localFlutter
} elseif (Get-Command flutter -ErrorAction SilentlyContinue) {
  $flutter = "flutter"
} else {
  Write-Host "Flutter SDK is not installed or not in PATH." -ForegroundColor Yellow
  Write-Host "Run scripts/install-windows-toolchain.ps1 first."
  exit 1
}

if (Test-Path $localDart) {
  $dart = $localDart
} elseif (Get-Command dart -ErrorAction SilentlyContinue) {
  $dart = "dart"
} else {
  $dart = Join-Path (Split-Path (Split-Path $flutter -Parent) -Parent) "bin\dart.bat"
}

if (Test-Path $scaffold) {
  Remove-Item -LiteralPath $scaffold -Recurse -Force
}

& $flutter create --project-name siegeconnect --org app.siegeconnect --platforms windows,android,ios --no-pub $scaffold
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

foreach ($dir in @("android", "ios", "windows")) {
  $target = Join-Path $root $dir
  if (-not (Test-Path $target)) {
    Copy-Item -LiteralPath (Join-Path $scaffold $dir) -Destination $target -Recurse
  }
}

$androidTarget = Join-Path $root "android\app\src\main\kotlin\app\pxxconnect\client"
New-Item -ItemType Directory -Force -Path $androidTarget | Out-Null
Copy-Item -LiteralPath (Join-Path $root "native\android\kotlin\app\pxxconnect\client\MainActivity.kt") -Destination $androidTarget -Force
Copy-Item -LiteralPath (Join-Path $root "native\android\kotlin\app\pxxconnect\client\PxxVpnService.kt") -Destination $androidTarget -Force

$iosTarget = Join-Path $root "ios\Runner\VpnBridge.swift"
if (Test-Path (Split-Path $iosTarget -Parent)) {
  Copy-Item -LiteralPath (Join-Path $root "native\ios\VpnBridge.swift") -Destination $iosTarget -Force
}

Remove-Item -LiteralPath $scaffold -Recurse -Force

& $flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $flutter pub run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "SiegeConnect Flutter project is ready." -ForegroundColor Green
