@echo off
echo ============================================================
echo   BiteHub - Starting Backend Server for Local & LAN Access
echo ============================================================
echo.
echo Active Host IP:        10.74.88.1
echo Local API Endpoint:    http://localhost:8000
echo Network API Endpoint:  http://10.74.88.1:8000
echo Swagger API Docs:      http://10.74.88.1:8000/docs
echo.
echo Listening on 0.0.0.0:8000 (Accessible from phones, laptops & emulators)...
echo.

uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
if %errorlevel% neq 0 (
    echo.
    echo Trying with Python module...
    python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
)
pause
