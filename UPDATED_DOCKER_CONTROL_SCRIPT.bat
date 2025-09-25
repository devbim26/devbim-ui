# Обновленный скрипт управления Open WebUI в Docker

## Windows Batch Script с новыми функциями обновления

Скопируйте следующий код в файл `docker-control-v2.bat`:

```batch
@echo off
chcp 65001 > nul
title Open WebUI Docker Control v2.0
color 0A

:menu
cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║              Open WebUI Docker Control Panel v2.0           ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 1. Запустить систему
echo 2. Остановить систему
echo 3. Перезапустить систему
echo 4. Проверить статус
echo 5. Просмотреть логи
echo 6. Обновить систему
echo 7. Установить модель
echo 8. Список моделей
echo 9. Резервное копирование
echo A. Обновить Open WebUI
echo B. Обновить Ollama
echo C. Проверить версии
echo 0. Выход
echo.
set /p choice=Выберите действие (0-9, A-C): 

if "%choice%"=="1" goto start
if "%choice%"=="2" goto stop
if "%choice%"=="3" goto restart
if "%choice%"=="4" goto status
if "%choice%"=="5" goto logs
if "%choice%"=="6" goto update
if "%choice%"=="7" goto install_model
if "%choice%"=="8" goto list_models
if "%choice%"=="9" goto backup
if "%choice%"=="A" goto update_webui
if "%choice%"=="B" goto update_ollama
if "%choice%"=="C" goto check_versions
if "%choice%"=="0" goto exit
echo Неверный выбор, попробуйте снова
timeout /t 2 > nul
goto menu

:start
echo.
echo Запуск Open WebUI...
docker-compose up -d
if %errorlevel% equ 0 (
    echo ✅ Система успешно запущена!
    echo 🌐 Доступ: http://localhost:3000
) else (
    echo ❌ Ошибка при запуске системы
)
pause
goto menu

:stop
echo.
echo Остановка Open WebUI...
docker-compose down
if %errorlevel% equ 0 (
    echo ✅ Система успешно остановлена!
) else (
    echo ❌ Ошибка при остановке системы
)
pause
goto menu

:restart
echo.
echo Перезапуск Open WebUI...
docker-compose restart
if %errorlevel% equ 0 (
    echo ✅ Система успешно перезапущена!
    echo 🌐 Доступ: http://localhost:3000
) else (
    echo ❌ Ошибка при перезапуске системы
)
pause
goto menu

:status
echo.
echo Проверка статуса контейнеров...
docker-compose ps
echo.
echo Нажмите любую клавишу для продолжения...
pause > nul
goto menu

:logs
echo.
echo Просмотр последних 50 строк логов...
docker-compose logs --tail 50
echo.
echo Нажмите любую клавишу для продолжения...
pause > nul
goto menu

:update
echo.
echo Обновление системы...
docker-compose down
docker-compose pull
docker-compose up -d
if %errorlevel% equ 0 (
    echo ✅ Система успешно обновлена!
) else (
    echo ❌ Ошибка при обновлении системы
)
pause
goto menu

:install_model
echo.
set /p model_name=Введите название модели (например, llama2): 
echo Установка модели %model_name%...
docker exec ollama ollama pull %model_name%
if %errorlevel% equ 0 (
    echo ✅ Модель %model_name% успешно установлена!
) else (
    echo ❌ Ошибка при установке модели %model_name%
)
pause
goto menu

:list_models
echo.
echo Список установленных моделей:
docker exec ollama ollama list
echo.
echo Нажмите любую клавишу для продолжения...
pause > nul
goto menu

:backup
echo.
echo Создание резервной копии...
set backup_name=backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set backup_name=%backup_name: =0%
mkdir backups 2>nul
docker run --rm -v open-webui-data:/data -v %cd%\backups:/backup alpine tar czf /backup/open-webui-%backup_name%.tar.gz -C /data .
docker run --rm -v ollama-data:/data -v %cd%\backups:/backup alpine tar czf /backup/ollama-%backup_name%.tar.gz -C /data .
echo ✅ Резервные копии созданы в папке backups
pause
goto menu

:update_webui
echo.
echo Обновление Open WebUI...
echo Создание резервной копии перед обновлением...
set backup_name=webui_pre_update_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set backup_name=%backup_name: =0%
mkdir backups 2>nul
docker run --rm -v open-webui-data:/data -v %cd%\backups:/backup alpine tar czf /backup/open-webui-pre-update-%backup_name%.tar.gz -C /data .
echo ✅ Резервная копия создана

echo Обновление образа Open WebUI...
docker-compose stop open-webui
docker pull ghcr.io/open-webui/open-webui:main
docker-compose up -d open-webui

if %errorlevel% equ 0 (
    echo ✅ Open WebUI успешно обновлен!
    echo Проверка логов обновления...
    timeout /t 10 > nul
    docker-compose logs open-webui --tail 20
) else (
    echo ❌ Ошибка при обновлении Open WebUI
)
pause
goto menu

:update_ollama
echo.
echo Обновление Ollama...
echo Создание списка моделей перед обновлением...
docker exec ollama ollama list > ollama_models_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%.txt
echo ✅ Список моделей сохранен

echo Обновление Ollama...
docker-compose stop ollama
docker pull ollama/ollama:latest
docker-compose up -d ollama

if %errorlevel% equ 0 (
    echo ✅ Ollama успешно обновлен!
    echo Проверка сохранности моделей...
    timeout /t 5 > nul
    docker exec ollama ollama list
    echo Проверка версии...
    docker exec ollama ollama --version
) else (
    echo ❌ Ошибка при обновлении Ollama
)
pause
goto menu

:check_versions
echo.
echo Проверка версий компонентов...
echo.
echo === Open WebUI ===
docker-compose logs open-webui --tail 10 | findstr /i version
echo.
echo === Ollama ===
docker exec ollama ollama --version 2>nul || echo Не удалось определить версию Ollama
echo.
echo === Docker образы ===
docker images | findstr /i "open-webui\|ollama"
echo.
echo Нажмите любую клавишу для продолжения...
pause > nul
goto menu

:exit
echo.
echo Спасибо за использование Open WebUI!
echo До свидания!
timeout /t 2 > nul
exit
```

