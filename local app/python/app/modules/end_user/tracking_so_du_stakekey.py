"""
Check ADA and token balance for a stake address using Koios API.
"""
import requests
from datetime import datetime

def hex_to_ascii(hex_str):
    ascii_str = ""
    for i in range(0, len(hex_str), 2):
        ascii_str += chr(int(hex_str[i:i+2], 16))
    return ascii_str

def check_stake_balance(stake_address: str) -> str:
    url1 = 'https://api.koios.rest/api/v1/account_info'
    url2 = 'https://api.koios.rest/api/v1/account_assets'
    headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    }
    payload = {
        '_stake_addresses': [stake_address]
    }
    try:
        r1 = requests.post(url1, headers=headers, json=payload, timeout=10)
        r1.raise_for_status()
        data1 = r1.json()
        r2 = requests.post(url2, headers=headers, json=payload, timeout=10)
        r2.raise_for_status()
        data2 = r2.json()
    except Exception as e:
        return f"Lỗi khi truy vấn Koios API: {e}"

    if not data1 or not isinstance(data1, list) or not data1[0].get('total_balance'):
        return "Không tìm thấy số dư cho địa chỉ này."

    adabal = round(float(data1[0]['total_balance']) * 1e-6, 2)
    asset_info = []
    checked_time1 = datetime.now().strftime('%H:%M %d-%m-%Y')
    for item in data2:
        asset_name = item.get('asset_name', '')
        asset_name_ascii = hex_to_ascii(asset_name) if asset_name else ''
        quantity = float(item.get('quantity', 0))
        decimal = item.get('decimals', 0)
        if decimal and decimal > 0:
            quantity = quantity * pow(10, -decimal)
        asset_info.append((asset_name_ascii, quantity))
    if asset_info:
        message = f"Thông tin sếp cần đây nhé 😄\n\nSố dư ADA: {adabal}₳\n\nDanh sách Token:\n\n"
        message += "\n".join([f"{name} - {qty}" for name, qty in asset_info])
        message += f"\n\nChecked time {checked_time1}\n\nHãy stake vào VIET pool nhé sếp 🙇 /pool"
        return message
    else:
        message1 = f"Thông tin sếp cần đây nhé 😄\n\nSố dư ADA: {adabal}₳\n\nToken: không có\n\nChecked time {checked_time1}\n\nHãy stake vào VIET pool nhé sếp 🙇 /pool"
        return message1

if __name__ == "__main__":
    stake_addr = input("Nhập địa chỉ stake: ").strip()
    print(check_stake_balance(stake_addr))
