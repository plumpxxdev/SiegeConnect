param(
  [string]$Architecture = "amd64"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$root = Split-Path -Parent $PSScriptRoot
$bin = Join-Path $root "bin"
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("siegeconnect-mihomo-" + [System.Guid]::NewGuid().ToString("N"))

New-Item -ItemType Directory -Force -Path $bin | Out-Null
New-Item -ItemType Directory -Force -Path $temp | Out-Null

try {
  Write-Host "Resolving MetaCubeX/mihomo ..."
  $release = Invoke-RestMethod -Uri "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" -Headers @{
    "User-Agent" = "SiegeConnect installer"
    "Accept" = "application/vnd.github+json"
  }

  $pattern = "mihomo-windows-$Architecture.*\.zip$"
  $asset = $release.assets | Where-Object { $_.name -match $pattern } | Select-Object -First 1
  if (-not $asset) {
    throw "No matching Mihomo asset ($pattern)"
  }

  $archive = Join-Path $temp $asset.name
  $extract = Join-Path $temp "extract"

  Write-Host "Downloading $($asset.name) ..."
  Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $archive -Headers @{
    "User-Agent" = "SiegeConnect installer"
  }

  New-Item -ItemType Directory -Force -Path $extract | Out-Null
  Expand-Archive -LiteralPath $archive -DestinationPath $extract -Force

  $exe = Get-ChildItem -LiteralPath $extract -Recurse -File -Filter "*.exe" | Select-Object -First 1
  if (-not $exe) {
    throw "Mihomo executable was not found in archive"
  }

  Copy-Item -LiteralPath $exe.FullName -Destination (Join-Path $bin "mihomo.exe") -Force
  Write-Host "Mihomo installed: $(Join-Path $bin "mihomo.exe")" -ForegroundColor Green
} finally {
  if (Test-Path $temp) {
    Remove-Item -LiteralPath $temp -Recurse -Force
  }
}
