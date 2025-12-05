"""
Multi-Address Key Generator
Generate multiple addresses from BIP39 mnemonic
"""
import json
import os
import sys
from typing import List, Dict, Optional

# Add paths for standalone imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../..'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from utils.bip39 import BIP39
from utils.cardano_address import CardanoAddressGenerator
from shared.derive_stake import StakeAddressDeriver


class KeyGenerator:
    """Generate multiple Cardano addresses from mnemonic"""
    
    def __init__(self, wallet_path: str, network: str = "mainnet"):
        """
        Initialize key generator
        
        Args:
            wallet_path: Path to wallet directory
            network: "mainnet" or "testnet"
        """
        self.wallet_path = wallet_path
        self.network = network
        self.addresses = []
        
    def generate_addresses(self, mnemonic: str, account_index: int = 0,
                          address_count: int = 5, address_index: int = 0, 
                          is_external: bool = True) -> Dict:
        """
        Generate multiple addresses from mnemonic
        
        Args:
            mnemonic: BIP39 mnemonic (12, 15, or 24 words)
            account_index: BIP44 account index (default 0)
            address_count: Number of addresses to generate (default 5)
            address_index: Specific address index (for single address generation)
            is_external: True for external addresses (0/i), False for internal (1/i)
            
        Returns:
            Dict with generated addresses and stake address
        """
        # Validate mnemonic
        bip39 = BIP39()
        if not bip39.is_valid(mnemonic):
            print("✗ Invalid mnemonic")
            return None
        
        # Get cardano-address tool
        cardano_address_exe = CardanoAddressGenerator.find_cardano_address_exe()
        if not cardano_address_exe:
            print("✗ cardano-address tool not found")
            return None
        
        # For single address (when address_index is specified)
        if address_count == 1 or address_index >= 0:
            print(f"[*] Generating {'external' if is_external else 'internal'} address {address_index}...")
        else:
            print(f"[*] Generating {address_count} addresses...")
        
        # Generate root key from mnemonic
        root_key = CardanoAddressGenerator.get_root_key(mnemonic, cardano_address_exe)
        if not root_key:
            return None
        
        # Derive account key (BIP44 path: m/1852H/1815H/account_indexH)
        account_path = f"1852H/1815H/{account_index}H"
        account_key = CardanoAddressGenerator.derive_key(
            root_key, account_path, cardano_address_exe
        )
        if not account_key:
            return None
        
        # Determine which chain (0 = external, 1 = internal)
        chain = 0 if is_external else 1
        
        # For single address generation
        if address_index >= 0:
            # Payment path: 1852H/1815H/accountH/chain/index
            payment_path = f"{chain}/{address_index}"
            payment_key = CardanoAddressGenerator.derive_key(
                account_key, payment_path, cardano_address_exe
            )
            if not payment_key:
                print(f"✗ Failed to derive payment key for address {address_index}")
                return None
            
            # Get public key
            pub_key = CardanoAddressGenerator.get_public_key(
                payment_key, cardano_address_exe
            )
            if not pub_key:
                print(f"✗ Failed to get public key for address {address_index}")
                return None
            
            # Generate payment address
            payment_addr = CardanoAddressGenerator.get_payment_address(
                pub_key, self.network, cardano_address_exe
            )
            if not payment_addr:
                print(f"✗ Failed to generate payment address {address_index}")
                return None
            
            print(f"✓ {'External' if is_external else 'Internal'} address {address_index}: {payment_addr[:30]}...")
            
            # Derive stake key (BIP44 path: m/1852H/1815H/accountH/2/0)
            stake_path = "2/0"  # Stake key
            stake_key = CardanoAddressGenerator.derive_key(
                account_key, stake_path, cardano_address_exe
            )
            if not stake_key:
                print("✗ Failed to derive stake key")
                return None
            
            # Get stake address
            stake_deriver = StakeAddressDeriver()
            stake_addr = stake_deriver.get_stake_address(stake_key)
            if not stake_addr:
                print("✗ Failed to generate stake address")
                return None
            
            return {
                "chain": "external" if is_external else "internal",
                "index": address_index,
                "address": payment_addr,
                "payment_key": payment_key,
                "public_key": pub_key,
                "stake_address": stake_addr
            }
        
        # Generate multiple addresses
        addresses = []
        for i in range(address_count):
            # Derive payment key
            payment_path = f"{chain}/{i}"
            payment_key = CardanoAddressGenerator.derive_key(
                account_key, payment_path, cardano_address_exe
            )
            if not payment_key:
                print(f"✗ Failed to derive payment key for address {i}")
                continue
            
            # Get public key
            pub_key = CardanoAddressGenerator.get_public_key(
                payment_key, cardano_address_exe
            )
            if not pub_key:
                print(f"✗ Failed to get public key for address {i}")
                continue
            
            # Generate payment address
            payment_addr = CardanoAddressGenerator.get_payment_address(
                pub_key, self.network, cardano_address_exe
            )
            if not payment_addr:
                print(f"✗ Failed to generate payment address {i}")
                continue
            
            addresses.append({
                "index": i,
                "address": payment_addr,
                "payment_key": payment_key,
                "public_key": pub_key
            })
            print(f"✓ Address {i+1}: {payment_addr[:20]}...")
        
        # Derive stake key (BIP44 path: m/1852H/1815H/accountH/2/0)
        stake_path = "2/0"  # Stake key
        stake_key = CardanoAddressGenerator.derive_key(
            account_key, stake_path, cardano_address_exe
        )
        if not stake_key:
            print("✗ Failed to derive stake key")
            return None
        
        # Get stake address
        stake_deriver = StakeAddressDeriver()
        stake_addr = stake_deriver.get_stake_address(stake_key)
        if not stake_addr:
            print("✗ Failed to generate stake address")
            return None
        
        print(f"✓ Stake address: {stake_addr[:20]}...")
        
        result = {
            "mnemonic": mnemonic,
            "account_index": account_index,
            "network": self.network,
            "addresses": addresses,
            "stake_key": stake_key,
            "stake_address": stake_addr,
            "account_key": account_key,
            "root_key": root_key
        }
        
        self.addresses = result
        return result
    
    def save_wallet(self, wallet_name: str) -> bool:
        """
        Save wallet to JSON file
        
        Args:
            wallet_name: Wallet name
            
        Returns:
            True if successful
        """
        if not self.addresses:
            print("✗ No addresses to save")
            return False
        
        # Create wallet directory
        os.makedirs(self.wallet_path, exist_ok=True)
        
        wallet_file = os.path.join(self.wallet_path, f"{wallet_name}.json")
        
        try:
            with open(wallet_file, 'w') as f:
                json.dump(self.addresses, f, indent=2)
            print(f"✓ Wallet saved: {wallet_file}")
            return True
        except Exception as e:
            print(f"✗ Error saving wallet: {e}")
            return False
    
    def export_addresses(self, output_file: str = None) -> bool:
        """
        Export addresses to CSV
        
        Args:
            output_file: CSV file path
            
        Returns:
            True if successful
        """
        if not self.addresses:
            print("✗ No addresses to export")
            return False
        
        if not output_file:
            output_file = os.path.join(self.wallet_path, "addresses.csv")
        
        try:
            os.makedirs(os.path.dirname(output_file), exist_ok=True)
            
            with open(output_file, 'w') as f:
                f.write("Index,Address\n")
                for addr in self.addresses.get("addresses", []):
                    f.write(f"{addr['index']},{addr['address']}\n")
            
            print(f"✓ Addresses exported: {output_file}")
            return True
        except Exception as e:
            print(f"✗ Error exporting: {e}")
            return False