## Обновленный Bash Script для Linux/Mac

Скопируйте следующий код в файл `docker-control-v2.sh`:

```bash
#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция вывода меню
show_menu() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              Open WebUI Docker Control Panel v2.0           ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${GREEN}1.${NC} Запустить систему"
    echo -e "${GREEN}2.${NC} Остановить систему"
    echo -e "${GREEN}3.${NC} Перезапустить систему"
    echo -e "${GREEN}4.${NC} Проверить статус"
    echo -e "${GREEN}5.${NC} Просмотреть логи"
    echo -e "${GREEN}6.${NC} Обновить систему"
    echo -e "${GREEN}7.${NC} Установить модель"
    echo -e "${GREEN}8.${NC} Список моделей"
    echo -e "${GREEN}9.${NC} Резервное копирование"
    echo -e "${GREEN}A.${NC} Обновить Open WebUI"
    echo -e "${GREEN}B.${NC} Обновить Ollama"
    echo -e "${GREEN}C.${NC} Проверить версии"
    echo -e "${RED}0.${NC} Выход"
    echo
}

# Функция обновления Open WebUI
update_webui() {
    echo -e "\n${YELLOW}Обновление Open WebUI...${NC}"
    echo -e "${YELLOW}Создание резервной копии перед обновлением...${NC}"
    backup_name="webui_pre_update_$(date +%Y%m%d_%H%M%S)"
    mkdir -p backups
    docker run --rm -v open-webui-data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/open-webui-pre-update-${backup_name}.tar.gz -C /data .
    echo -e "${GREEN}✅ Резервная копия создана${NC}"

    echo -e "${YELLOW}Обновление образа Open WebUI...${NC}"
    docker-compose stop open-webui
    docker pull ghcr.io/open-webui/open-webui:main
    docker-compose up -d open-webui

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Open WebUI успешно обновлен!${NC}"
        echo -e "${YELLOW}Проверка логов обновления...${NC}"
        sleep 10
        docker-compose logs open-webui --tail 20
    else
        echo -e "${RED}❌ Ошибка при обновлении Open WebUI${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Функция обновления Ollama
update_ollama() {
    echo -e "\n${YELLOW}Обновление Ollama...${NC}"
    echo -e "${YELLOW}Создание списка моделей перед обновлением...${NC}"
    docker exec ollama ollama list > "ollama_models_backup_$(date +%Y%m%d).txt"
    echo -e "${GREEN}✅ Список моделей сохранен${NC}"

    echo -e "${YELLOW}Обновление Ollama...${NC}"
    docker-compose stop ollama
    docker pull ollama/ollama:latest
    docker-compose up -d ollama

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Ollama успешно обновлен!${NC}"
        echo -e "${YELLOW}Проверка сохранности моделей...${NC}"
        sleep 5
        docker exec ollama ollama list
        echo -e "${YELLOW}Проверка версии...${NC}"
        docker exec ollama ollama --version
    else
        echo -e "${RED}❌ Ошибка при обновлении Ollama${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Функция проверки версий
check_versions() {
    echo -e "\n${YELLOW}Проверка версий компонентов...${NC}"
    echo
    echo -e "${BLUE}=== Open WebUI ===${NC}"
    docker-compose logs open-webui --tail 10 | grep -i version || echo "Не удалось определить версию Open WebUI"
    echo
    echo -e "${BLUE}=== Ollama ===${NC}"
    docker exec ollama ollama --version 2>/dev/null || echo "Не удалось определить версию Ollama"
    echo
    echo -e "${BLUE}=== Docker образы ===${NC}"
    docker images | grep -E "open-webui|ollama"
    read -p "Нажмите Enter для продолжения..."
}

# Остальные функции остаются без изменений...
# (здесь должны быть все предыдущие функции из оригинального скрипта)

# Главный цикл
while true; do
    show_menu
    read -p "Выберите действие (0-9, A-C): " choice
    
    case $choice in
        1) start_system ;;
        2) stop_system ;;
        3) restart_system ;;
        4) check_status ;;
        5) view_logs ;;
        6) update_system ;;
        7) install_model ;;
        8) list_models ;;
        9) create_backup ;;
        A|a) update_webui ;;
        B|b) update_ollama ;;
        C|c) check_versions ;;
        0) 
            echo -e "\n${GREEN}Спасибо за использование Open WebUI!${NC}"
            echo -e "${GREEN}До свидания!${NC}"
            sleep 2
            exit 0
            ;;
        *) 
            echo -e "${RED}Неверный выбор, попробуйте снова${NC}"
            sleep 2
            ;;
    esac
done
```

