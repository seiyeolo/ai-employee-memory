#!/usr/bin/env python3
"""
스마트스토어 배송 Excel → 롯데택배 일괄업로드 Excel 변환기
사용법: python3 convert_to_lotte.py <스마트스토어파일.xlsx> [비밀번호]
"""
import sys
import os
import pandas as pd
import openpyxl
from openpyxl import Workbook
from datetime import datetime
import msoffcrypto
import io

def decrypt_excel(filepath, password):
    """비밀번호로 암호화된 Excel 복호화"""
    with open(filepath, 'rb') as f:
        office_file = msoffcrypto.OfficeFile(f)
        if office_file.is_encrypted():
            decrypted = io.BytesIO()
            office_file.load_key(password=password)
            office_file.decrypt(decrypted)
            decrypted.seek(0)
            return decrypted
        else:
            return filepath

def parse_smartstore_excel(filepath, password=None):
    """스마트스토어 주문 Excel 파싱"""
    try:
        if password:
            file_data = decrypt_excel(filepath, password)
        else:
            file_data = filepath

        # 스마트스토어는 보통 헤더가 1~2행에 있음
        df = pd.read_excel(file_data, header=1, dtype=str)
        df = df.fillna('')
        print(f"✅ 파일 로드 완료: {len(df)}행, 컬럼: {list(df.columns[:5])}...")
        return df

    except Exception as e:
        print(f"❌ 파일 로드 실패: {e}")
        sys.exit(1)

def find_column(df, candidates):
    """후보 컬럼명 중 실제 존재하는 것 반환"""
    for col in candidates:
        for actual in df.columns:
            if col in str(actual):
                return actual
    return None

def convert_to_lotte_format(df):
    """롯데택배 일괄업로드 형식으로 변환"""

    # 스마트스토어 컬럼 → 롯데택배 컬럼 매핑
    col_map = {
        '수취인명':     ['수취인명', '받는분 성명', '수령인', '수취인'],
        '수취인전화':   ['수취인 전화번호', '수취인전화', '받는분 전화번호', '전화번호1'],
        '수취인핸드폰': ['수취인 휴대폰번호', '핸드폰', '휴대폰', '전화번호2'],
        '우편번호':     ['우편번호', '수취인 우편번호'],
        '주소':         ['수취인 주소(전체)', '배송지', '수취인 주소', '주소'],
        '상품명':       ['상품명', '상품 이름'],
        '수량':         ['수량', '주문수량'],
        '주문번호':     ['주문번호', '상품주문번호'],
        '메모':         ['배송 메시지', '배송메시지', '구매자 메모'],
    }

    result_rows = []
    missing_cols = []

    for target, candidates in col_map.items():
        found = find_column(df, candidates)
        if not found and target in ['수취인명', '수취인전화', '주소']:
            missing_cols.append(f"{target} (후보: {candidates})")

    if missing_cols:
        print(f"⚠️  필수 컬럼 찾기 실패: {missing_cols}")
        print(f"   실제 컬럼 목록: {list(df.columns)}")

    for _, row in df.iterrows():
        def get(key):
            col = find_column(df, col_map.get(key, [key]))
            return str(row[col]).strip() if col and col in df.columns else ''

        # 빈 행 스킵
        name = get('수취인명')
        if not name or name in ['nan', '']:
            continue

        # 주소 분리 (시도 + 상세주소)
        full_addr = get('주소')
        addr_parts = full_addr.split(' ', 2)
        addr1 = ' '.join(addr_parts[:2]) if len(addr_parts) >= 2 else full_addr
        addr2 = addr_parts[2] if len(addr_parts) >= 3 else ''

        result_rows.append({
            '보내는분성명':   '퍼티스트',
            '보내는분전화':   '01012345678',  # 회사 전화로 수정 필요
            '보내는분주소':   '서울특별시',    # 회사 주소로 수정 필요
            '받는분성명':     name,
            '받는분전화':     get('수취인전화') or get('수취인핸드폰'),
            '받는분휴대폰':   get('수취인핸드폰'),
            '우편번호':       get('우편번호'),
            '받는분주소(시도+시군구)': addr1,
            '받는분주소(상세)':       addr2,
            '품명':           get('상품명') or '퍼티스트 퍼팅미터',
            '수량':           get('수량') or '1',
            '메모':           get('메모'),
            '주문번호':       get('주문번호'),
        })

    print(f"✅ 변환 완료: {len(result_rows)}건")
    return pd.DataFrame(result_rows)

def save_lotte_excel(df, output_path):
    """롯데택배 업로드용 Excel 저장"""
    wb = Workbook()
    ws = wb.active
    ws.title = "운송장등록"

    # 롯데택배 양식 헤더 (실제 양식과 맞춰야 함)
    headers = list(df.columns)
    ws.append(headers)

    for _, row in df.iterrows():
        ws.append([str(v) if v else '' for v in row.values])

    # 컬럼 너비 자동 조정
    for col in ws.columns:
        max_len = max(len(str(cell.value or '')) for cell in col)
        ws.column_dimensions[col[0].column_letter].width = min(max_len + 2, 30)

    wb.save(output_path)
    print(f"✅ 저장 완료: {output_path}")
    return output_path

def main():
    if len(sys.argv) < 2:
        print("사용법: python3 convert_to_lotte.py <파일.xlsx> [비밀번호]")
        sys.exit(1)

    input_file = sys.argv[1]
    password = sys.argv[2] if len(sys.argv) > 2 else None

    if not os.path.exists(input_file):
        print(f"❌ 파일 없음: {input_file}")
        sys.exit(1)

    print(f"📂 입력 파일: {input_file}")
    if password:
        print(f"🔑 비밀번호 있음 (복호화 시도)")

    df = parse_smartstore_excel(input_file, password)
    lotte_df = convert_to_lotte_format(df)

    today = datetime.now().strftime('%Y%m%d_%H%M')
    output_file = os.path.join(
        os.path.dirname(input_file),
        f'롯데택배_업로드_{today}.xlsx'
    )

    save_lotte_excel(lotte_df, output_file)

    print(f"\n📋 결과 요약:")
    print(f"   처리 건수: {len(lotte_df)}건")
    print(f"   출력 파일: {output_file}")
    return output_file

if __name__ == '__main__':
    main()
