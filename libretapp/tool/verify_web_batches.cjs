// Run after flutter build web --release --no-wasm-dry-run
// --target test/web/offline_batch_smoke_app.dart --output build/web-batch-smoke.
// Uses an isolated Chrome profile. Stops network responses before reloading.
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const {spawn} = require('node:child_process');
const {once} = require('node:events');
const projectRoot = path.resolve(__dirname, '..');
const root = path.join(projectRoot, 'build/web-batch-smoke');
const profile = path.join(projectRoot, `artifacts/web-batch-chrome-${Date.now()}`);
const chrome = process.env.CHROME_EXECUTABLE || (process.platform === 'win32'
  ? 'C:/Program Files/Google/Chrome/Application/chrome.exe'
  : process.platform === 'darwin' ? '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' : 'google-chrome');
const sleep = ms => new Promise(r=>setTimeout(r,ms));
const types = {'.js':'text/javascript','.wasm':'application/wasm','.html':'text/html',
  '.json':'application/json','.ttf':'font/ttf','.otf':'font/otf','.svg':'image/svg+xml','.png':'image/png'};
let offline = false;
let browser;
let ws;
const server = http.createServer((req,res)=>{
  if(offline){req.socket.destroy();return;}
  let relative = decodeURIComponent(new URL(req.url,'http://local/').pathname);
  if(relative.endsWith('/'))relative+='index.html';
  const file=path.resolve(root,relative.slice(1));
  if(!file.startsWith(root+path.sep)||!fs.existsSync(file)||fs.statSync(file).isDirectory()){res.writeHead(404).end();return;}
  res.writeHead(200,{'Content-Type':types[path.extname(file)]||'application/octet-stream','Cache-Control':'no-cache'});
  fs.createReadStream(file).pipe(res);
});
(async()=>{
  await new Promise(r=>server.listen(0,'127.0.0.1',r));
  const appUrl=`http://127.0.0.1:${server.address().port}/`;
  fs.mkdirSync(profile,{recursive:true});
  browser=spawn(chrome,['--headless','--disable-gpu','--no-first-run','--no-default-browser-check',
    '--remote-debugging-port=0',`--user-data-dir=${profile}`,appUrl],{windowsHide:true,stdio:'ignore'});
  const portFile=path.join(profile,'DevToolsActivePort');
  for(let n=0;n<100&&!fs.existsSync(portFile);n++)await sleep(100);
  if(!fs.existsSync(portFile))throw Error('Chrome did not expose its isolated test port');
  const debugPort=fs.readFileSync(portFile,'utf8').split('\n')[0];
  let target;
  for(let n=0;n<100&&!target;n++){
    target=(await(await fetch(`http://127.0.0.1:${debugPort}/json`)).json()).find(t=>t.type==='page'&&t.url.startsWith(appUrl));
    if(!target)await sleep(100);
  }
  ws=new WebSocket(target.webSocketDebuggerUrl);
  await once(ws,'open');
  let id=0;const pending=new Map();const errors=[];
  ws.addEventListener('message',e=>{
    const m=JSON.parse(e.data);
    if(m.id){pending.get(m.id)?.(m);pending.delete(m.id);}
    if(m.method==='Runtime.exceptionThrown')errors.push(m.params.exceptionDetails.text);
  });
  const cmd=(method,params={})=>new Promise(resolve=>{const n=++id;pending.set(n,resolve);ws.send(JSON.stringify({id:n,method,params}));});
  async function evaluate(expression){const r=await cmd('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});if(r.error||r.result?.exceptionDetails)throw Error(JSON.stringify(r));return r.result?.result?.value;}
  async function result(){for(let n=0;n<600;n++){const raw=await evaluate('window.libretappBatchSmoke || null');if(raw)return JSON.parse(raw);await sleep(100);}throw Error(`Smoke test timed out: ${errors.join('; ')}`);}
  await cmd('Runtime.enable');await cmd('Network.enable');
  const first=await result();
  console.log(`Initial browser result: ${JSON.stringify(first)}`);
  if(first.phase!=='draft_saved')throw Error(JSON.stringify(first));
  await evaluate('navigator.serviceWorker.ready.then(async () => {while(!navigator.serviceWorker.controller) await new Promise(r=>setTimeout(r,50));return true;})');
  const cached=await evaluate('Promise.all(["main.dart.js","sqlite3.wasm","drift_worker.js","canvaskit/canvaskit.wasm","assets/assets/fonts/Roboto-Regular.ttf"].map(async file => !!(await caches.match(file)))).then(values=>values.every(Boolean))');
  if(!cached)throw Error('Offline shell installation is incomplete');
  const previousOrigin=await evaluate('performance.timeOrigin');
  await evaluate('window.libretappBatchSmoke = null');
  offline=true;
  await cmd('Network.emulateNetworkConditions',{offline:true,latency:0,downloadThroughput:0,uploadThroughput:0});
  await cmd('Page.reload',{ignoreCache:false});
  for(let n=0;n<100;n++){
    if(await evaluate('performance.timeOrigin')!==previousOrigin)break;
    await sleep(100);
  }
  const final=await result();
  if(final.phase!=='passed')throw Error(JSON.stringify(final));
  fs.writeFileSync(path.join(projectRoot, 'artifacts/web-batch-browser-smoke-result.json'),JSON.stringify({...final,initialOfflineShellCached:cached},null,2));
  console.log(JSON.stringify({...final,initialOfflineShellCached:cached}));
})().catch(e=>{console.error(e.stack);process.exitCode=1;}).finally(async()=>{
  if(ws){try{ws.send(JSON.stringify({id:999999,method:'Browser.close'}));}catch{}ws.close();}
  if(browser){await Promise.race([once(browser,'exit'),sleep(3000)]);if(browser.exitCode===null)browser.kill();}
  server.closeAllConnections();await new Promise(r=>server.close(r));
  if(profile.startsWith(path.join(projectRoot, 'artifacts')+path.sep)){
    try{await fs.promises.rm(profile,{recursive:true,force:true,maxRetries:8,retryDelay:200});}catch(e){console.log(`Test profile retained: ${e.code}`);}
  }
});
