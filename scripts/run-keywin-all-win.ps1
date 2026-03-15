# KeyWin Windows Multi-Component Launcher (PowerShell)
# Starts daemon, server, client in background and GUI in foreground

param()

$ErrorActionPreference = "SilentlyContinue"

# Navigate to build\bin directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildBin = Join-Path $scriptDir "..\build\bin"

if (-not (Test-Path $buildBin)) {
    Write-Host "Error: Build directory not found at $buildBin" -ForegroundColor Red
    Write-Host "Please build KeyWin first"
    exit 1
}

Push-Location $buildBin

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "KeyWin Windows Multi-Component Launcher" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Kill any existing KeyWin processes
Write-Host "Cleaning up old processes..." -ForegroundColor Yellow
Get-Process keywin* -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Verify daemon executable exists
if (-not (Test-Path ".\keywin-daemon.exe")) {
    Write-Host "Error: keywin-daemon.exe not found in $buildBin" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Start daemon in foreground mode so it stays alive when not running as a Windows service.
Write-Host "Starting daemon..." -ForegroundColor Green
$daemonProcess = Start-Process -FilePath ".\keywin-daemon.exe" -ArgumentList @("--foreground") -PassThru -WindowStyle Hidden -ErrorAction Stop
Write-Host "Daemon started (PID: $($daemonProcess.Id))" -ForegroundColor Green

# Give daemon time to initialize IPC socket
Write-Host "Waiting for daemon to initialize (12 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 12

# Verify daemon is still running
if ($daemonProcess.HasExited) {
    Write-Host "Error: Daemon crashed or exited prematurely" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "Daemon is running" -ForegroundColor Green

# Keep startup minimal and deterministic: daemon + GUI only.
# Server/client are launched by user action/config from the GUI via daemon IPC.

# Launch GUI
Write-Host ""
Write-Host "Launching GUI..." -ForegroundColor Cyan
Write-Host "(All background services are running. Close the GUI window to stop all services.)" -ForegroundColor Gray
Write-Host ""

$guiProcess = Start-Process -FilePath ".\keywin.exe" -PassThru -Wait -ErrorAction Stop

# GUI has closed, clean up
Write-Host ""
Write-Host "GUI closed. Shutting down background services..." -ForegroundColor Yellow
Get-Process keywin* -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

Write-Host "All services stopped." -ForegroundColor Green
Pop-Location
