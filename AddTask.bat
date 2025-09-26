@echo off
setlocal enabledelayedexpansion
:: ============================================================================
:: PowerRate - Setup Script (Colorful Version)
:: ============================================================================

:: Enable ANSI colors (works on Windows 10+)
for /f "tokens=2 delims=: " %%i in ('reg query HKEY_CURRENT_USER\Console ^| findstr /i "VirtualTerminalLevel"') do set "VT=%%i"
if not defined VT (
    reg add HKEY_CURRENT_USER\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul
)

:: Define colors
set "C_RESET=[0m"
set "C_GREEN=[32m"
set "C_RED=[31m"
set "C_YELLOW=[33m"
set "C_BLUE=[34m"
set "C_CYAN=[36m"
set "C_BOLD=[1m"

echo %C_CYAN%%C_BOLD%===============================================%C_RESET%
echo      %C_GREEN%PowerRate Task - Setup%C_RESET%
echo   Developed by: %C_BLUE%https://github.com/YashRana738%C_RESET%
echo %C_CYAN%%C_BOLD%===============================================%C_RESET%
echo.

:: 1. Check for Administrator Privileges
echo %C_YELLOW%[INFO]%C_RESET% Checking for administrator privileges...
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo %C_RED%[ERROR]%C_RESET% This script requires administrator privileges.
    echo Please %C_BOLD%right-click%C_RESET% on 'run.bat' and select "%C_BOLD%Run as administrator%C_RESET%".
    echo.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)
echo %C_GREEN%[SUCCESS]%C_RESET% Running with administrator privileges.
echo.

:: Set script directory
pushd "%~dp0"

:: Create Scheduled Task from Template
echo %C_YELLOW%[INFO]%C_RESET% Creating PowerRate Scheduled task...

set "TASK_DIR=xml"
set "BIN_DIR=bin"
set "TASK_TEMP=%TASK_DIR%\PowerRate.xml"
set "OUTPUT_XML=%TEMP%\PowerRate_apply.xml"
set "TASK_NAME=Power Rate"

:: Check for template file
if not exist "%TASK_TEMP%" (
    echo %C_RED%[ERROR]%C_RESET% Template file not found at "%TASK_TEMP%"
    echo.
    echo Press any key to exit...
    pause > nul
    popd
    exit /b 1
)

:: Find exe script
set "EXE_FOUND="
for %%F in ("%BIN_DIR%\*.exe") do (
    set "EXE_PATH=%~dp0%%F"
    set "EXE_FOUND=1"
    goto :foundexe
)

:foundexe
if not defined EXE_FOUND (
    echo %C_RED%[ERROR]%C_RESET% No binary found in "%BIN_DIR%".
    echo.
    echo Press any key to exit...
    pause > nul
    popd
    exit /b 1
)
echo %C_GREEN%[FOUND]%C_RESET% Exe: "!EXE_PATH!"

:: Replace placeholder in XML
echo %C_YELLOW%[INFO]%C_RESET% Preparing task XML with current user SID...
for /f "usebackq delims=" %%S in (`powershell -NoProfile -Command "(New-Object System.Security.Principal.NTAccount($env:USERDOMAIN, $env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value"`) do (
    set "CURRENT_SID=%%S"
)

if not defined CURRENT_SID (
    echo %C_RED%[ERROR]%C_RESET% Could not resolve current user's SID.
    echo.
    echo Press any key to exit...
    pause > nul
    popd
    exit /b 1
)
echo %C_GREEN%[SUCCESS]%C_RESET% Using SID: !CURRENT_SID!

powershell -Command "(Get-Content '%TASK_TEMP%' -Raw) -replace '##EXE_PATH##', '!EXE_PATH!' -replace '<UserId>.*?</UserId>', ('<UserId>' + '!CURRENT_SID!' + '</UserId>') | Out-File '%OUTPUT_XML%' -Encoding Unicode"
if not exist "%OUTPUT_XML%" (
    echo %C_RED%[ERROR]%C_RESET% Failed to create final task XML file.
    echo.
    echo Press any key to exit...
    pause > nul
    popd
    exit /b 1
)

:: Create the scheduled task
echo %C_YELLOW%[INFO]%C_RESET% Registering task...
schtasks /create /tn "%TASK_NAME%" /xml "%OUTPUT_XML%" /f > nul
if %errorlevel% neq 0 (
    echo %C_RED%[ERROR]%C_RESET% Failed to create the scheduled task '%TASK_NAME%'.
    echo Try running this script as an administrator.
) else (
    echo %C_GREEN%[SUCCESS]%C_RESET% Task '%TASK_NAME%' created successfully.
)

del "%OUTPUT_XML%"
popd

echo.
echo %C_GREEN%Installation complete!%C_RESET%
echo.
echo Press any key to close this window...
pause > nul
exit /b 0
