@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul 2>&1
title Nano Every MuxTO Build Lab v6

rem ================================================================
rem Nano Every MuxTO Build Lab v6
rem BUILD ONLY - NEVER OPENS A COM PORT AND NEVER FLASHES THE BOARD.
rem
rem Dead MattairTech Boards Manager dependency removed.
rem Historical GCC/CMSIS tools are checksummed; CMSIS-Atmel is pinned to an exact Git commit.
rem Embedded PowerShell avoids literal exclamation marks because delayed expansion is enabled.
rem ================================================================

goto :INIT

:INIT
set "ROOT=%~dp0"
set "LAB=%ROOT%NanoEvery_USB_Lab"
set "CLI_DIR=%LAB%\cli"
set "CLI=%CLI_DIR%\arduino-cli.exe"
set "CONFIG=%LAB%\arduino-cli.yaml"
set "DATA=%LAB%\arduino-data"
set "DOWNLOADS=%LAB%\arduino-downloads"
set "SKETCHBOOK=%LAB%\sketchbook"
set "HARDWARE=%SKETCHBOOK%\hardware\arduino\samd"
set "SRC=%LAB%\MuxTO"
set "OUT=%LAB%\build_stock"
set "CACHE=%LAB%\cache"
set "TC=%LAB%\toolchain"
set "GCCDIR=%TC%\gcc-4.8.3"
set "CMSISDIR=%TC%\cmsis-4.5.0"
set "ATMELDIR=%TC%\cmsis-atmel-github"
set "LOG=%LAB%\build_stock.log"

rem Exact source revisions from the engineering dossier.
set "SAMD_COMMIT=ff3cf67b4bee9d6d4ba732423eb3cb3db1cb0994"
set "MEGA_COMMIT=e8edb4ef2e8ab5c98544c3884a653f0b9c1318dc"

set "SAMD_ZIP=https://github.com/arduino/ArduinoCore-samd/archive/%SAMD_COMMIT%.zip"
set "MEGA_ZIP=https://github.com/arduino/ArduinoCore-megaavr/archive/%MEGA_COMMIT%.zip"

rem Historical Arduino-hosted compiler.
set "GCC_URL=https://downloads.arduino.cc/gcc-arm-none-eabi-4.8.3-2014q1-windows.tar.gz"
set "GCC_SHA=fd8c111c861144f932728e00abd3f7d1107e186eb9cd6083a54c7236ea78b7c2"

rem Historical Arduino CMSIS package.
set "CMSIS_URL=https://downloads.arduino.cc/CMSIS-4.5.0.tar.bz2"
set "CMSIS_SHA=cd8f7eae9fc7c8b4a1b5e40b89b9666d33953b47d3d2eb81844f5af729fa224d"

rem MattairTech CMSIS-Atmel source tree, pinned to an exact commit.
set "ATMEL_COMMIT=3c2958f87a88a4f5faab4f4a93a474bcdbf83941"
set "ATMEL_GITHUB_URL=https://github.com/mattairtech/CMSIS-Atmel/archive/%ATMEL_COMMIT%.zip"

set "FQBN=arduino:samd:muxto"

for %%D in ("%LAB%" "%CLI_DIR%" "%DATA%" "%DOWNLOADS%" "%SKETCHBOOK%" "%CACHE%" "%TC%") do (
  if not exist "%%~D" mkdir "%%~D" >nul 2>&1
)

goto :MENU

:MENU
cls
echo ================================================================
echo        NANO EVERY MUXTO BUILD LAB v6
echo ================================================================
echo.
echo BUILD ONLY - COM ports are never opened by this script.
echo.
echo [1] SETUP preserved historical toolchain + exact MuxTO sources
echo [2] BUILD stock Arduino MuxTO ^(CDC^)
echo [3] SHOW toolchain / board status
echo [4] SHOW last build artifacts and size
echo [5] Open lab folder
echo [D] Diagnostics
echo [Q] Quit
echo.
set "C="
set /p "C=Choose: "

