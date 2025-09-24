@echo off
title Open WebUI - Clean Restart
echo ========================================
echo Полная очистка и перезапуск Open WebUI...
echo ========================================
cd /d "%~dp0"

:: Получение текущего времени
set datetime=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set datetime=%datetime: =0%

echo [%datetime%] Начало полной очистки и перезапуска...

:: Шаг 1: Остановка текущей системы
echo.
echo [1/5] Остановка текущей системы...
call "%~dp0stop-all.bat"
timeout /t 5 /nobreak > nul

:: Шаг 2: Полная очистка
echo.
echo [2/5] Полная очистка системы...

:: Очистка node_modules и переустановка зависимостей
echo Очистка node_modules...
if exist "node_modules" (
    rmdir /s /q "node_modules"
    echo node_modules удалена
)

:: Очистка .svelte-kit
echo Очистка .svelte-kit...
if exist ".svelte-kit" (
    rmdir /s /q ".svelte-kit"
    echo .svelte-kit удалена
)

:: Очистка Python кэша в backend
echo Очистка Python кэша...
if exist "backend\__pycache__" (
    rmdir /s /q "backend\__pycache__"
    echo backend\__pycache__ удалена
)
for /d /r "backend" %%d in (__pycache__) do (
    if exist "%%d" rmdir /s /q "%%d" >nul 2>&1
)

:: Очистка .pyc файлов
echo Очистка .pyc файлов...
for /r "backend" %%f in (*.pyc) do (
    del "%%f" >nul 2>&1
)

:: Очистка папки build/dist
echo Очистка build/dist папок...
if exist "build" (
    rmdir /s /q "build"
    echo build удалена
)
if exist "dist" (
    rmdir /s /q "dist"
    echo dist удалена
)

:: Очистка логов старше 7 дней
echo Очистка старых логов...
if exist "logs" (
    forfiles /p "logs" /s /m "*.log" /d -7 /c "cmd /c del @path" >nul 2>&1
    echo Старые логи удалены
)

:: Очистка npm кэша
echo Очистка npm кэша...
call npm cache clean --force >nul 2>&1

:: Очистка pip кэша в backend
echo Очистка pip кэша...
cd backend
if exist "venv\Scripts\python.exe" (
    call venv\Scripts\activate.bat
    call python -m pip cache purge >nul 2>&1
)
cd ..

:: Шаг 3: Проверка и восстановление окружения
echo.
echo [3/5] Восстановление окружения...

:: Проверка Node.js и npm
echo Проверка Node.js и npm...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ОШИБКА: Node.js не найден! Установите Node.js и запустите скрипт заново.
    pause
    exit /b 1
)

where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo ОШИБКА: npm не найден! Убедитесь, что Node.js установлен корректно.
    pause
    exit /b 1
)

:: Проверка Python
echo Проверка Python...
where python >nul 2>nul
if %errorlevel% neq 0 (
    where python3 >nul 2>nul
    if %errorlevel% neq 0 (
        echo ОШИБКА: Python не найден! Установите Python и запустите скрипт заново.
        pause
        exit /b 1
    )
)

:: Шаг 4: Установка зависимостей
echo.
echo [4/5] Установка зависимостей...

:: Установка npm зависимостей
echo Установка npm зависимостей...
call npm install
if %errorlevel% neq 0 (
    echo ОШИБКА: Не удалось установить npm зависимости!
    pause
    exit /b 1
)

:: Установка Python зависимостей в backend
echo Установка Python зависимостей...
cd backend
if exist "venv\Scripts\python.exe" (
    call venv\Scripts\activate.bat
    call python -m pip install --upgrade pip
    if exist "requirements.txt" (
        call python -m pip install -r requirements.txt
    )
) else (
    echo Создание виртуального окружения...
    python -m venv venv
    call venv\Scripts\activate.bat
    call python -m pip install --upgrade pip
    if exist "requirements.txt" (
        call python -m pip install -r requirements.txt
    )
)
cd ..

:: Шаг 5: Запуск системы
echo.
echo [5/5] Запуск системы...
call "%~dp0start-all.bat"

:: Логирование завершения
set datetime=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set datetime=%datetime: =0%
echo [%datetime%] Полная очистка и перезапуск завершены!

:: Опционально: открытие браузера
echo.
echo Открытие браузера? (Y/n)
choice /c YN /n /t 10 /d Y
if %errorlevel% equ 1 (
    echo Открытие браузера...
    start http://localhost:5173
)

echo.
echo Полная очистка и перезапуск завершены успешно!
echo Система Open WebUI готова к работе!
echo Нажмите любую клавишу для выхода...
pause > nul