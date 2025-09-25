// @ts-nocheck
/**
 * DevBIM branding shim (frontend)
 * Ensures Svelte build places this at /build/static/loader.js so it's served as /static/loader.js.
 * Also duplicated into backend static on startup by [backend.open_webui.config.py](open-webui-main/open-webui-main/backend/open_webui/config.py:825).
 *
 * Function: client-side override of /api/config.name and minimal DOM patch
 * so that UI displays "DevBIM" instead of "Open WebUI", without touching backend code.
 */
(() => {
  const BRAND_NAME = 'DevBIM';

  function patchDomBrand() {
    try {
      // Sidebar brand text (open state)
      const brandNodes = document.querySelectorAll('#sidebar .sidebar a.flex.flex-1.px-1\\.5 > div.font-primary');
      brandNodes.forEach((el) => {
        if (el && !el.dataset?.devbimApplied) {
          el.textContent = BRAND_NAME;
          el.dataset.devbimApplied = 'true';
          // Apply DevBIM blue color to the emblem
          el.style.color = '#0066cc';
        }
      });

      // Page title fallback
      if (document.title && document.title.indexOf(BRAND_NAME) === -1) {
        document.title = BRAND_NAME;
      }
    } catch (e) {
      console.warn('DevBIM DOM patch error:', e);
    }
  }

  // Intercept fetch to rewrite /api/config response.name => DevBIM
  const originalFetch = window.fetch.bind(window);
  window.fetch = async function(input, init) {
    const url = typeof input === 'string' ? input : (input && input.url) || '';
    const res = await originalFetch(input, init);

    try {
      let pathname = '';
      try {
        const u = new URL(url, window.location.origin);
        pathname = u.pathname;
      } catch {
        pathname = url || '';
      }

      if (res && res.ok && /\/api\/config$/.test(pathname)) {
        const ct = (res.headers.get('content-type') || '').toLowerCase();
        if (ct.indexOf('application/json') !== -1) {
          const data = await res.clone().json();
          if (data && typeof data === 'object') {
            data.name = BRAND_NAME;

            const headers = new Headers(res.headers);
            headers.set('content-type', 'application/json; charset=utf-8');
            headers.delete('content-length');

            const body = JSON.stringify(data);
            queueMicrotask(patchDomBrand);

            return new Response(body, {
              status: res.status,
              statusText: res.statusText,
              headers
            });
          }
        }
      }
    } catch (e) {
      console.warn('DevBIM fetch patch error:', e);
    }

    return res;
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', patchDomBrand, { once: true });
  } else {
    patchDomBrand();
  }
// --- DevBIM: remove Open WebUI license/Twemoji blocks from "About" tab (loader.js) ---
function removeLicenseBlocks() {
  try {
    const about = document.getElementById('tab-about') || document.querySelector('#tab-about');
    if (!about) return;

    const candidates = about.querySelectorAll('div, p, span, a, li');
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
    console.debug('DevBIM license-block cleanup (loader.js) skip:', e);
  }
}

// Выполнить сразу и несколько раз в первые секунды (как и бренд-патч)
removeLicenseBlocks();
(function burstLicenseClean() {
  let t = 0;
  const id = setInterval(() => {
    removeLicenseBlocks();
    if ((t += 1) > 20) clearInterval(id); // ~5 секунд при 250мс
  }, 250);
})();

// Дополнительно: наблюдаем за изменениями DOM и стираем блоки лицензии динамически
const devbimObserver = new MutationObserver(function(mutations) {
  // быстрый вызов — дешёвая операция по сравнению с селекторами
  removeLicenseBlocks();
});
try {
  devbimObserver.observe(document.documentElement || document.body, {
    childList: true,
    subtree: true
  });
} catch {}
})();