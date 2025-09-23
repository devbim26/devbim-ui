# Руководство по внедрению DevBIM брендинга

## Конкретные примеры замен Open WebUI → DevBIM

### 1. Замена в конфигурационных файлах

**backend/config.py:**
```python
# Было:
APP_NAME = "Open WebUI"
APP_DESCRIPTION = "User-friendly WebUI for LLMs"
DEFAULT_MODELS = "gpt-3.5-turbo,gpt-4"

# Стало (DevBIM):
APP_NAME = "DevBIM AI Assistant"
APP_DESCRIPTION = "Интеллектуальный ассистент для BIM моделей"
DEFAULT_MODELS = "gpt-3.5-turbo,gpt-4,claude-3"
```

**package.json:**
```json
{
  "name": "devbim-ai",
  "version": "1.0.0",
  "description": "Интеллектуальный ассистент для работы с BIM моделями",
  "author": "DevBIM Team",
  "license": "MIT"
}
```

### 2. Замена в HTML и мета-тегах

**src/app.html:**
```html
<!-- Было: -->
<head>
  <title>Open WebUI</title>
  <meta name="description" content="Open WebUI - User-friendly WebUI for LLMs">
  <meta name="author" content="Open WebUI Team">
</head>

<!-- Стало (DevBIM): -->
<head>
  <title>DevBIM AI Assistant</title>
  <meta name="description" content="DevBIM AI - Интеллектуальный ассистент для BIM моделей">
  <meta name="author" content="DevBIM Team">
  <meta name="keywords" content="BIM, AI, DevBIM, архитектура, строительство">
</head>
```

### 3. Замена в Svelte компонентах

**src/lib/components/layout/Navbar.svelte:**
```svelte
<!-- Было: -->
<div class="flex items-center">
  <img src="/static/logo.png" alt="Open WebUI" class="h-8 w-auto" />
  <span class="ml-2 text-xl font-semibold text-gray-900 dark:text-gray-100">
    Open WebUI
  </span>
</div>

<!-- Стало (DevBIM): -->
<div class="flex items-center devbim-branding">
  <img src="/static/logo.png" alt="DevBIM" class="h-8 w-auto" />
  <span class="ml-2 text-xl font-semibold text-devbim-primary">
    DevBIM AI
  </span>
  <span class="ml-1 text-xs text-devbim-accent font-medium">BETA</span>
</div>
```

**src/lib/components/chat/Chat.svelte:**
```svelte
<!-- Было: -->
<div class="text-center text-gray-500 dark:text-gray-400">
  <h1 class="text-4xl font-bold mb-4">Open WebUI</h1>
  <p class="text-lg">User-friendly WebUI for LLMs</p>
</div>

<!-- Стало (DevBIM): -->
<div class="text-center text-devbim-gray-500">
  <h1 class="text-4xl font-bold mb-4 text-devbim-primary">DevBIM AI</h1>
  <p class="text-lg">Интеллектуальный ассистент для BIM моделей</p>
  <p class="text-sm text-devbim-accent mt-2">Постройте будущее с ИИ</p>
</div>
```

### 4. Замена в JavaScript константах

**src/lib/constants.ts:**
```typescript
// Было:
export const APP_NAME = 'Open WebUI';
export const APP_DESCRIPTION = 'User-friendly WebUI for LLMs';
export const DEFAULT_TITLE = 'Open WebUI - Chat';
export const DEFAULT_DESCRIPTION = 'Chat with AI models';

// Стало (DevBIM):
export const APP_NAME = 'DevBIM AI Assistant';
export const APP_DESCRIPTION = 'Интеллектуальный ассистент для BIM моделей';
export const DEFAULT_TITLE = 'DevBIM AI - Чат';
export const DEFAULT_DESCRIPTION = 'Общайтесь с ИИ для работы с BIM';
export const BIM_MODELS = ['Revit', 'ArchiCAD', 'Tekla', 'Navisworks'];
```

### 5. Замена в CSS переменных

