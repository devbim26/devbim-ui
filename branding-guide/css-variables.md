# CSS переменные и стили

## Основные CSS переменные

Open WebUI использует CSS переменные для управления цветами и стилями. Вот основные переменные, которые вы можете переопределить:

### Цветовая палитра

```css
:root {
  /* Основные цвета */
  --primary: #3b82f6;           /* Главный цвет бренда */
  --secondary: #64748b;         /* Вторичный цвет */
  --accent: #10b981;            /* Акцентный цвет */
  
  /* Цвета текста */
  --text-primary: #1f2937;      /* Основной текст */
  --text-secondary: #6b7280;    /* Вторичный текст */
  --text-muted: #9ca3af;        /* Приглушенный текст */
  
  /* Фоновые цвета */
  --bg-primary: #ffffff;        /* Основной фон */
  --bg-secondary: #f9fafb;      /* Вторичный фон */
  --bg-muted: #f3f4f6;          /* Приглушенный фон */
  
  /* Границы */
  --border: #e5e7eb;            /* Цвет границ */
  --border-light: #f3f4f6;      /* Светлая граница */
  
  /* Состояния */
  --hover: #f3f4f6;             /* Цвет при наведении */
  --active: #e5e7eb;            /* Цвет при активации */
  --disabled: #9ca3af;          /* Цвет отключенного состояния */
}
```

### Темная тема

```css
.dark {
  /* Цвета текста для темной темы */
  --text-primary: #f9fafb;
  --text-secondary: #e5e7eb;
  --text-muted: #d1d5db;
  
  /* Фоновые цвета для темной темы */
  --bg-primary: #111827;
  --bg-secondary: #1f2937;
  --bg-muted: #374151;
  
  /* Границы для темной темы */
  --border: #374151;
  --border-light: #4b5563;
  
  /* Состояния для темной темы */
  --hover: #374151;
  --active: #4b5563;
}
```

## Компоненты и их стили

### Шапка приложения

```css
/* Навигационная панель */
#nav {
  background-color: var(--bg-primary);
  border-bottom: 1px solid var(--border);
}

/* Логотип в шапке */
.nav-logo {
  height: 32px;
  width: auto;
}
```

### Чат интерфейс

```css
/* Контейнер чата */
.chat-container {
  background-color: var(--bg-secondary);
}

/* Сообщения */
.message {
  background-color: var(--bg-primary);
  border: 1px solid var(--border);
  color: var(--text-primary);
}

/* Поле ввода */
#chat-input {
  background-color: var(--bg-primary);
  border: 1px solid var(--border);
  color: var(--text-primary);
}
```

### Кнопки

```css
/* Основная кнопка */
.btn-primary {
  background-color: var(--primary);
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 0.375rem;
  transition: all 0.2s;
}

.btn-primary:hover {
  background-color: color-mix(in srgb, var(--primary) 90%, black);
}

/* Вторичная кнопка */
.btn-secondary {
  background-color: var(--bg-secondary);
  color: var(--text-primary);
  border: 1px solid var(--border);
}
```

## Пользовательские стили

Создайте файл `static/static/custom.css` и добавьте свои стили:

```css
/* Переопределение переменных */
:root {
  --primary: #your-brand-color;
  --secondary: #your-secondary-color;
}

/* Кастомные стили для специфических элементов */
.custom-header {
  background: linear-gradient(135deg, var(--primary), var(--secondary));
}

/* Анимации */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.fade-in {
  animation: fadeIn 0.3s ease-out;
}
```

## Типографика

### Шрифты

```css
/* Подключение кастомных шрифтов */
@font-face {
  font-family: 'YourBrandFont';
  src: url('/static/assets/fonts/your-font.woff2') format('woff2');
  font-weight: normal;
  font-style: normal;
  font-display: swap;
}

/* Применение шрифта */
body {
  font-family: 'YourBrandFont', -apple-system, BlinkMacSystemFont, sans-serif;
}

/* Заголовки */
h1, h2, h3 {
  font-weight: 700;
  letter-spacing: -0.025em;
}
```

## Резиновый дизайн

```css
/* Адаптивные стили */
@media (max-width: 768px) {
  .nav-logo {
    height: 24px;
  }
  
  .chat-container {
    padding: 0.5rem;
  }
}

@media (min-width: 1024px) {
  .container {
    max-width: 1200px;
    margin: 0 auto;
  }
}
```

## Переходы и анимации

```css
/* Плавные переходы */
.transition-all {
  transition: all 0.2s ease-in-out;
}

.transition-colors {
  transition: background-color 0.2s, color 0.2s, border-color 0.2s;
}

/* Ховер эффекты */
.hover\:scale-105:hover {
  transform: scale(1.05);
}

.hover\:shadow-lg:hover {
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}
```

## Советы по кастомизации

1. **Используйте CSS переменные** - это облегчит поддержку и изменения
2. **Тестируйте в обеих темах** - светлой и тёмной
3. **Проверяйте контрастность** - текст должен быть читаемым
4. **Минимизируйте изменения** - изменяйте только необходимое
5. **Документируйте изменения** - комментируйте свои стили

## Отладка стилей

Используйте браузерные инструменты разработчика (F12) для:

- Просмотра применённых стилей
- Тестирования изменений в реальном времени
- Проверки адаптивности
- Анализа производительности