@echo off
echo ============================================================
echo   BiteHub - Starting Flutter Web for Multi-Device Access
echo ============================================================
echo.
echo Active Host IP: 10.74.88.1
echo.
echo Open this URL on your PHONE or OTHER LAPTOP (Connected to same Wi-Fi / Hotspot):
echo   --->  http://10.74.88.1:3000
echo.
echo Starting Web Server on 0.0.0.0:3000...
echo.

cd flutter_app
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000
pause
