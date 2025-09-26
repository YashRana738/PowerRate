@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: PowerRate - Uninstaller (Colorful Version)
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
echo      %C_RED%PowerRate Task - Uninstaller%C_RESET%
echo %C_CYAN%%C_BOLD%===============================================%C_RESET%
echo.

:: Check for Administrator Privileges
echo %C_YELLOW%[INFO]%C_RESET% Checking for administrator privileges...
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo %C_RED%[ERROR]%C_RESET% This script requires administrator privileges.
    echo Please %C_BOLD%right-click%C_RESET% on 'RemoveTask.bat' and select "%C_BOLD%Run as administrator%C_RESET%".
    echo.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)
echo %C_GREEN%[SUCCESS]%C_RESET% Running with administrator privileges.
echo.

pushd "%CD%"
cd /D "%~dp0"

:: Check if the scheduled task exists
echo %C_YELLOW%[INFO]%C_RESET% Checking installation...
schtasks /query /tn "Power Rate" >nul 2>&1
if errorlevel 1 (
    echo %C_RED%[NOT FOUND]%C_RESET% No installation found for "Power Rate".
) else (
    echo %C_GREEN%[FOUND]%C_RESET% Task "Power Rate" is installed.
    echo.
    set /p REMOVE_TASK="%C_YELLOW%Do you want to remove the PowerRate task? (Y/N): %C_RESET%"
    if /i "!REMOVE_TASK!"=="Y" (
        echo %C_YELLOW%[INFO]%C_RESET% Removing scheduled task...
        schtasks /delete /tn "Power Rate" /f
        if errorlevel 1 (
            echo %C_RED%[ERROR]%C_RESET% Failed to remove task.
        ) else (
            echo %C_GREEN%[SUCCESS]%C_RESET% Task removed successfully.
        )
    ) else (
        echo %C_YELLOW%[INFO]%C_RESET% Scheduled task was not removed.
    )
)

echo.
echo %C_CYAN%%C_BOLD%===============================================%C_RESET%
echo %C_GREEN%Uninstall process completed.%C_RESET%
echo %C_CYAN%%C_BOLD%===============================================%C_RESET%
echo.
echo %C_YELLOW%If you want to completely remove the application,%C_RESET%
echo %C_YELLOW%you can manually delete the entire folder.%C_RESET%
echo.
pause
