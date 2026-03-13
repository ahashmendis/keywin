@echo off
setlocal

call D:\keywin-tools\vs-buildtools\Common7\Tools\VsDevCmd.bat -arch=x64 -host_arch=x64
if errorlevel 1 exit /b 1

set "PATH=C:\Program Files\CMake\bin;%LOCALAPPDATA%\Microsoft\WinGet\Packages\Ninja-build.Ninja_Microsoft.Winget.Source_8wekyb3d8bbwe;%PATH%"
set "VCPKG_ROOT=D:\keywin-tools\vcpkg"

if exist build\CMakeCache.txt del /f /q build\CMakeCache.txt

"C:\Program Files\CMake\bin\cmake.exe" -S . -B build --preset windows-release-min -DCMAKE_TOOLCHAIN_FILE=D:/keywin-tools/vcpkg/scripts/buildsystems/vcpkg.cmake -DCMAKE_MAKE_PROGRAM="%LOCALAPPDATA%\Microsoft\WinGet\Packages\Ninja-build.Ninja_Microsoft.Winget.Source_8wekyb3d8bbwe\ninja.exe"
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

echo keywin.exe not found after build
exit /b 1
