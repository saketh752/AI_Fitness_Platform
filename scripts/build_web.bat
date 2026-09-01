@echo off
setlocal
echo ========================================================
echo Building AI Fitness Platform - Release Web (SPA)
echo ========================================================

set BACKEND_URL=%1
if "%BACKEND_URL%"=="" (
    set /p BACKEND_URL="Enter production backend base URL (e.g. https://your-backend.up.railway.app): "
)

cd ..\ai_fitness_app
echo Building release Web bundle with API_BASE_URL=%BACKEND_URL% ...
call flutter build web --release --dart-define=API_BASE_URL=%BACKEND_URL%

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================================
    echo Web build SUCCESS!
    echo Static output ready in: ai_fitness_app\build\web
    echo You can deploy this folder directly to Firebase Hosting or Vercel.
    echo ========================================================
) else (
    echo.
    echo Web build FAILED. Check errors above.
)
pause