if /I "!C!"=="1" goto :SETUP
if /I "!C!"=="2" goto :BUILD
if /I "!C!"=="3" goto :STATUS
if /I "!C!"=="4" goto :REPORT
if /I "!C!"=="5" start "" "%LAB%" & goto :MENU
if /I "!C!"=="D" goto :DIAG
if /I "!C!"=="Q" goto :END
goto :MENU

:SETUP
cls
echo === PRESERVED BUILD ENVIRONMENT ===
echo.
echo This downloads compiler/source files only.
echo It DOES NOT communicate with the Nano Every.
echo.

where powershell.exe >nul 2>&1 || (
  echo ERROR: PowerShell is required.
  goto :PAUSE
)
where curl.exe >nul 2>&1 || (
  echo ERROR: curl.exe is required.
  goto :PAUSE
)
where tar.exe >nul 2>&1 || (
  echo ERROR: Windows tar.exe is required.
  goto :PAUSE
)

call :FindOrInstallCLI
if errorlevel 1 goto :PAUSE

echo.
echo Arduino CLI:
"!CLI!" version

echo.
echo Creating isolated config with NO MattairTech package URL...
"!CLI!" config init --dest-file "%CONFIG%" --overwrite >nul 2>&1
if errorlevel 1 goto :FAIL
"!CLI!" config set directories.data "%DATA%" --config-file "%CONFIG%" >nul
if errorlevel 1 goto :FAIL
"!CLI!" config set directories.downloads "%DOWNLOADS%" --config-file "%CONFIG%" >nul
if errorlevel 1 goto :FAIL
"!CLI!" config set directories.user "%SKETCHBOOK%" --config-file "%CONFIG%" >nul
if errorlevel 1 goto :FAIL

echo.
echo [1/5] Installing GCC ARM 4.8.3-2014q1...
call :InstallGCC
if errorlevel 1 goto :PAUSE

echo.
echo [2/5] Installing CMSIS 4.5.0...
call :InstallCMSIS
if errorlevel 1 goto :PAUSE

echo.
echo [3/5] Installing pinned MattairTech CMSIS-Atmel source...
call :InstallAtmel
if errorlevel 1 goto :PAUSE

echo.
echo [4/5] Installing exact ArduinoCore-samd commit...
call :InstallCore
if errorlevel 1 goto :PAUSE

echo.
echo [5/5] Installing exact MuxTO source...
call :InstallSource
if errorlevel 1 goto :PAUSE

call :WritePlatformLocal
if errorlevel 1 goto :PAUSE

echo.
echo Verifying MuxTO board definition...
"!CLI!" board listall --config-file "%CONFIG%" | findstr /I "MuxTO"
if errorlevel 1 (
  echo ERROR: MuxTO board was not detected.
  goto :PAUSE
)

echo.
echo ================================================================
echo SETUP COMPLETE.
echo ================================================================
echo Next choose option 2 to BUILD STOCK MuxTO.
goto :PAUSE

:BUILD
cls
echo === BUILD STOCK MuxTO ===
echo.
echo No board access. No flashing.
echo.
call :NeedSetup
if errorlevel 1 goto :PAUSE

if exist "%OUT%" rmdir /s /q "%OUT%"
mkdir "%OUT%" >nul 2>&1

echo FQBN:
echo   %FQBN%
echo.
echo Building...
echo.

"!CLI!" compile ^
  --config-file "%CONFIG%" ^
  --fqbn "%FQBN%" ^
  --output-dir "%OUT%" ^
  --verbose ^
  "%SRC%" >"%LOG%" 2>&1

set "RC=!ERRORLEVEL!"
type "%LOG%"

if not "!RC!"=="0" (
  echo.
  echo ================================================================
  echo BUILD FAILED - BOARD WAS NOT TOUCHED
  echo ================================================================
  echo Log:
  echo   %LOG%
  goto :PAUSE
)