## Установка и использование

### Для Windows:
1. Скопируйте код Windows Batch Script в файл `docker-control-v2.bat`
2. Сохраните в корневой папке проекта
3. Дважды кликните по файлу для запуска

### Для Linux/Mac:
1. Скопируйте код Bash Script в файл `docker-control-v2.sh`
2. Сделайте файл исполняемым: `chmod +x docker-control-v2.sh`
3. Запустите: `./docker-control-v2.sh`

## Новые функции версии 2.0:

### 🔧 Обновление Open WebUI:
- Автоматическое создание резервной копии перед обновлением
- Обновление образа до последней версии
- Проверка логов обновления
- Автоматический перезапуск сервиса

### 🦙 Обновление Ollama:
- Сохранение списка моделей перед обновлением
- Обновление до последней версии
- Проверка сохранности моделей
- Проверка версии после обновления

### 📊 Проверка версий:
- Показ версий Open WebUI и Ollama
- Отображение информации о Docker образах
- Проверка логов на наличие информации о версии

## Преимущества новой версии:
- 🛡️ Безопасное обновление с автоматическим резервным копированием
- 📋 Сохранение списков моделей при обновлении Ollama
- 🔍 Возможность проверки версий компонентов
- ⚡ Улучшенная обработка ошибок и информативные сообщения

**Дата создания**: 25.09.2025  
**Версия**: 2.0  
**Автор**: AI Assistant