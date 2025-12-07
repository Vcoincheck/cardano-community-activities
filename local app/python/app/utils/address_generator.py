"""
Address Generation Pipeline
Step-by-step address generation from mnemonic
"""
from typing import Optional
from utils.cardano_address import CardanoAddressGenerator
from shared.derive_stake import StakeAddressDeriver


class AddressGenerator:
    """Generate Cardano addresses step by step"""
    
    @staticmethod
    def generate_payment_address(mnemonic: str, account_index: int = 0,
                                address_index: int = 0, is_external: bool = True,
                                network: str = "mainnet") -> Optional[dict]:
        """
        Generate a single payment address
        
        Args:
            mnemonic: BIP39 mnemonic phrase
            account_index: BIP44 account index
            address_index: Address index in chain
            is_external: True for external (0/i), False for internal (1/i)
            network: "mainnet" or "testnet"
            
        Returns:
            Dict with address info or None
        """
        print(f"[*] Generating {'external' if is_external else 'internal'} address {address_index}...")
        
        # Find cardano-address tool
        cardano_address_exe = CardanoAddressGenerator.find_cardano_address_exe()
        if not cardano_address_exe:
            print("✗ cardano-address tool not found")
            return None
        
        # Generate root key
        root_key = CardanoAddressGenerator.get_root_key(mnemonic, cardano_address_exe)
        if not root_key:
            print("✗ Failed to generate root key")
            return None
        
        # Derive account key (BIP44: m/1852H/1815H/accountH)
        account_path = f"1852H/1815H/{account_index}H"
        account_key = CardanoAddressGenerator.derive_key(root_key, account_path, cardano_address_exe)
        if not account_key:
            print(f"✗ Failed to derive account key")
            return None
        
        # Derive payment key
        chain = 0 if is_external else 1
        payment_path = f"{chain}/{address_index}"
        payment_key = CardanoAddressGenerator.derive_key(account_key, payment_path, cardano_address_exe)
        if not payment_key:
            print(f"✗ Failed to derive payment key")
            return None
        
        # Get public key
        pub_key = CardanoAddressGenerator.get_public_key(payment_key, cardano_address_exe)
        if not pub_key:
            print(f"✗ Failed to get public key")
            return None
        
        # Generate payment address
        payment_addr = CardanoAddressGenerator.get_payment_address(pub_key, network, cardano_address_exe)
        if not payment_addr:
            print(f"✗ Failed to generate payment address")
            return None
        
        print(f"✓ Payment address: {payment_addr[:40]}...")
        
        return {
            "index": address_index,
            "chain": "external" if is_external else "internal",
            "address": payment_addr,
            "public_key": pub_key
        }
    
    @staticmethod
    def generate_stake_address(mnemonic: str, account_index: int = 0) -> Optional[str]:
        """
        Generate stake address
        
        Args:
            mnemonic: BIP39 mnemonic phrase
            account_index: BIP44 account index
            
        Returns:
            Stake address or None
        """
        print("[*] Generating stake address...")
        
        # Find cardano-address tool
        cardano_address_exe = CardanoAddressGenerator.find_cardano_address_exe()
        if not cardano_address_exe:
            print("✗ cardano-address tool not found")
            return None
        
        # Generate root key
        root_key = CardanoAddressGenerator.get_root_key(mnemonic, cardano_address_exe)
        if not root_key:
            print("✗ Failed to generate root key")
            return None
        
        # Derive account key
        account_path = f"1852H/1815H/{account_index}H"
        account_key = CardanoAddressGenerator.derive_key(root_key, account_path, cardano_address_exe)
        if not account_key:
            print(f"✗ Failed to derive account key")
            return None
        
        # Derive stake key (BIP44: m/1852H/1815H/accountH/2/0)
        stake_path = "2/0"
        stake_key = CardanoAddressGenerator.derive_key(account_key, stake_path, cardano_address_exe)
        if not stake_key:
            print("✗ Failed to derive stake key")
            return None
        
        # Get stake address
        stake_deriver = StakeAddressDeriver()
        stake_addr = stake_deriver.get_stake_address(stake_key)
        if not stake_addr:
            print("✗ Failed to generate stake address")
            return None
        
        print(f"✓ Stake address: {stake_addr[:40]}...")
        return stake_addr
