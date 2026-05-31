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
using Microsoft.Win32;
using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.Compression;
using System.Management;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Windows.Forms;

internal static class Program
{
    internal const string AppName = "SiegeConnect";
    internal const string AppVersion = "0.1.4";
    internal const string TaskName = "SiegeConnectMihomo";

    [STAThread]
    private static int Main(string[] args)
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        try
        {
            if (args.Length > 0 && args[0].Equals("/uninstall", StringComparison.OrdinalIgnoreCase))
            {
                return Uninstall(args);
            }

            if (!LanguageDialog.ShowDialogAndConfirm())
            {
                return 0;
            }

            using (InstallerWizard wizard = new InstallerWizard())
            {
                Application.Run(wizard);
                return wizard.ExitCode;
            }
        }
        catch (Exception error)
        {
            MessageBox.Show(error.ToString(), "SiegeConnect Setup", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
    }

    private static int Uninstall(string[] args)
    {
        bool quiet = args.Length > 1 && args[1].Equals("/quiet", StringComparison.OrdinalIgnoreCase);
        if (!quiet)
        {
            DialogResult confirm = MessageBox.Show(
                "Удалить SiegeConnect с этого компьютера?",
                "Удаление SiegeConnect",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);
            if (confirm != DialogResult.Yes)
            {
                return 0;
            }
        }

        string installDir = InstallerPaths.InstallDir;
        InstallerActions.StopSiegeConnectProcesses(installDir);
        InstallerActions.UnregisterTunTask();
        InstallerActions.DeleteShortcuts();
        InstallerActions.DeleteUninstallEntry();
        InstallerActions.ScheduleDirectoryRemoval(installDir);

        if (!quiet)
        {
            MessageBox.Show("SiegeConnect удалён.", "Удаление SiegeConnect", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
        return 0;
    }
}

internal static class InstallerPaths
{
    internal static string InstallDir
    {
        get { return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "SiegeConnect"); }
    }

    internal static string RuntimeDir
    {
        get { return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "SiegeConnect", "runtime"); }
    }

    internal static string LegacyInstallDir
    {
        get { return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "SiegeConnect", "app"); }
    }

    internal static string DesktopShortcut
    {
        get { return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory), "SiegeConnect.lnk"); }
    }

    internal static string StartMenuDir
    {
        get { return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonPrograms), "SiegeConnect"); }
    }
}

internal sealed class LanguageDialog : Form
{
    private readonly ComboBox language = new ComboBox();
    private bool confirmed;

    private LanguageDialog()
    {
        Text = "Выберите язык установки";
        Font = new Font("Segoe UI", 9F);
        FormBorderStyle = FormBorderStyle.FixedDialog;
        StartPosition = FormStartPosition.CenterScreen;
        MaximizeBox = false;
        MinimizeBox = false;
        ClientSize = new Size(360, 128);

        PictureBox icon = new PictureBox();
        icon.Image = SystemIcons.Application.ToBitmap();
        icon.SizeMode = PictureBoxSizeMode.CenterImage;
        icon.Location = new Point(16, 24);
        icon.Size = new Size(32, 32);

        Label label = new Label();
        label.Text = "Выберите язык, который будет использован в процессе установки.";
        label.Location = new Point(64, 18);
        label.Size = new Size(280, 36);

        language.DropDownStyle = ComboBoxStyle.DropDownList;
        language.Items.Add("Русский");
        language.SelectedIndex = 0;
        language.Location = new Point(64, 64);
        language.Size = new Size(290, 24);

        Button ok = new Button();
        ok.Text = "OK";
        ok.Location = new Point(200, 98);
        ok.Size = new Size(74, 24);
        ok.Click += delegate { confirmed = true; Close(); };

        Button cancel = new Button();
        cancel.Text = "Отмена";
        cancel.Location = new Point(282, 98);
        cancel.Size = new Size(74, 24);
        cancel.Click += delegate { Close(); };

        AcceptButton = ok;
        CancelButton = cancel;
        Controls.AddRange(new Control[] { icon, label, language, ok, cancel });
    }