**static/themes/devbim-theme.css:**
```css
/* Было: стандартные цвета Open WebUI */
:root {
  --primary: #3b82f6;
  --secondary: #64748b;
  --accent: #10b981;
}

/* Стало: цвета DevBIM */
:root {
  --devbim-primary: #0066cc;
  --devbim-secondary: #004499;
  --devbim-accent: #ff6600;
  --devbim-success: #28a745;
  --devbim-warning: #ffc107;
}

.devbim-theme {
  --primary: var(--devbim-primary);
  --secondary: var(--devbim-secondary);
  --accent: var(--devbim-accent);
}
```

### 6. Замена в API и эндпоинтах

**backend/open_webui/main.py:**
```python
# Было:
@app.get("/api/config")
async def get_config():
    return {
        "name": "Open WebUI",
        "version": "1.0.0",
        "description": "User-friendly WebUI for LLMs"
    }

# Стало (DevBIM):
@app.get("/api/config")
async def get_config():
    return {
        "name": "DevBIM AI Assistant",
        "version": "1.0.0",
        "description": "Интеллектуальный ассистент для BIM моделей",
        "features": ["bim-analysis", "model-optimization", "clash-detection"]
    }
```

## Пошаговая инструкция внедрения

### Шаг 1: Подготовка ресурсов DevBIM
```bash
mkdir devbim-assets
# Создайте или получите:
# - logo-512.png (512x512px)
# - favicon.ico (многоразмерный)
# - icon-192.png (192x192px)
# - icon-512.png (512x512px)
# - apple-touch-icon.png (180x180px)
```

### Шаг 2: Замена изображений
```bash
# Создайте резервную копию
cp -r static/static static-backup-$(date +%Y%m%d)

# Замените изображения
cp devbim-assets/logo-512.png static/static/logo.png
cp devbim-assets/favicon.ico static/static/favicon.ico
cp devbim-assets/icon-192.png static/static/web-app-manifest-192x192.png
cp devbim-assets/icon-512.png static/static/web-app-manifest-512x512.png
```

### Шаг 3: Создание DevBIM темы
```bash
# Создайте тему
cat > static/themes/devbim-theme.css << 'EOF'
/* DevBIM Brand Theme */
.devbim-theme {
  --primary: #0066cc;
  --secondary: #004499;
  --accent: #ff6600;
}

.devbim-theme #nav {
  background: linear-gradient(135deg, #0066cc, #004499);
  border-bottom: 2px solid #ff6600;
}
EOF
```

### Шаг 4: Обновление конфигурации
```bash
# Обновите manifest
cat > static/static/site.webmanifest << 'EOF'
{
  "name": "DevBIM AI Assistant",
  "short_name": "DevBIM AI",
  "theme_color": "#0066cc",
  "background_color": "#0066cc"
}
EOF
```

### Шаг 5: Применение темы
```bash
# Обновите custom.css
cat > static/static/custom.css << 'EOF'
@import url('/static/themes/devbim-theme.css');

body {
  font-family: 'Inter', sans-serif;
}

.devbim-branding {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.devbim-logo-text {
  color: #0066cc;
  font-weight: 700;
}
EOF
```

## Проверка результата

### Визуальная проверка:
```bash
# Проверьте все замененные элементы
echo "Проверка DevBIM брендинга:"
echo "✓ Логотип DevBIM в шапке"
echo "✓ Цвета интерфейса #0066cc, #004499, #ff6600"
echo "✓ Иконки DevBIM в браузере"
echo "✓ Название 'DevBIM AI Assistant'"
echo "✓ Описание на русском языке"
```

### Техническая проверка:
```bash
# Проверьте файлы
ls -la static/static/logo.png
ls -la static/static/favicon.ico
ls -la static/themes/devbim-theme.css
ls -la static/static/custom.css
ls -la static/static/site.webmanifest

# Проверьте размеры изображений
file static/static/logo.png
file static/static/favicon.ico
```

## Результат для повторения

После выполнения всех шагов получаем:

### Визуальные изменения:
- Логотип DevBIM вместо Open WebUI
- Синяя цветовая схема #0066cc
- Оранжевые акценты #ff6600
- Русскоязычные описания

### Технические изменения:
- Обновленный Web App Manifest
- DevBIM тема в CSS
- Новые иконки и изображения
- Обновленные константы и тексты

Этот подход можно повторить для любого другого бренда, заменив "DevBIM" на нужный бренд и соответствующие цвета.