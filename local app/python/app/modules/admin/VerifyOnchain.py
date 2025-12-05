import requests

def verify_onchain_stake(stake_address, api_provider="koios", api_key=""):
    if api_provider == "koios":
        api_url = f"https://api.koios.rest/api/v0/account_info?_stake_addresses={stake_address}"
        try:
            response = requests.get(api_url, timeout=10)
            response.raise_for_status()
            data = response.json()
            if data and len(data) > 0:
                account = data[0]
                balance = int(account.get("balance", 0))
                ada = balance / 1_000_000
                print(f"✓ Stake address found on-chain\n  Balance: {ada} ADA ({balance} Lovelace)\n  Status: {account.get('status')}")
                return {
                    "StakeAddress": stake_address,
                    "Balance": balance,
                    "BalanceAda": ada,
                    "Status": account.get("status"),
                    "Verified": True
                }
            else:
                print("✗ Stake address not found or has no ADA")
                return {"Verified": False}
        except Exception as e:
            print(f"✗ Error checking on-chain: {e}")
            return {"Verified": False}
    else:
        print(f"✗ API provider '{api_provider}' not yet implemented")
        return None