    internal static bool ShowDialogAndConfirm()
    {
        using (LanguageDialog dialog = new LanguageDialog())
        {
            dialog.ShowDialog();
            return dialog.confirmed;
        }
    }
}

internal sealed class InstallerWizard : Form
{
    private readonly Label title = new Label();
    private readonly Label subtitle = new Label();
    private readonly Panel body = new Panel();
    private readonly Button back = new Button();
    private readonly Button next = new Button();
    private readonly Button cancel = new Button();
    private readonly ProgressBar progress = new ProgressBar();
    private readonly Label progressText = new Label();
    private readonly CheckBox desktopShortcut = new CheckBox();
    private readonly CheckBox startMenuShortcut = new CheckBox();
    private readonly CheckBox resetSettings = new CheckBox();
    private readonly CheckBox launchAfter = new CheckBox();
    private int page;
    private bool installing;

    internal int ExitCode { get; private set; }

    internal InstallerWizard()
    {
        Text = "Установка — SiegeConnect " + Program.AppVersion;
        Font = new Font("Segoe UI", 9F);
        StartPosition = FormStartPosition.CenterScreen;
        FormBorderStyle = FormBorderStyle.FixedSingle;
        MaximizeBox = false;
        ClientSize = new Size(598, 462);

        Panel header = new Panel();
        header.Dock = DockStyle.Top;
        header.Height = 88;
        header.BackColor = Color.White;

        title.Font = new Font("Segoe UI", 10F, FontStyle.Bold);
        title.Location = new Point(26, 16);
        title.Size = new Size(460, 22);

        subtitle.Location = new Point(42, 42);
        subtitle.Size = new Size(440, 28);

        PictureBox box = new PictureBox();
        box.Image = SystemIcons.Application.ToBitmap();
        box.Location = new Point(532, 18);
        box.Size = new Size(42, 42);
        box.SizeMode = PictureBoxSizeMode.StretchImage;

        header.Controls.AddRange(new Control[] { title, subtitle, box });

        body.Dock = DockStyle.Fill;
        body.Padding = new Padding(42, 22, 42, 22);

        Panel footer = new Panel();
        footer.Dock = DockStyle.Bottom;
        footer.Height = 58;
        footer.BackColor = SystemColors.Control;

        back.Text = "Назад";
        back.Location = new Point(318, 17);
        back.Size = new Size(84, 26);
        back.Click += delegate { if (page > 0) { ShowPage(page - 1); } };

        next.Text = "Далее";
        next.Location = new Point(410, 17);
        next.Size = new Size(84, 26);
        next.Click += delegate { NextClicked(); };

        cancel.Text = "Отмена";
        cancel.Location = new Point(502, 17);
        cancel.Size = new Size(84, 26);
        cancel.Click += delegate
        {
            if (!installing || MessageBox.Show("Прервать установку?", "SiegeConnect Setup", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
                ExitCode = 1;
                Close();
            }
        };

        footer.Controls.AddRange(new Control[] { back, next, cancel });
        Controls.AddRange(new Control[] { body, header, footer });

        desktopShortcut.Text = "Создать ярлык на рабочем столе";
        desktopShortcut.Checked = true;
        desktopShortcut.AutoSize = true;

        startMenuShortcut.Text = "Создать ярлык в меню Пуск";
        startMenuShortcut.Checked = true;
        startMenuShortcut.AutoSize = true;

        resetSettings.Text = "Сбросить весь кэш и настройки после установки";
        resetSettings.AutoSize = true;

        launchAfter.Text = "Запустить SiegeConnect после установки";
        launchAfter.Checked = true;
        launchAfter.AutoSize = true;

        ShowPage(0);
    }

    private void ShowPage(int nextPage)
    {
        page = nextPage;
        body.Controls.Clear();
        back.Enabled = page > 0 && page < 3;
        next.Enabled = true;
        cancel.Enabled = true;
        next.Text = page == 4 ? "Готово" : "Далее";

        if (page == 0)
        {
            title.Text = "Установка SiegeConnect";
            subtitle.Text = "Мастер установит VPN-клиент на ваш компьютер.";
            AddParagraph("Перед продолжением закройте старые окна SiegeConnect. Установщик добавит приложение, фоновый TUN-компонент, ярлыки и запись удаления.");
            AddInstallPath();
        }
        else if (page == 1)
        {
            title.Text = "Выберите дополнительные задачи";
            subtitle.Text = "Какие дополнительные задачи необходимо выполнить?";
            AddLabel("Дополнительные ярлыки:", 0, true);
            AddControl(desktopShortcut, 28);
            AddControl(startMenuShortcut, 54);
            AddLabel("Параметры после установки:", 94, true);
            AddControl(resetSettings, 122);
            AddControl(launchAfter, 148);
        }
        else if (page == 2)
        {
            title.Text = "Готово к установке";
            subtitle.Text = "Нажмите «Установить», чтобы начать.";
            next.Text = "Установить";
            AddParagraph(
                "Папка установки:\r\n" + InstallerPaths.InstallDir + "\r\n\r\n" +
                "Будет установлен SiegeConnect, Mihomo, фоновая задача для TUN без постоянного UAC и ярлыки по выбранным параметрам.");
        }
        else if (page == 3)
        {
            title.Text = "Установка";
            subtitle.Text = "Пожалуйста, подождите, пока SiegeConnect устанавливается.";
            back.Enabled = false;
            next.Enabled = false;
            cancel.Enabled = false;
            progress.Location = new Point(0, 44);
            progress.Size = new Size(510, 22);
            progress.Minimum = 0;
            progress.Maximum = 100;
            progress.Value = 0;
            progressText.Location = new Point(0, 14);
            progressText.Size = new Size(510, 22);
            body.Controls.AddRange(new Control[] { progressText, progress });
            StartInstall();
        }
        else
        {
            title.Text = "Установка завершена";
            subtitle.Text = "SiegeConnect установлен на компьютер.";
            back.Enabled = false;
            cancel.Text = "Закрыть";
            AddParagraph("Теперь можно запускать SiegeConnect из меню Пуск или с рабочего стола. Для TUN без UAC фоновый компонент уже зарегистрирован.");
        }
    }

    private void NextClicked()
    {
        if (page == 4)
        {
            Close();
            return;
        }
        ShowPage(page + 1);
    }

    private void StartInstall()
    {
        installing = true;
        ThreadPool.QueueUserWorkItem(delegate
        {
            try
            {
                InstallerOptions options = new InstallerOptions();
                options.CreateDesktopShortcut = desktopShortcut.Checked;
                options.CreateStartMenuShortcut = startMenuShortcut.Checked;
                options.ResetSettings = resetSettings.Checked;
                options.LaunchAfterInstall = launchAfter.Checked;

                InstallerActions.Install(options, ReportProgress);
                BeginInvoke(new MethodInvoker(delegate
                {
                    installing = false;
                    ExitCode = 0;
                    if (options.LaunchAfterInstall)
                    {
                        InstallerActions.LaunchApp();
                    }
                    ShowPage(4);
                }));
            }
            catch (Exception error)
            {
                BeginInvoke(new MethodInvoker(delegate
                {
                    installing = false;
                    ExitCode = 1;
                    cancel.Enabled = true;
                    cancel.Text = "Закрыть";
                    MessageBox.Show(error.ToString(), "Ошибка установки", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }));
            }
        });
    }

    private void ReportProgress(int value, string text)
    {
        BeginInvoke(new MethodInvoker(delegate
        {
            progress.Value = Math.Max(progress.Minimum, Math.Min(progress.Maximum, value));
            progressText.Text = text;
        }));
    }

    private void AddParagraph(string text)
    {
        Label label = new Label();
        label.Text = text;
        label.Location = new Point(0, 0);
        label.Size = new Size(510, 130);
        body.Controls.Add(label);
    }

    private void AddInstallPath()
    {
        TextBox path = new TextBox();
        path.ReadOnly = true;
        path.Text = InstallerPaths.InstallDir;
        path.Location = new Point(0, 142);
        path.Size = new Size(510, 23);
        body.Controls.Add(path);
    }

    private void AddLabel(string text, int y, bool bold)
    {
        Label label = new Label();
        label.Text = text;
        label.Location = new Point(0, y);
        label.Size = new Size(510, 22);
        if (bold)
        {
            label.Font = new Font(Font, FontStyle.Bold);
        }
        body.Controls.Add(label);
    }

    private void AddControl(Control control, int y)
    {
        control.Location = new Point(4, y);
        body.Controls.Add(control);
    }
}

internal sealed class InstallerOptions
{
    internal bool CreateDesktopShortcut;
    internal bool CreateStartMenuShortcut;
    internal bool ResetSettings;
    internal bool LaunchAfterInstall;
}

internal static class InstallerActions
{
    internal delegate void Progress(int value, string text);

    internal static void Install(InstallerOptions options, Progress progress)
    {
        string installDir = InstallerPaths.InstallDir;
        string runtimeDir = InstallerPaths.RuntimeDir;

        progress(5, "Остановка старой версии...");
        StopSiegeConnectProcesses(installDir);
        UnregisterTunTask();

        if (options.ResetSettings)
        {
            progress(12, "Очистка настроек и кэша...");
            DeleteDirectoryIfExists(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "SiegeConnect"));
            DeleteDirectoryIfExists(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "app.siegeconnect.client"));
        }

        progress(20, "Подготовка папки установки...");
        DeleteDirectoryIfExists(installDir);
        DeleteDirectoryIfExists(InstallerPaths.LegacyInstallDir);
        Directory.CreateDirectory(installDir);
        Directory.CreateDirectory(runtimeDir);

        progress(34, "Распаковка файлов приложения...");
        ExtractPayload(installDir);

        progress(58, "Регистрация фонового TUN-компонента...");
        RegisterTunTask(installDir, runtimeDir);

        progress(72, "Создание ярлыков...");
        DeleteShortcuts();
        if (options.CreateDesktopShortcut)
        {
            CreateShortcut(InstallerPaths.DesktopShortcut, Path.Combine(installDir, "siegeconnect.exe"), installDir);
        }
        if (options.CreateStartMenuShortcut)
        {
            Directory.CreateDirectory(InstallerPaths.StartMenuDir);
            CreateShortcut(Path.Combine(InstallerPaths.StartMenuDir, "SiegeConnect.lnk"), Path.Combine(installDir, "siegeconnect.exe"), installDir);
            CreateShortcut(Path.Combine(InstallerPaths.StartMenuDir, "Удалить SiegeConnect.lnk"), Path.Combine(installDir, "SiegeConnect-Uninstall.exe"), installDir, "/uninstall");
        }

        progress(86, "Регистрация удаления...");
        File.Copy(Application.ExecutablePath, Path.Combine(installDir, "SiegeConnect-Uninstall.exe"), true);
        RegisterUninstallEntry(installDir);

        progress(100, "Готово.");
    }

