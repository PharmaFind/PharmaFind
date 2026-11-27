import base64
import functools
import http.server
import json
import pathlib
import subprocess
import tempfile
import threading
import time
import urllib.request
import websocket
import sys

ROOT = pathlib.Path(r'C:\Codes\vscode\PharmaFind')
OUT = ROOT / 'docs' / 'evidencias' / 'u10' / 'refinamento'
if '--navigation-only' in sys.argv:
    OUT = pathlib.Path(tempfile.mkdtemp(prefix='pharmafind-nav-qa-'))
if '--homologacao' in sys.argv:
    OUT = ROOT / 'docs' / 'evidencias' / 'u10' / 'homologacao' / ('acessibilidade' if '--a11y-extra' in sys.argv else 'sticky' if '--navigation-only' in sys.argv else 'browser')
OUT.mkdir(parents=True, exist_ok=True)
PROFILE = pathlib.Path(tempfile.mkdtemp(prefix='pharmafind-u10-refinamento-profile-'))
class Handler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args): pass
server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), functools.partial(Handler, directory=str(ROOT / 'frontend')))
threading.Thread(target=server.serve_forever, daemon=True).start()
BASE = f'http://127.0.0.1:{server.server_port}/'
browser = subprocess.Popen([
    r'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe',
    '--headless=new', '--remote-debugging-port=0', f'--user-data-dir={PROFILE}',
    '--no-first-run', '--no-default-browser-check', '--disable-extensions', 'about:blank'
], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, creationflags=subprocess.CREATE_NO_WINDOW)
print(json.dumps({'output': str(OUT), 'url': BASE, 'pid': browser.pid}), flush=True)
seq = 0
events = []
checks = []
metrics = []
ws = None
def command(method, params=None):
    global seq
    seq += 1
    ws.send(json.dumps({'id':seq, 'method':method, 'params':params or {}}))
    while True:
        msg = json.loads(ws.recv())
        if msg.get('id') == seq:
            if 'error' in msg: raise RuntimeError(msg['error'])
            return msg.get('result', {})
        events.append(msg)
def js(expression):
    result = command('Runtime.evaluate', {'expression': expression, 'returnByValue': True, 'awaitPromise': True})
    if 'exceptionDetails' in result: raise RuntimeError(result['exceptionDetails'])
    return result.get('result', {}).get('value')
def check(name, expression):
    try: result = js(expression)
    except Exception as error:
        checks.append({'name':name,'passed':False,'expected':expression,'testError':str(error)})
        print('FAIL '+name+': '+str(error),flush=True)
        return
    checks.append({'name':name, 'passed':bool(result), 'expected':expression, 'obtained':result})
    print(('PASS ' if result else 'FAIL ') + name, flush=True)
def goto(page):
    command('Page.navigate', {'url':BASE+page})
    time.sleep(.15)
    for _ in range(150):
        if js('document.readyState === "complete"'): break
        time.sleep(.1)
    js('Promise.race([document.fonts.ready, new Promise(r => setTimeout(r, 3000))]).then(() => true)')
def size(width, height=900):
    command('Emulation.setDeviceMetricsOverride', {'width':width, 'height':height, 'deviceScaleFactor':1, 'mobile':False})
    time.sleep(.1)
def key(value, shift=False):
    command('Input.dispatchKeyEvent', {'type':'keyDown','key':value,'code':value,'windowsVirtualKeyCode':{'Tab':9,'Enter':13,'Escape':27}[value], 'modifiers':8 if shift else 0, **({'text':'\r'} if value == 'Enter' else {})})
    command('Input.dispatchKeyEvent', {'type':'keyUp','key':value,'code':value,'windowsVirtualKeyCode':{'Tab':9,'Enter':13,'Escape':27}[value]})
def shot(name):
    data = command('Page.captureScreenshot', {'captureBeyondViewport':False})['data']
    (OUT / (name+'.png')).write_bytes(base64.b64decode(data))
