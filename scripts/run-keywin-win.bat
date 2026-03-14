@echo off
setlocal

set "BUILD_MODE=%~1"
set "PRESET=windows-release-min"
set "DESKFLOW_BUILD_MINIMAL=true"

if /I "%BUILD_MODE%"=="GUI" (
  set "PRESET=windows-release"
  set "DESKFLOW_BUILD_MINIMAL=false"
)

set "MSVC_TOOLS_DIR="
for /d %%D in ("D:\keywin-tools\vs-buildtools\VC\Tools\MSVC\*") do set "MSVC_TOOLS_DIR=%%~fD"

if not defined MSVC_TOOLS_DIR (
  echo MSVC tools directory not found under D:\keywin-tools\vs-buildtools
  exit /b 1
)

call D:\keywin-tools\vs-buildtools\VC\Auxiliary\Build\vcvars64.bat
if errorlevel 1 exit /b 1

rem Avoid linker lock errors when previously launched binaries are still running.
taskkill /F /IM keywin.exe >nul 2>&1
taskkill /F /IM keywin-daemon.exe >nul 2>&1
taskkill /F /IM keywin-server.exe >nul 2>&1
taskkill /F /IM keywin-client.exe >nul 2>&1
taskkill /F /IM keywin-legacy.exe >nul 2>&1

set "PATH=%MSVC_TOOLS_DIR%\bin\Hostx64\x64;C:\Program Files\CMake\bin;%LOCALAPPDATA%\Microsoft\WinGet\Packages\Ninja-build.Ninja_Microsoft.Winget.Source_8wekyb3d8bbwe;%PATH%"
set "VCPKG_ROOT=D:\keywin-tools\vcpkg"
set "VCPKG_DEFAULT_TRIPLET=x64-windows-release"
set "VCPKG_DEFAULT_HOST_TRIPLET=x64-windows-release"
set "DESKFLOW_BUILD_TESTS=false"

if exist build\CMakeCache.txt del /f /q build\CMakeCache.txt

"C:\Program Files\CMake\bin\cmake.exe" -S . -B build --preset %PRESET% -DCMAKE_C_COMPILER="%MSVC_TOOLS_DIR%\bin\Hostx64\x64\cl.exe" -DCMAKE_CXX_COMPILER="%MSVC_TOOLS_DIR%\bin\Hostx64\x64\cl.exe" -DVCPKG_TARGET_TRIPLET=x64-windows-release -DVCPKG_HOST_TRIPLET=x64-windows-release -DVCPKG_BUILD_TYPE=release -DCMAKE_TOOLCHAIN_FILE=D:/keywin-tools/vcpkg/scripts/buildsystems/vcpkg.cmake -DCMAKE_MAKE_PROGRAM="%LOCALAPPDATA%\Microsoft\WinGet\Packages\Ninja-build.Ninja_Microsoft.Winget.Source_8wekyb3d8bbwe\ninja.exe"
if errorlevel 1 exit /b 1

"C:\Program Files\CMake\bin\cmake.exe" --build build --config Release
if errorlevel 1 exit /b 1

if /I "%BUILD_MODE%"=="GUI" (
  if exist build\bin\keywin.exe (
    set "QT_ROOT=build\vcpkg_installed\x64-windows-release\Qt6"

    if exist "%QT_ROOT%\plugins\platforms\qwindows.dll" (
      if not exist build\bin\platforms mkdir build\bin\platforms
      copy /Y "%QT_ROOT%\plugins\platforms\*.dll" build\bin\platforms\ >nul
    )

    if exist "%QT_ROOT%\plugins\networkinformation" (
      if not exist build\bin\networkinformation mkdir build\bin\networkinformation
      copy /Y "%QT_ROOT%\plugins\networkinformation\*.dll" build\bin\networkinformation\ >nul
    )

    if exist "%QT_ROOT%\plugins\tls" (
      if not exist build\bin\tls mkdir build\bin\tls
      copy /Y "%QT_ROOT%\plugins\tls\*.dll" build\bin\tls\ >nul
    )

    if exist "%QT_ROOT%\plugins\styles" (
      if not exist build\bin\styles mkdir build\bin\styles
      copy /Y "%QT_ROOT%\plugins\styles\*.dll" build\bin\styles\ >nul
    )

    if exist "%QT_ROOT%\plugins\imageformats" (
      if not exist build\bin\imageformats mkdir build\bin\imageformats
      copy /Y "%QT_ROOT%\plugins\imageformats\*.dll" build\bin\imageformats\ >nul
    )
  )
)

if exist build\bin-copy\keywin.exe (
  start "" build\bin-copy\keywin.exe
  exit /b 0
)

if exist build\bin\keywin.exe (
  start "" build\bin\keywin.exe
  exit /b 0
)

if exist build\bin\keywin-server.exe (
  start "" build\bin\keywin-server.exe
  exit /b 0
)

if exist build\bin\keywin-client.exe (
  start "" build\bin\keywin-client.exe
  exit /b 0
)

if exist build\bin\synergy-server.exe (
  start "" build\bin\synergy-server.exe
  exit /b 0
)

if exist build\bin\synergy-client.exe (
  start "" build\bin\synergy-client.exe
  exit /b 0
)

if exist build\bin\synergy-legacy.exe (
  start "" build\bin\synergy-legacy.exe
  exit /b 0
)

echo No launchable binary found after build
exit /b 1