    internal static void LaunchApp()
    {
        string appExe = Path.Combine(InstallerPaths.InstallDir, "siegeconnect.exe");
        if (File.Exists(appExe))
        {
            Process.Start(new ProcessStartInfo(appExe) { WorkingDirectory = InstallerPaths.InstallDir, UseShellExecute = true });
        }
    }

    private static void ExtractPayload(string installDir)
    {
        Stream payload = Assembly.GetExecutingAssembly().GetManifestResourceStream("payload.zip");
        if (payload == null)
        {
            throw new InvalidOperationException("Embedded payload.zip not found.");
        }

        string tempZip = Path.Combine(Path.GetTempPath(), "SiegeConnect-App-" + Guid.NewGuid().ToString("N") + ".zip");
        using (payload)
        using (FileStream output = File.Create(tempZip))
        {
            payload.CopyTo(output);
        }

        ZipFile.ExtractToDirectory(tempZip, installDir);
        File.Delete(tempZip);
    }

    internal static void RegisterTunTask(string installDir, string runtimeDir)
    {
        string mihomo = Path.Combine(installDir, "mihomo.exe");
        string config = Path.Combine(runtimeDir, "current.yaml");
        if (!File.Exists(config))
        {
            File.WriteAllText(
                config,
                "mixed-port: 7890\nexternal-controller: 127.0.0.1:9090\nproxies: []\nproxy-groups: []\nrules:\n  - MATCH,DIRECT\n",
                Encoding.UTF8);
        }

        string launchScript = "& " + PsQuote(mihomo) + " -f " + PsQuote(config);
        string launchEncoded = Convert.ToBase64String(Encoding.Unicode.GetBytes(launchScript));
        string launchArguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -EncodedCommand " + launchEncoded;

        string script =
            "$action = New-ScheduledTaskAction -Execute 'powershell.exe'" +
            " -Argument " + PsQuote(launchArguments) +
            " -WorkingDirectory " + PsQuote(installDir) + ";" +
            "$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries " +
            "-ExecutionTimeLimit (New-TimeSpan -Seconds 0) -MultipleInstances IgnoreNew;" +
            "Register-ScheduledTask -TaskName " + PsQuote(Program.TaskName) +
            " -Action $action -Settings $settings -RunLevel Highest -Force | Out-Null";

        string encoded = Convert.ToBase64String(Encoding.Unicode.GetBytes(script));
        Run("powershell.exe", "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -EncodedCommand " + encoded);
    }

