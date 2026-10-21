@echo off
echo ============================================================
echo   BiteHub - Starting Flutter Web for Multi-Device Access
echo ============================================================
echo.
echo Host Laptop Wi-Fi IP: 10.102.3.137
echo.
echo Open this URL on your PHONE or OTHER LAPTOP (Connected to same Wi-Fi):
echo   --->  http://10.102.3.137:3000
echo.
echo Starting Web Server on 0.0.0.0:3000...
echo.

cd flutter_app
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000
pause
