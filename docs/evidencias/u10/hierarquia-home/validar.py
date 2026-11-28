import base64
import functools
import hashlib
import http.server
import io
import json
import pathlib
import subprocess
import sys
import tempfile
import threading
import time
import urllib.request

import websocket
from PIL import Image, ImageChops

ROOT = pathlib.Path(__file__).resolve().parents[4]
OUT = ROOT / 'docs/evidencias/u10/hierarquia-home'
BASELINE = OUT / 'regressao-antes'
PHASE = sys.argv[1]
OUT.mkdir(parents=True, exist_ok=True)
BASELINE.mkdir(parents=True, exist_ok=True)
WIDTHS = [320, 390, 768, 1280, 1920]
checks, events, metrics = [], [], []


class Handler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), functools.partial(Handler, directory=str(ROOT / 'frontend')))
threading.Thread(target=server.serve_forever, daemon=True).start()
base = f'http://127.0.0.1:{server.server_port}/'
profile = pathlib.Path(tempfile.mkdtemp(prefix='pharmafind-home-profile-'))
browser = subprocess.Popen([
    r'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe',
    '--headless=new', '--remote-debugging-port=0', f'--user-data-dir={profile}',
    '--no-first-run', '--no-default-browser-check', '--disable-extensions', 'about:blank'
], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, creationflags=subprocess.CREATE_NO_WINDOW)
seq, ws = 0, None


def command(method, params=None):
    global seq
    seq += 1
    ws.send(json.dumps({'id': seq, 'method': method, 'params': params or {}}))
    while True:
        message = json.loads(ws.recv())
        if message.get('id') == seq:
            if 'error' in message:
                raise RuntimeError(message['error'])
            return message.get('result', {})
        events.append(message)


def js(expression):
    result = command('Runtime.evaluate', {'expression': expression, 'returnByValue': True, 'awaitPromise': True})
    if 'exceptionDetails' in result:
        raise RuntimeError(result['exceptionDetails'])
    return result.get('result', {}).get('value')


def goto(path):
    command('Page.navigate', {'url': base + path})
    time.sleep(.2)
    for _ in range(200):
        if js('document.readyState === "complete"'):
            break
        time.sleep(.1)
    js('document.fonts.ready.then(() => true)')
    time.sleep(.15)


def key(name):
    code = {'Tab': 9, 'Enter': 13, 'Escape': 27}[name]
    for kind in ['keyDown', 'keyUp']:
        command('Input.dispatchKeyEvent', {'type': kind, 'key': name, 'code': name, 'windowsVirtualKeyCode': code, **({'text': '\r'} if name == 'Enter' and kind == 'keyDown' else {})})


def check(name, expression):
    obtained = js(expression)
    checks.append({'name': name, 'passed': bool(obtained), 'expression': expression, 'obtained': obtained})
    print(('PASS ' if obtained else 'FAIL ') + name, flush=True)


def shot(path):
    content = base64.b64decode(command('Page.captureScreenshot', {'captureBeyondViewport': False})['data'])
    path.write_bytes(content)
    return content