    internal static void UnregisterTunTask()
    {
        RunIgnore("schtasks.exe", "/End /TN " + Quote(Program.TaskName));
        RunIgnore("schtasks.exe", "/Delete /TN " + Quote(Program.TaskName) + " /F");
    }

    internal static void StopSiegeConnectProcesses(string installDir)
    {
        KillProcessByName("siegeconnect", "SiegeConnect");
        KillProcessByName("mihomo", "SiegeConnect");
    }

    private static void KillProcessByName(string processName, string commandLineNeedle)
    {
        try
        {
            ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT ProcessId, ExecutablePath, CommandLine FROM Win32_Process WHERE Name = '" + processName + ".exe'");
            foreach (ManagementObject item in searcher.Get())
            {
                string executablePath = Convert.ToString(item["ExecutablePath"]) ?? "";
                string commandLine = Convert.ToString(item["CommandLine"]) ?? "";
                if (executablePath.IndexOf(commandLineNeedle, StringComparison.OrdinalIgnoreCase) >= 0 ||
                    commandLine.IndexOf(commandLineNeedle, StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    int processId = Convert.ToInt32(item["ProcessId"]);
                    if (processId != Process.GetCurrentProcess().Id)
                    {
                        RunIgnore("taskkill.exe", "/F /PID " + processId.ToString());
                    }
                }
            }
        }
        catch
        {
        }
    }

    internal static void CreateShortcut(string shortcutPath, string targetPath, string workingDirectory)
    {
        CreateShortcut(shortcutPath, targetPath, workingDirectory, "");
    }

    internal static void CreateShortcut(string shortcutPath, string targetPath, string workingDirectory, string arguments)
    {
        Type shellType = Type.GetTypeFromProgID("WScript.Shell");
        if (shellType == null)
        {
            return;
        }

        object shell = Activator.CreateInstance(shellType);
        object shortcut = shellType.InvokeMember("CreateShortcut", BindingFlags.InvokeMethod, null, shell, new object[] { shortcutPath });
        Type shortcutType = shortcut.GetType();
        shortcutType.InvokeMember("TargetPath", BindingFlags.SetProperty, null, shortcut, new object[] { targetPath });
        shortcutType.InvokeMember("WorkingDirectory", BindingFlags.SetProperty, null, shortcut, new object[] { workingDirectory });
        shortcutType.InvokeMember("Arguments", BindingFlags.SetProperty, null, shortcut, new object[] { arguments });
        shortcutType.InvokeMember("IconLocation", BindingFlags.SetProperty, null, shortcut, new object[] { targetPath });
        shortcutType.InvokeMember("Save", BindingFlags.InvokeMethod, null, shortcut, null);
    }

    internal static void DeleteShortcuts()
    {
        DeleteFileIfExists(InstallerPaths.DesktopShortcut);
        DeleteDirectoryIfExists(InstallerPaths.StartMenuDir);
    }

    private static void RegisterUninstallEntry(string installDir)
    {
        using (RegistryKey key = Registry.LocalMachine.CreateSubKey(@"Software\Microsoft\Windows\CurrentVersion\Uninstall\SiegeConnect"))
        {
            string appExe = Path.Combine(installDir, "siegeconnect.exe");
            string uninstallExe = Path.Combine(installDir, "SiegeConnect-Uninstall.exe");
            key.SetValue("DisplayName", "SiegeConnect");
            key.SetValue("DisplayVersion", Program.AppVersion);
            key.SetValue("Publisher", "ytplumpxx");
            key.SetValue("InstallLocation", installDir);
            key.SetValue("DisplayIcon", appExe);
            key.SetValue("UninstallString", Quote(uninstallExe) + " /uninstall");
            key.SetValue("QuietUninstallString", Quote(uninstallExe) + " /uninstall /quiet");
            key.SetValue("NoModify", 1, RegistryValueKind.DWord);
            key.SetValue("NoRepair", 1, RegistryValueKind.DWord);
        }
    }

    internal static void DeleteUninstallEntry()
    {
        try
        {
            Registry.LocalMachine.DeleteSubKeyTree(@"Software\Microsoft\Windows\CurrentVersion\Uninstall\SiegeConnect", false);
        }
        catch
        {
        }
    }

    internal static void ScheduleDirectoryRemoval(string installDir)
    {
        string script = "Start-Sleep -Seconds 1; Remove-Item -LiteralPath " + PsQuote(installDir) + " -Recurse -Force -ErrorAction SilentlyContinue";
        string encoded = Convert.ToBase64String(Encoding.Unicode.GetBytes(script));
        Process.Start(new ProcessStartInfo("powershell.exe", "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -EncodedCommand " + encoded)
        {
            UseShellExecute = false,
            CreateNoWindow = true,
            WindowStyle = ProcessWindowStyle.Hidden
        });
    }

    private static void DeleteDirectoryIfExists(string path)
    {
        if (Directory.Exists(path))
        {
            Directory.Delete(path, true);
        }
    }

    private static void DeleteFileIfExists(string path)
    {
        if (File.Exists(path))
        {
            File.Delete(path);
        }
    }

    private static void Run(string fileName, string arguments)
    {
        Process process = Process.Start(new ProcessStartInfo(fileName, arguments)
        {
            UseShellExecute = false,
            CreateNoWindow = true,
            WindowStyle = ProcessWindowStyle.Hidden
        });
        process.WaitForExit();
        if (process.ExitCode != 0)
        {
            throw new InvalidOperationException(fileName + " failed with exit code " + process.ExitCode);
        }
    }

    private static void RunIgnore(string fileName, string arguments)
    {
        try
        {
            Process process = Process.Start(new ProcessStartInfo(fileName, arguments)
            {
                UseShellExecute = false,
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden
            });
            process.WaitForExit();
        }
        catch
        {
        }
    }

    private static string Quote(string value)
    {
        return "\"" + value.Replace("\"", "\\\"") + "\"";
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
  /codepage:65001 `
  /out:$setupExe `
  /win32manifest:$manifest `
  /resource:$payload,payload.zip `
  /reference:System.Drawing.dll `
  /reference:System.IO.Compression.dll `
  /reference:System.IO.Compression.FileSystem.dll `
  /reference:System.Management.dll `
  /reference:System.Windows.Forms.dll `
  $setupSource

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Setup EXE:" -ForegroundColor Green
Write-Host $setupExe
