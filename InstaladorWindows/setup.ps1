Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$scriptDir = $PSScriptRoot
$defaultPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, "ERPMarmoraria", "App")

$form = New-Object System.Windows.Forms.Form
$form.Text = "Instalador - ERP Marmoraria"
$form.Size = New-Object System.Drawing.Size(620, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)

$icoPath = Join-Path $scriptDir "appicon.ico"
if (Test-Path $icoPath) {
    try { $form.Icon = New-Object System.Drawing.Icon($icoPath) } catch {}
}

# Header
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock = "Top"
$pnlHeader.Height = 85
$pnlHeader.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$form.Controls.Add($pnlHeader)

$logoPath = Join-Path $scriptDir "icon-512.png"
if (Test-Path $logoPath) {
    $pbLogo = New-Object System.Windows.Forms.PictureBox
    $pbLogo.Location = New-Object System.Drawing.Point(16, 10)
    $pbLogo.Size = New-Object System.Drawing.Size(64, 64)
    $pbLogo.SizeMode = "Zoom"
    $pbLogo.Image = [System.Drawing.Image]::FromFile($logoPath)
    $pnlHeader.Controls.Add($pbLogo)
}

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Instalação do ERP Marmoraria"
$lblTitle.Location = New-Object System.Drawing.Point(90, 16)
$lblTitle.AutoSize = $true
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12.5, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::White
$pnlHeader.Controls.Add($lblTitle)

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Sistema de Gestão Completo para Marmorarias - Windows Desktop"
$lblSub.Location = New-Object System.Drawing.Point(92, 45)
$lblSub.AutoSize = $true
$lblSub.ForeColor = [System.Drawing.Color]::FromArgb(148, 163, 184)
$pnlHeader.Controls.Add($lblSub)

# Body
$lblDesc = New-Object System.Windows.Forms.Label
$lblDesc.Text = "Este assistente instalará o ERP Marmoraria no seu computador com atalhos na Área de Trabalho e Menu Iniciar."
$lblDesc.Location = New-Object System.Drawing.Point(20, 100)
$lblDesc.Size = New-Object System.Drawing.Size(560, 30)
$form.Controls.Add($lblDesc)

$lblDir = New-Object System.Windows.Forms.Label
$lblDir.Text = "Pasta de Destino:"
$lblDir.Location = New-Object System.Drawing.Point(20, 140)
$lblDir.AutoSize = $true
$lblDir.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblDir)

$txtDir = New-Object System.Windows.Forms.TextBox
$txtDir.Text = $defaultPath
$txtDir.Location = New-Object System.Drawing.Point(20, 165)
$txtDir.Size = New-Object System.Drawing.Size(460, 26)
$form.Controls.Add($txtDir)

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "Procurar..."
$btnBrowse.Location = New-Object System.Drawing.Point(490, 164)
$btnBrowse.Size = New-Object System.Drawing.Size(95, 28)
$btnBrowse.Add_Click({
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.SelectedPath = $txtDir.Text
    if ($fbd.ShowDialog() -eq "OK") {
        $txtDir.Text = $fbd.SelectedPath
    }
})
$form.Controls.Add($btnBrowse)

$chkDesktop = New-Object System.Windows.Forms.CheckBox
$chkDesktop.Text = "Criar atalho na Área de Trabalho"
$chkDesktop.Checked = $true
$chkDesktop.Location = New-Object System.Drawing.Point(20, 215)
$chkDesktop.AutoSize = $true
$form.Controls.Add($chkDesktop)

$chkStart = New-Object System.Windows.Forms.CheckBox
$chkStart.Text = "Adicionar ao Menu Iniciar"
$chkStart.Checked = $true
$chkStart.Location = New-Object System.Drawing.Point(20, 245)
$chkStart.AutoSize = $true
$form.Controls.Add($chkStart)

$chkRun = New-Object System.Windows.Forms.CheckBox
$chkRun.Text = "Executar o ERP Marmoraria após a instalação"
$chkRun.Checked = $true
$chkRun.Location = New-Object System.Drawing.Point(20, 275)
$chkRun.AutoSize = $true
$form.Controls.Add($chkRun)

# Progresso
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 320)
$progressBar.Size = New-Object System.Drawing.Size(565, 20)
$progressBar.Visible = $false
$form.Controls.Add($progressBar)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(20, 345)
$lblStatus.Size = New-Object System.Drawing.Size(565, 20)
$lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
$form.Controls.Add($lblStatus)

# Botões Inferiores
$pnlFooter = New-Object System.Windows.Forms.Panel
$pnlFooter.Dock = "Bottom"
$pnlFooter.Height = 60
$pnlFooter.BackColor = [System.Drawing.Color]::FromArgb(241, 245, 249)
$form.Controls.Add($pnlFooter)

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = "Cancelar"
$btnCancel.Location = New-Object System.Drawing.Point(490, 16)
$btnCancel.Size = New-Object System.Drawing.Size(95, 32)
$btnCancel.Add_Click({ $form.Close() })
$pnlFooter.Controls.Add($btnCancel)

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "Instalar Agora"
$btnInstall.Location = New-Object System.Drawing.Point(365, 16)
$btnInstall.Size = New-Object System.Drawing.Size(115, 32)
$btnInstall.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$btnInstall.ForeColor = [System.Drawing.Color]::White
$btnInstall.FlatStyle = "Flat"
$btnInstall.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

