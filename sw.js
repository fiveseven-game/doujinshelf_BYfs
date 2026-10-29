// Doumi 离线缓存（通过 https 网址访问时生效）
// 规则：先去服务器取最新文件；网速慢（超过 2.5 秒）或断网时，先用这台设备上存的副本马上打开，
//       同时在后台继续下载最新版，下次打开就是新的。
const CACHE = 'doumi-v7';
const CORE = ['./', './index.html', './config.js', './supabase.js'];
const WAIT = 2500;

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(CORE.map(u => new Request(u, {cache: 'reload'})))).catch(() => {}).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const req = e.request, url = new URL(req.url);
  if (req.method !== 'GET' || url.origin !== location.origin) return;
  if (url.pathname.endsWith('/check.html')) return;   // 自检页永远直接取最新
  const network = fetch(req, {cache: 'no-store'}).then(res => {
    if (res.ok) { const copy = res.clone(); caches.open(CACHE).then(c => c.put(req, copy)); }
    return res;
  });
  e.waitUntil(network.catch(() => {}));   // 即使先用了缓存，也让后台下载继续完成
  e.respondWith((async () => {
    const cached = await caches.match(req, {ignoreSearch: true}) || (req.mode === 'navigate' ? await caches.match('./') : null);
    if (!cached) return network.catch(() => caches.match('./'));
    const slow = new Promise(r => setTimeout(() => r(null), WAIT));
    const first = await Promise.race([network.catch(() => null), slow]);
    return first || cached;
  })());
});
