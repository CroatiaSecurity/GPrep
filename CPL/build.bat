@echo off
setlocal
cd /d "%~dp0"

set "VERSION=1.0.0"

REM Build GPrep.cpl - requires Visual Studio or Windows SDK
REM Run from Developer Command Prompt, or adjust path to cl.exe

where cl.exe >nul 2>&1
if errorlevel 1 (
    echo Looking for Visual Studio...
    for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "& {'$(dir /b /ad "C:\Program Files\Microsoft Visual Studio\2022\*" 2^>nul)'}"`) do set VSDIR=%%i
    if defined VSDIR (
        call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" 2>nul
        if errorlevel 1 call "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" 2>nul
    )
)

where cl.exe >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: cl.exe not found. Please run from "Developer Command Prompt for VS"
    echo   or install Visual Studio Build Tools.
    echo.
    echo Alternative: Use MinGW:
    echo   gcc -shared -o GPrep.cpl GPrep.c -lshell32 -lole32 -s
    exit /b 1
)

if not exist "..\..\releases\%VERSION%" mkdir "..\..\releases\%VERSION%"

echo Building GPrep.cpl v%VERSION%...
cl /nologo /LD /O2 /W3 GPrep.c shell32.lib /Fe:"..\..\releases\%VERSION%\GPrep.cpl" /link /DEF:GPrep.def
if errorlevel 1 exit /b 1

echo.
echo Copying additional files...
copy /Y "GPrepUI.hta"      "..\..\releases\%VERSION%\"
copy /Y "GPrepHelper.ps1"  "..\..\releases\%VERSION%\"
copy /Y "manifest.json"    "..\..\releases\%VERSION%\" 2>nul

echo.
echo Build complete: releases\%VERSION%\GPrep.cpl
exit /b 0
