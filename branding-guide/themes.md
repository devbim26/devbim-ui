# Создание тем

## Обзор системы тем

Open WebUI поддерживает систему тем, которая позволяет полностью изменить внешний вид приложения. Темы основаны на CSS классах и переменных.

## Структура темы

### Базовая структура

```css
/* Название темы */
.your-theme-name {
  /* Переменные цветов */
  --primary: #your-color;
  --secondary: #your-color;
  
  /* Стили компонентов */
  background-color: var(--bg-primary);
  color: var(--text-primary);
}
```

### Пример простой темы

```css
/* blue-theme.css */
.blue-theme {
  /* Основные цвета */
  --primary: #2563eb;
  --secondary: #64748b;
  --accent: #06b6d4;
  
  /* Цвета текста */
  --text-primary: #1e293b;
  --text-secondary: #475569;
  --text-muted: #64748f;
  
  /* Фоновые цвета */
  --bg-primary: #ffffff;
  --bg-secondary: #f8fafc;
  --bg-muted: #f1f5f9;
  
  /* Границы */
  --border: #e2e8f0;
  --border-light: #f1f5f9;
}

/* Тёмная версия темы */
.blue-theme.dark {
  --text-primary: #f1f5f9;
  --text-secondary: #cbd5e1;
  --text-muted: #94a3b8;
  
  --bg-primary: #0f172a;
  --bg-secondary: #1e293b;
  --bg-muted: #334155;
  
  --border: #334155;
  --border-light: #475569;
}
```

## Создание новой темы

### Шаг 1: Анализ бренда

Определите ключевые цвета вашего бренда:

```css
/* Пример извлечения цветов из бренда */
.brand-theme {
  /* Основной цвет логотипа */
  --primary: #ff6b35;
  
  /* Вторичный цвет бренда */
  --secondary: #004e89;
  
  /* Акцентный цвет */
  --accent: #ffd23f;
  
  /* Нейтральные цвета из палитры */
  --neutral-50: #fafafa;
  --neutral-100: #f5f5f5;
  /* ... */
}
```

### Шаг 2: Создание CSS файла

Создайте новый файл в папке `static/themes/`:

```css
/* static/themes/your-brand.css */

/* Светлая тема */
.your-brand {
  /* Цветовая палитра */
  --primary-hue: 210;
  --primary-saturation: 50%;
  --primary-lightness: 50%;
  
  --primary: hsl(var(--primary-hue), var(--primary-saturation), var(--primary-lightness));
  --primary-dark: hsl(var(--primary-hue), var(--primary-saturation), calc(var(--primary-lightness) - 10%));
  --primary-light: hsl(var(--primary-hue), var(--primary-saturation), calc(var(--primary-lightness) + 10%));
  
  /* Текст */
  --text-primary: #1a1a1a;
  --text-secondary: #4a4a4a;
  --text-muted: #8a8a8a;
  --text-on-primary: #ffffff;
  
  /* Фоны */
  --bg-primary: #ffffff;
  --bg-secondary: #f8f9fa;
  --bg-tertiary: #e9ecef;
  --bg-accent: var(--primary-light);
  
  /* Границы */
  --border: #dee2e6;
  --border-light: #f1f3f4;
  
  /* Состояния */
  --hover: rgba(0, 0, 0, 0.04);
  --active: rgba(0, 0, 0, 0.08);
  --disabled: rgba(0, 0, 0, 0.26);
  
  /* Тени */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
}

/* Тёмная тема */
.your-brand.dark {
  --text-primary: #ffffff;
  --text-secondary: #b3b3b3;
  --text-muted: #666666;
  --text-on-primary: #ffffff;
  
  --bg-primary: #121212;
  --bg-secondary: #1e1e1e;
  --bg-tertiary: #2d2d2d;
  --bg-accent: var(--primary-dark);
  
  --border: #404040;
  --border-light: #2a2a2a;
  
  --hover: rgba(255, 255, 255, 0.08);
  --active: rgba(255, 255, 255, 0.12);
  --disabled: rgba(255, 255, 255, 0.3);
  
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.4);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.5);
}
```

### Шаг 3: Стилизация компонентов

