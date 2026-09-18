using System.Diagnostics;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;

namespace ERPMarmoraria;

public class MainWindow : Form
{
    private WebView2 _webView = null!;

    public MainWindow()
    {
        SetupWindow();
        InitializeWebView();
    }

    private void SetupWindow()
    {
        Text = "ERP Marmoraria - Sistema de Gestao Integrado";
        Width = 1400;
        Height = 900;
        MinimumSize = new Size(960, 640);
        StartPosition = FormStartPosition.CenterScreen;

        var icoPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "appicon.ico");
        if (File.Exists(icoPath))
        {
            try { Icon = new Icon(icoPath); } catch { }
        }
    }

    private async void InitializeWebView()
    {
        _webView = new WebView2
        {
            Dock = DockStyle.Fill
        };
        Controls.Add(_webView);

        try
        {
            var localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            var userDataFolder = Path.Combine(localAppData, "ERPMarmoraria", "WebView2Data");
            Directory.CreateDirectory(userDataFolder);

            var env = await CoreWebView2Environment.CreateAsync(null, userDataFolder);
            await _webView.EnsureCoreWebView2Async(env);

            var wwwPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "www");
            if (!Directory.Exists(wwwPath))
            {
                wwwPath = Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "..", "..", "..", "build", "web"));
            }

            _webView.CoreWebView2.SetVirtualHostNameToFolderMapping(
                "erp.local",
                wwwPath,
                CoreWebView2HostResourceAccessKind.Allow
            );

            _webView.CoreWebView2.Settings.IsStatusBarEnabled = false;
            _webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = true;
            _webView.CoreWebView2.Settings.AreDevToolsEnabled = false;

            _webView.CoreWebView2.NewWindowRequested += (s, e) =>
            {
                if (!string.IsNullOrEmpty(e.Uri) && !e.Uri.Contains("erp.local"))
                {
                    e.Handled = true;
                    try
                    {
                        Process.Start(new ProcessStartInfo(e.Uri) { UseShellExecute = true });
                    }
                    catch { }
                }
            };

            _webView.CoreWebView2.Navigate("https://erp.local/index.html");
        }
        catch (Exception ex)
        {
            MessageBox.Show(
                $"Erro ao inicializar o WebView2:\n\n{ex.Message}\n\nVerifique se o Microsoft Edge WebView2 Runtime esta instalado.",
                "Erro de Inicializacao",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error
            );
        }
    }
}
