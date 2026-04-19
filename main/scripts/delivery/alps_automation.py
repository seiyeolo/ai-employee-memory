#!/usr/bin/env python3
"""
ALPS(롯데택배 파트너 시스템) 브라우저 자동화
- 로그인: partner.alps.llogis.com
- 일괄주문접수: 집배달 > 집하지시 > 일괄주문접수 (iframe)
"""
import json, time, os, threading, requests, websocket

CHROME_URL  = "http://127.0.0.1:9222"
ALPS_LOGIN  = "https://partner.alps.llogis.com/main/pages/sec/authentication"
ALPS_ID     = "641244"
ALPS_PW     = "vjxltmxm01"

class CDP:
    def __init__(self):
        self.ws = None
        self._id = 0
        self._resp = {}
        self._lock = threading.Lock()

    def connect(self, target_url_fragment=None):
        pages = requests.get(f"{CHROME_URL}/json/list", timeout=5).json()
        if target_url_fragment:
            target = next((p for p in pages if target_url_fragment in p.get('url','') and p.get('type')=='page'), None)
        target = target or next((p for p in pages if p.get('type')=='page'), pages[0])
        ws_url = target['webSocketDebuggerUrl']
        self.ws = websocket.WebSocketApp(ws_url, on_message=self._on_msg)
        t = threading.Thread(target=self.ws.run_forever, daemon=True)
        t.start()
        time.sleep(1)
        return self

    def _on_msg(self, ws, msg):
        d = json.loads(msg)
        if 'id' in d:
            with self._lock:
                self._resp[d['id']] = d

    def cmd(self, method, params=None, timeout=15):
        self._id += 1
        mid = self._id
        self.ws.send(json.dumps({'id': mid, 'method': method, 'params': params or {}}))
        deadline = time.time() + timeout
        while time.time() < deadline:
            with self._lock:
                if mid in self._resp:
                    return self._resp.pop(mid)
            time.sleep(0.1)
        return None

    def js(self, expr, timeout=10):
        r = self.cmd('Runtime.evaluate', {'expression': expr, 'awaitPromise': True}, timeout)
        if r:
            return r.get('result', {}).get('result', {}).get('value')
        return None

    def navigate(self, url, wait=3):
        print(f"  → {url[:70]}")
        self.cmd('Page.navigate', {'url': url})
        time.sleep(wait)

    def close(self):
        if self.ws:
            self.ws.close()


def login_alps():
    """ALPS 로그인 및 JWT 토큰 획득"""
    print("\n🔐 ALPS 로그인 중...")
    cdp = CDP().connect('alps.llogis.com')
    cdp.navigate(ALPS_LOGIN, wait=2)

    # 로그인 폼 입력
    cdp.js(f'''
        (function() {{
            const nv = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set;
            const id = document.querySelector('input[name="principal"]');
            const pw = document.querySelector('input[name="credential"]');
            nv.call(id, '{ALPS_ID}');
            nv.call(pw, '{ALPS_PW}');
            ['input','change'].forEach(e => {{
                id.dispatchEvent(new Event(e, {{bubbles:true}}));
                pw.dispatchEvent(new Event(e, {{bubbles:true}}));
            }});
        }})()
    ''')
    time.sleep(0.5)

    # 로그인 버튼 클릭
    cdp.js('''
        (function() {
            const li = document.querySelector('li.login_btn i-button');
            if (li) li.dispatchEvent(new MouseEvent('click',{bubbles:true,cancelable:true,view:window}));
        })()
    ''')
    time.sleep(3)

    url = cdp.js('window.location.href') or ''
    if 'token=' in url:
        print("  ✅ 로그인 성공 — (주)퍼티스트")
        return cdp, url
    else:
        print(f"  ❌ 로그인 실패: {url[:80]}")
        cdp.close()
        return None, None


