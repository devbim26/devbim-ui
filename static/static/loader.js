// @ts-nocheck
(function() {
  'use strict';
  
  console.log('🚀 DevBIM: Запуск скрипта блокировки и замены текста');
  
  // Блокируем всплывающие окна сразу при загрузке (деликатно: удаляем целиком модальные узлы)
  function blockPopups() {
    try {
      // Кандидаты на модальные окна/оверлеи
      const selectors = [
        '[role="dialog"]',
        '[aria-modal="true"]',
        '[data-modal]',
        '.modal',
        '.modal-content',
        '.modal-overlay',
        '.onboarding-modal',
        '.welcome-modal',
        '[class*="welcome"]',
        '[class*="onboarding"]',
        '[class*="whats-new"]',
        '[class*="changelog"]',
        '.update-modal',
        '.update-info'
      ];
  
      const nodes = new Set();
      selectors.forEach(sel => document.querySelectorAll(sel).forEach(n => nodes.add(n)));
  
      nodes.forEach(node => {
        const txt = (node.textContent || '').toLowerCase();
        // Фильтруем по смыслу, чтобы не задеть обычные блоки
        if (
          txt.includes("what's new") ||
          txt.includes('что нового') ||
          txt.includes('changelog') ||
          txt.includes('обновлен') ||
          txt.includes('welcome') ||
          txt.includes('onboarding')
        ) {
          // Удаляем модалку и её backdrop
          const backdrop = node.parentElement?.querySelector?.('[class*="backdrop"],[class*="overlay"],.fixed.inset-0');
          try { backdrop && backdrop.remove(); } catch {}
          try { node.remove(); } catch {}
        }
      });
    } catch (e) {
      console.debug('DevBIM popup-block skip:', e);
    }
  }
  
  // Запускаем блокировку сразу и в первые секунды многократно, чтобы убрать всплывашку до клика
  blockPopups();
  (function burstBlock() {
    let t = 0;
    const id = setInterval(() => {
      blockPopups();
      if ((t += 1) > 20) clearInterval(id); // ~5 секунд при 250мс
    }, 250);
  })();
  
  // Перехватываем fetch для изменения данных из /api/config и i18n
  const originalFetch = window.fetch;
  window.fetch = async function(...args) {
    const response = await originalFetch.apply(this, args);
    
    // Проверяем, не является ли это запросом к i18n переводам
    const url = typeof args[0] === 'string' ? args[0] : (args[0].url || args[0].toString());
    // Подмена источника чейнджлога на локальный файл /static/devbim-changelog.json
    if (url && url.indexOf('/api/changelog') !== -1) {
      try {
        const localUrl = `${location.origin}/static/devbim-changelog.json?v=${Date.now()}`;
        const local = await originalFetch.call(this, localUrl, { cache: 'no-store' });
        const data = await local.json();
        return new Response(JSON.stringify(data), {
          status: 200,
          statusText: 'OK',
          headers: { 'Content-Type': 'application/json' }
        });
      } catch (e) {
        console.debug('DevBIM changelog local override failed, falling back to server:', e);
        // Вернём оригинальный ответ сервера, если нет локального файла
      }
    }
    if (url && (url.includes('translation') || url.includes('i18n') || url.includes('locale') || url.includes('.json'))) {
      try {
        const clonedResponse = response.clone();
        const data = await clonedResponse.json();
        
        // Заменяем в данных перевода
        if (data['Made by Open WebUI Community']) {
          data['Made by Open WebUI Community'] = 'Made by DevBIM Community';
          console.log('🌍 DevBIM: Заменен перевод в i18n данных');
        }
        
        // Заменяем другие варианты
        for (var key in data) {
          if (key.includes('Open WebUI')) {
            data[key] = data[key].replace(/Open WebUI/g, 'DevBIM');
          }
          if (data[key] && typeof data[key] === 'string') {
            data[key] = data[key].replace(/Made by Open WebUI Community/g, 'Made by DevBIM Community');
            data[key] = data[key].replace(/Сделано сообществом OpenWebUI/g, 'Сделано сообществом DevBIM');
            data[key] = data[key].replace(/Сделано сообществом Open WebUI/g, 'Сделано сообществом DevBIM');
          }
        }
        
        return new Response(JSON.stringify(data), {
          status: response.status,
          statusText: response.statusText,
          headers: response.headers
        });
      } catch (e) {
        console.log('❌ DevBIM: Ошибка при обработке i18n данных:', e);
      }
    }
    
    // Проверяем, что это запрос к /api/config
    if (url && url.indexOf('/api/config') !== -1) {
      const clonedResponse = response.clone();
      const data = await clonedResponse.json();
      
      // Заменяем имя бренда
      if (data.name) {
        data.name = 'DevBIM';
      }
      
      // Создаем новый response с измененными данными
      const newResponse = new Response(JSON.stringify(data), {
        status: response.status,
        statusText: response.statusText,
        headers: response.headers
      });
      
      // Также обновляем заголовок страницы
      document.title = document.title.replace(/Open WebUI/g, 'DevBIM');
      
      return newResponse;
    }
    
    return response;
  };
  
  // Раннее обновление DOM при загрузке
  function updateBrandEarly() {
    // Находим элемент с текстом бренда в сайдбаре
    const brandElement = document.querySelector('#sidebar .sidebar a.flex.flex-1.px-1\\.5 > div.font-primary');
    if (brandElement && brandElement.textContent && brandElement.textContent.indexOf('Open WebUI') !== -1) {
      brandElement.textContent = 'DevBIM';
    }
    
    // Обновляем заголовок страницы
    if (document.title && document.title.indexOf('Open WebUI') !== -1) {
      document.title = document.title.replace(/Open WebUI/g, 'DevBIM');
    }
    
    // Улучшенная функция замены текста с учетом i18n
    function replaceText(element) {
        if (!element || !element.textContent) return;
        
        const text = element.textContent;
        let newText = text;
        
        // Замена для английского языка
        newText = newText.replace(/Made by Open WebUI Community/g, 'Made by DevBIM Community');
        newText = newText.replace(/Open WebUI/g, 'DevBIM');
        
        // Замена для русского языка
        newText = newText.replace(/Сделано сообществом OpenWebUI/g, 'Сделано сообществом DevBIM');
        newText = newText.replace(/Сделано сообществом Open WebUI/g, 'Сделано сообществом DevBIM');
        
        // Замена для других языков (основные переводы)
        newText = newText.replace(/Réalisé par la communauté OpenWebUI/g, 'Réalisé par la communauté DevBIM');
        newText = newText.replace(/Von der OpenWebUI-Community/g, 'Von der DevBIM-Community');
        newText = newText.replace(/Realizzato dalla Comunità Open WebUI/g, 'Realizzato dalla Comunità DevBIM');
        newText = newText.replace(/Creado por la Comunidad Open-WebUI/g, 'Creado por la Comunidad DevBIM');
        newText = newText.replace(/Feito pela Comunidade OpenWebUI/g, 'Feito pela Comunidade DevBIM');
        
        if (newText !== text) {
            element.textContent = newText;
            console.log('📝 DevBIM: Заменен текст:', text, '→', newText);
        }
    }
    
    // Заменяем текст "Made by Open WebUI Community" в рабочем пространстве
    const communityElements = document.querySelectorAll('div.text-xl.font-medium.mb-1.line-clamp-1');
    for (var i = 0; i < communityElements.length; i++) {
        replaceText(communityElements[i]);
    }
    
    // Дополнительно: перехватываем динамически создаваемые элементы
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            mutation.addedNodes.forEach(function(node) {
                if (node.nodeType === 1) { // Элемент
                    // Заменяем текст только в целевом блоке сообщества
                    const elements = node.querySelectorAll('div.text-xl.font-medium.mb-1.line-clamp-1');
                    elements.forEach(el => replaceText(el));
                }
            });
        });
    });
    
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
    
    // Дополнительно ищем другие элементы с брендом
    const titleElements = document.querySelectorAll('title, h1, h2, .brand, .logo');
    for (var i = 0; i < titleElements.length; i++) {
      var el = titleElements[i];
      if (el.textContent && el.textContent.indexOf('Open WebUI') !== -1) {
        el.textContent = el.textContent.replace(/Open WebUI/g, 'DevBIM');
      }
    }
  }