set "BIN="
for /r "%OUT%" %%F in (*.bin) do if not defined BIN set "BIN=%%~fF"

if not defined BIN (
  echo ERROR: Compile succeeded but no .bin was found.
  goto :PAUSE
)

for %%F in ("!BIN!") do set "SIZE=%%~zF"
set /a FREE=12288-SIZE

echo.
echo ================================================================
echo STOCK BUILD SUCCESS
echo ================================================================
echo BIN:
echo   !BIN!
echo Size: !SIZE! bytes
echo Free against 12288-byte app region: !FREE! bytes
goto :PAUSE

:STATUS
cls
echo === STATUS ===
echo.
call :DiscoverPaths
echo CLI: !CLI!
echo GCC: !GCCEXE!
echo CMSIS root: !CMSISROOT!
echo CMSIS-Atmel root: !ATMELROOT!
echo Core: %HARDWARE%
echo Source: %SRC%
echo.
goto :PAUSE

:REPORT
cls
echo === LAST BUILD ===
echo.
if exist "%LOG%" echo Log: %LOG%
if exist "%OUT%" (
  for /r "%OUT%" %%F in (*.bin) do echo %%~fF  %%~zF bytes
) else (
  echo No build output folder yet.
)
goto :PAUSE

:DIAG
cls
echo === DIAGNOSTICS ===
echo.
where powershell.exe 2>nul
where curl.exe 2>nul
where tar.exe 2>nul
call :DiscoverPaths
echo.
echo CLI: !CLI!
echo GCC: !GCCEXE!
echo CMSIS: !CMSISROOT!
echo ATMEL: !ATMELROOT!
echo.
if exist "%LOG%" (
  echo Last build log tail:
  powershell.exe -NoProfile -Command "Get-Content -LiteralPath '%LOG%' -Tail 60"
)
goto :PAUSE

:FindOrInstallCLI
if exist "%CLI%" exit /b 0

set "IDECLI=%LOCALAPPDATA%\Programs\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe"
if exist "!IDECLI!" (
  copy /y "!IDECLI!" "%CLI%" >nul
  exit /b 0
)

set "Z=%CACHE%\arduino-cli.zip"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$h=@{'User-Agent'='NanoEvery-MuxTO-Lab'}; $r=Invoke-RestMethod -Headers $h -Uri 'https://api.github.com/repos/arduino/arduino-cli/releases/latest'; $a=$r.assets | Where-Object {$_.name -match 'Windows_64bit\.zip$'} | Select-Object -First 1; if($null -eq $a){exit 2}; Invoke-WebRequest -Headers $h -Uri $a.browser_download_url -OutFile '%CACHE%\arduino-cli.zip'"
if errorlevel 1 exit /b 1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "Expand-Archive -LiteralPath '%CACHE%\arduino-cli.zip' -DestinationPath '%CLI_DIR%' -Force"
if errorlevel 1 exit /b 1
if not exist "%CLI%" exit /b 1
exit /b 0

:InstallGCC
call :DiscoverPaths
if defined GCCEXE exit /b 0
set "A=%CACHE%\gcc-arm-none-eabi-4.8.3.tar.gz"
if not exist "!A!" curl.exe -L --fail --retry 3 -o "!A!" "%GCC_URL%"
if errorlevel 1 exit /b 1
call :VerifySHA "!A!" "%GCC_SHA%"
if errorlevel 1 exit /b 1
if exist "%GCCDIR%" rmdir /s /q "%GCCDIR%"
mkdir "%GCCDIR%" >nul 2>&1
tar.exe -xzf "!A!" -C "%GCCDIR%"
if errorlevel 1 exit /b 1
call :DiscoverPaths
if not defined GCCEXE exit /b 1
exit /b 0