def open_bulk_order_page(cdp):
    """집배달 > 일괄주문접수 메뉴 열기"""
    print("\n📋 일괄주문접수 메뉴 이동 중...")

    # 집배달 메뉴 클릭
    cdp.js('''
        (function() {
            const spans = Array.from(document.querySelectorAll('span'));
            const s = spans.find(x => x.innerText.trim() === '집배달');
            if (s) { let el = s; for(let i=0;i<5;i++){el.click();el=el.parentElement;if(!el)break;} }
        })()
    ''')
    time.sleep(1)

    # 일괄주문접수 링크 클릭
    cdp.js('''
        (function() {
            const links = Array.from(document.querySelectorAll('a.menuLeaf'));
            const t = links.find(a => a.innerText.trim() === '일괄주문접수');
            if (t) t.dispatchEvent(new MouseEvent('click',{bubbles:true,cancelable:true,view:window}));
        })()
    ''')
    time.sleep(3)

    # 메뉴 닫기
    cdp.js('''
        (function() {
            document.querySelectorAll('.btnClose').forEach(b => { if(b.offsetParent) b.click(); });
        })()
    ''')
    time.sleep(1)
    print("  ✅ 일괄주문접수 페이지 열림")
    return True


def upload_excel_to_alps(excel_file):
    """ALPS 일괄주문접수 페이지에 Excel 파일 업로드"""
    print(f"\n🚚 ALPS 운송장 업로드: {os.path.basename(excel_file)}")

    # 이미 ALPS에 로그인되어 있는지 확인
    cdp = CDP().connect('alps.llogis.com')
    current = cdp.js('window.location.href') or ''

    if 'authentication' in current or 'alps' not in current:
        print("  재로그인 필요...")
        cdp.close()
        cdp, _ = login_alps()
        if not cdp:
            return False

    # 일괄주문접수 페이지 이동
    open_bulk_order_page(cdp)

    # iframe 내부 페이지 찾기 (별도 CDP 타겟)
    time.sleep(2)
    all_targets = requests.get(f"{CHROME_URL}/json/list", timeout=5).json()
    iframe_target = next((t for t in all_targets if 'PIDCUS014U' in t.get('url','')), None)

    if iframe_target:
        print("  ✅ iframe 타겟 발견")
        iframe_cdp = CDP()
        iframe_ws = iframe_target['webSocketDebuggerUrl']
        iframe_cdp.ws = websocket.WebSocketApp(iframe_ws, on_message=iframe_cdp._on_msg)
        t = threading.Thread(target=iframe_cdp.ws.run_forever, daemon=True)
        t.start()
        time.sleep(1)

        # DOM에서 파일 input 찾아 CDP로 파일 설정
        doc = iframe_cdp.cmd('DOM.getDocument')
        root_id = doc.get('result', {}).get('root', {}).get('nodeId', 1)

        file_input = iframe_cdp.cmd('DOM.querySelector', {'nodeId': root_id, 'selector': 'input[type="file"]'})
        file_node_id = file_input.get('result', {}).get('nodeId') if file_input else None

        if file_node_id:
            iframe_cdp.cmd('DOM.setFileInputFiles', {
                'nodeId': file_node_id,
                'files': [os.path.abspath(excel_file)]
            })
            print(f"  ✅ 파일 선택 완료: {os.path.basename(excel_file)}")
            time.sleep(2)

            # 업로드 버튼 클릭
            iframe_cdp.js('''
                (function() {
                    const btns = Array.from(document.querySelectorAll('button, i-button, [class*="btn"]'));
                    const btn = btns.find(b => {
                        const t = (b.innerText || b.getAttribute("value") || "").trim();
                        return t.includes("업로드") || t.includes("접수") || t.includes("파일열기");
                    });
                    if (btn) { btn.dispatchEvent(new MouseEvent("click",{bubbles:true})); return btn.innerText; }
                    return "버튼없음";
                })()
            ''')
            time.sleep(5)
            print("  ✅ 업로드 완료")
            iframe_cdp.close()
        else:
            print("  ⚠️  파일 input을 찾지 못했습니다")
    else:
        print("  ⚠️  iframe 타겟을 찾지 못했습니다 — 메인 DOM으로 시도")

    cdp.close()
    return True


if __name__ == '__main__':
    import sys
    mode = sys.argv[1] if len(sys.argv) > 1 else 'login'

    if mode == 'login':
        cdp, url = login_alps()
        if cdp: cdp.close()

    elif mode == 'upload':
        f = sys.argv[2] if len(sys.argv) > 2 else input("업로드 파일: ")
        upload_excel_to_alps(f)
