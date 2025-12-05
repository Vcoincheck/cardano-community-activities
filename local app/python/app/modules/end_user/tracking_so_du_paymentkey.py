"""
Cardano Wallet Checker (Python)
- Payment Address: Get balance, assets, stake address
- Stake Address: Get delegation info
"""
import requests
from datetime import datetime

def hex_to_ascii(hex_str):
    ascii_str = ""
    for i in range(0, len(hex_str), 2):
        ascii_str += chr(int(hex_str[i:i+2], 16))
    return ascii_str

def get_payment_address_info(payment_address):
    url1 = 'https://api.koios.rest/api/v1/address_info'
    url2 = 'https://api.koios.rest/api/v1/address_assets'
    headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    }
    payload = {
        '_addresses': [payment_address]
    }
    try:
        r1 = requests.post(url1, headers=headers, json=payload, timeout=10)
        r1.raise_for_status()
        data1 = r1.json()
        r2 = requests.post(url2, headers=headers, json=payload, timeout=10)
        r2.raise_for_status()
        data2 = r2.json()
        adabal = round(float(data1[0]['balance']) * 1e-6, 2)
        stake_address = data1[0].get('stake_address', 'N/A')
        asset_info = []
        if data2 and len(data2) > 0 and data2[0].get('asset_list'):
            for item in data2[0]['asset_list']:
                asset_name = item.get('asset_name', '')
                asset_name_ascii = hex_to_ascii(asset_name) if asset_name else ''
                quantity = float(item.get('quantity', 0))
                decimal = item.get('decimals', 0)
                if decimal and decimal > 0:
                    quantity = quantity * pow(10, -decimal)
                asset_info.append((asset_name_ascii, quantity))
        return {
            'PaymentAddress': payment_address,
            'StakeAddress': stake_address,
            'ADABalance': adabal,
            'Assets': asset_info,
            'Success': True
        }
    except Exception as e:
        return {
            'PaymentAddress': payment_address,
            'StakeAddress': 'N/A',
            'ADABalance': 0,
            'Assets': [],
            'Success': False,
            'Error': str(e)
        }

def get_account_info(stake_address):
    url = 'https://api.koios.rest/api/v1/account_info'
    headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    }
    payload = {
        '_stake_addresses': [stake_address]
    }
    try:
        r = requests.post(url, headers=headers, json=payload, timeout=10)
        r.raise_for_status()
        data = r.json()
        if data and len(data) > 0:
            account_data = data[0]
            pool_id = account_data.get('delegated_pool', 'Not delegated')
            pool_name = 'Unknown'
            # If delegated, get pool name
            if pool_id != 'Not delegated':
                try:
                    pool_url = 'https://api.koios.rest/api/v1/pool_info'
                    pool_payload = {'_pool_bech32_ids': [pool_id]}
                    pool_r = requests.post(pool_url, headers=headers, json=pool_payload, timeout=10)
                    pool_r.raise_for_status()
                    pool_data = pool_r.json()
                    if pool_data and len(pool_data) > 0:
                        meta = pool_data[0].get('meta_json', {})
                        pool_name = meta.get('name') or pool_data[0].get('pool_id_bech32', 'Unknown')
                except Exception:
                    pass
            return {
                'StakeAddress': stake_address,
                'PoolId': pool_id,
                'PoolName': pool_name,
                'Status': account_data.get('status', 'Unknown'),
                'Success': True
            }
        else:
            return {
                'StakeAddress': stake_address,
                'PoolId': 'Not delegated',
                'PoolName': 'N/A',
                'Status': 'Not registered',
                'Success': True
            }
    except Exception as e:
        return {
            'StakeAddress': stake_address,
            'PoolId': 'Error',
            'PoolName': 'Error',
            'Status': 'Error',
            'Success': False,
            'Error': str(e)
        }

def show_payment_address_info(address_data):
    if not address_data.get('Success'):
        print("\n❌ Failed to retrieve address information")
        if address_data.get('Error'):
            print(f"Error: {address_data['Error']}")
        return
    checked_time = datetime.now().strftime('%H:%M %d-%m-%Y')
    print("\n========================================")
    print("     THÔNG TIN PAYMENT ADDRESS")
    print("========================================")
    print(f"\nPayment Address:\n  {address_data['PaymentAddress']}")
    print(f"\nStake Address:\n  {address_data['StakeAddress']}")
    print(f"\nSố dư ADA: {address_data['ADABalance']} ₳")
    if address_data['Assets']:
        print("\nDanh sách Token:")
        for asset in address_data['Assets']:
            print(f"  - {asset[0]}: {asset[1]}")
    else:
        print("\nToken: không có")
    print(f"\nChecked time: {checked_time}")
    print("========================================\n")

def show_account_info(account_data):
    if not account_data.get('Success'):
        print("\n❌ Failed to retrieve account information")
        if account_data.get('Error'):
            print(f"Error: {account_data['Error']}")
        return
    checked_time = datetime.now().strftime('%H:%M %d-%m-%Y')
    print("\n========================================")
    print("     THÔNG TIN STAKE ACCOUNT")
    print("========================================")
    print(f"\nStake Address:\n  {account_data['StakeAddress']}")
    print(f"\nDelegation Status:\n  Status: {account_data['Status']}")
    print("\nDelegated Pool:")
    if account_data['PoolId'] == 'Not delegated':
        print("  Not delegated to any pool")
    else:
        print(f"  Pool Name: {account_data['PoolName']}")
        print(f"  Pool ID: {account_data['PoolId']}")
    print(f"\nChecked time: {checked_time}")
    print("========================================\n")

def check_payment_address(payment_address):
    print("\n========================================")
    print("  Cardano Payment Address Checker")
    print("========================================\n")
    address_data = get_payment_address_info(payment_address)
    show_payment_address_info(address_data)
    return address_data

def check_stake_account(stake_address):
    print("\n========================================")
    print("  Cardano Stake Account Checker")
    print("========================================\n")
    account_data = get_account_info(stake_address)
    show_account_info(account_data)
    return account_data

if __name__ == "__main__":
    print("""
USAGE EXAMPLES:
===============

# Check payment address (balance + assets):
check_payment_address("addr1...")

# Check stake account (delegation info):
check_stake_account("stake1...")

# Or use functions directly for custom handling:
address_data = get_payment_address_info("addr1...")
account_data = get_account_info("stake1...")
""")
    # Simple CLI
    mode = input("Chọn chế độ (1: Payment Address, 2: Stake Address): ").strip()
    if mode == '1':
        addr = input("Nhập Payment Address (addr1...): ").strip()
        check_payment_address(addr)
    elif mode == '2':
        stake = input("Nhập Stake Address (stake1...): ").strip()
        check_stake_account(stake)
    else:
        print("Chế độ không hợp lệ.")