:InstallCMSIS
call :DiscoverPaths
if defined CMSISROOT exit /b 0
set "A=%CACHE%\CMSIS-4.5.0.tar.bz2"
if not exist "!A!" curl.exe -L --fail --retry 3 -o "!A!" "%CMSIS_URL%"
if errorlevel 1 exit /b 1
call :VerifySHA "!A!" "%CMSIS_SHA%"
if errorlevel 1 exit /b 1
if exist "%CMSISDIR%" rmdir /s /q "%CMSISDIR%"
mkdir "%CMSISDIR%" >nul 2>&1
tar.exe -xjf "!A!" -C "%CMSISDIR%"
if errorlevel 1 exit /b 1
call :DiscoverPaths
if not defined CMSISROOT exit /b 1
exit /b 0

:InstallAtmel
call :DiscoverPaths
if defined ATMELROOT if exist "!ATMELROOT!\CMSIS\Device\ATMEL\sam.h" exit /b 0
set "Z=%CACHE%\CMSIS-Atmel-%ATMEL_COMMIT%.zip"
set "X=%CACHE%\cmsis_atmel_git_extract"
if not exist "!Z!" curl.exe -L --fail --retry 3 -o "!Z!" "%ATMEL_GITHUB_URL%"
if errorlevel 1 exit /b 1
if exist "!X!" rmdir /s /q "!X!"
mkdir "!X!" >nul 2>&1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "Expand-Archive -LiteralPath '!Z!' -DestinationPath '!X!' -Force"
if errorlevel 1 exit /b 1
if exist "%ATMELDIR%" rmdir /s /q "%ATMELDIR%"
mkdir "%ATMELDIR%" >nul 2>&1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$r=Get-ChildItem -LiteralPath '!X!' -Directory | Select-Object -First 1; if($null -eq $r){exit 2}; Copy-Item -Path ($r.FullName+'\*') -Destination '%ATMELDIR%' -Recurse -Force"
if errorlevel 1 exit /b 1
call :DiscoverPaths
if not defined ATMELROOT exit /b 1
exit /b 0

:InstallCore
set "A=%CACHE%\ArduinoCore-samd-%SAMD_COMMIT%.zip"
if not exist "!A!" curl.exe -L --fail --retry 3 -o "!A!" "%SAMD_ZIP%"
if errorlevel 1 exit /b 1
if exist "%HARDWARE%" rmdir /s /q "%HARDWARE%"
mkdir "%HARDWARE%" >nul 2>&1
set "X=%CACHE%\samd_core_extract"
if exist "!X!" rmdir /s /q "!X!"
mkdir "!X!" >nul 2>&1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "Expand-Archive -LiteralPath '!A!' -DestinationPath '!X!' -Force; $r=Get-ChildItem -LiteralPath '!X!' -Directory | Select-Object -First 1; Copy-Item -Path ($r.FullName+'\*') -Destination '%HARDWARE%' -Recurse -Force"
if errorlevel 1 exit /b 1
if not exist "%HARDWARE%\boards.txt" exit /b 1
exit /b 0

:InstallSource
set "A=%CACHE%\ArduinoCore-megaavr-%MEGA_COMMIT%.zip"
if not exist "!A!" curl.exe -L --fail --retry 3 -o "!A!" "%MEGA_ZIP%"
if errorlevel 1 exit /b 1
if exist "%SRC%" rmdir /s /q "%SRC%"
mkdir "%SRC%" >nul 2>&1
set "X=%CACHE%\mega_extract"
if exist "!X!" rmdir /s /q "!X!"
mkdir "!X!" >nul 2>&1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "Expand-Archive -LiteralPath '!A!' -DestinationPath '!X!' -Force; $r=Get-ChildItem -LiteralPath '!X!' -Directory | Select-Object -First 1; Copy-Item -Path ($r.FullName+'\firmwares\MuxTO\*') -Destination '%SRC%' -Recurse -Force"
if errorlevel 1 exit /b 1
if not exist "%SRC%\MuxTO.ino" exit /b 1
exit /b 0

