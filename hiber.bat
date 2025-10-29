@echo off
taskkill /F /PID 42724
timeout /t 5 /nobreak
start "" ".\wus.exe"
exit