$btnInstall.Add_Click({
    $btnInstall.Enabled = $false
    $btnBrowse.Enabled = $false
    $txtDir.Enabled = $false
    $progressBar.Visible = $true
    $progressBar.Value = 10

    $target = $txtDir.Text.Trim()
    $lblStatus.Text = "Preparando pasta de destino..."
    $form.Refresh()

    try {
        if (!(Test-Path $target)) {
            New-Item -ItemType Directory -Path $target -Force | Out-Null
        }

        $progressBar.Value = 30
        $lblStatus.Text = "Copiando executável e arquivos do sistema..."
        $form.Refresh()

        $exeSource = Join-Path $scriptDir "ERPMarmoraria.exe"
        Copy-Item $exeSource (Join-Path $target "ERPMarmoraria.exe") -Force

        $dllSource = Join-Path $scriptDir "WebView2Loader.dll"
        if (Test-Path $dllSource) {
            Copy-Item $dllSource (Join-Path $target "WebView2Loader.dll") -Force
        }

        $runtimesSource = Join-Path $scriptDir "runtimes"
        if (Test-Path $runtimesSource) {
            Copy-Item $runtimesSource (Join-Path $target "runtimes") -Recurse -Force
        }

        $icoSource = Join-Path $scriptDir "appicon.ico"
        if (Test-Path $icoSource) {
            Copy-Item $icoSource (Join-Path $target "appicon.ico") -Force
        }

        $targetWww = Join-Path $target "www"
        if (Test-Path $targetWww) {
            Remove-Item $targetWww -Recurse -Force
        }
        $sourceWww = Join-Path $scriptDir "www"
        if (Test-Path $sourceWww) {
            Copy-Item $sourceWww $targetWww -Recurse -Force
        }

        $progressBar.Value = 70
        $lblStatus.Text = "Criando atalhos..."
        $form.Refresh()

        $targetExe = Join-Path $target "ERPMarmoraria.exe"
        $wshShell = New-Object -ComObject WScript.Shell

        if ($chkDesktop.Checked) {
            $desktopPath = [System.Environment]::GetFolderPath('Desktop')
            $lnkDesktop = $wshShell.CreateShortcut((Join-Path $desktopPath "ERP Marmoraria.lnk"))
            $lnkDesktop.TargetPath = $targetExe
            $lnkDesktop.WorkingDirectory = $target
            $lnkDesktop.IconLocation = "$targetExe,0"
            $lnkDesktop.Description = "ERP Marmoraria - Sistema de Gestão"
            $lnkDesktop.Save()
        }

        if ($chkStart.Checked) {
            $startMenuPath = [System.Environment]::GetFolderPath('Programs')
            $lnkStart = $wshShell.CreateShortcut((Join-Path $startMenuPath "ERP Marmoraria.lnk"))
            $lnkStart.TargetPath = $targetExe
            $lnkStart.WorkingDirectory = $target
            $lnkStart.IconLocation = "$targetExe,0"
            $lnkStart.Description = "ERP Marmoraria - Sistema de Gestão"
            $lnkStart.Save()
        }

        # Registro para desinstalação no Painel de Controle
        $progressBar.Value = 90
        $lblStatus.Text = "Configurando desinstalador no Windows..."
        $form.Refresh()

        $uninstPath = Join-Path $target "uninstall.bat"
        $uninstContent = "@echo off`r`ntaskkill /F /IM ERPMarmoraria.exe >nul 2>&1`r`nrd /s /q `"$target`"`r`ndel /f /q `"`%USERPROFILE`%\Desktop\ERP Marmoraria.lnk`" >nul 2>&1`r`ndel /f /q `"`%APPDATA`%\Microsoft\Windows\Start Menu\Programs\ERP Marmoraria.lnk`" >nul 2>&1`r`nreg delete `"HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\ERPMarmoraria`" /f >nul 2>&1`r`necho ERP Marmoraria desinstalado com sucesso.`r`npause"
        [System.IO.File]::WriteAllText($uninstPath, $uninstContent)

        $regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\ERPMarmoraria"
        if (!(Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
        Set-ItemProperty -Path $regKey -Name "DisplayName" -Value "ERP Marmoraria"
        Set-ItemProperty -Path $regKey -Name "DisplayVersion" -Value "1.0.0"
        Set-ItemProperty -Path $regKey -Name "Publisher" -Value "ERP Marmoraria"
        Set-ItemProperty -Path $regKey -Name "DisplayIcon" -Value $targetExe
        Set-ItemProperty -Path $regKey -Name "UninstallString" -Value "`"$uninstPath`""

        $progressBar.Value = 100
        $lblStatus.Text = "Instalação concluída com sucesso!"
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(22, 101, 52)
        $form.Refresh()

        [System.Windows.Forms.MessageBox]::Show(
            "ERP Marmoraria foi instalado com sucesso!",
            "Instalação Concluída",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )

        if ($chkRun.Checked) {
            Start-Process -FilePath $targetExe -WorkingDirectory $target
        }

        $form.Close()
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Erro durante a instalação: $($_.Exception.Message)",
            "Erro",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        $btnInstall.Enabled = $true
    }
})
$pnlFooter.Controls.Add($btnInstall)

$form.ShowDialog() | Out-Null
