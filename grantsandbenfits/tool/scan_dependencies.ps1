$ErrorActionPreference = 'Continue'
Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host 'Checking package versions...'
flutter pub outdated

if (Get-Command osv-scanner -ErrorAction SilentlyContinue) {
  Write-Host 'Scanning pubspec.lock...'
  osv-scanner --lockfile=pubspec.lock
} else {
  Write-Host 'osv-scanner is not installed. Install it to scan pubspec.lock against the OSV database.'
}
