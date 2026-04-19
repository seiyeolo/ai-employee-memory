#!/usr/bin/env python3
"""
Chrome DevTools Protocol을 이용한 브라우저 자동화
- 스마트스토어 발주 Excel 다운로드
- 롯데택배 사업자 사이트 운송장 일괄 업로드
"""
import json
import time
import os
import glob
import requests
import websocket
import threading
import urllib.parse
from datetime import datetime

CHROME_URL = "http://127.0.0.1:9222"
DOWNLOAD_DIR = os.path.expanduser("~/Downloads/puttist-delivery")

class ChromeController:
    def __init__(self):
        self.ws = None
        self.msg_id = 0
        self.responses = {}
        self.lock = threading.Lock()

    def connect(self):
        pages = requests.get(f"{CHROME_URL}/json/list").json()
        target = next((p for p in pages if p.get('type') == 'page'), pages[0])
        ws_url = target['webSocketDebuggerUrl']
        self.ws = websocket.WebSocketApp(ws_url,
            on_message=self._on_message,
            on_error=lambda ws, e: print(f"WS Error: {e}"))
        thread = threading.Thread(target=self.ws.run_forever)
        thread.daemon = True
        thread.start()
        time.sleep(1)
        return self

    def _on_message(self, ws, message):
        data = json.loads(message)
        if 'id' in data:
            with self.lock:
                self.responses[data['id']] = data

    def send(self, method, params=None, timeout=15):
        self.msg_id += 1
        mid = self.msg_id
        msg = json.dumps({'id': mid, 'method': method, 'params': params or {}})
        self.ws.send(msg)
        start = time.time()
        while time.time() - start < timeout:
            with self.lock:
                if mid in self.responses:
                    return self.responses.pop(mid)
            time.sleep(0.1)
        return None

    def navigate(self, url, wait=3):
        print(f"  → 이동: {url[:60]}...")
        self.send('Page.navigate', {'url': url})
        time.sleep(wait)

    def click(self, selector, wait=1):
        result = self.send('Runtime.evaluate', {
            'expression': f'''
                (function() {{
                    var el = document.querySelector("{selector}");
                    if (el) {{ el.click(); return true; }}
                    return false;
                }})()
            '''
        })
        time.sleep(wait)
        return result

    def fill(self, selector, value, wait=0.5):
        escaped = value.replace('"', '\\"')
        self.send('Runtime.evaluate', {
            'expression': f'''
                (function() {{
                    var el = document.querySelector("{selector}");
                    if (el) {{
                        el.value = "{escaped}";
                        el.dispatchEvent(new Event('input', {{bubbles:true}}));
                        el.dispatchEvent(new Event('change', {{bubbles:true}}));
                        return true;
                    }}
                    return false;
                }})()
            '''
        })
        time.sleep(wait)

    def wait_for(self, selector, timeout=10):
        start = time.time()
        while time.time() - start < timeout:
            result = self.send('Runtime.evaluate', {
                'expression': f'!!document.querySelector("{selector}")'
            })
            if result and result.get('result', {}).get('result', {}).get('value'):
                return True
            time.sleep(0.5)
        return False

    def get_text(self, selector):
        result = self.send('Runtime.evaluate', {
            'expression': f'document.querySelector("{selector}")?.innerText || ""'
        })
        return result.get('result', {}).get('result', {}).get('value', '')

    def set_download_dir(self, directory):
        self.send('Page.setDownloadBehavior', {
            'behavior': 'allow',
            'downloadPath': directory
        })

    def close(self):
        if self.ws:
            self.ws.close()


