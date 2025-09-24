@echo off
title Open WebUI - Restart System
echo ========================================
echo Перезапуск системы Open WebUI...
echo ========================================
cd /d "%~dp0"

:: Получение текущего времени
set datetime=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set datetime=%datetime: =0%

echo [%datetime%] Начало перезапуска...

:: Шаг 1: Остановка текущей системы
echo.
echo [1/3] Остановка текущей системы...
call "%~dp0stop-all.bat"
timeout /t 3 /nobreak > nul

:: Шаг 2: Очистка временных файлов (опционально)
echo.
echo [2/3] Очистка временных файлов...
if exist "logs" (
    echo Логи сохранены в папке logs\
)

:: Очистка кэша npm (опционально)
echo Очистка кэша npm...
call npm cache clean --force >nul 2>&1

:: Очистка __pycache__ в backend
echo Очистка Python кэша...
if exist "backend\__pycache__" (
    rmdir /s /q "backend\__pycache__" >nul 2>&1
)
for /d /r "backend" %%d in (__pycache__) do (
    if exist "%%d" rmdir /s /q "%%d" >nul 2>&1
)

:: Шаг 3: Запуск системы заново
echo.
echo [3/3] Запуск системы...
call "%~dp0start-all.bat"

:: Логирование завершения
set datetime=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set datetime=%datetime: =0%
echo [%datetime%] Перезапуск завершен!

:: Опционально: открытие браузера
echo.
echo Открытие браузера? (Y/n)
choice /c YN /n /t 10 /d Y
if %errorlevel% equ 1 (
    echo Открытие браузера...
    start http://localhost:5173
)

echo.
echo Перезапуск завершен успешно!
echo Нажмите любую клавишу для выхода...
pause > nul