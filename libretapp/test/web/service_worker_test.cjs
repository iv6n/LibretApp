const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const origin = 'https://libretapp.test';
const base = `${origin}/app/`;
const source = fs.readFileSync(path.join(__dirname, '../../web/service_worker.js'), 'utf8');

function harness() {
  const handlers = {};
  const buckets = new Map();
  const installed = [];
  let response = null;
  let claimed = false;
  function key(request, ignoreSearch = false) {
    const url = new URL(typeof request === 'string' ? request : request.url, base);
    if (ignoreSearch) url.search = '';
    return url.href;
  }
  const caches = {
    keys: async () => [...buckets.keys()],
    delete: async (name) => buckets.delete(name),
    open: async (name) => {
      if (!buckets.has(name)) buckets.set(name, new Map());
      const bucket = buckets.get(name);
      return {
        addAll: async (urls) => {
          installed.push(...urls);
          for (const url of urls) bucket.set(key(url), new Response(`cached:${url}`));
        },
        put: async (request, value) => { bucket.set(key(request), value); },
      };
    },
    match: async (request, options = {}) => {
      for (const bucket of buckets.values()) {
        for (const [url, value] of bucket) {
          if (key(url, options.ignoreSearch) === key(request, options.ignoreSearch)) return value.clone();
        }
      }
    },
  };
  vm.runInNewContext(source, {
    URL, Response, caches,
    fetch: async () => { if (response === null) throw new TypeError('offline'); return response.clone(); },
    self: {
      location: { origin },
      addEventListener: (type, callback) => { handlers[type] = callback; },
      skipWaiting: async () => {},
      clients: { claim: async () => { claimed = true; } },
    },
  });
  return {
    caches, installed, buckets,
    get claimed() { return claimed; },
    online: (value) => { response = value; },
    fire: async (type, request) => {
      const waits = [];
      let result;
      handlers[type]({ request, waitUntil: (p) => waits.push(p), respondWith: (p) => { result = p; } });
      const returned = await result;
      await Promise.all(waits);
      return returned;
    },
  };
}

test('install precaches the application, local renderer and persistent database runtime', async () => {
  const h = harness();
  await h.fire('install');
  for (const asset of ['./main.dart.js', './sqlite3.wasm', './drift_worker.js',
    './canvaskit/canvaskit.js', './canvaskit/canvaskit.wasm', './assets/FontManifest.json']) {
    assert.ok(h.installed.includes(asset), asset);
  }
});

test('offline nested navigation works under a deployment subpath', async () => {
  const h = harness();
  await h.fire('install');
  const response = await h.fire('fetch', {method: 'GET', url: `${base}registro/lotes`, mode: 'navigate'});
  assert.equal(await response.text(), 'cached:./index.html');
});

test('offline WASM and workers retain their cached bodies, including version queries', async () => {
  const h = harness();
  await h.fire('install');
  for (const file of ['sqlite3.wasm', 'drift_worker.js', 'main.dart.js']) {
    const response = await h.fire('fetch', {method: 'GET', url: `${base}${file}?v=1`, mode: 'cors'});
    assert.equal(await response.text(), `cached:./${file}`);
  }
  const absent = await h.fire('fetch', {method: 'GET', url: `${base}missing.wasm`, mode: 'cors'});
  assert.equal(absent.type, 'error');
});

test('failed HTTP responses never replace usable cached files', async () => {
  const h = harness();
  await h.fire('install');
  const request = {method: 'GET', url: `${base}sqlite3.wasm`, mode: 'cors'};
  h.online(new Response('server failure', {status: 503}));
  assert.equal((await h.fire('fetch', request)).status, 503);
  h.online(null);
  assert.equal(await (await h.fire('fetch', request)).text(), 'cached:./sqlite3.wasm');
  h.online(new Response('updated wasm'));
  await h.fire('fetch', request);
  h.online(null);
  assert.equal(await (await h.fire('fetch', request)).text(), 'updated wasm');
});

test('activation only removes obsolete LibretApp caches and claims clients', async () => {
  const h = harness();
  await h.caches.open('unrelated-cache');
  await h.caches.open('libretapp-shell-old');
  await h.fire('install');
  await h.fire('activate');
  const keys = await h.caches.keys();
  assert.ok(keys.includes('unrelated-cache'));
  assert.ok(!keys.includes('libretapp-shell-old'));
  assert.ok(h.claimed);
});

test('non-GET and third-party requests bypass the offline cache', async () => {
  const h = harness();
  assert.equal(await h.fire('fetch', {method: 'POST', url: `${base}records`}), undefined);
  assert.equal(await h.fire('fetch', {method: 'GET', url: 'https://other.test/file'}), undefined);
});
