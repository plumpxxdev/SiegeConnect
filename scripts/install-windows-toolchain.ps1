param(
  [string]$InstallRoot = ".tools",
  [switch]$InteractiveVisualStudio
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$root = Split-Path -Parent $PSScriptRoot
$tools = Join-Path $root $InstallRoot
$flutterDir = Join-Path $tools "flutter"
$downloads = Join-Path $tools "downloads"

New-Item -ItemType Directory -Force -Path $tools, $downloads | Out-Null

function Install-PortableFlutter {
  if (Test-Path (Join-Path $flutterDir "bin\flutter.bat")) {
    Write-Host "Flutter already installed in $flutterDir" -ForegroundColor Green
    return
  }

  Write-Host "Resolving latest Flutter stable for Windows ..."
  $releases = Invoke-RestMethod -Uri "https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json"
  $stableHash = $releases.current_release.stable
  $release = $releases.releases | Where-Object { $_.hash -eq $stableHash } | Select-Object -First 1
  if (-not $release) {
    throw "Could not resolve Flutter stable release"
  }

  $archiveUrl = "https://storage.googleapis.com/flutter_infra_release/releases/$($release.archive)"
  $archivePath = Join-Path $downloads ([System.IO.Path]::GetFileName($release.archive))

  Write-Host "Downloading Flutter $($release.version) ..."
  Invoke-WebRequest -Uri $archiveUrl -OutFile $archivePath

  Write-Host "Extracting Flutter ..."
  Expand-Archive -LiteralPath $archivePath -DestinationPath $tools -Force
}

function Install-VisualStudioBuildTools {
  $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
  if (Test-Path $vswhere) {
    $installPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($installPath) {
      Write-Host "Visual Studio C++ toolchain already installed: $installPath" -ForegroundColor Green
      return
    }
  }

  $bootstrapper = Join-Path $downloads "vs_BuildTools.exe"
  Write-Host "Downloading Visual Studio Build Tools bootstrapper ..."
  Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_BuildTools.exe" -OutFile $bootstrapper

  Write-Host "Installing Visual Studio Build Tools. This can take a while ..."
  $args = @(
    $(if ($InteractiveVisualStudio) { "--passive" } else { "--quiet" }),
    "--wait",
    "--norestart",
    "--nocache",
    "--add", "Microsoft.VisualStudio.Workload.VCTools",
    "--add", "Microsoft.VisualStudio.Component.VC.CMake.Project",
    "--add", "Microsoft.VisualStudio.Component.Windows11SDK.22621"
  )
  if ($InteractiveVisualStudio) {
    $process = Start-Process -FilePath $bootstrapper -ArgumentList $args -Wait -PassThru -Verb RunAs
  } else {
    $process = Start-Process -FilePath $bootstrapper -ArgumentList $args -Wait -PassThru -WindowStyle Hidden
  }
  if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 3010) {
    throw "Visual Studio Build Tools installer failed with exit code $($process.ExitCode)"
  }
}

Install-PortableFlutter
Install-VisualStudioBuildTools

$flutter = Join-Path $flutterDir "bin\flutter.bat"
$env:GIT_CONFIG_COUNT = "1"
$env:GIT_CONFIG_KEY_0 = "safe.directory"
$env:GIT_CONFIG_VALUE_0 = ($flutterDir -replace "\\", "/")
& $flutter config --enable-windows-desktop
& $flutter doctor -v
