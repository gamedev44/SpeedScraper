@echo off
SETLOCAL

:: Define paths relative to the batch file
SET SCRIPT_PATH=%~dp0..\Src\SpeedScraper.ps1
SET LOGS_DIR=%~dp0..\Logs

:: Ensure the Logs directory exists
if not exist "%LOGS_DIR%" mkdir "%LOGS_DIR%"

:: Define the log file path
SET LOGFILE=%LOGS_DIR%\SpeedScraper_Launcher_Log.txt
SET TIMESTAMP=%DATE%_%TIME%

:: Welcome Message
echo Welcome to SpeedScraper!
echo This batch file will automatically run the SpeedScraper PowerShell script.
echo Please ensure you have administrative rights to execute installations.

:: Check if PowerShell is available on the system
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo %TIMESTAMP% - Error: PowerShell is not installed on this system. >> "%LOGFILE%"
    echo Error: PowerShell is not installed on this system.
    pause
    exit /b
)

:: Running PowerShell script as Administrator
echo Attempting to run the PowerShell script as an Administrator...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%SCRIPT_PATH%\"' -Verb RunAs}" 2>> "%LOGFILE%"

if %errorlevel% neq 0 (
    echo %TIMESTAMP% - Failed to execute PowerShell script as Administrator. >> "%LOGFILE%"
)

echo Script execution has completed. Please check the output logs found in the Logs Folder for any error messages or Problems.
pause

ENDLOCAL
