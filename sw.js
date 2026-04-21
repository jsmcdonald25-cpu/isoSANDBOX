const CACHE_NAME = 'grailiso-shell-v16';
const SHELL_ASSETS = ['/dashboard.html', '/manifest.json', '/icons/icon-192.png', '/icons/icon-512.png',
  '/isograding-scan.html', '/js/isograding-engine.js', '/js/jsqr.min.js', '/js/qrcode-generator.min.js'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE_NAME).then(c => c.addAll(SHELL_ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  const u = new URL(e.request.url);

  // Supabase storage uploads (POST/PUT with binary body) — let the browser handle
  // directly so the SW doesn't break large-body requests (causes false "offline" errors)
  if (u.hostname.endsWith('.supabase.co') && (e.request.method === 'POST' || e.request.method === 'PUT') && u.pathname.includes('/storage/')) {
    return; // don't call e.respondWith — browser handles natively
  }

  // Supabase API calls — always network, offline fallback
  if (u.hostname.endsWith('.supabase.co')) {
    e.respondWith(
      fetch(e.request).catch(() =>
        new Response(JSON.stringify({ error: 'offline' }), {
          status: 503,
          headers: { 'Content-Type': 'application/json' }
        })
      )
    );
    return;
  }

  // HTML pages — network-first so deploys are always picked up immediately
  if (e.request.destination === 'document' || u.pathname.endsWith('.html')) {
    e.respondWith(
      fetch(e.request)
        .then(r => {
          caches.open(CACHE_NAME).then(c => c.put(e.request, r.clone()));
          return r;
        })
        .catch(() => caches.match(e.request))
    );
    return;
  }

  // Icons / static shell assets — network-first with cache fallback
  if (SHELL_ASSETS.some(a => u.pathname === a) || u.pathname.startsWith('/icons/')) {
    e.respondWith(
      fetch(e.request)
        .then(r => {
          caches.open(CACHE_NAME).then(c => c.put(e.request, r.clone()));
          return r;
        })
        .catch(() => caches.match(e.request))
    );
    return;
  }

  // Everything else — network with cache fallback
  e.respondWith(fetch(e.request).catch(() => caches.match(e.request)));
});
