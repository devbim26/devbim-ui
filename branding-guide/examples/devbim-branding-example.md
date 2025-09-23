# Пример брендирования Open WebUI → DevBIM

Этот документ показывает конкретный пример превращения стандартного Open WebUI в брендированный DevBIM интерфейс.

## Что было сделано для DevBIM

### 1. Замена логотипов и иконок

**Оригинальные файлы:**
```
static/static/logo.png              # Стандартный логотип Open WebUI
static/static/favicon.ico           # Стандартная иконка
static/static/apple-touch-icon.png # Стандартная иконка iOS
```

**Заменено на DevBIM:**
```
static/static/logo.png              # Логотип DevBIM (синий, минималистичный)
static/static/favicon.ico           # Иконка DevBIM (DB монограмма)
static/static/apple-touch-icon.png  # Иконка DevBIM для iOS
```

### 2. Создание DevBIM темы

**Файл: `static/themes/devbim-theme.css`**
```css
/* DevBIM Brand Theme */
:root {
  /* Основные цвета DevBIM */
  --devbim-primary: #0066cc;        /* DevBIM синий */
  --devbim-secondary: #004499;      /* Темно-синий */
  --devbim-accent: #ff6600;       /* Оранжевый акцент */
  
  /* Цвета текста */
  --text-primary: #1a1a1a;
  --text-secondary: #4a4a4a;
  --text-muted: #8a8a8a;
  --text-on-primary: #ffffff;
  
  /* Фоновые цвета */
  --bg-primary: #ffffff;
  --bg-secondary: #f8f9fa;
  --bg-tertiary: #e9ecef;
  
  /* Границы */
  --border: #dee2e6;
  --border-light: #f1f3f4;
}

/* DevBIM Dark Theme */
[data-theme="dark"] {
  --text-primary: #ffffff;
  --text-secondary: #cccccc;
  --text-muted: #999999;
  
  --bg-primary: #121212;
  --bg-secondary: #1e1e1e;
  --bg-tertiary: #2d2d2d;
  
  --border: #404040;
  --border-light: #2a2a2a;
}

/* Стили DevBIM */
.devbim-theme #nav {
  background: linear-gradient(135deg, var(--devbim-primary), var(--devbim-secondary));
  border-bottom: 2px solid var(--devbim-accent);
}

.devbim-theme .nav-logo {
  height: 32px;
  filter: brightness(0) invert(1); /* Белый логотип на темном фоне */
}

.devbim-theme .btn-primary {
  background: var(--devbim-primary);
  border: 1px solid var(--devbim-secondary);
}

.devbim-theme .btn-primary:hover {
  background: var(--devbim-secondary);
}
```

### 3. Обновление Web App Manifest

**Файл: `static/static/site.webmanifest`**
```json
{
  "name": "DevBIM AI Assistant",
  "short_name": "DevBIM AI",
  "description": "Интеллектуальный ассистент для работы с BIM моделями",
  "icons": [
    {
      "src": "/static/web-app-manifest-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "/static/web-app-manifest-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ],
  "theme_color": "#0066cc",
  "background_color": "#0066cc",
  "display": "standalone"
}
```

### 4. Пользовательские стили DevBIM

**Файл: `static/static/custom.css`**
```css
/* DevBIM Custom Styles */
@import url('/static/themes/devbim-theme.css');

/* Применение темы */
body {
  --primary: #0066cc;
  --secondary: #004499;
  --accent: #ff6600;
}

/* Кастомные стили DevBIM */
.devbim-header {
  background: linear-gradient(135deg, #0066cc, #004499);
  color: white;
  padding: 1rem;
  text-align: center;
}

.devbim-branding {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.devbim-logo-text {
  font-size: 1.5rem;
  font-weight: 700;
  color: white;
}

/* Стили для чата DevBIM */
.devbim-chat-container {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
}

.devbim-message {
  border-left: 3px solid #0066cc;
  background: white;
  margin: 0.5rem 0;
  padding: 1rem;
  border-radius: 0 8px 8px 0;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

/* Кнопки DevBIM */
.devbim-btn {
  background: #0066cc;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 4px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  transition: all 0.3s ease;
}

.devbim-btn:hover {
  background: #004499;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}

/* Акцентные элементы */
.devbim-accent {
  color: #ff6600;
  font-weight: 600;
}

.devbim-accent-bg {
  background: #ff6600;
  color: white;
}
```

## Пошаговая инструкция для повторения

### Шаг 1: Подготовка бренд-ресурсов

