$ErrorActionPreference = 'Stop'

$scriptPath = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }
$root = if ($PSScriptRoot) { $PSScriptRoot } else { [System.IO.Path]::GetDirectoryName($scriptPath) }
$source = Join-Path $root 'trackedit.package.default-fixed'



$target = 'C:\Program Files\Fender\Studio Pro 8\Scripts\trackedit.package'



$backupDir = Join-Path $root 'backups'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', ('"{0}"' -f $scriptPath)
    )
    exit
}

if (-not (Test-Path -LiteralPath $source)) {
    throw "Patched file not found: $source"
}

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = Join-Path $backupDir "trackedit.package.before-admin-install-$timestamp"

Copy-Item -LiteralPath $target -Destination $backup -Force
Copy-Item -LiteralPath $source -Destination $target -Force

Write-Host "Backup created: $backup"
Write-Host "Installed patched package: $target"
