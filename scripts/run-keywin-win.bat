@echo off
setlocal

set "MSVC_TOOLS_DIR="
for /d %%D in ("D:\keywin-tools\vs-buildtools\VC\Tools\MSVC\*") do set "MSVC_TOOLS_DIR=%%~fD"

if not defined MSVC_TOOLS_DIR (
  echo MSVC tools directory not found under D:\keywin-tools\vs-buildtools
  exit /b 1
)

call D:\keywin-tools\vs-buildtools\VC\Auxiliary\Build\vcvars64.bat
if errorlevel 1 exit /b 1

set "PATH=%MSVC_TOOLS_DIR%\bin\Hostx64\x64;C:\Program Files\CMake\bin;%LOCALAPPDATA%\Microsoft\WinGet\Packages\Ninja-build.Ninja_Microsoft.Winget.Source_8wekyb3d8bbwe;%PATH%"
set "VCPKG_ROOT=D:\keywin-tools\vcpkg"
set "VCPKG_DEFAULT_TRIPLET=x64-windows-release"
set "VCPKG_DEFAULT_HOST_TRIPLET=x64-windows"
set "DESKFLOW_BUILD_MINIMAL=true"
set "DESKFLOW_BUILD_TESTS=false"

if exist build\CMakeCache.txt del /f /q build\CMakeCache.txt

"C:\Program Files\CMake\bin\cmake.exe" -S . -B build --preset windows-release-min -DCMAKE_C_COMPILER="%MSVC_TOOLS_DIR%\bin\Hostx64\x64\cl.exe" -DCMAKE_CXX_COMPILER="%MSVC_TOOLS_DIR%\bin\Hostx64\x64\cl.exe" -DVCPKG_TARGET_TRIPLET=x64-windows-release -DVCPKG_BUILD_TYPE=release -DCMAKE_TOOLCHAIN_FILE=D:/keywin-tools/vcpkg/scripts/buildsystems/vcpkg.cmake -DCMAKE_MAKE_PROGRAM="%LOCALAPPDATA%\Microsoft\WinGet\Packages\Ninja-build.Ninja_Microsoft.Winget.Source_8wekyb3d8bbwe\ninja.exe"
if errorlevel 1 exit /b 1

"C:\Program Files\CMake\bin\cmake.exe" --build build --config Release
if errorlevel 1 exit /b 1

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