Создайте папку с ресурсами:
```
devbim-branding/
├── logo-master.svg          # Векторный логотип DevBIM
├── logo-512.png            # Основной логотип 512x512
├── icon-192.png            # Иконка 192x192
├── icon-512.png            # Иконка 512x512
├── favicon.ico             # Favicon
├── colors.json             # Палитра цветов
└── fonts/                  # Шрифты DevBIM
    └── DevBIM-Font.woff2
```

### Шаг 2: Замена изображений

```bash
# Создайте резервные копии
cd static/static
mkdir backup-original
cp logo.png favicon* apple-touch-icon.png web-app-manifest-*.png splash*.png backup-original/

# Замените на DevBIM ресурсы
cp /path/to/devbim-branding/logo-512.png logo.png
cp /path/to/devbim-branding/favicon.ico favicon.ico
cp /path/to/devbim-branding/icon-192.png web-app-manifest-192x192.png
cp /path/to/devbim-branding/icon-512.png web-app-manifest-512x512.png
```

### Шаг 3: Создание темы DevBIM

Создайте файл `static/themes/devbim-theme.css`:
```css
/* DevBIM Brand Colors */
:root {
  --devbim-primary: #0066cc;
  --devbim-secondary: #004499;
  --devbim-accent: #ff6600;
  --devbim-text: #1a1a1a;
  --devbim-bg: #ffffff;
}

/* Apply DevBIM branding */
.devbim-theme {
  --primary: var(--devbim-primary);
  --secondary: var(--devbim-secondary);
  --accent: var(--devbim-accent);
}

.devbim-theme #nav {
  background: linear-gradient(135deg, var(--devbim-primary), var(--devbim-secondary));
}
```

### Шаг 4: Обновление конфигурации

**Файл: `static/static/site.webmanifest`**
```json
{
  "name": "DevBIM AI Assistant",
  "short_name": "DevBIM AI",
  "theme_color": "#0066cc",
  "background_color": "#0066cc"
}
```

### Шаг 5: Подключение темы

**Файл: `static/static/custom.css`**
```css
@import url('/static/themes/devbim-theme.css');

body {
  font-family: 'Your DevBIM Font', sans-serif;
}

/* DevBIM specific styles */
.devbim-header {
  background: var(--devbim-primary);
  color: white;
}
```

### Шаг 6: Применение в коде

**В HTML/Svelte компонентах:**
```html
<!-- Добавьте класс темы к body -->
<body class="devbim-theme">
  <!-- Ваш контент -->
</body>

<!-- Или используйте data-attribute -->
<body data-theme="devbim">
```

## Результат брендирования

### До (Open WebUI):
- Стандартный синий цвет интерфейса
- Generic логотип
- Стандартные иконки
- Нейтральная цветовая схема

### После (DevBIM):
- Корпоративные цвета DevBIM (#0066cc, #004499, #ff6600)
- Логотип DevBIM на всех носителях
- Брендированные иконки и заставки
- Уникальная тема оформления
- Персонализированный Web App Manifest

## Проверка результата

### Визуальная проверка:
- [ ] Логотип DevBIM отображается в шапке
- [ ] Цвета интерфейса соответствуют бренду DevBIM
- [ ] Иконки DevBIM в браузере и на устройствах
- [ ] Заставка DevBIM при запуске PWA

### Техническая проверка:
- [ ] Все файлы заменены корректно
- [ ] CSS переменные работают
- [ ] Тема переключается светлая/тёмная
- [ ] PWA manifest обновлён
- [ ] Нет ошибок в консоли браузера

## Повторение в другом проекте

Для применения этого подхода к другому бренду:

1. **Замените "DevBIM" на ваш бренд** во всех файлах
2. **Измените цвета** на ваши корпоративные
3. **Подготовьте свои логотипы** по тем же размерам
4. **Следуйте той же структуре файлов**
5. **Используйте предоставленные CSS шаблоны**

### Быстрая замена бренда:
```bash
# Замените все упоминания DevBIM на ваш бренд
find . -name "*.css" -o -name "*.json" -o -name "*.md" | xargs sed -i 's/DevBIM/YourBrand/g'
find . -name "*.css" -o -name "*.json" -o -name "*.md" | xargs sed -i 's/#0066cc/YourPrimaryColor/g'
find . -name "*.css" -o -name "*.json" -o -name "*.md" | xargs sed -i 's/#004499/YourSecondaryColor/g'
find . -name "*.css" -o -name "*.json" -o -name "*.md" | xargs sed -i 's/#ff6600/YourAccentColor/g'
```

Этот пример демонстрирует полный процесс превращения стандартного Open WebUI в брендированное приложение DevBIM с конкретными файлами, кодом и инструкциями для повторения.