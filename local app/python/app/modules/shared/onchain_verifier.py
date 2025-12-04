"""
Community Admin - Verify On-Chain Module
Xác minh số dư ví và stake sử dụng Koios/Blockfrost API
"""
import requests
from app.utils.crypto import Logger


class OnChainVerifier:
    """Verify wallet balance and stake on-chain"""
    
    KOIOS_API_URL = "https://api.koios.rest/api/v0"
    LOVELACE_PER_ADA = 1000000
    
    @staticmethod
    def verify_stake(
        stake_address: str,
        api_provider: str = "koios",
        api_key: str = ""
    ) -> dict:
        """
        Verify stake address on-chain
        
        Args:
            stake_address: Cardano stake address
            api_provider: API provider (koios or blockfrost)
            api_key: API key (if needed)
        
        Returns:
            Dictionary with verification results
        """
        Logger.info(f"========== On-Chain Stake Verification ==========", "ONCHAIN")
        Logger.warning(f"Verifying stake address: {stake_address}")
        
        if api_provider == "koios":
            return OnChainVerifier._verify_koios(stake_address)
        elif api_provider == "blockfrost":
            return OnChainVerifier._verify_blockfrost(stake_address, api_key)
        else:
            Logger.error(f"API provider '{api_provider}' not implemented")
            return {"verified": False}
    
    @staticmethod
    def _verify_koios(stake_address: str) -> dict:
        """Verify using Koios API"""
        try:
            url = f"{OnChainVerifier.KOIOS_API_URL}/account_info"
            params = {"_stake_addresses": f'"{stake_address}"'}
            
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            
            if data and len(data) > 0:
                account = data[0]
                balance = int(account.get('balance', 0))
                ada = balance / OnChainVerifier.LOVELACE_PER_ADA
                
                Logger.success("Stake address found on-chain")
                print(f"  Balance: {ada} ADA ({balance} Lovelace)")
                print(f"  Status: {account.get('status', 'unknown')}")
                
                return {
                    'stake_address': stake_address,
                    'balance': balance,
                    'balance_ada': ada,
                    'status': account.get('status', 'unknown'),
                    'verified': True
                }
            else:
                Logger.error("Stake address not found or has no ADA")
                return {"verified": False}
                
        except requests.RequestException as e:
            Logger.error(f"Error checking on-chain: {str(e)}")
            return {"verified": False}
    
    @staticmethod
    def _verify_blockfrost(stake_address: str, api_key: str) -> dict:
        """Verify using Blockfrost API (placeholder)"""
        Logger.error("Blockfrost API not yet implemented")
        return {"verified": False}