try:
    portfile = PROFILE / 'DevToolsActivePort'
    for _ in range(100):
        if portfile.exists(): break
        if browser.poll() is not None: raise RuntimeError(f'Browser exited {browser.returncode}')
        time.sleep(.1)
    port = portfile.read_text().splitlines()[0]
    targets = json.load(urllib.request.urlopen(f'http://127.0.0.1:{port}/json/list'))
    ws = websocket.create_connection(next(x['webSocketDebuggerUrl'] for x in targets if x['type']=='page'), suppress_origin=True, timeout=30)
    command('Page.enable'); command('Runtime.enable'); command('Log.enable')
    command('Network.enable')
    browser_version=command('Browser.getVersion')
    if '--a11y-extra' in sys.argv:
        def ratio(a,b):
            def lum(c):
                rgb=[float(n)/255 for n in __import__('re').findall(r'[\d.]+',c)[:3]]
                return sum((v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4)*w for v,w in zip(rgb,[.2126,.7152,.0722]))
            l=sorted([lum(a),lum(b)]);return (l[1]+.05)/(l[0]+.05)
        size(390,900)
        for page in ['index.html','consulta.html','como-funciona.html','sobre.html']:
            goto(page)
            pairs=js("[...document.querySelectorAll('nav a, .primary-button, #heroSearchButton')].filter(e=>e.getBoundingClientRect().width>0).map(e=>({label:e.innerText,fg:getComputedStyle(e).color,bg:getComputedStyle(e).backgroundColor==='rgba(0, 0, 0, 0)'?'rgb(255, 255, 255)':getComputedStyle(e).backgroundColor}))")
            values=[dict(p,ratio=round(ratio(p['fg'],p['bg']),2)) for p in pairs]
            checks.append({'name':page+': primary controls and navigation contrast','expected':'>=4.5:1','obtained':values,'passed':all(v['ratio']>=4.5 for v in values)})
            js('mobileMenuButton.click();locOpen.click()')
            key('Escape')
            check(page+': modal Escape returns to location trigger with menu previously open','locationPopup.hidden && document.activeElement===locOpen')
            if not checks[-1]['passed']:shot(page.replace('.html','')+'-focus-after-escape')
            goto(page)
            js('cepOpen.click();cepInput.focus()');key('Tab',True)
            check(page+': CEP Shift Tab reaches close button','document.activeElement===cepClose')
            key('Escape')
            check(page+': CEP Escape returns focus','cepBox.hidden && document.activeElement===cepOpen')
        goto('consulta.html?termo=Omeprazol')
        js("document.querySelector('.offer-button').click()")
        colors=js("[...document.querySelectorAll('.offer-card .product-price,.offer-card .availability,.offer-card .product-description')].map(e=>({label:e.innerText,fg:getComputedStyle(e).color,bg:getComputedStyle(e.closest('.offer-card')).backgroundColor}))")
        values=[dict(p,ratio=round(ratio(p['fg'],p['bg']),2)) for p in colors]
        checks.append({'name':'offer prices, availability and addresses contrast','expected':'>=4.5:1','obtained':values,'passed':all(v['ratio']>=4.5 for v in values)})
        errors=[e for e in events if e.get('method')=='Runtime.exceptionThrown']
        (OUT/'report.json').write_text(json.dumps({'checks':checks,'jsErrors':errors,'browser':browser_version,'networkErrors':[e for e in events if e.get('method')=='Log.entryAdded' and e['params']['entry'].get('source')=='network']},ensure_ascii=False,indent=2),encoding='utf8')
        print(json.dumps({'passed':sum(c['passed'] for c in checks),'failed':[c['name'] for c in checks if not c['passed']],'jsErrors':len(errors)}),flush=True)
        raise SystemExit(0)
    if '--navigation-only' in sys.argv:
        for width in [320,390,768,1280,1920]:
            size(width, 600 if '--sticky-only' in sys.argv else 900)
            for page in ['index.html','consulta.html','como-funciona.html','sobre.html']:
                goto(page)
                js("window.nav = document.querySelector('nav.container-fluid')")
                check(f'{page} {width}: rounded white nav and border', "getComputedStyle(nav).borderTopLeftRadius === '18px' && getComputedStyle(nav).backgroundColor === 'rgb(255, 255, 255)' && getComputedStyle(nav).borderLeftWidth === '1px'")
                check(f'{page} {width}: inset content and no overflow', "parseFloat(getComputedStyle(nav).paddingLeft)>=12 && parseFloat(getComputedStyle(nav).paddingRight)>=12 && document.documentElement.scrollWidth<=innerWidth && nav.querySelector('.brand').getBoundingClientRect().left-nav.getBoundingClientRect().left >=12")
                check(f'{page} {width}: vertical alignment', "(() => {const a=nav.querySelector('.brand').getBoundingClientRect(),b=(innerWidth<=850?mobileMenuButton:nav.querySelector('.desktop-menu')).getBoundingClientRect();return Math.abs((a.top+a.bottom-b.top-b.bottom)/2)<4})()")
                if '--sticky-only' in sys.argv:
                    js("window.navBefore={width:nav.getBoundingClientRect().width,left:nav.getBoundingClientRect().left,height:nav.getBoundingClientRect().height,contentY:document.querySelector('#conteudo-principal').getBoundingClientRect().top+scrollY}")
                    check(f'{page} {width}: initial natural position', "nav.getBoundingClientRect().top>=14 && getComputedStyle(nav).position==='sticky' && getComputedStyle(nav).zIndex==='20' && getComputedStyle(nav).boxShadow!=='none'")
                    for offset in [100,300]:
                        js(f'scrollTo({{top:{offset},behavior:"instant"}})')
                        check(f'{page} {width}: scroll {offset} fixed inset and stable layout', "scrollY>28 && Math.abs(nav.getBoundingClientRect().top-14)<1 && Math.abs(nav.getBoundingClientRect().width-navBefore.width)<1 && Math.abs(nav.getBoundingClientRect().left-navBefore.left)<1 && Math.abs(nav.getBoundingClientRect().height-navBefore.height)<1 && Math.abs(document.querySelector('#conteudo-principal').getBoundingClientRect().top+scrollY-navBefore.contentY)<1")
                if width<=850:
                    js('mobileMenuButton.click()')
                    check(f'{page} {width}: mobile menu opens and fits', "!mobileMenu.hidden && mobileMenuButton.getAttribute('aria-expanded')==='true' && document.documentElement.scrollWidth<=innerWidth")
                    if '--sticky-only' in sys.argv:
                        check(f'{page} {width}: scrolled mobile links visible and clickable', "[...mobileMenu.querySelectorAll('a')].every(a=>{const r=a.getBoundingClientRect();return r.top>=nav.getBoundingClientRect().bottom && r.bottom<=innerHeight && a.contains(document.elementFromPoint(r.left+r.width/2,r.top+r.height/2))})")
                    key('Escape')
                    check(f'{page} {width}: Escape closes menu and restores focus', 'mobileMenu.hidden && document.activeElement===mobileMenuButton')
                else:
                    check(f'{page} {width}: desktop navigation fits', "nav.querySelector('.desktop-menu').getBoundingClientRect().right <= nav.getBoundingClientRect().right-12 && getComputedStyle(mobileMenuButton).display==='none'")
                if page=='index.html':
                    if '--sticky-only' in sys.argv: js('scrollTo({top:0,behavior:"instant"})')
                    check(f'home {width}: search remains visible', "document.querySelector('#heroSearchButton').getBoundingClientRect().bottom<=innerHeight")
                if width in [320,1280]: shot(page.replace('.html','')+f'-{width}')
        errors=[e for e in events if e.get('method')=='Runtime.exceptionThrown']
        report={'checks':checks,'jsErrors':errors,'browser':browser_version,'networkErrors':[e for e in events if e.get('method')=='Log.entryAdded' and e['params']['entry'].get('source')=='network']}
        (OUT/'report.json').write_text(json.dumps(report,indent=2),encoding='utf8')
        print(json.dumps({'passed':sum(c['passed'] for c in checks),'failed':[c['name'] for c in checks if not c['passed']],'jsErrors':len(errors),'report':str(OUT/'report.json')}),flush=True)
        raise SystemExit(0 if all(c['passed'] for c in checks) and not errors else 1)
    for width in [320, 390, 768, 1280, 1920]:
        size(width, 720 if width >= 1280 else 900)
        goto('index.html')
        check(f'home {width}: Pico loaded', "!!document.querySelector('link[href*=picocss]').sheet")
        check(f'home {width}: search in first viewport', "document.querySelector('#heroSearchButton').getBoundingClientRect().bottom <= innerHeight && document.querySelector('#heroMedicineSearch').getBoundingClientRect().top > 0")
        check(f'home {width}: no horizontal overflow', 'document.documentElement.scrollWidth <= innerWidth')
        check(f'home {width}: search precedes banner', "document.querySelector('.home-search').getBoundingClientRect().bottom <= document.querySelector('.hero').getBoundingClientRect().top")
        check(f'palette {width}: blue gray background and white search', "getComputedStyle(document.documentElement).backgroundColor === 'rgb(232, 237, 243)' && getComputedStyle(document.body).backgroundColor === 'rgb(232, 237, 243)' && getComputedStyle(document.querySelector('.home-search')).backgroundColor === 'rgb(255, 255, 255)'")
        metrics.append({'page':'home','width':width, 'searchBottom':js("document.querySelector('#heroSearchButton').getBoundingClientRect().bottom")})
        shot(f'home-{width}')
        goto('consulta.html?termo=Dipi')
        check(f'products {width}: two presentations, no public IDs', "document.querySelectorAll('.product-card').length === 2 && !/ID 100/.test(document.querySelector('#productsGrid').innerText)")
        check(f'products {width}: no horizontal overflow', 'document.documentElement.scrollWidth <= innerWidth')
        check(f'products {width}: compact cards', "Array.from(document.querySelectorAll('.product-card')).every(c => c.getBoundingClientRect().height < 380 && c.getBoundingClientRect().width <= 261)")
        check(f'products {width}: buttons aligned within row', "(() => {const c = [...document.querySelectorAll('.product-card')]; return c[0].offsetTop !== c[1].offsetTop || Math.abs(c[0].querySelector('button').getBoundingClientRect().bottom - c[1].querySelector('button').getBoundingClientRect().bottom) < 1})()")
        js("scrollTo({top: Math.max(0, document.querySelector('.results-header').getBoundingClientRect().top + scrollY - 100), behavior:'instant'})")
        shot(f'products-{width}')
        js("document.querySelectorAll('.offer-button')[1].click()")
        check(f'offers {width}: focus transferred', "document.activeElement.id === 'comparisonPanel'")
        check(f'offers {width}: compact navy header replaces introduction', "getComputedStyle(document.querySelector('.consulta-header')).display === 'none' && getComputedStyle(document.querySelector('.comparison-header')).backgroundColor === 'rgb(16, 43, 78)' && document.querySelector('.comparison-header').getBoundingClientRect().height < 210 && getComputedStyle(comparisonPanel).backgroundColor === 'rgba(0, 0, 0, 0)'")
        check(f'offers {width}: no overflow', 'document.documentElement.scrollWidth <= innerWidth')
        check(f'offers {width}: compact and 14px gap', "(() => {const c = [...document.querySelectorAll('.offer-card')]; return c.length === 2 && c.every(e => e.getBoundingClientRect().height < 250 && getComputedStyle(e).marginTop === '0px' && getComputedStyle(e).marginBottom === '0px') && getComputedStyle(document.querySelector('.offers-list')).rowGap === '14px'})()")
        if width > 560:
            check(f'offers {width}: price centered', "[...document.querySelectorAll('.offer-card')].every(c => {const a=c.firstElementChild.getBoundingClientRect(), b=c.lastElementChild.getBoundingClientRect(); return Math.abs((a.top+a.bottom-b.top-b.bottom)/2)<1})")
        metrics.append({'page':'offers','width':width,'heights':js("[...document.querySelectorAll('.offer-card')].map(e=>e.getBoundingClientRect().height)")})
        shot(f'offers-{width}')
        js("document.getElementById('cepOpen').click()")
        check(f'CEP {width}: nonmodal and fits viewport', "cepBox.getAttribute('aria-modal') === 'false' && cepBox.getBoundingClientRect().left >= 0 && cepBox.getBoundingClientRect().right <= innerWidth && cepBox.getBoundingClientRect().bottom <= innerHeight")
        shot(f'cep-{width}')
        key('Escape')
        js("document.getElementById('locOpen').click()")
        check(f'location {width}: fits viewport', "document.querySelector('.popup-card').getBoundingClientRect().right <= innerWidth && document.querySelector('.popup-card').getBoundingClientRect().bottom <= innerHeight")
        shot(f'location-{width}')
        key('Escape')
    size(1280,720)
    for action in ['button','Enter']:
        goto('index.html')
        js("heroMedicineSearch.focus()")
        command('Input.insertText', {'text':'Dipi'})
        if action == 'button': js('heroSearchButton.click()')
        else: key('Enter')
        time.sleep(.5)
        check('home search via '+action, "location.pathname.endsWith('consulta.html') && new URLSearchParams(location.search).get('termo') === 'Dipi' && document.querySelectorAll('.product-card').length === 2")
    goto('consulta.html')
    check('initial state distinct from no results', "!initialState.hidden && emptyState.hidden && document.querySelectorAll('.product-card').length === 0")
    for term, count in [('Dipi',2),('Dipirona',2),('DIPIRONA',2),('zzzz-inexistente',0),('',0),('   ',0)]:
        js(f'searchInput.value = {json.dumps(term)}; searchInput.dispatchEvent(new Event("input", {{bubbles:true}}))')
        check('search '+repr(term), f'document.querySelectorAll(".product-card").length === {count} && emptyState.hidden === {str(bool(count) or not term.strip()).lower()}')
    for id_, count, unavailable, prices in [(1001,3,1,['8,99','10,99','7,50']),(1002,2,0,['14,00','16,00']),(1003,3,3,['6,50','7,25','5,99']),(1004,0,0,[]),(1005,1,0,['12,00']),(1006,3,0,['15,90','15,90','18,50'])]:
        js(f'selecionarMedicamento({id_})')
        check(f'medicine {id_}: offers, availability, exact prices', f'document.querySelectorAll(".offer-card").length === {count} && document.querySelectorAll(".offer-card.unavailable").length === {unavailable} && JSON.stringify([...document.querySelectorAll(".product-price")].map(e=>e.textContent.replace(/[^0-9,]/g,""))) === {json.dumps(json.dumps(prices,separators=(",",":")))}')
        if id_ == 1003: check('all unavailable message', 'comparisonPanel.innerText.includes("Nenhuma oferta disponível")')
        if id_ == 1004: check('no offers message and focus', 'comparisonPanel.innerText.includes("Nenhuma oferta cadastrada") && document.activeElement === comparisonPanel')
        check(f'medicine {id_}: no public ID', '!/ID 100/.test(comparisonPanel.innerText)')
        js("document.querySelector('.comparison-header button').click()")
        check(f'medicine {id_}: return to search and focus', '!searchStep.hidden && comparisonPanel.hidden && document.activeElement === searchInput')
    js("cepOpen.click(); cepInput.value='123'; saveCep.click()")
    check('invalid CEP stays open and focuses input', "!cepBox.hidden && document.activeElement === cepInput && document.querySelector('#toastStatus').innerText.includes('inválido')")
    js("cepInput.value='72429005'; saveCep.click()")
    check('valid CEP formats, closes, returns focus', "cepBox.hidden && document.activeElement === cepOpen && localStorage.getItem('pharmafindCep') === '72429-005'")
    js('cepOpen.click(); saveCep.focus()'); key('Tab')
    check('CEP Tab can leave nonmodal dialog', 'document.activeElement !== cepClose')
    key('Escape')
    check('CEP Escape returns focus', 'cepBox.hidden && document.activeElement === cepOpen')
    js('locOpen.click(); decline.focus()'); key('Tab')
    check('modal Tab wraps and background inert', 'document.activeElement === locClose && document.querySelector("main").inert')
    key('Tab', True)
    check('modal Shift Tab wraps', 'document.activeElement === decline')
    key('Escape')
    check('location Escape restores focus and background', 'locationPopup.hidden && document.activeElement === locOpen && !document.querySelector("main").inert')
    command('Browser.setPermission', {'permission':{'name':'geolocation'},'setting':'denied','origin':BASE})
    js('locOpen.click(); allow.click()'); time.sleep(.3)
    check('denied GPS is handled', 'locationPopup.hidden && document.querySelector("#toastStatus").innerText.includes("GPS negado") && !searchStep.hidden')
    goto('consulta.html?termo=Dipi')
    js("document.querySelector('.product-card img').src='missing-u10-test.png'"); time.sleep(.4)
    check('image fallback loads', "document.querySelector('.product-card img').getAttribute('src') === 'medicamento-placeholder.svg' && document.querySelector('.product-card img').naturalWidth > 0")
    check('placeholder contrast color', "getComputedStyle(searchInput,'::placeholder').color === 'rgb(95, 111, 130)'")
    js("document.querySelectorAll('.offer-button')[0].click(); document.querySelector('.comparison-header button').click(); document.querySelectorAll('.offer-button')[1].click()")
    check('select another presentation through its button', "document.querySelector('#comparisonTitle').textContent.includes('Dipirona 1 g') && document.querySelectorAll('.offer-card').length === 2 && !comparisonPanel.textContent.includes('8,99')")
    for width in [320,390,768,1280,1920]:
        size(width)
        goto('consulta.html?termo=mg')
        check(f'catalog {width}: 5 cards and no overflow', "document.querySelectorAll('.product-card').length === 5 && document.documentElement.scrollWidth <= innerWidth")
        check(f'catalog {width}: actions align within every row', "(() => {const rows = new Map(); for(const c of document.querySelectorAll('.product-card')){const y=c.offsetTop;const b=c.querySelector('button').getBoundingClientRect().bottom;if(rows.has(y) && Math.abs(rows.get(y)-b)>1)return false; rows.set(y,b)}return true})()")
    size(1280,720)
    goto('consulta.html?termo=Dipi')
    js("document.querySelector('.product-card h3').textContent='Nome ilustrativo com várias linhas para verificar o alinhamento'; document.querySelector('.product-description').textContent='Dosagem e apresentação de teste com texto mais longo'")
    check('buttons align with different content lengths', "(() => {const b=[...document.querySelectorAll('.offer-button')].map(e=>e.getBoundingClientRect().bottom);return Math.abs(b[0]-b[1])<1})()")
    js('searchInput.focus()')
    key('Tab'); key('Tab')
    check('keyboard action has visible outline', "getComputedStyle(document.activeElement).outlineStyle !== 'none' && parseFloat(getComputedStyle(document.activeElement).outlineWidth) >= 2")
    key('Enter')
    check('keyboard selects medicine and focuses comparison', "document.activeElement === comparisonPanel && comparisonPanel.innerText.includes('Dipirona 500 mg')")
    js("document.querySelector('.comparison-header button').focus()")
    key('Enter')
    check('keyboard returns to search', 'document.activeElement === searchInput && comparisonPanel.hidden')
    goto('consulta.html')
    js("document.getElementById('initialState').hidden=true; document.getElementById('errorState').hidden=false")
    check('reserved error state visible and legible', "getComputedStyle(document.getElementById('errorState')).display !== 'none' && document.getElementById('errorState').getAttribute('role') === 'alert'")
    shot('query-error-1280')
    for width in [320,390,768,1280,1920]:
        size(width)
        for page in ['como-funciona.html','sobre.html']:
            goto(page)
            check(f'{page} {width}: no horizontal overflow', 'document.documentElement.scrollWidth <= innerWidth')
            shot(page.replace('.html','')+f'-{width}')
    size(390)
    for page in ['index.html','consulta.html','como-funciona.html','sobre.html']:
        goto(page)
        check(page+': unique IDs', "(() => {const ids = [...document.querySelectorAll('[id]')].map(e=>e.id);return new Set(ids).size===ids.length})()")
        js("document.querySelector('.skip-link').focus()")
        key('Enter'); time.sleep(.15)
        check(page+': skip bypasses navigation', "document.activeElement.id === 'conteudo-principal' && !document.activeElement.contains(document.querySelector('nav'))")
        js('mobileMenuButton.click()')
        check(page+': mobile menu opens', "!mobileMenu.hidden && mobileMenuButton.getAttribute('aria-expanded') === 'true'")
        key('Escape')
        check(page+': mobile menu Escape and focus', 'mobileMenu.hidden && document.activeElement === mobileMenuButton')
        js('locOpen.click()'); key('Escape')
        check(page+': modal restores inert elements', "![...document.querySelectorAll('[inert]')].some(e=>e.inert)")
    goto('consulta.html?termo=Dipi')
    js('''window.contrastRatio = (a,b) => {
      const luminance = color => {
        const rgb=color.match(/[\\d.]+/g).slice(0,3).map(n=>Number(n)/255).map(n=>n<=.04045?n/12.92:((n+.055)/1.055)**2.4);
        return rgb.reduce((sum,n,i)=>sum+n*[.2126,.7152,.0722][i],0);
      };
      const l=[luminance(a),luminance(b)].sort((a,b)=>a-b); return (l[1]+.05)/(l[0]+.05);
    }''')
    check('contrast: secondary text on blue gray >= 4.5', "contrastRatio(getComputedStyle(document.querySelector('.consulta-header p')).color, getComputedStyle(document.body).backgroundColor)>=4.5")
    check('contrast: placeholder on white >= 4.5', "contrastRatio(getComputedStyle(searchInput,'::placeholder').color, getComputedStyle(searchInput).backgroundColor)>=4.5")
    js("document.querySelector('.offer-button').click(); document.querySelector('.comparison-header button').focus()")
    check('contrast: selected medicine on navy >= 4.5', "contrastRatio(getComputedStyle(document.querySelector('#comparisonTitle')).color, getComputedStyle(document.querySelector('.comparison-header')).backgroundColor)>=4.5")
    key('Tab'); key('Tab', True)
    check('contrast: comparison return focus outline >= 3', "contrastRatio(getComputedStyle(document.activeElement).outlineColor, getComputedStyle(document.querySelector('.comparison-header')).backgroundColor)>=3")
    js("document.querySelector('.skip-link').focus()")
    key('Enter')
    key('Tab')
    check('comparison skip link still bypasses navigation', "document.activeElement === document.querySelector('.comparison-header button')")
    js("document.querySelector('.comparison-header button').click()")
    check('search introduction restored after comparison', "getComputedStyle(document.querySelector('.consulta-header')).display !== 'none' && !searchStep.hidden")
    if '--homologacao' in sys.argv:
        fixtures=js('({medicamentos,farmacias,ofertas})')
        (OUT/'dados-observados.json').write_text(json.dumps(fixtures,ensure_ascii=False,indent=2),encoding='utf8')
        observations=[]
        for med in fixtures['medicamentos']:
            js(f"searchInput.value={json.dumps(med['nome'])}; searchInput.dispatchEvent(new Event('input',{{bubbles:true}}))")
            js(f"[...document.querySelectorAll('.offer-button')].find(b=>b.getAttribute('aria-label').includes({json.dumps(med['dosagem']+', '+med['apresentacao'])})).click()")
            check(f"UI medicine {med['id']}: exact selection and isolation",f"medicamentoSelecionadoId==={med['id']} && document.querySelectorAll('.offer-card').length===ofertas.filter(o=>o.medicamentoId==={med['id']}).length && comparisonPanel.textContent.includes({json.dumps(med['nome']+' '+med['dosagem'])})")
            check(f"UI medicine {med['id']}: available order and unavailable not highlighted", "(() => {const cards=[...document.querySelectorAll('.offer-card')];let unavailable=false;const prices=[];for(const c of cards){if(c.classList.contains('unavailable')){unavailable=true;if(!c.textContent.includes('Indisponível')||/melhor preço|menor preço/i.test(c.textContent))return false}else{if(unavailable)return false;prices.push(Number(c.querySelector('.product-price').textContent.replace(/[^0-9,]/g,'').replace(',','.')))}}return prices.every((p,i)=>!i||p>=prices[i-1])})()")
            check(f"UI medicine {med['id']}: no economic calculations in UI", "!/[Mm]édia|[Ee]conomia potencial|[Rr]anking/.test(comparisonPanel.textContent)")
            observations.append({'id':med['id'],'observed':js('comparisonPanel.innerText')})
            shot(f"medicine-{med['id']}-1280")
            js("document.querySelector('.comparison-header button').click()")
            check(f"UI medicine {med['id']}: selection cleared", "medicamentoSelecionadoId===null && comparisonPanel.hidden && comparisonPanel.children.length===0 && document.activeElement===searchInput")
        (OUT/'comparacoes-observadas.json').write_text(json.dumps(observations,ensure_ascii=False,indent=2),encoding='utf8')
        for cep in ['72429-005','72429005']:
            js(f"cepOpen.click(); cepInput.value={json.dumps(cep)};saveCep.click()")
            check('CEP input '+cep, "cepBox.hidden && cepInput.value==='72429-005' && document.activeElement===cepOpen && toastStatus.textContent.includes('ainda não está integrada')")
        js("Object.defineProperty(navigator,'geolocation',{configurable:true,value:undefined});locOpen.click();allow.click()")
        check('GPS unavailable simulated without coordinates', "locationPopup.hidden && toastStatus.textContent.includes('Localização indisponível') && toastStatus.textContent.includes('ainda não está integrada') && !searchStep.hidden")
        js("delete navigator.geolocation; searchInput.value='DIPIRONA';searchInput.dispatchEvent(new Event('input',{bubbles:true}))")
        check('search continues after GPS unavailable', "document.querySelectorAll('.product-card').length===2")
        for page in ['index.html','consulta.html','como-funciona.html','sobre.html']:
            goto(page)
            check(page+': no public authentication links', "![...document.querySelectorAll('a')].some(a=>/login|cadastro|signup|signin/i.test(a.getAttribute('href')||''))")
            check(page+': CEP nonmodal semantics', "cepBox.getAttribute('role')==='dialog' && cepBox.getAttribute('aria-modal')==='false' && !!cepBox.getAttribute('aria-label')")
            check(page+': location modal semantics', "locationPopup.getAttribute('role')==='dialog' && locationPopup.getAttribute('aria-modal')==='true' && !!locationPopup.getAttribute('aria-label')")
            links=[a for a in js("[...new Set([...document.querySelectorAll('a[href]')].map(a=>a.href))]") if a.startswith(BASE)]
            statuses=[]
            for link in links:
                try:
                    with urllib.request.urlopen(link) as response: statuses.append({'url':link.replace(BASE,'/'),'status':response.status})
                except Exception as error: statuses.append({'url':link.replace(BASE,'/'),'error':str(error)})
            ok=all(s.get('status')==200 for s in statuses)
            checks.append({'name':page+': public links HTTP','passed':ok,'expected':'200 for all local public links','obtained':statuses})
            if page=='sobre.html':
                check('institutional catalog count agrees with six medicines', "!/dez medicamentos/i.test(document.body.innerText)")
                if not checks[-1]['passed']:
                    js("document.querySelectorAll('.about-card')[1].scrollIntoView({block:'center',behavior:'instant'})"); shot('finding-catalog-count')
            if page=='como-funciona.html':
                check('public instructions do not promise missing filters', "!/utilize os filtros/i.test(document.body.innerText)")
                if not checks[-1]['passed']:
                    js("document.querySelector('.how-cta').scrollIntoView({block:'center',behavior:'instant'})") if js("!!document.querySelector('.how-cta')") else js("scrollTo({top:document.body.scrollHeight,behavior:'instant'})")
                    shot('finding-filters')
        goto('consulta.html?termo=Dipi')
        zoom_before=js('({dpr:devicePixelRatio,innerWidth,outerWidth,visualScale:visualViewport.scale})')
        command('Input.dispatchKeyEvent',{'type':'keyDown','key':'0','code':'Digit0','windowsVirtualKeyCode':48,'modifiers':2})
        command('Input.dispatchKeyEvent',{'type':'keyUp','key':'0','code':'Digit0','windowsVirtualKeyCode':48,'modifiers':2})
        for _ in range(4):
            command('Input.dispatchKeyEvent',{'type':'keyDown','key':'+','code':'Equal','windowsVirtualKeyCode':187,'modifiers':2,'text':'+'})
            command('Input.dispatchKeyEvent',{'type':'keyUp','key':'+','code':'Equal','windowsVirtualKeyCode':187,'modifiers':2})
        time.sleep(.2)
        zoom_after=js('({dpr:devicePixelRatio,innerWidth,outerWidth,visualScale:visualViewport.scale})')
        (OUT/'zoom-tentativa.json').write_text(json.dumps({'method':'Browser shortcut Ctrl+0 and four Ctrl++ via CDP; no viewport reduction','before':zoom_before,'after':zoom_after,'verified200Percent':abs(zoom_after['dpr']/zoom_before['dpr']-2)<.05},indent=2),encoding='utf8')
        if abs(zoom_after['dpr']/zoom_before['dpr']-2)<.05:
            check('real browser zoom 200 no horizontal overflow', 'document.documentElement.scrollWidth<=innerWidth')
            shot('zoom-200')
    errors = [e for e in events if e.get('method') == 'Runtime.exceptionThrown' or (e.get('method')=='Log.entryAdded' and e['params']['entry'].get('source')=='javascript' and e['params']['entry'].get('level')=='error')]
    checks.append({'name':'no JavaScript console errors', 'passed':not errors})
    report={'checks':checks,'metrics':metrics,'browser':browser_version,'jsErrors':errors,'networkErrors':[e for e in events if e.get('method')=='Log.entryAdded' and e['params']['entry'].get('source')=='network'],'failedRequests':[e for e in events if e.get('method')=='Network.loadingFailed']}
    (OUT/'report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
    print(json.dumps({'passed':sum(c['passed'] for c in checks),'failed':[c['name'] for c in checks if not c['passed']],'jsErrors':len(errors),'report':str(OUT/'report.json')},ensure_ascii=False),flush=True)
finally:
    if ws:
        try: command('Browser.close')
        except Exception: pass
        ws.close()
    try: browser.wait(timeout=5)
    except subprocess.TimeoutExpired: browser.terminate()
    server.shutdown()
