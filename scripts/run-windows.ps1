$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
$env:GIT_CONFIG_COUNT = "1"
$env:GIT_CONFIG_KEY_0 = "safe.directory"
$env:GIT_CONFIG_VALUE_0 = ((Join-Path (Get-Location) ".tools\flutter") -replace "\\", "/")

$localFlutter = Join-Path (Get-Location) ".tools\flutter\bin\flutter.bat"
if (Test-Path $localFlutter) {
  $flutter = $localFlutter
} elseif (Get-Command flutter -ErrorAction SilentlyContinue) {
  $flutter = "flutter"
} else {
  throw "Flutter SDK is not installed. Run scripts/install-windows-toolchain.ps1 first."
}

if (-not (Test-Path ".\windows")) {
  powershell.exe -ExecutionPolicy Bypass -File .\scripts\bootstrap-flutter.ps1
}

& $flutter run -d windows
