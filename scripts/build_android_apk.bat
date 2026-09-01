@echo off
setlocal
echo ========================================================
echo Building AI Fitness Platform - Release Android APK
echo ========================================================

set BACKEND_URL=%1
if "%BACKEND_URL%"=="" (
    set /p BACKEND_URL="Enter production backend base URL (e.g. https://your-backend.onrender.com): "
)

cd ..\ai_fitness_app
echo Building release APK with API_BASE_URL=%BACKEND_URL% ...
call flutter build apk --release --dart-define=API_BASE_URL=%BACKEND_URL%

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================================
    echo Build SUCCESS!
    echo Output APK located at: ai_fitness_app\build\app\outputs\flutter-apk\app-release.apk
    echo ========================================================
) else (
    echo.
    echo Build FAILED. Check errors above.
)
pause