// --- DevBIM: remove Open WebUI license/Twemoji blocks from "About" tab ---
function removeLicenseBlocks() {
  try {
    const about = document.getElementById('tab-about') || document.querySelector('#tab-about');
    if (!about) return;

    const candidates = about.querySelectorAll('div, p, span, a');
    candidates.forEach((node) => {
      const t = (node.textContent || '').toLowerCase();

      if (
        t.includes('emoji graphics provided by') ||
        t.includes('twemoji') ||
        t.includes('copyright (c) 2025 open webui') ||
        t.includes('redistribution and use in source and binary forms') ||
        t.includes('this software is provided by the copyright holders')
      ) {
        // поднимаемся немного вверх, чтобы удалить целый блок
        let target = node;
        for (let i = 0; i < 3 && target && target.parentElement; i++) {
          if (target.classList?.contains('text-xs') || target.tagName === 'DIV') break;
          target = target.parentElement;
        }
        try { target && target.remove(); } catch {}
      }
    });
  } catch (e) {
    console.debug('DevBIM license-block cleanup skip:', e);
  }
}

// Выполнить сразу и несколько раз в первые секунды (как и блокировку попапов)
removeLicenseBlocks();
(function burstLicenseClean() {
  let t = 0;
  const id = setInterval(() => {
    removeLicenseBlocks();
    if ((t += 1) > 20) clearInterval(id); // ~5 секунд при 250мс
  }, 250);
})();
  
  // Пробуем обновить сразу
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', updateBrandEarly);
  } else {
    updateBrandEarly();
  }

  // Если после обновления контейнера хэши бандлов изменились,
  // браузер может держать устаревший index.html и ломаться 404 на /_app/immutable/*.js.
  // Поймаем ошибку загрузки скриптов и один раз принудительно сбросим кэш.
  (function setupOnceCacheBust() {
    if (sessionStorage.getItem('devbim-cache-busted') === '1') return;
    
    // Агрессивная проверка 404 ошибок
    let errorCount = 0;
    const maxErrors = 3;
    
    window.addEventListener('error', function (e) {
      const target = e.target || e.srcElement;
      if (target && target.tagName === 'SCRIPT') {
        const src = target.getAttribute('src') || '';
        if (src.indexOf('/_app/immutable/') !== -1) {
          errorCount++;
          console.log('🔄 DevBIM: Обнаружена 404 ошибка для скрипта:', src);
          
          if (errorCount >= maxErrors) {
            try {
              sessionStorage.setItem('devbim-cache-busted', '1');
              const url = new URL(window.location.href);
              url.searchParams.set('v', 'force_' + Date.now().toString());
              console.log('🔄 DevBIM: Принудительный сброс кэша, переход на:', url.toString());
              window.location.replace(url.toString());
            } catch (err) {
              console.error('🔄 DevBIM: Ошибка при сбросе кэша:', err);
            }
          }
        }
      }
    }, true);
    
    // Дополнительно: проверяем, что скрипты действительно загрузились
    window.addEventListener('load', function() {
      setTimeout(function() {
        // Проверяем, загрузились ли основные скрипты
        const scripts = document.querySelectorAll('script[src*="/_app/immutable/"]');
        let failedScripts = 0;
        
        scripts.forEach(function(script) {
          if (!script.loaded) {
            failedScripts++;
          }
        });
        
        if (failedScripts > 0 && sessionStorage.getItem('devbim-cache-busted') !== '1') {
          console.log('🔄 DevBIM: Обнаружены незагруженные скрипты, сброс кэша');
          sessionStorage.setItem('devbim-cache-busted', '1');
          const url = new URL(window.location.href);
          url.searchParams.set('v', 'force_' + Date.now().toString());
          window.location.replace(url.toString());
        }
      }, 3000); // Проверяем через 3 секунды после загрузки
    });
    
    // Сбросим флаг через 2 минуты на всякий случай
    setTimeout(() => sessionStorage.removeItem('devbim-cache-busted'), 120000);
  })();
  
  // ВНИМАНИЕ: дубль функции blockPopups был заменен на вызов основной реализации
  // (оставлено для совместимости с ранними версиями файла)
  function blockPopups() { try { /* no-op: реализовано выше */ } catch {} }
  
  // Функция для перехвата создания новых элементов (включая всплывающие окна)
  function interceptNewElements() {
    const observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        mutation.addedNodes.forEach(function(node) {
          if (node.nodeType === 1) { // Элемент
            // Заменяем текст только в целевом блоке сообщества
            const elements = node.querySelectorAll('div.text-xl.font-medium.mb-1.line-clamp-1');
            elements.forEach(el => replaceText(el));
            // Блокируем только явные модальные ноды/оверлеи
            const className = node.className || '';
            const id = node.id || '';
            const text = (node.textContent || '').toLowerCase();
            if (
              className?.toLowerCase?.().includes('modal') ||
              className?.toLowerCase?.().includes('popup') ||
              className?.toLowerCase?.().includes('welcome') ||
              className?.toLowerCase?.().includes('onboarding') ||
              className?.toLowerCase?.().includes('update') ||
              id.includes('modal') || id.includes('popup') ||
              text.includes("what's new") || text.includes('что нового') ||
              text.includes('changelog') || text.includes('обновлен')
            ) {
              try { node.remove(); } catch {}
              console.log('🚫 DevBIM: Удалено динамическое всплывающее окно');
            }
          }
        });
      });
    });
    
    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
  
  // Дополнительная проверка через MutationObserver
  const observer = new MutationObserver(function(mutations) {
    updateBrandEarly();
    blockPopups(); // Добавляем блокировку всплывающих окон
  });
  
  // Наблюдаем за изменениями в DOM
  if (document.body) {
    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  } else {
    document.addEventListener('DOMContentLoaded', () => {
      observer.observe(document.body, {
        childList: true,
        subtree: true
      });
    });
  }
})();