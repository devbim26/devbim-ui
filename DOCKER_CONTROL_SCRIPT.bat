# Скрипт управления Open WebUI в Docker

## Windows Batch Script (docker-control.bat)

Скопируйте следующий код в файл `docker-control.bat`:

```batch
@echo off
chcp 65001 > nul
title Open WebUI Docker Control
color 0A

:menu
cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║              Open WebUI Docker Control Panel                ║
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
echo 0. Выход
echo.
set /p choice=Выберите действие (0-9): 

if "%choice%"=="1" goto start
if "%choice%"=="2" goto stop
if "%choice%"=="3" goto restart
if "%choice%"=="4" goto status
if "%choice%"=="5" goto logs
if "%choice%"=="6" goto update
if "%choice%"=="7" goto install_model
if "%choice%"=="8" goto list_models
if "%choice%"=="9" goto backup
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

:exit
echo.
echo Спасибо за использование Open WebUI!
echo До свидания!
timeout /t 2 > nul
exit
```

## Bash Script для Linux/Mac (docker-control.sh)

Скопируйте следующий код в файл `docker-control.sh`:

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
    echo -e "${BLUE}║              Open WebUI Docker Control Panel                ║${NC}"
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
    echo -e "${RED}0.${NC} Выход"
    echo
}

# Функция запуска системы
start_system() {
    echo -e "\n${YELLOW}Запуск Open WebUI...${NC}"
    if docker-compose up -d; then
        echo -e "${GREEN}✅ Система успешно запущена!${NC}"
        echo -e "${GREEN}🌐 Доступ: http://localhost:3000${NC}"
    else
        echo -e "${RED}❌ Ошибка при запуске системы${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Функция остановки системы
stop_system() {
    echo -e "\n${YELLOW}Остановка Open WebUI...${NC}"
    if docker-compose down; then
        echo -e "${GREEN}✅ Система успешно остановлена!${NC}"
    else
        echo -e "${RED}❌ Ошибка при остановке системы${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Функция перезапуска системы
restart_system() {
    echo -e "\n${YELLOW}Перезапуск Open WebUI...${NC}"
    if docker-compose restart; then
        echo -e "${GREEN}✅ Система успешно перезапущена!${NC}"
        echo -e "${GREEN}🌐 Доступ: http://localhost:3000${NC}"
    else
        echo -e "${RED}❌ Ошибка при перезапуске системы${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Функция проверки статуса
check_status() {
    echo -e "\n${YELLOW}Проверка статуса контейнеров...${NC}"
    docker-compose ps
    read -p "Нажмите Enter для продолжения..."
}

# Функция просмотра логов
view_logs() {
    echo -e "\n${YELLOW}Просмотр последних 50 строк логов...${NC}"
    docker-compose logs --tail 50
    read -p "Нажмите Enter для продолжения..."
}

# Функция обновления системы
update_system() {
    echo -e "\n${YELLOW}Обновление системы...${NC}"
    docker-compose down
    docker-compose pull
    if docker-compose up -d; then
        echo -e "${GREEN}✅ Система успешно обновлена!${NC}"
    else
        echo -e "${RED}❌ Ошибка при обновлении системы${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Функция установки модели
install_model() {
    echo -e "\n${YELLOW}Установка модели${NC}"
    read -p "Введите название модели (например, llama2): " model_name
    echo -e "${YELLOW}Установка модели $model_name...${NC}"
    if docker exec ollama ollama pull $model_name; then
        echo -e "${GREEN}✅ Модель $model_name успешно установлена!${NC}"
    else
        echo -e "${RED}❌ Ошибка при установке модели $model_name${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Функция списка моделей
list_models() {
    echo -e "\n${YELLOW}Список установленных моделей:${NC}"
    docker exec ollama ollama list
    read -p "Нажмите Enter для продолжения..."
}

# Функция резервного копирования
create_backup() {
    echo -e "\n${YELLOW}Создание резервной копии...${NC}"
    backup_name="backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p backups
    docker run --rm -v open-webui-data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/open-webui-$backup_name.tar.gz -C /data .
    docker run --rm -v ollama-data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/ollama-$backup_name.tar.gz -C /data .
    echo -e "${GREEN}✅ Резервные копии созданы в папке backups${NC}"
    read -p "Нажмите Enter для продолжения..."
}

# Главный цикл
while true; do
    show_menu
    read -p "Выберите действие (0-9): " choice
    
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
1. Скопируйте код Windows Batch Script в файл `docker-control.bat`
2. Сохраните в корневой папке проекта
3. Дважды кликните по файлу для запуска

### Для Linux/Mac:
1. Скопируйте код Bash Script в файл `docker-control.sh`
2. Сделайте файл исполняемым: `chmod +x docker-control.sh`
3. Запустите: `./docker-control.sh`

## Основные функции скрипта:
- 🚀 Запуск и остановка системы
- 🔄 Перезапуск контейнеров
- 📊 Проверка статуса
- 📋 Просмотр логов
- ⬆️ Обновление системы
- 🤖 Управление моделями Ollama
- 💾 Резервное копирование

**Дата создания**: 25.09.2025  
**Версия**: 1.0