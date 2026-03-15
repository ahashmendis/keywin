@echo off
REM KeyWin Windows Multi-Component Launcher
REM Starts daemon, server, client in background and GUI in foreground

setlocal enabledelayedexpansion

REM Get script directory and navigate to build\bin
set SCRIPT_DIR=%~dp0
set BUILD_BIN=%SCRIPT_DIR%..\build\bin

REM Check if build directory exists
if not exist "%BUILD_BIN%" (
    echo Error: Build directory not found at %BUILD_BIN%
    echo Please build KeyWin first using: .\scripts\run-keywin-win.bat GUI
    exit /b 1
)

cd /d "%BUILD_BIN%"

REM Function to check if process is running
setlocal enabledelayedexpansion

REM Kill any existing KeyWin processes for clean start
taskkill /F /IM keywin-daemon.exe >nul 2>&1
taskkill /F /IM keywin-server.exe >nul 2>&1
taskkill /F /IM keywin-client.exe >nul 2>&1
taskkill /F /IM keywin.exe >nul 2>&1

REM Give processes time to exit
timeout /t 1 /nobreak >nul

echo.
echo ========================================
echo KeyWin Windows Multi-Component Launcher
echo ========================================
echo.

REM Start daemon in foreground mode so it stays alive when not running as a Windows service.
echo Starting daemon...
start /B /LOW "KeyWin Daemon" keywin-daemon.exe --foreground
if errorlevel 1 (
    echo Warning: Daemon may have issues, continuing...
)

REM Give daemon more time to fully initialize IPC socket before GUI tries to connect
timeout /t 12 /nobreak >nul

REM Keep startup deterministic: launch daemon first, then GUI.
REM Server/client are started by user action or GUI config via daemon IPC.

REM Show status
echo.
echo All background services started. Launching GUI...
echo (To stop all services, run scripts\stop-keywin-all-win.bat or close this window)
echo.

REM Start GUI in foreground (user sees this)
keywin.exe

REM GUI has closed, cleanup
echo.
echo GUI closed. Shutting down background services...

REM Kill all KeyWin processes
taskkill /F /IM keywin-daemon.exe >nul 2>&1
taskkill /F /IM keywin-server.exe >nul 2>&1
taskkill /F /IM keywin-client.exe >nul 2>&1

echo All services stopped.
exit /b 0
