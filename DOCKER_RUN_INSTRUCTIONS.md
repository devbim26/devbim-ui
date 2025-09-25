# Инструкция по запуску и управлению Open WebUI в Docker

## 📋 Содержание
- [Быстрый запуск](#-быстрый-запуск)
- [Основные команды](#-основные-команды)
- [Перезапуск системы](#-перезапуск-системы)
- [Остановка системы](#-остановка-системы)
- [Проверка статуса](#-проверка-статуса)
- [Просмотр логов](#-просмотр-логов)
- [Работа с моделями](#-работа-с-моделями)
- [Обновление интерфейса Open WebUI](#-обновление-интерфейса-open-webui)
- [Обновление Ollama](#-обновление-ollama)
- [Резервное копирование](#-резервное-копирование)
- [Восстановление](#-восстановление)
- [Решение проблем](#-решение-проблем)

## 🚀 Быстрый запуск

### Первый запуск
```bash
# Запуск всей системы
docker-compose up -d

# Проверка статуса
docker-compose ps

# Просмотр логов
docker-compose logs -f
```

### Доступ к системе
- **Веб-интерфейс**: http://localhost:3000
- **Ollama API**: http://localhost:11434

## 🔄 Основные команды

### Запуск системы
```bash
# Запуск в фоновом режиме
docker-compose up -d

# Запуск с выводом логов в консоль
docker-compose up
```

### Перезапуск системы
```bash
# Мягкий перезапуск (сохранение данных)
docker-compose restart

# Перезапуск с обновлением образов
docker-compose down
docker-compose pull
docker-compose up -d
```

### Остановка системы
```bash
# Остановка без удаления контейнеров
docker-compose stop

# Остановка и удаление контейнеров
docker-compose down

# Остановка с удалением контейнеров и томов (ВНИМАНИЕ: удалит все данные!)
docker-compose down -v
```

## 📊 Проверка статуса

### Проверка всех сервисов
```bash
# Статус контейнеров
docker-compose ps

# Статус всех контейнеров (включая остановленные)
docker ps -a

# Подробная информация о контейнерах
docker-compose ps -v
```

### Проверка ресурсов
```bash
# Использование ресурсов
docker stats

# Использование диска
docker system df
```

## 📋 Просмотр логов

### Просмотр логов всех сервисов
```bash
# Логи всех сервисов
docker-compose logs

# Логи с отслеживанием изменений
docker-compose logs -f

# Логи за последние 100 строк
docker-compose logs --tail 100
```

### Просмотр логов конкретного сервиса
```bash
# Логи Open WebUI
docker-compose logs open-webui

# Логи Ollama
docker-compose logs ollama

# Логи с фильтрацией по времени
docker-compose logs open-webui --since 1h
```

## 🤖 Работа с моделями

### Просмотр установленных моделей
```bash
# Список моделей в Ollama
docker exec ollama ollama list

# Информация о конкретной модели
docker exec ollama ollama show gemma2:latest
```

### Установка новых моделей
```bash
# Установка модели (пример: llama2)
docker exec ollama ollama pull llama2

# Установка модели с определенным тегом
docker exec ollama ollama pull mistral:latest
```

### Удаление моделей
```bash
# Удаление модели
docker exec ollama ollama rm model_name
```

## 🔄 Обновление интерфейса Open WebUI

### Обновление через Docker Compose
```bash
# Остановка текущей версии
docker-compose down

# Обновление образа Open WebUI
docker pull ghcr.io/open-webui/open-webui:main

# Запуск с новой версией
docker-compose up -d
```

### Обновление с сохранением данных
```bash
# Создание резервной копии перед обновлением
docker run --rm -v open-webui-data:/data -v $(pwd):/backup alpine tar czf /backup/open-webui-pre-update-backup.tar.gz -C /data .

# Обновление
docker-compose down
docker-compose pull
docker-compose up -d

# Проверка работы
docker-compose logs open-webui --tail 50
```

### Обновление до конкретной версии
```bash
# Указание версии в docker-compose.yaml
# Измените строку image: на нужную версию, например:
# image: ghcr.io/open-webui/open-webui:v1.0.0

# Применение изменений
docker-compose down
docker-compose up -d
```

### Проверка версии после обновления
```bash
# Проверка логов на наличие информации о версии
docker-compose logs open-webui | grep -i version

# Проверка через веб-интерфейс
# Версия отображается в настройках или нижней части страницы
```

## 🦙 Обновление Ollama

### Обновление Ollama до последней версии
```bash
# Остановка Ollama
docker-compose stop ollama

# Обновление образа Ollama
docker pull ollama/ollama:latest

# Запуск обновленного Ollama
docker-compose up -d ollama

# Проверка версии
docker exec ollama ollama --version
```

### Обновление с сохранением моделей
```bash
# Создание списка установленных моделей
docker exec ollama ollama list > ollama_models_backup.txt

# Обновление Ollama
docker-compose stop ollama
docker pull ollama/ollama:latest
docker-compose up -d ollama

# Проверка сохранности моделей
docker exec ollama ollama list
```

### Обновление Ollama WebUI
```bash
# Если используется отдельный контейнер для WebUI
docker-compose stop ollama-webui
docker pull ollama/ollama-webui:latest
docker-compose up -d ollama-webui
```

### Проверка работы после обновления
```bash
# Проверка статуса Ollama
docker-compose ps ollama

# Проверка API
curl http://localhost:11434/api/tags

# Проверка логов
docker-compose logs ollama --tail 30
```

### Откат к предыдущей версии Ollama
```bash
# Остановка текущей версии
docker-compose stop ollama

# Указание предыдущей версии в docker-compose.yaml
# image: ollama/ollama:0.1.32

# Запуск предыдущей версии
docker-compose up -d ollama
```

## 💾 Резервное копирование

### Создание резервной копии данных
```bash
# Создание архива с данными Open WebUI
docker run --rm -v open-webui-data:/data -v $(pwd):/backup alpine tar czf /backup/open-webui-backup.tar.gz -C /data .

# Создание архива с данными Ollama
docker run --rm -v ollama-data:/data -v $(pwd):/backup alpine tar czf /backup/ollama-backup.tar.gz -C /data .
```

### Резервное копирование настроек
```bash
# Сохранение списка моделей
docker exec ollama ollama list > models_backup.txt
```

## 🔄 Восстановление

### Восстановление из резервной копии
```bash
# Восстановление данных Open WebUI
docker run --rm -v open-webui-data:/data -v $(pwd):/backup alpine tar xzf /backup/open-webui-backup.tar.gz -C /data

# Восстановление данных Ollama
docker run --rm -v ollama-data:/data -v $(pwd):/backup alpine tar xzf /backup/ollama-backup.tar.gz -C /data
```

## 🔧 Решение проблем

### Контейнер не запускается
```bash
# Проверка логов ошибок
docker-compose logs [service-name]

# Перезапуск с очисткой кэша
docker-compose down
docker system prune -f
docker-compose up -d
```

### Проблемы с подключением к Ollama
```bash
# Проверка доступности Ollama
docker exec open-webui curl -f http://ollama:11434/api/tags

# Перезапуск Ollama
docker-compose restart ollama
```

### Проблемы с производительностью
```bash
# Проверка использования ресурсов
docker stats

# Очистка неиспользуемых образов
docker image prune -a

# Очистка системы
docker system prune -a
```

### Сброс настроек
```bash
# Полная очистка и перезапуск
docker-compose down -v
docker-compose up -d
```

## 📋 Полезные команды

### Обновление системы
```bash
# Остановка текущей версии
docker-compose down

# Обновление образов
docker-compose pull

# Запуск новой версии
docker-compose up -d
```

### Мониторинг
```bash
# Мониторинг ресурсов в реальном времени
docker stats

# Просмотр событий Docker
docker events

# Проверка логов системы
docker system events
```

### Работа с томами
```bash
# Список томов
docker volume ls

# Информация о томе
docker volume inspect open-webui-data

# Удаление неиспользуемых томов
docker volume prune
```

## ⚠️ Важные замечания

1. **Сохранение данных**: Все данные сохраняются в Docker томах (`open-webui-data` и `ollama-data`)
2. **Порты**: Убедитесь, что порты 3000 и 11434 свободны
3. **Ресурсы**: Для стабильной работы рекомендуется минимум 4GB RAM
4. **Бэкапы**: Регулярно создавайте резервные копии важных данных

## 🆘 Экстренные ситуации

### Полный сброс системы
```bash
# Остановка и удаление всего
docker-compose down -v
docker system prune -a

# Запуск с чистого листа
docker-compose up -d
```

### Получение помощи
```bash
# Информация о системе
docker system info

# Состояние всех контейнеров
docker ps -a

# Логи всех сервисов
docker-compose logs --tail 50
```

---

**Дата создания**: 25.09.2025  
**Версия**: 1.0  
**Автор**: AI Assistant