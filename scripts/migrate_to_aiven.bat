@echo off
setlocal
echo ===================================================================
echo AI Fitness Platform - Aiven Cloud MySQL 8.0 Database Initializer
echo ===================================================================

set HOST=%1
set PORT=%2
set USER=%3
set PASS=%4
set DBNAME=%5

if "%HOST%"=="" set /p HOST="Enter Aiven MySQL Host: "
if "%PORT%"=="" set /p PORT="Enter Aiven MySQL Port: "
if "%USER%"=="" set /p USER="Enter Aiven MySQL User (e.g. avnadmin): "
if "%PASS%"=="" set /p PASS="Enter Aiven MySQL Password: "
if "%DBNAME%"=="" set /p DBNAME="Enter Database Name (e.g. defaultdb): "

echo.
echo Connecting to %HOST%:%PORT% and executing schema...
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -h %HOST% -P %PORT% -u %USER% -p%PASS% --ssl-mode=REQUIRED %DBNAME% < "..\SQL file.sql"

if %ERRORLEVEL% equ 0 (
    echo.
    echo ===================================================================
    echo SUCCESS: All tables, constraints, and master data seeded in Aiven!
    echo ===================================================================
) else (
    echo.
    echo FAILED: Could not seed database. Check your credentials and connectivity.
)
pause