:DiscoverPaths
set "GCCEXE="
set "GCCROOT="
set "CMSISROOT="
set "ATMELROOT="
if exist "%GCCDIR%" for /r "%GCCDIR%" %%F in (arm-none-eabi-gcc.exe) do if not defined GCCEXE (
  set "GCCEXE=%%~fF"
  for %%B in ("%%~dpF..") do set "GCCROOT=%%~fB"
)
if exist "%CMSISDIR%" for /f "delims=" %%F in ('powershell.exe -NoProfile -Command "$f=Get-ChildItem -LiteralPath '%CMSISDIR%' -Filter core_cm0plus.h -File -Recurse -ErrorAction SilentlyContinue ^| Where-Object {$_.FullName -match '\\CMSIS\\Include\\core_cm0plus\.h$'} ^| Select-Object -First 1; if($f){Split-Path $f.DirectoryName -Parent}"') do if not defined CMSISROOT set "CMSISROOT=%%F"
if exist "%ATMELDIR%" for /f "delims=" %%F in ('powershell.exe -NoProfile -Command "$d=Get-ChildItem -LiteralPath '%ATMELDIR%' -Directory -Recurse -ErrorAction SilentlyContinue ^| Where-Object {$_.Name -eq 'ATMEL' -and $_.Parent.Name -eq 'Device' -and $_.Parent.Parent.Name -eq 'CMSIS' -and (Test-Path (Join-Path $_.FullName 'sam.h'))} ^| Select-Object -First 1; if($d){$d.Parent.Parent.Parent.FullName}"') do if not defined ATMELROOT set "ATMELROOT=%%F"
exit /b 0

:WritePlatformLocal
call :DiscoverPaths
if not defined GCCROOT exit /b 1
if not defined CMSISROOT exit /b 1
if not defined ATMELROOT exit /b 1
set "PL=%HARDWARE%\platform.local.txt"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$gcc='%GCCROOT%'.Replace('\','/'); $cms='%CMSISROOT%'.Replace('\','/'); $atm='%ATMELROOT%'.Replace('\','/'); $x=@(); $x += 'compiler.path='+$gcc+'/bin/'; $inc='\"-I'+$cms+'/Include/\" \"-I'+$atm+'/CMSIS/Device/ATMEL/\" -D{build.floatconfig} -D{build.timerconfig} -D{build.buildconfig} -D{build.clockconfig} -D{build.usbcom} -D{build.serialcom_uart} -D{build.serialcom_wire} -D{build.serialcom_spi} -D{build.bootloader_size}'; $x += 'compiler.c.extra_flags='+$inc; $x += 'compiler.cpp.extra_flags='+$inc; Set-Content -LiteralPath '%PL%' -Value $x -Encoding ASCII"
if errorlevel 1 exit /b 1
exit /b 0

:NeedSetup
if not exist "%CLI%" exit /b 1
if not exist "%CONFIG%" exit /b 1
if not exist "%SRC%\MuxTO.ino" exit /b 1
if not exist "%HARDWARE%\platform.local.txt" exit /b 1
call :DiscoverPaths
if not defined GCCEXE exit /b 1
exit /b 0

:VerifySHA
set "VF=%~1"
set "VS=%~2"
for /f "delims=" %%H in ('powershell.exe -NoProfile -Command "(Get-FileHash -Algorithm SHA256 -LiteralPath '%VF%').Hash.ToLowerInvariant()"') do set "GOT=%%H"
if /I not "!GOT!"=="%VS%" (
  echo SHA-256 mismatch for %VF%
  echo Expected: %VS%
  echo Got     : !GOT!
  exit /b 1
)
exit /b 0

:FAIL
echo.
echo ERROR: setup command failed.
exit /b 1

:PAUSE
echo.
echo ------------------------------------------------
pause
goto :MENU

:END
endlocal
exit /b 0