try:
    for _ in range(100):
        if (profile / 'DevToolsActivePort').exists():
            break
        if browser.poll() is not None:
            raise RuntimeError(f'Browser exited {browser.returncode}')
        time.sleep(.1)
    port = (profile / 'DevToolsActivePort').read_text().splitlines()[0]
    targets = json.load(urllib.request.urlopen(f'http://127.0.0.1:{port}/json/list'))
    ws = websocket.create_connection(next(t['webSocketDebuggerUrl'] for t in targets if t['type'] == 'page'), suppress_origin=True, timeout=40)
    for domain in ['Page', 'Runtime', 'Log', 'Network']:
        command(domain + '.enable')
    version = command('Browser.getVersion')
    for width in WIDTHS:
        command('Emulation.setDeviceMetricsOverride', {'width': width, 'height': 900, 'deviceScaleFactor': 1, 'mobile': False})
        goto('index.html')
        shot(OUT / f'home-{PHASE}-{width}.png')
        metrics.append(js("""(() => {
          const rect = s => {const r=document.querySelector(s).getBoundingClientRect();return {x:r.x,y:r.y,width:r.width,height:r.height}};
          return {width:innerWidth,search:rect('.home-search'),form:rect('.hero-search'),input:rect('#heroMedicineSearch'),button:rect('#heroSearchButton'),
            titleSize:getComputedStyle(homeSearchTitle).fontSize,bannerTitleSize:getComputedStyle(document.querySelector('.hero h2')).fontSize,
            lupa:getComputedStyle(heroMedicineSearch).backgroundImage,fontsLoaded:document.fonts.check('700 24px "Playfair Display"'),
            images:[...document.images].map(i=>({src:i.src,loaded:i.complete&&i.naturalWidth>0}))};
        })()"""))
        if PHASE == 'antes':
            continue
        prefix = f'home {width}: '
        check(prefix + 'sem overflow', 'document.documentElement.scrollWidth <= innerWidth')
        check(prefix + 'titulo e subtitulo centralizados', "getComputedStyle(homeSearchTitle).textAlign==='center' && getComputedStyle(document.querySelector('.home-search > p')).textAlign==='center'")
        check(prefix + 'formulario centralizado e limitado a 720px', "(() => {const a=document.querySelector('.home-search').getBoundingClientRect(),b=document.querySelector('.hero-search').getBoundingClientRect();return b.width<=720 && Math.abs(a.x+a.width/2-b.x-b.width/2)<1})()")
        check(prefix + 'rotulo alinhado ao campo e associado', "(() => {const l=document.querySelector('.hero-search label');return l.control===heroMedicineSearch && getComputedStyle(l).textAlign==='left' && Math.abs(l.getBoundingClientRect().left-heroMedicineSearch.getBoundingClientRect().left)<1})()")
        check(prefix + 'banner secundario alinhado a esquerda', "getComputedStyle(document.querySelector('.hero-content')).textAlign==='left' && parseFloat(getComputedStyle(document.querySelector('.hero h2')).fontSize)<parseFloat(getComputedStyle(homeSearchTitle).fontSize)")
        check(prefix + 'lupa e botao vermelho preservados', "getComputedStyle(heroMedicineSearch).backgroundImage!=='none' && getComputedStyle(heroSearchButton).backgroundColor==='rgb(214, 47, 63)'")
        check(prefix + 'acao visivel e alvos de toque', 'heroSearchButton.getBoundingClientRect().bottom<innerHeight && heroSearchButton.getBoundingClientRect().height>=44 && heroMedicineSearch.getBoundingClientRect().height>=44')
        check(prefix + 'disposicao responsiva', "(() => {const a=heroMedicineSearch.getBoundingClientRect(),b=heroSearchButton.getBoundingClientRect();return innerWidth<=560?b.top>=a.bottom:Math.abs(a.top-b.top)<1})()")
        js('heroMedicineSearch.focus()')
        key('Tab')
        check(prefix + 'Tab e foco visivel', "document.activeElement===heroSearchButton && getComputedStyle(heroSearchButton).outlineStyle==='solid' && parseFloat(getComputedStyle(heroSearchButton).outlineWidth)>=3")
        js("heroMedicineSearch.value='  Dipirona 500 mg  '")
        key('Enter')
        time.sleep(.3)
        check(prefix + 'pesquisa por teclado chega a apresentacao exata', "location.pathname.endsWith('/consulta.html') && new URLSearchParams(location.search).get('termo')==='Dipirona 500 mg' && document.querySelectorAll('.product-card').length===1 && searchInput.value==='Dipirona 500 mg'")
        js("document.querySelector('.offer-button').click()")
        check(prefix + 'ofertas preservadas apos selecao', "!comparisonPanel.hidden && document.querySelectorAll('.offer-card').length===3 && document.querySelectorAll('.offer-card.unavailable').length===1")
        goto('index.html')
        js("heroMedicineSearch.value='Dipirona';heroSearchButton.click()")
        time.sleep(.3)
        check(prefix + 'clique pesquisa sem misturar apresentacoes', "new URLSearchParams(location.search).get('termo')==='Dipirona' && document.querySelectorAll('.product-card').length===2 && comparisonPanel.hidden")
        goto('index.html')
        js("heroMedicineSearch.value='Loratadina';heroMedicineSearch.focus()")
        key('Enter')
        time.sleep(.3)
        check(prefix + 'Enter no campo continua pesquisando', "new URLSearchParams(location.search).get('termo')==='Loratadina' && document.querySelectorAll('.product-card').length===1 && searchInput.value==='Loratadina'")
        goto('index.html')
        js('heroSearchButton.click()')
        time.sleep(.3)
        check(prefix + 'busca vazia preserva estado inicial', "location.pathname.endsWith('/consulta.html') && location.search==='' && !initialState.hidden")

    for width in [320, 768, 1280]:
        command('Emulation.setDeviceMetricsOverride', {'width': width, 'height': 900, 'deviceScaleFactor': 1, 'mobile': False})
        for page in ['consulta.html?termo=Dipirona', 'como-funciona.html', 'sobre.html']:
            goto(page)
            name = page.split('.')[0] + '-' + str(width)
            if PHASE == 'antes':
                shot(BASELINE / (name + '.png'))
            else:
                current = base64.b64decode(command('Page.captureScreenshot', {'captureBeyondViewport': False})['data'])
                diff = ImageChops.difference(Image.open(BASELINE / (name + '.png')).convert('RGB'), Image.open(io.BytesIO(current)).convert('RGB'))
                checks.append({'name': name + ': comparacao pixel a pixel com antes', 'passed': diff.getbbox() is None, 'differenceBounds': diff.getbbox()})
                check(name + ': sem overflow', 'document.documentElement.scrollWidth<=innerWidth')
                if 'consulta' in page:
                    js("document.querySelector('.offer-button').click()")
                    check(name + ': comparacao utilizavel', '!comparisonPanel.hidden && document.querySelectorAll(".offer-card").length===3')

    errors = [e for e in events if e.get('method') == 'Runtime.exceptionThrown']
    report = {'phase': PHASE, 'browser': version, 'viewportHeight': 900, 'checks': checks, 'metrics': metrics, 'jsErrors': errors,
              'networkErrors': [e for e in events if e.get('method') == 'Log.entryAdded' and e['params']['entry'].get('source') == 'network'],
              'frontendHashes': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in (ROOT / 'frontend').iterdir() if p.is_file()}}
    (OUT / f'report-{PHASE}.json').write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding='utf-8')
    print(json.dumps({'phase': PHASE, 'passed': sum(c['passed'] for c in checks), 'failed': [c['name'] for c in checks if not c['passed']], 'jsErrors': len(errors)}), flush=True)
    if any(not c['passed'] for c in checks) or errors:
        raise SystemExit(1)
finally:
    if ws:
        ws.close()
    browser.terminate()
    browser.wait(timeout=10)
    server.shutdown()
