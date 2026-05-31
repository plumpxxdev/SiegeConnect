$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root "dist"
$releaseDir = Join-Path $root "build\windows\x64\runner\Release"
$payload = Join-Path $dist "SiegeConnect-App.zip"
$setupSource = Join-Path $dist "SiegeConnectSetup.cs"
$manifest = Join-Path $dist "SiegeConnectSetup.manifest"
$setupExe = Join-Path $dist "SiegeConnect-Setup.exe"

New-Item -ItemType Directory -Force -Path $dist | Out-Null

& (Join-Path $PSScriptRoot "build-windows-release.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (-not (Test-Path $releaseDir)) {
  throw "Release directory not found: $releaseDir"
}

if (Test-Path $payload) {
  Remove-Item -LiteralPath $payload -Force
}
Compress-Archive -Path (Join-Path $releaseDir "*") -DestinationPath $payload -Force

@'
using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;

internal static class Program
{
    private const string TaskName = "SiegeConnectMihomo";

    [STAThread]
    private static int Main()
    {
        try
        {
            Install();
            return 0;
        }
        catch (Exception error)
        {
            MessageBox.Show(
                error.ToString(),
                "SiegeConnect Setup",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
            return 1;
        }
    }

    private static void Install()
    {
        string root = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "SiegeConnect");
        string installDir = Path.Combine(root, "app");
        string runtimeDir = Path.Combine(root, "runtime");

        Directory.CreateDirectory(root);
        Directory.CreateDirectory(runtimeDir);
        if (Directory.Exists(installDir))
        {
            Directory.Delete(installDir, true);
        }
        Directory.CreateDirectory(installDir);

        ExtractPayload(installDir);
        RegisterTunTask(installDir, runtimeDir);
        CreateShortcut(installDir);

        string appExe = Path.Combine(installDir, "siegeconnect.exe");
        if (File.Exists(appExe))
        {
            Process.Start(new ProcessStartInfo(appExe)
            {
                WorkingDirectory = installDir,
                UseShellExecute = true
            });
        }
    }

    private static void ExtractPayload(string installDir)
    {
        Stream payload = Assembly.GetExecutingAssembly()
            .GetManifestResourceStream("payload.zip");
        if (payload == null)
        {
            throw new InvalidOperationException("Embedded payload.zip not found.");
        }

        string tempZip = Path.Combine(Path.GetTempPath(), "SiegeConnect-App.zip");
        using (payload)
        using (FileStream output = File.Create(tempZip))
        {
            payload.CopyTo(output);
        }

        ZipFile.ExtractToDirectory(tempZip, installDir);
        File.Delete(tempZip);
    }

    private static void RegisterTunTask(string installDir, string runtimeDir)
    {
        string mihomo = Path.Combine(installDir, "mihomo.exe");
        string config = Path.Combine(runtimeDir, "current.yaml");
        if (!File.Exists(config))
        {
            File.WriteAllText(
                config,
                "mixed-port: 7890\nproxies: []\nproxy-groups: []\nrules:\n  - MATCH,DIRECT\n",
                Encoding.UTF8);
        }

        string launchScript = "& " + PsQuote(mihomo) + " -f " + PsQuote(config);
        string launchEncoded = Convert.ToBase64String(Encoding.Unicode.GetBytes(launchScript));
        string launchArguments =
            "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -EncodedCommand " +
            launchEncoded;

        string script =
            "$action = New-ScheduledTaskAction -Execute 'powershell.exe'" +
            " -Argument " + PsQuote(launchArguments) +
            " -WorkingDirectory " + PsQuote(installDir) + ";" +
            "$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries " +
            "-ExecutionTimeLimit (New-TimeSpan -Seconds 0) -MultipleInstances IgnoreNew;" +
            "Register-ScheduledTask -TaskName " + PsQuote(TaskName) +
            " -Action $action -Settings $settings -RunLevel Highest -Force | Out-Null";

        string encoded = Convert.ToBase64String(Encoding.Unicode.GetBytes(script));
        Run("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -EncodedCommand " + encoded);
    }

    private static void CreateShortcut(string installDir)
    {
        string desktop = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
        string shortcutPath = Path.Combine(desktop, "SiegeConnect.lnk");
        string appExe = Path.Combine(installDir, "siegeconnect.exe");

        Type shellType = Type.GetTypeFromProgID("WScript.Shell");
        if (shellType == null)
        {
            return;
        }

        object shell = Activator.CreateInstance(shellType);
        object shortcut = shellType.InvokeMember(
            "CreateShortcut",
            BindingFlags.InvokeMethod,
            null,
            shell,
            new object[] { shortcutPath });

        Type shortcutType = shortcut.GetType();
        shortcutType.InvokeMember("TargetPath", BindingFlags.SetProperty, null, shortcut, new object[] { appExe });
        shortcutType.InvokeMember("WorkingDirectory", BindingFlags.SetProperty, null, shortcut, new object[] { installDir });
        shortcutType.InvokeMember("IconLocation", BindingFlags.SetProperty, null, shortcut, new object[] { appExe });
        shortcutType.InvokeMember("Save", BindingFlags.InvokeMethod, null, shortcut, null);
    }

    private static void Run(string fileName, string arguments)
    {
        Process process = Process.Start(new ProcessStartInfo(fileName, arguments)
        {
            UseShellExecute = false,
            CreateNoWindow = true
        });
        process.WaitForExit();
        if (process.ExitCode != 0)
        {
            throw new InvalidOperationException(fileName + " failed with exit code " + process.ExitCode);
        }
    }

    private static string PsQuote(string value)
    {
        return "'" + value.Replace("'", "''") + "'";
    }
}
'@ | Set-Content -LiteralPath $setupSource -Encoding UTF8

@'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
    <security>
      <requestedPrivileges>
        <requestedExecutionLevel level="requireAdministrator" uiAccess="false" />
      </requestedPrivileges>
    </security>
  </trustInfo>
</assembly>
'@ | Set-Content -LiteralPath $manifest -Encoding UTF8

$cscCandidates = @(
  (Join-Path $env:WINDIR "Microsoft.NET\Framework64\v4.0.30319\csc.exe"),
  (Join-Path $env:WINDIR "Microsoft.NET\Framework\v4.0.30319\csc.exe")
)
$csc = $cscCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $csc) {
  throw "csc.exe was not found. Install .NET Framework developer tools."
}

& $csc `
  /nologo `
  /target:winexe `
  /platform:x64 `
  /out:$setupExe `
  /win32manifest:$manifest `
  /resource:$payload,payload.zip `
  /reference:System.IO.Compression.dll `
  /reference:System.IO.Compression.FileSystem.dll `
  /reference:System.Windows.Forms.dll `
  $setupSource

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Setup EXE:" -ForegroundColor Green
Write-Host $setupExe
