@echo off
title Open WebUI - Backend
echo ========================================
echo Запуск Backend Open WebUI...
echo ========================================
cd /d "%~dp0"
cd backend
echo Текущая директория: %CD%

:: Проверка наличия Python
where python >nul 2>nul
if %errorlevel% neq 0 (
    where python3 >nul 2>nul
    if %errorlevel% neq 0 (
        echo ОШИБКА: Python не найден! Установите Python с официального сайта.
        pause
        exit /b 1
    ) else (
        set PYTHON_CMD=python3
    )
) else (
    set PYTHON_CMD=python
)

echo Используем Python: %PYTHON_CMD%

:: Проверка наличия виртуального окружения
if exist "venv\Scripts\python.exe" (
    echo Активация виртуального окружения...
    call venv\Scripts\activate.bat
) else (
    echo Создание виртуального окружения...
    %PYTHON_CMD% -m venv venv
    if %errorlevel% neq 0 (
        echo ОШИБКА: Не удалось создать виртуальное окружение!
        pause
        exit /b 1
    )
    echo Активация виртуального окружения...
    call venv\Scripts\activate.bat
)

:: Установка зависимостей
echo Установка зависимостей Python...
%PYTHON_CMD% -m pip install --upgrade pip
if exist "requirements.txt" (
    %PYTHON_CMD% -m pip install -r requirements.txt
    if %errorlevel% neq 0 (
        echo ПРЕДУПРЕЖДЕНИЕ: Некоторые зависимости могли не установиться корректно
    )
)

:: Установка Playwright браузеров если нужно
if "%WEB_LOADER_ENGINE%"=="playwright" (
    if "%PLAYWRIGHT_WS_URL%"=="" (
        echo Установка Playwright браузеров...
        playwright install chromium
        playwright install-deps chromium
    )
    echo Загрузка NLTK данных...
    %PYTHON_CMD% -c "import nltk; nltk.download('punkt_tab')"
)

:: Проверка и генерация секретного ключа
if not exist ".webui_secret_key" (
    echo Генерация секретного ключа...
    echo %random%%random%%random%%random%%random%%random% > .webui_secret_key
)

:: Установка переменных окружения по умолчанию
if "%PORT%"=="" set PORT=8080
if "%HOST%"=="" set HOST=0.0.0.0
if "%UVICORN_WORKERS%"=="" set UVICORN_WORKERS=1

echo ========================================
echo Запуск Backend сервера...
echo Host: %HOST%
echo Port: %PORT%
echo Workers: %UVICORN_WORKERS%
echo ========================================
echo Backend будет доступен по адресу: http://%HOST%:%PORT%
echo Health check: http://%HOST%:%PORT%/health
echo Нажмите Ctrl+C для остановки сервера
echo ========================================

:: Запуск uvicorn
%PYTHON_CMD% -m uvicorn open_webui.main:app --host %HOST% --port %PORT% --forwarded-allow-ips '*' --workers %UVICORN_WORKERS% --reload

pause