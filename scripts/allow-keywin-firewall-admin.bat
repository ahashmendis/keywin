@echo off
setlocal

set SCRIPT_DIR=%~dp0
set PS_SCRIPT=%SCRIPT_DIR%allow-keywin-firewall.ps1

if not exist "%PS_SCRIPT%" (
  echo Missing script: %PS_SCRIPT%
  exit /b 1
)

echo Requesting Administrator permission to add KeyWin firewall rules...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%PS_SCRIPT%""'"

if errorlevel 1 (
  echo Failed to request elevation.
  exit /b 1
)

echo If prompted by Windows UAC, click Yes.
echo Done.
exit /b 0
