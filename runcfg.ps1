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
    $latestVersion = $tags[0].name
    $url_system_informer = "https://github.com/winsiderss/si-builds/releases/download/$latestVersion/systeminformer-$latestVersion-setup.exe"
    $output_si = "$env:TEMP\systeminformer-$latestVersion-setup.exe"
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
    $url_glazewm = $release_info.assets | Where-Object { $_.name -like "GlazeWM_x64_*.exe" } | Select-Object -ExpandProperty browser_download_url
    Write-Host $url_glazewm
    $output_glazewm = "$env:Temp\GlazeWM_x64.exe"
    Invoke-WebRequest -Uri $url_glazewm -OutFile $output_glazewm
    $startup_folder = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    Move-Item -Path $output_glazewm -Destination $startup_folder -Force
    if (IsInstalled "$startup_folder\GlazeWM_x64.exe") {
        Write-Host "GlazeWM installation successful!"
        #Configure GlazeWM
        Write-Host "Configurating GlazeWM..."
        $glaze_config = "$env:USERPROFILE\.glaze-wm"
        if (!(Test-Path $glaze_config)) {
            New-Item -Path $glaze_config -ItemType Directory -Force
        }
        Copy-Item -Path ".\GlazeWM\config.yaml" -Destination $glaze_config -Force
        Write-Host "Configuration successful!"
        Start-Process -FilePath "$startup_folder\GlazeWM_x64.exe"
    }
    else {
        Write-Host "GlazeWM installation failed!"
    }
}
function zebar_install {

}

# winget_install
# memreduct_install
# sys_inf_install
# uxtu_install
# traffic_monitor_install
# msedge
# onedrive_remove
glazewm_install
