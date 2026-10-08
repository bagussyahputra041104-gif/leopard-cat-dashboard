@echo off
title Wildlife Intelligence - AI Server

cd /d "%~dp0"

echo.
echo ==========================================
echo   WILDLIFE INTELLIGENCE - AI SERVER
echo ==========================================
echo.
echo Starting local AI server...
echo.
echo API: http://127.0.0.1:5000
echo.
echo Jangan tutup jendela ini selama
echo aplikasi AI sedang digunakan.
echo.
echo ==========================================
echo.

py app.py

echo.
echo ==========================================
echo AI SERVER BERHENTI
echo ==========================================
pause
