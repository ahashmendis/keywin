@echo off
REM Stop all KeyWin Windows services

echo Stopping KeyWin services...
taskkill /F /IM keywin-daemon.exe >nul 2>&1
taskkill /F /IM keywin-server.exe >nul 2>&1
taskkill /F /IM keywin-client.exe >nul 2>&1
taskkill /F /IM keywin.exe >nul 2>&1

echo All KeyWin services stopped.
exit /b 0
