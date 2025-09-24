@echo off
title Open WebUI - Full System
echo ========================================
echo Запуск всей системы Open WebUI...
echo ========================================
cd /d "%~dp0"

:: Проверка наличия необходимых компонентов
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ОШИБКА: Node.js не найден! Установите Node.js с официального сайта.
    pause
    exit /b 1
)

where python >nul 2>nul
if %errorlevel% neq 0 (
    where python3 >nul 2>nul
    if %errorlevel% neq 0 (
        echo ОШИБКА: Python не найден! Установите Python с официального сайта.
        pause
        exit /b 1
    )
)

:: Создание лог-директории
if not exist "logs" mkdir logs

:: Получение текущего времени для логов
set datetime=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set datetime=%datetime: =0%

echo.
echo Запуск Backend в фоновом режиме...
start "Open WebUI - Backend" cmd /k "cd /d "%~dp0backend" && call python -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8080 --forwarded-allow-ips '*' --reload 2^>^&1 ^| tee logs\backend_%datetime%.log"

:: Ожидание запуска Backend
echo Ожидание запуска Backend...
timeout /t 8 /nobreak > nul

:: Проверка доступности Backend
echo Проверка доступности Backend...
powershell -Command "$retryCount = 0; while ($retryCount -lt 10) { try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/health' -TimeoutSec 5; if ($response.StatusCode -eq 200) { Write-Host 'Backend доступен!'; exit 0; } } catch { }; $retryCount++; Write-Host \"Попытка $retryCount из 10...\"; Start-Sleep -Seconds 2; } Write-Host 'Backend не отвечает!'; exit 1;"
if %errorlevel% neq 0 (
    echo ПРЕДУПРЕЖДЕНИЕ: Backend может быть не полностью готов, но продолжаем...
)

echo.
echo Запуск Frontend в фоновом режиме...
start "Open WebUI - Frontend" cmd /k "cd /d "%~dp0" && npm run dev 2^>^&1 ^| tee logs\frontend_%datetime%.log"

:: Ожидание запуска Frontend
echo Ожидание запуска Frontend...
timeout /t 5 /nobreak > nul

echo.
echo ========================================
echo Система Open WebUI запущена!
echo ========================================
echo.
echo Доступные URL:
echo   Frontend: http://localhost:5173
echo   Backend:  http://localhost:8080
echo   Health:   http://localhost:8080/health
echo.
echo Логи сохранены в папке: logs\
echo.
echo Для остановки системы используйте: stop-all.bat
echo Для перезапуска системы используйте: restart-all.bat
echo.
echo Нажмите любую клавишу для выхода из этого окна...
pause > nul