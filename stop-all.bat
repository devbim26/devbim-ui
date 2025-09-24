@echo off
title Open WebUI - Stop System
echo ========================================
echo Остановка системы Open WebUI...
echo ========================================

:: Остановка процессов по названиям окон
echo Остановка процессов Open WebUI...
taskkill /F /FI "WindowTitle eq Open WebUI*" >nul 2>&1

:: Остановка конкретных процессов
echo Остановка Node.js процессов...
taskkill /F /IM node.exe >nul 2>&1

echo Остановка Python процессов...
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM python3.exe >nul 2>&1

echo Остановка Uvicorn процессов...
taskkill /F /IM uvicorn.exe >nul 2>&1

:: Остановка процессов по портам (если доступны netstat и taskkill)
echo Проверка занятых портов...
for %%p in (5173 8080) do (
    echo Проверка порта %%p...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%%p" ^| findstr "LISTENING"') do (
        if not "%%a"=="" (
            echo Найден процесс на порту %%p с PID %%a
            taskkill /F /PID %%a >nul 2>&1
        )
    )
)

:: Очистка временных файлов (опционально)
echo Очистка временных файлов...
if exist "logs" (
    echo Логи сохранены в папке logs\
)

echo.
echo ========================================
echo Система Open WebUI остановлена!
echo ========================================
echo.
echo Проверка оставшихся процессов:
tasklist /FI "WindowTitle eq Open WebUI*" 2>nul | findstr "Open WebUI" >nul
if %errorlevel% equ 0 (
    echo ВНИМАНИЕ: Некоторые процессы могли не завершиться!
) else (
    echo Все процессы успешно остановлены.
)
echo.
echo Нажмите любую клавишу для выхода...
pause > nul