def download_smartstore_orders(password):
    """스마트스토어 발주확인/발송관리에서 Excel 다운로드"""
    print("\n📦 스마트스토어 주문 Excel 다운로드 시작")
    os.makedirs(DOWNLOAD_DIR, exist_ok=True)

    chrome = ChromeController().connect()
    chrome.set_download_dir(DOWNLOAD_DIR)

    # 발주확인/발송관리 페이지
    chrome.navigate("https://sell.smartstore.naver.com/#/order/delivery", wait=4)

    # 로그인 확인
    current_url_result = chrome.send('Runtime.evaluate', {
        'expression': 'window.location.href'
    })
    current_url = current_url_result.get('result', {}).get('result', {}).get('value', '')

    if 'login' in current_url.lower() or 'about:blank' in current_url:
        print("❌ 로그인 필요 - 스마트스토어 로그인 상태를 확인하세요")
        chrome.close()
        return None

    print("  ✅ 스마트스토어 접속 확인")
    time.sleep(2)

    # 전체 기간 조회 또는 오늘 날짜 설정 후 조회
    # Excel 다운로드 버튼 클릭 (스마트스토어 UI에 맞게 조정 필요)
    download_btn_selectors = [
        'button[data-nclick*="excel"]',
        'button:contains("엑셀")',
        '.excel-download',
        'a[href*="excel"]',
        'button.btn-excel',
    ]

    clicked = False
    for sel in download_btn_selectors:
        result = chrome.send('Runtime.evaluate', {
            'expression': f'''
                (function() {{
                    var btns = Array.from(document.querySelectorAll('button, a'));
                    var btn = btns.find(el => el.innerText && el.innerText.includes('엑셀'));
                    if (btn) {{ btn.click(); return btn.innerText; }}
                    return null;
                }})()
            '''
        })
        val = result.get('result', {}).get('result', {}).get('value')
        if val:
            print(f"  ✅ Excel 버튼 클릭: '{val}'")
            clicked = True
            break

    if not clicked:
        print("  ⚠️  Excel 다운로드 버튼을 찾지 못했습니다")
        print("  → 수동으로 다운로드 후 비밀번호를 입력해 주세요")

    # 비밀번호 입력 팝업 처리
    time.sleep(2)
    pw_inputs = ['input[type="password"]', 'input[placeholder*="비밀번호"]', 'input[placeholder*="password"]']
    for sel in pw_inputs:
        result = chrome.send('Runtime.evaluate', {
            'expression': f'!!document.querySelector("{sel}")'
        })
        if result and result.get('result', {}).get('result', {}).get('value'):
            chrome.fill(sel, password)
            time.sleep(0.5)
            chrome.click('button[type="submit"], .btn-confirm, .confirm-btn')
            print(f"  ✅ 비밀번호 입력 완료")
            break

    # 다운로드 완료 대기
    print("  ⏳ 다운로드 대기 중...")
    time.sleep(5)

    # 다운로드된 파일 찾기
    before = set()
    downloaded = None
    for _ in range(12):  # 최대 60초 대기
        files = set(glob.glob(os.path.join(DOWNLOAD_DIR, "*.xlsx")) +
                   glob.glob(os.path.join(DOWNLOAD_DIR, "*.xls")))
        new_files = files - before
        if new_files:
            downloaded = sorted(new_files, key=os.path.getmtime)[-1]
            print(f"  ✅ 다운로드 완료: {os.path.basename(downloaded)}")
            break
        before = files
        time.sleep(5)

    chrome.close()
    return downloaded


def upload_to_lotte(excel_file):
    """롯데택배 사업자 사이트에 운송장 일괄 업로드"""
    print("\n🚚 롯데택배 운송장 일괄 업로드 시작")

    chrome = ChromeController().connect()

    # 롯데택배 사업자 사이트
    LOTTE_URL = "https://www.lotteglogis.com"
    chrome.navigate(f"{LOTTE_URL}/business/waybill/bulk", wait=4)

    # 로그인 확인
    current_url_result = chrome.send('Runtime.evaluate', {
        'expression': 'window.location.href'
    })
    current_url = current_url_result.get('result', {}).get('result', {}).get('value', '')
    print(f"  현재 URL: {current_url[:60]}")

    # 파일 업로드 (input[type=file])
    time.sleep(2)
    chrome.send('Runtime.evaluate', {
        'expression': f'''
            (function() {{
                var input = document.querySelector('input[type="file"]');
                if (!input) return "파일 input 없음";
                // 파일 업로드는 보안상 직접 설정 불가 → CDP로 처리
                return "found";
            }})()
        '''
    })

    # CDP DOM.setFileInputFiles로 파일 선택
    node_result = chrome.send('DOM.getDocument')
    root_id = node_result.get('result', {}).get('root', {}).get('nodeId', 1)

    file_input = chrome.send('DOM.querySelector', {
        'nodeId': root_id,
        'selector': 'input[type="file"]'
    })
    file_node_id = file_input.get('result', {}).get('nodeId')

    if file_node_id:
        chrome.send('DOM.setFileInputFiles', {
            'nodeId': file_node_id,
            'files': [os.path.abspath(excel_file)]
        })
        print(f"  ✅ 파일 선택: {os.path.basename(excel_file)}")
        time.sleep(1)

        # 업로드/확인 버튼 클릭
        chrome.send('Runtime.evaluate', {
            'expression': '''
                (function() {
                    var btns = Array.from(document.querySelectorAll('button'));
                    var btn = btns.find(el => el.innerText && (
                        el.innerText.includes('업로드') ||
                        el.innerText.includes('등록') ||
                        el.innerText.includes('확인')
                    ));
                    if (btn) { btn.click(); return btn.innerText; }
                    return null;
                })()
            '''
        })
        time.sleep(3)
        print("  ✅ 업로드 버튼 클릭")
    else:
        print("  ⚠️  파일 업로드 입력창을 찾지 못했습니다")
        print(f"  → 수동으로 {excel_file} 파일을 업로드해 주세요")

    chrome.close()
    return True


if __name__ == '__main__':
    import sys
    mode = sys.argv[1] if len(sys.argv) > 1 else 'download'

    if mode == 'download':
        pw = sys.argv[2] if len(sys.argv) > 2 else input("스마트스토어 Excel 비밀번호: ")
        result = download_smartstore_orders(pw)
        if result:
            print(f"\n결과 파일: {result}")
    elif mode == 'upload':
        file = sys.argv[2] if len(sys.argv) > 2 else input("업로드할 Excel 파일 경로: ")
        upload_to_lotte(file)
