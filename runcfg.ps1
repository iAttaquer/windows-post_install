function winget_install {
    # Checking if winget is installed, when is not install it
    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Information "Downloading WinGet and its dependencies..."
        $URLwinget = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        $URLwinget = (Invoke-WebRequest -Uri $URLwinget).Content | convertFrom-Json |
        Select-Object -ExpandProperty "assets" |
        Where-Object "browser_download_url" -Match '.msixbundle' |
        Select-Object -ExpandProperty "browser_download_url"
        Invoke-WebRequest -Uri $URLwinget -OutFile "Setup.msix" -UseBasicParsing
        Add-AppxPackage -Path "Setup.msix"
        Remove-Item "Setup.msix"
        # $progressPreference = 'silentlyContinue'
        # Write-Information "Downloading WinGet and its dependencies..."
        # Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
        # Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
        # Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Microsoft.UI.Xaml.2.7.x64.appx
        # Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
        # Add-AppxPackage Microsoft.UI.Xaml.2.7.x64.appx
        # Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
    }
    else {
        Write-Host "Winget is installed!"
    }
}
function IsInstalled {
    param (
        [Parameter(Position = 0)]
        $name
    )
    $paths_to_check = @(
        Join-Path ${env:ProgramFiles} $name
        Join-Path ${env:ProgramFiles(x86)} $name
    )
    foreach ($current in $paths_to_check) {
        if (Test-Path $current) {
            return $true
        }
    }
    return $false
}
function Destroy {
    param (
        [Parameter(Position = 0)]
        $process_name
    )
    #If process name exists, kill it
    if (Get-Process -Name $process_name -ErrorAction SilentlyContinue) {
        Stop-Process -Name $process_name -Force
    }
}
function memreduct_install {
    #Memreduct Installation
    Write-Host "Downloading Mem Reduct and its dependencies..."
    winget install memreduct
    if ($?) {
        Write-Host "Mem Reduct installation successful!"
    }
    if (IsInstalled "Mem Reduct\memreduct.exe") {
        #Configure memreduct
        Write-Host "Configurating Mem Reduct..."
        $memreduct_path = Join-Path $env:APPDATA "Henry++\Mem Reduct\memreduct.ini"
        if (!(Test-Path $memreduct_path)) {
            New-Item -Path $memreduct_path -Force
        }
        "[memreduct]
CheckUpdatesLast=1706640458
IsStartMinimized=true
IsShowReductConfirmation=false
StatisticLastReduct=1704046280
AutoreductEnable=false
AutoreductIntervalEnable=false
HotkeyCleanEnable=false
SettingsLastPage=105
TrayShowBorder=false
TrayChangeBg=false
TrayUseTransparency=true
TrayFont=Segoe UI;9;700
Language=English
IsAutoinstallUpdates=true
TrayRoundCorners=false
TrayUseAntialiasing=true
TrayActionDc=0
AlwaysOnTop=true
IsAllowStandbyListCleanup=true
[memreduct\window]
Position=1523,533" | Out-File -FilePath $memreduct_path -Encoding utf8
        Write-Host "Configuration successful!"    
    }
    else {
        Write-Host "Memreduct installation failed!"
    }
}
function sys_inf_install {
    #System Informer Installation
    Write-Host "Downloading SystemInformer and its dependencies..."
    $tags = Invoke-RestMethod -Uri https://api.github.com/repos/winsiderss/si-builds/tags
    $release_info = Invoke-RestMethod -Uri "https://api.github.com/repos/winsiderss/si-builds/releases/latest"
    $latest_version = $release_info.tag_name
    # $url_system_informer = "https://github.com/winsiderss/si-builds/releases/download/$latestVersion/systeminformer-$latestVersion-setup.exe"
    $url_system_informer = "https://github.com/winsiderss/si-builds/releases/download/$latest_version/systeminformer-$latest_version-canary-setup.exe"
    $output_si = "$env:TEMP\systeminformer-setup.exe"
    Invoke-WebRequest -Uri $url_system_informer -OutFile $output_si
    Write-Host "After installation make sure to close SystemInformer!"
    Start-Process -FilePath $output_si -ArgumentList "/quiet" -Wait
    if (IsInstalled "SystemInformer\SystemInformer.exe") {
        Write-Host "SystemInformer installation successful!"
        #Configure System Informer
        Write-Host "Configurating SystemInformer..."
        $sys_inf_source = ".\Sys_Inf"
        $sys_inf_pev = Join-Path $env:APPDATA "SystemInformer\peview.xml"
        $sys_inf_sett = Join-Path $env:APPDATA "SystemInformer\settings.xml"
        $sys_inf_user = Join-Path $env:APPDATA "SystemInformer\usernotesdb.xml"

        if (!(Test-Path $sys_inf_pev)) {
            New-Item -Path $sys_inf_pev -Force
        }
        Copy-Item -Path (Join-Path $sys_inf_source "peview.xml") -Destination $sys_inf_pev -Force
        if (!(Test-Path $sys_inf_sett)) {
            New-Item -Path $sys_inf_sett -Force
        }
        Copy-Item -Path (Join-Path $sys_inf_source "settings.xml") -Destination $sys_inf_sett -Force
        if (!(Test-Path $sys_inf_user)) {
            New-Item -Path $sys_inf_user -Force
        }
        Copy-Item -Path (Join-Path $sys_inf_source "usernotesdb.xml") -Destination $sys_inf_user -Force
        Write-Host "Configuration successful!"
    }
    else {
        Write-Host "SystemInformer installation failed!"
    }
}
function uxtu_install {
    #Universal x86 Tuning Utility installation
    Write-Host "Downloading UXTU and its dependencies..."
    $release_info = Invoke-RestMethod -Uri "https://api.github.com/repos/JamesCJ60/Universal-x86-Tuning-Utility/releases/latest"
    if ($release_info -match '\d+\.\d+\.\d+') {
        $version_uxtu = $Matches[0]
    }
    $url_uxtu = $release_info.assets | Where-Object { $_.name -like "*Universal.x86.Tuning.Utility*.msi" } | Select-Object -ExpandProperty browser_download_url
    # Write-Host $url_uxtu
    $output_uxtu = "$env:Temp\Universal.x86.Tuning.Utility.msi"
    Invoke-WebRequest -Uri $url_uxtu -OutFile $output_uxtu
    Destroy "Universal x86 Tuning Utility"
    Start-Process msiexec.exe -ArgumentList "/i $output_uxtu /quiet /norestart" -Wait 
    Remove-Item $output_uxtu
    if (IsInstalled "JamesCJ60\Universal x86 Tuning Utility\Universal x86 Tuning Utility.exe") {
        Write-host "Universal x86 Tuning Utility installation successful!" 
        #Configure Universal x86 Tuning Utility 
        Write-Host "Configurating UXTU..."
        $uxtu_source = ".\UXTU"
        $uxtu_user = Join-Path $env:LOCALAPPDATA "JamesCJ60\Universal_x86_Tuning_Util_Url_iimytrsuzb5xtek5eydxvq1ggdurydrv" $version_uxtu "user.config"
        if (!(Test-Path $uxtu_user)) {
            New-Item -Path $uxtu_user -Force
        }
        Copy-Item -Path (Join-Path $uxtu_source "user.config") -Destination $uxtu_user -Force
        $apu_path = Join-Path $env:ProgramFiles "\JamesCJ60\Universal x86 Tuning Utility"
        if (!(Test-Path $apu_path)) {
            New-Item -Path $apu_path -Force
        }
        Copy-Item -Path (Join-Path $uxtu_source "apuPresets.json") -Destination $apu_path -Force
        Write-Host "Configuration successful!"
    }
    else {
        Write-Host "Universal x86 Tuning Utility istallation failed!"
    }
}
function traffic_monitor_install {
    #Traffic Monitor installation
    Write-Host "Downloading TrafficMonitor and its dependencies..."
    $release_info = Invoke-RestMethod -Uri "https://api.github.com/repos/zhongyang219/TrafficMonitor/releases/latest"
    # Write-Host $release_info
    $url_traffic_monitor = $release_info.assets | Where-Object { $_.name -like "*TrafficMonitor_*_x64_Lite.zip" } | Select-Object -ExpandProperty browser_download_url
    Write-Host $url_traffic_monitor
    $output_traffic_monitor = "$env:Temp\TrafficMonitor_X_x64_Lite.zip"
    Invoke-WebRequest -Uri $url_traffic_monitor -OutFile $output_traffic_monitor
    $final_folder = "$env:ProgramFiles"
    Expand-Archive -Path $output_traffic_monitor -DestinationPath $final_folder
    if ($?) {
        Write-Host "TrafficMonitor installation successful!"
    }
    Destroy "TrafficMonitor"
    #Configure TrafficMonitor
    Write-Host "Configurating TrafficMonitor..."
    Copy-Item -Path ".\TrafMon\config.ini" -Destination (Join-Path $final_folder "\TrafficMonitor\config.ini") -Force
    Write-Host "Configuration successful!"
    Start-Process -FilePath "$env:ProgramFiles\TrafficMonitor\TrafficMonitor.exe"
}
function msedge {
    Destroy "msedge"
    Get-AppxPackage *MicrosoftEdge* | Remove-AppxPackage
    Get-Appxpackage -AllUsers | Where-Object { $_.Name -like "*MicrosoftEdge*" } | Select Name | Remove-AppxPackage
    Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -eq "<PackageFullName>" } | Remove-APPxPackage

}
function onedrive_remove {
    #OneDrive remove
    Write-Host "Removing OneDrive..."
    taskkill.exe /F /IM "OneDrive.exe"
    taskkill.exe /F /IM "explorer.exe"
    if (Test-Path "$env:SYSTEMROOT\System32\OneDriveSetup.exe") {
        & "$env:SYSTEMROOT\System32\OneDriveSetup.exe" /uninstall
    }
    if (Test-Path "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe") {
        & "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe" /uninstall
    }
    Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Recurse -Force -ErrorAction SilentlyContinue
    if ((Get-ChildItem "$env:USERPROFILE\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
        Remove-Item "$env:USERPROFILE\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSync" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Name "DisableMeteredNetworkFileSync" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Name "DisableLibrariesDefaultSaveToOneDrive" -Value 0
    New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
    New-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0
    New-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0
    Remove-PSDrive "HKCR"
    Remove-Item "$env:AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force -ErrorAction SilentlyContinue
    Write-Host "OneDrive Removed!"
    Start-Process "explorer.exe"
}
function glazewm_install {
    #GlazeWM installation
    Write-Host "Downloading GlazeWM..."
    $release_info = Invoke-RestMethod -Uri "https://api.github.com/repos/glzr-io/glazewm/releases/latest"
    $url_glazewm = $release_info.assets | Where-Object { $_.name -like "glazewm-v*.exe" } | Select-Object -ExpandProperty browser_download_url
    if ($url_glazewm) {
        $output_glazewm = "$env:Temp\GlazeWM_x64.exe"
        Invoke-WebRequest -Uri $url_glazewm -OutFile $output_glazewm
        if (Test-Path $output_glazewm) {
            Start-Process -FilePath $output_glazewm
        } else {
            Write-Host "Failed to download GlazeWM installer."
        }
    } else {
        Write-Host "Failed to retrieve GlazeWM download URL."
    }
    if (!(Test-Path "$startup_folder\GlazeWM_x64.exe")) {
        Write-Host "GlazeWM installation successful!"
    }
    else {
        Write-Host "GlazeWM installation failed!"
    }
}
function glazewm_config {
    Write-Host "Configurating GlazeWM & Zebar..."
    $registry_path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $glzr_conf_directory = "$env:UserProfile\Desktop\glzr"
    $glaze_dir = "$env:ProgramFiles\glzr.io\GlazeWM\glazewm.exe"
    git clone https://github.com/iAttaquer/.glzr.git $glzr_conf_directory
    if (!$?) {
        Write-Host "Failed to clone GlazeWM configuration!"
    }
    Set-ItemProperty -Path $registry_path -Name "GlazeWM" -Value $glaze_dir
    if ($?) {
        Write-Host "Added GlazeWM to startup!"
    }
}
function zebar_install {
    #Zebar installation
    Write-Host "Downloading Zebar..."
    $release_info = Invoke-RestMethod -Uri "https://api.github.com/repos/glzr-io/zebar/releases/latest"
    $url_zebar = $release_info.assets | Where-Object { $_.name -like "Zebar_x64*.msi" } | Select-Object -ExpandProperty browser_download_url
    Write-Host $url_zebar
    $output_zebar = "$env:Temp\Zebar_x64.msi"
    Invoke-WebRequest -Uri $url_zebar -OutFile $output_zebar
    Start-Process msiexec.exe -ArgumentList "/i $output_zebar /quiet /norestart" -Wait
    Remove-Item $output_zebar
    $zebar_istallation = "$env:ProgramFiles\Zebar\Zebar.exe"
    if (IsInstalled "\Zebar\Zebar.exe") {
        Write-Host "Zebar installation successful!"
        #Configure Zebar
        # Write-Host "Configurating Zebar..."
        # $zebar_config = "$env:USERPROFILE\.glzr\zebar"
        # if (!(Test-Path $zebar_config)) {
        #     New-Item -Path $zebar_config -ItemType Directory -Force
        # }
        # Copy-Item -Path ".\Zebar\config.yaml" -Destination $zebar_config -Force
        # $start_bat = "$env:ProgramFiles\Zebar\resources\start.bat"
        # $startup_folder = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
        # Copy-Item -Path $start_bat -Destination $startup_folder -Force
        # Write-Host "Configuration successful!"
        # Start-Process -FilePath $start_bat
    }
    else {
        Write-Host "Zebar installation failed!"
    }
}
function powerShell_install {
    #Windows Terminal installation
    Write-Host "PowerShell installation..."
    winget install Microsoft.WindowsTerminal
    if ($?) {
        Write-Host "Windows Terminal installation successful!"
    }
    winget install Microsoft.PowerShell
    if ($?) {
        Write-Host "PowerShell installation successful!"
    }
    winget install JanDeDobbeleer.OhMyPosh -s winget
    #Configure Windows Terminal
    Write-Host "Configurating Terminals..."
    $powershell_profile = "$env:USERPROFILE\Documents\PowerShell"
    if (!(Test-Path $powershell_profile)) {
        New-Item -Path $powershell_profile -ItemType Directory -Force
    }
    Copy-Item -Path ".\PowerShell\Microsoft.PowerShell_profile.ps1" -Destination $powershell_profile -Force
    Copy-Item -Path ".\PowerShell\myprofile3.omp.json" -Destination $powershell_profile -Force
    Write-Host "Configuration successful!"
}
function menu{
    Clear-Host
    Write-Host "Please select the software you want to install:"
    Start-Sleep -Milliseconds 10
    Write-Host "[1] Winget"
    Start-Sleep -Milliseconds 10
    Write-Host "[2] System Informer"
    Start-Sleep -Milliseconds 10
    Write-Host "[3] MemReduct"
    Start-Sleep -Milliseconds 10
    Write-Host "[4] Universal x86 Tuning Utility"
    Start-Sleep -Milliseconds 10
    Write-Host "[5] Traffic Monitor"
    Start-Sleep -Milliseconds 10
    Write-Host "[6] GlazeWM with Zebar              [9] Config for GlazeWM & Zebar"
    Start-Sleep -Milliseconds 10
    Write-Host "[7] Zebar"
    Start-Sleep -Milliseconds 10
    Write-Host "[8] PowerShell"
    Start-Sleep -Milliseconds 10
    Write-Host "[Q] Exit"
}
function main{
    Clear-Host
    Write-Host "    ░█████╗░████████╗████████╗░█████╗░░██████╗░██╗░░░██╗███████╗██████╗░"
    Start-Sleep -Milliseconds 10
    Write-Host "    ██╔══██╗╚══██╔══╝╚══██╔══╝██╔══██╗██╔═══██╗██║░░░██║██╔════╝██╔══██╗"
    Start-Sleep -Milliseconds 10
    Write-Host "    ███████║░░░██║░░░░░░██║░░░███████║██║██╗██║██║░░░██║█████╗░░██████╔╝"
    Start-Sleep -Milliseconds 10
    Write-Host "    ██╔══██║░░░██║░░░░░░██║░░░██╔══██║╚██████╔╝██║░░░██║██╔══╝░░██╔══██╗"
    Start-Sleep -Milliseconds 10
    Write-Host "    ██║░░██║░░░██║░░░░░░██║░░░██║░░██║░╚═██╔═╝░╚██████╔╝███████╗██║░░██║"
    Start-Sleep -Milliseconds 10
    Write-Host "    ╚═╝░░╚═╝░░░╚═╝░░░░░░╚═╝░░░╚═╝░░╚═╝░░░╚═╝░░░░╚═════╝░╚══════╝╚═╝░░╚═╝"
    Start-Sleep -Milliseconds 10
    Write-Host ""
    Write-Host "    ░██╗░░░░░░░██╗██╗███╗░░██╗██████╗░░█████╗░░██╗░░░░░░░██╗░██████╗"
    Start-Sleep -Milliseconds 10
    Write-Host "    ░██║░░██╗░░██║██║████╗░██║██╔══██╗██╔══██╗░██║░░██╗░░██║██╔════╝"
    Start-Sleep -Milliseconds 10
    Write-Host "    ░╚██╗████╗██╔╝██║██╔██╗██║██║░░██║██║░░██║░╚██╗████╗██╔╝╚█████╗░"
    Start-Sleep -Milliseconds 10
    Write-Host "    ░░████╔═████║░██║██║╚████║██║░░██║██║░░██║░░████╔═████║░░╚═══██╗"
    Start-Sleep -Milliseconds 10
    Write-Host "    ░░╚██╔╝░╚██╔╝░██║██║░╚███║██████╔╝╚█████╔╝░░╚██╔╝░╚██╔╝░██████╔╝"
    Start-Sleep -Milliseconds 10
    Write-Host "    ░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░░╚════╝░░░░╚═╝░░░╚═╝░░╚═════╝░"
    Start-Sleep -Milliseconds 10
    Write-Host ""
    Write-Host "    ██████╗░░█████╗░████████╗███████╗██╗██╗░░░░░███████╗░██████╗"
    Start-Sleep -Milliseconds 10
    Write-Host "    ██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║██║░░░░░██╔════╝██╔════╝"
    Start-Sleep -Milliseconds 10
    Write-Host "    ██║░░██║██║░░██║░░░██║░░░█████╗░░██║██║░░░░░█████╗░░╚█████╗░"
    Start-Sleep -Milliseconds 10
    Write-Host "    ██║░░██║██║░░██║░░░██║░░░██╔══╝░░██║██║░░░░░██╔══╝░░░╚═══██╗"
    Start-Sleep -Milliseconds 10
    Write-Host "    ██████╔╝╚█████╔╝░░░██║░░░██║░░░░░██║███████╗███████╗██████╔╝"
    Start-Sleep -Milliseconds 10
    Write-Host "    ╚═════╝░░╚════╝░░░░╚═╝░░░╚═╝░░░░░╚═╝╚══════╝╚══════╝╚═════╝░"
    Start-Sleep -Milliseconds 10
    pause
    while ($true){
        menu
        $option = Read-Host
        switch ($option) {
            "1" {
                winget_install
                pause
                break
            }
            '2' {
                sys_inf_install
                pause
                break
            }
            '3' {
                memreduct_install
                pause
                break
            }
            '4' {
                uxtu_install
                pause
                break
            }
            '5' {

                traffic_monitor_install
                pause
                break
            }
            '6' {
                glazewm_install
                pause
                break
            }
            '7' {
                zebar_install
                pause
                break
            }
            '8' {
                powerShell_install
                pause
                break
            }
            '9' {
                glazewm_config
                pause
                break
            }
            'q' {
                exit
            }
        }
    }
}
# winget_install
# memreduct_install
# sys_inf_install
# uxtu_install
# traffic_monitor_install
# msedge
# onedrive_remove
# glazewm_install
# zebar_install
# powerShell_install
main