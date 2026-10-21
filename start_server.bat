@echo off
echo ============================================================
echo   BiteHub - Starting Backend Server for Local & LAN Access
echo ============================================================
echo.
echo Host Laptop Wi-Fi IP: 10.102.3.137
echo Local API Endpoint:   http://localhost:8000
echo Network API Endpoint: http://10.102.3.137:8000
echo Swagger API Docs:     http://10.102.3.137:8000/docs
echo.
echo Listening on 0.0.0.0:8000 (Accessible from phones & other PCs)...
echo.

uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
if %errorlevel% neq 0 (
    echo.
    echo Trying with Python module...
    python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
)
pause
