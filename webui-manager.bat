@echo off
title Open WebUI - System Manager
chcp 65001 > nul
:menu
cls
echo ========================================
echo Open WebUI - Система Управления
echo ========================================
echo.
echo Выберите действие:
echo.
echo [1] Запустить Frontend
echo [2] Запустить Backend  
echo [3] Запустить всю систему
echo [4] Остановить систему
echo [5] Перезапустить систему
echo [6] Полная очистка и перезапуск
echo [7] Проверить статус системы
echo [8] Просмотреть логи
echo [9] Настройки
echo [0] Выход
echo.
set /p choice="Введите номер действия (0-9): "

if "%choice%"=="1" goto start_frontend
if "%choice%"=="2" goto start_backend
if "%choice%"=="3" goto start_all
if "%choice%"=="4" goto stop_all
if "%choice%"=="5" goto restart_all
if "%choice%"=="6" goto clean_restart
if "%choice%"=="7" goto check_status
if "%choice%"=="8" goto view_logs
if "%choice%"=="9" goto settings
if "%choice%"=="0" goto exit
echo.
echo Неверный выбор! Попробуйте снова.
timeout /t 2 /nobreak > nul
goto menu

:start_frontend
echo.
echo Запуск Frontend...
call "%~dp0start-frontend.bat"
goto menu

:start_backend
echo.
echo Запуск Backend...
call "%~dp0start-backend.bat"
goto menu

:start_all
echo.
echo Запуск всей системы...
call "%~dp0start-all.bat"
goto menu

:stop_all
echo.
echo Остановка системы...
call "%~dp0stop-all.bat"
echo.
echo Нажмите любую клавишу для возврата в меню...
pause > nul
goto menu

:restart_all
echo.
echo Перезапуск системы...
call "%~dp0restart-all.bat"
echo.
echo Нажмите любую клавишу для возврата в меню...
pause > nul
goto menu

:clean_restart
echo.
echo Полная очистка и перезапуск...
echo ВНИМАНИЕ: Это удалит node_modules и очистит кэш!
echo Продолжить? (Y/n)
choice /c YN /n
if %errorlevel% equ 1 (
    call "%~dp0clean-restart.bat"
) else (
    echo Операция отменена.
    timeout /t 2 /nobreak > nul
)
goto menu

:check_status
cls
echo ========================================
echo Проверка статуса системы Open WebUI
echo ========================================
echo.
echo Проверка портов...
for %%p in (5173 8080) do (
    netstat -ano | findstr ":%%p" | findstr "LISTENING" >nul
    if !errorlevel! equ 0 (
        echo [ЗАПУЩЕН] Порт %%p - занят
    ) else (
        echo [ОСТАНОВЛЕН] Порт %%p - свободен
    )
)
echo.
echo Проверка процессов...
tasklist /FI "WindowTitle eq Open WebUI*" 2>nul | findstr "Open WebUI" >nul
if %errorlevel% equ 0 (
    echo [ЗАПУЩЕН] Найдены процессы Open WebUI
) else (
    echo [ОСТАНОВЛЕН] Процессы Open WebUI не найдены
)
echo.
echo Проверка зависимостей...
where node >nul 2>nul
if %errorlevel% equ 0 (
    echo [ДОСТУПЕН] Node.js
) else (
    echo [НЕДОСТУПЕН] Node.js
)

where python >nul 2>nul
if %errorlevel% equ 0 (
    echo [ДОСТУПЕН] Python
) else (
    where python3 >nul 2>nul
    if %errorlevel% equ 0 (
        echo [ДОСТУПЕН] Python3
    ) else (
        echo [НЕДОСТУПЕН] Python
    )
)
echo.
echo Проверка логов...
if exist "logs" (
    echo [СУЩЕСТВУЕТ] Папка logs\
    dir /b "logs\*.log" 2>nul | find /c /v "" > temp_count.txt
    set /p log_count=<temp_count.txt
    del temp_count.txt
    echo Найдено логов: !log_count!
) else (
    echo [ОТСУТСТВУЕТ] Папка logs\
)
echo.
echo Нажмите любую клавишу для возврата в меню...
pause > nul
goto menu

:view_logs
cls
echo ========================================
echo Просмотр логов Open WebUI
echo ========================================
echo.
if not exist "logs" (
    echo Папка logs не найдена!
    echo Нажмите любую клавишу для возврата в меню...
    pause > nul
    goto menu
)
echo Доступные логи:
echo.
dir /b /o-d "logs\*.log" 2>nul
echo.
set /p logfile="Введите имя лога для просмотра (или 'menu' для возврата): "
if /i "%logfile%"=="menu" goto menu
if not exist "logs\%logfile%" (
    echo Лог не найден!
    timeout /t 2 /nobreak > nul
    goto view_logs
)
echo.
echo Содержимое лога %logfile%:
echo ========================================
type "logs\%logfile%" | more
echo.
echo Нажмите любую клавишу для возврата...
pause > nul
goto view_logs

:settings
cls
echo ========================================
echo Настройки Open WebUI
echo ========================================
echo.
echo Текущие настройки:
echo.
echo Frontend порт: 5173
echo Backend порт: 8080
echo Backend host: 0.0.0.0
echo.
echo Доступные действия:
echo [1] Изменить порты
echo [2] Сбросить настройки
echo [3] Назад в меню
echo.
set /p settings_choice="Выберите действие (1-3): "
if "%settings_choice%"=="1" goto change_ports
if "%settings_choice%"=="2" goto reset_settings
if "%settings_choice%"=="3" goto menu
goto settings

:change_ports
echo.
echo Функция изменения портов в разработке...
echo Для изменения портов отредактируйте файлы вручную:
echo - start-all.bat для frontend порта
echo - start-backend.bat для backend порта
echo.
pause
goto settings

:reset_settings
echo.
echo Функция сброса настроек в разработке...
echo.
pause
goto settings

:exit
cls
echo ========================================
echo Спасибо за использование Open WebUI Manager!
echo ========================================
echo.
echo Полезные ссылки:
echo - Frontend: http://localhost:5173
echo - Backend:  http://localhost:8080
echo - Health:   http://localhost:8080/health
echo.
echo До свидания!
timeout /t 3 /nobreak > nul
exit