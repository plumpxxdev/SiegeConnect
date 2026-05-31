$ErrorActionPreference = "Stop"

$originalRoot = Split-Path -Parent $PSScriptRoot
$originalParent = Split-Path -Parent $originalRoot
$projectLeaf = Split-Path -Leaf $originalRoot
$substDrive = "P:"
$usingSubst = $false

if ($originalRoot -match '[^\x00-\x7F]') {
  if (Test-Path "$substDrive\") {
    subst $substDrive /D | Out-Null
  }
  subst $substDrive $originalParent | Out-Null
  $usingSubst = $true
  Set-Location "$substDrive\$projectLeaf"
} else {
  Set-Location $originalRoot
}

try {
  $env:GIT_CONFIG_COUNT = "1"
  $env:GIT_CONFIG_KEY_0 = "safe.directory"
  $env:GIT_CONFIG_VALUE_0 = ((Join-Path (Get-Location) ".tools\flutter") -replace "\\", "/")
  $env:FLUTTER_SUPPRESS_ANALYTICS = "true"
  $env:DART_TELEMETRY_DISABLED = "true"

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
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  }

  & $flutter pub get
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

  & $flutter pub run build_runner build --delete-conflicting-outputs
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

  if (Test-Path ".\build\windows") {
    Remove-Item -LiteralPath ".\build\windows" -Recurse -Force
  }

  $wrapperSource = Join-Path (Get-Location) ".tools\flutter\bin\cache\artifacts\engine\windows-x64\cpp_client_wrapper"
  $wrapperDestination = Join-Path (Get-Location) "windows\flutter\ephemeral\cpp_client_wrapper"
  if (Test-Path $wrapperSource) {
    New-Item -ItemType Directory -Force -Path $wrapperDestination | Out-Null
    Copy-Item -LiteralPath (Join-Path $wrapperSource "*") -Destination $wrapperDestination -Recurse -Force
  }

  & $flutter build windows --release
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

  $releaseDir = Join-Path (Get-Location) "build\windows\x64\runner\Release"
  $binDir = Join-Path (Get-Location) "bin"
  if (Test-Path (Join-Path $binDir "mihomo.exe")) {
    Copy-Item -LiteralPath (Join-Path $binDir "mihomo.exe") -Destination $releaseDir -Force
  }

  Write-Host "Release EXE:" -ForegroundColor Green
  Write-Host (Join-Path $originalRoot "build\windows\x64\runner\Release\siegeconnect.exe")
} finally {
  if ($usingSubst) {
    Set-Location $originalRoot
    subst $substDrive /D | Out-Null
  }
}