```css
/* Стили для специфических компонентов */

/* Навигационная панель */
.your-brand #nav {
  background-color: var(--bg-primary);
  border-bottom: 1px solid var(--border);
  box-shadow: var(--shadow-sm);
}

/* Чат контейнер */
.your-brand .chat-container {
  background-color: var(--bg-secondary);
}

/* Сообщения */
.your-brand .message {
  background-color: var(--bg-primary);
  border: 1px solid var(--border);
  border-radius: 8px;
  box-shadow: var(--shadow-sm);
}

/* Поле ввода */
.your-brand #chat-input {
  background-color: var(--bg-primary);
  border: 1px solid var(--border);
  border-radius: 8px;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.your-brand #chat-input:focus {
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(var(--primary-rgb), 0.1);
}

/* Кнопки */
.your-brand .btn-primary {
  background-color: var(--primary);
  color: var(--text-on-primary);
  border: none;
  border-radius: 6px;
  padding: 0.5rem 1rem;
  font-weight: 500;
  transition: all 0.2s;
}

.your-brand .btn-primary:hover {
  background-color: var(--primary-dark);
  transform: translateY(-1px);
  box-shadow: var(--shadow-md);
}

/* Скроллбар */
.your-brand ::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

.your-brand ::-webkit-scrollbar-track {
  background: var(--bg-secondary);
}

.your-brand ::-webkit-scrollbar-thumb {
  background: var(--border);
  border-radius: 4px;
}

.your-brand ::-webkit-scrollbar-thumb:hover {
  background: var(--text-muted);
}
```

## Продвинутые техники

### Использование CSS переменных в RGB формате

```css
.your-brand {
  /* Конвертация HEX в RGB для использования с прозрачностью */
  --primary-rgb: 59, 130, 246;
  --primary: rgb(var(--primary-rgb));
  
  /* Использование с прозрачностью */
  --primary-alpha-10: rgba(var(--primary-rgb), 0.1);
  --primary-alpha-20: rgba(var(--primary-rgb), 0.2);
}
```

### Градиенты

```css
.your-brand {
  /* Простые градиенты */
  --gradient-primary: linear-gradient(135deg, var(--primary), var(--primary-dark));
  --gradient-secondary: linear-gradient(135deg, var(--secondary), var(--accent));
  
  /* Сложные градиенты */
  --gradient-header: linear-gradient(
    135deg,
    hsl(var(--primary-hue), 50%, 50%) 0%,
    hsl(calc(var(--primary-hue) + 30), 50%, 50%) 100%
  );
}

/* Применение градиентов */
.your-brand .header {
  background: var(--gradient-header);
}
```

### Анимации

```css
.your-brand {
  /* Переходы */
  --transition-fast: 0.15s ease-out;
  --transition-normal: 0.25s ease-out;
  --transition-slow: 0.35s ease-out;
  
  /* Анимации */
  --animation-fade-in: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.your-brand .fade-in {
  animation: var(--animation-fade-in);
}
```

## Подключение темы

### Способ 1: Через пользовательские стили

Добавьте в `static/static/custom.css`:

```css
/* Импортируйте вашу тему */
@import url('/static/themes/your-brand.css');

/* Примените тему к body */
body {
  /* Ваша тема будет применена автоматически */
}
```

### Способ 2: Через JavaScript

```javascript
// Добавьте класс темы к body
document.body.classList.add('your-brand');

// Для тёмной темы
if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
  document.body.classList.add('dark');
}
```

## Тестирование темы

### Тестовые сценарии

1. **Светлая/тёмная тема**: Проверьте оба варианта
2. **Разные устройства**: Десктоп, планшет, мобильный
3. **Разные браузеры**: Chrome, Firefox, Safari, Edge
4. **Контрастность**: Убедитесь в читаемости текста
5. **Производительность**: Проверьте скорость загрузки

### Инструменты для тестирования

```css
/* Временные стили для тестирования */
.test-borders * {
  border: 1px solid red !important;
}

.test-colors {
  /* Показать все цветовые переменные */
  --debug: ;
}
```

## Примеры готовых тем

### Минималистичная тема

```css
.minimal {
  --primary: #000000;
  --secondary: #666666;
  --accent: #cccccc;
  
  --text-primary: #000000;
  --text-secondary: #666666;
  --text-muted: #999999;
  
  --bg-primary: #ffffff;
  --bg-secondary: #fafafa;
  --bg-muted: #f5f5f5;
  
  --border: #e0e0e0;
  --border-light: #f0f0f0;
  
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}
```

### Яркая тема

```css
.vibrant {
  --primary: #ff0080;
  --secondary: #00ff80;
  --accent: #8000ff;
  
  --text-primary: #1a0033;
  --text-secondary: #4d0099;
  --text-muted: #8000ff;
  
  --bg-primary: #ffffff;
  --bg-secondary: #f0e6ff;
  --bg-muted: #e6d6ff;
  
  --border: #d9b3ff;
  --border-light: #f0e6ff;
}
```

## Советы по созданию тем

1. **Начните с базовых цветов**: primary, secondary, accent
2. **Используйте HSL**: Легче создавать вариации цвета
3. **Тестируйте контрастность**: WCAG 2.1 AA стандарт
4. **Делайте тему последовательной**: Используйте систему цветов
5. **Документируйте**: Добавляйте комментарии к CSS
6. **Оптимизируйте**: Минимизируйте размер CSS файла