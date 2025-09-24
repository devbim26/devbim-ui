@echo off
title Open WebUI - Frontend
echo ========================================
echo Запуск Frontend Open WebUI...
echo ========================================
cd /d "%~dp0"
echo Текущая директория: %CD%

:: Проверка наличия Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ОШИБКА: Node.js не найден! Установите Node.js с официального сайта.
    pause
    exit /b 1
)

:: Проверка наличия npm
where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo ОШИБКА: npm не найден! Убедитесь, что Node.js установлен корректно.
    pause
    exit /b 1
)

echo Установка зависимостей...
call npm install
if %errorlevel% neq 0 (
    echo ОШИБКА: Не удалось установить зависимости npm!
    pause
    exit /b 1
)

echo Запуск Pyodide подготовки...
call npm run pyodide:fetch
if %errorlevel% neq 0 (
    echo ПРЕДУПРЕЖДЕНИЕ: Не удалось выполнить pyodide:fetch, но продолжаем...
)

echo Запуск Frontend сервера разработки...
echo Frontend будет доступен по адресу: http://localhost:5173
echo Нажмите Ctrl+C для остановки сервера
echo ========================================
call npm run dev
pause