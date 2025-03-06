# Check if the script is running as Administrator
$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
$AdminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

if (-Not $Principal.IsInRole($AdminRole)) {
    Write-Host "Requesting Administrator Privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Now running as Administrator, continue with installation
Write-Host "Installing RMM Agent as Admin..."
$logFile = Join-Path ([System.IO.Path]::GetTempPath()) "level_msiexec_install.log"
$args = "LEVEL_API_KEY=J34zUcEJX4T1GEgpWrwF5vPY LEVEL_LOGS=$logFile"
$tempFile = Join-Path ([System.IO.Path]::GetTempPath()) "level.msi"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://downloads.level.io/level.msi" -OutFile $tempFile

Start-Process msiexec.exe -Wait -ArgumentList "/i `"$tempFile`" $args /qn"
Get-Content -Path $logFile
