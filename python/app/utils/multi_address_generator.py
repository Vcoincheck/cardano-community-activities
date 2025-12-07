"""
Multi-Address Generator
Generate multiple addresses from mnemonic
"""
import json
import os
from typing import List, Dict, Optional
from utils.cardano_address import CardanoAddressGenerator
from utils.address_generator import AddressGenerator


class MultiAddressGenerator:
    """Generate multiple addresses from mnemonic"""
    
    def __init__(self, wallet_path: str, network: str = "mainnet"):
        """
        Initialize multi-address generator
        
        Args:
            wallet_path: Path to wallet directory
            network: "mainnet" or "testnet"
        """
        self.wallet_path = wallet_path
        self.network = network
        self.addresses = []
        self.stake_address = None
    
    def generate_multiple_addresses(self, mnemonic: str, account_index: int = 0,
                                   address_count: int = 5, is_external: bool = True) -> Optional[Dict]:
        """
        Generate multiple addresses
        
        Args:
            mnemonic: BIP39 mnemonic phrase
            account_index: BIP44 account index
            address_count: Number of addresses to generate
            is_external: True for external, False for internal
            
        Returns:
            Dict with addresses and stake address or None
        """
        print(f"[*] Generating {address_count} {'external' if is_external else 'internal'} addresses...")
        
        addresses = []
        for i in range(address_count):
            addr_info = AddressGenerator.generate_payment_address(
                mnemonic, account_index, i, is_external, self.network
            )
            if addr_info:
                addresses.append(addr_info)
            else:
                print(f"⚠️  Skipping address {i}")
        
        if not addresses:
            print("✗ Failed to generate any addresses")
            return None
        
        # Generate stake address
        stake_addr = AddressGenerator.generate_stake_address(mnemonic, account_index)
        if not stake_addr:
            print("✗ Failed to generate stake address")
            return None
        
        self.addresses = addresses
        self.stake_address = stake_addr
        
        result = {
            "mnemonic": mnemonic,
            "account_index": account_index,
            "network": self.network,
            "chain": "external" if is_external else "internal",
            "addresses": addresses,
            "stake_address": stake_addr
        }
        
        print(f"✓ Generated {len(addresses)} addresses")
        return result
    
    def generate_single_address(self, mnemonic: str, account_index: int = 0,
                               address_index: int = 0, is_external: bool = True) -> Optional[Dict]:
        """
        Generate a single address
        
        Args:
            mnemonic: BIP39 mnemonic phrase
            account_index: BIP44 account index
            address_index: Address index
            is_external: True for external, False for internal
            
        Returns:
            Dict with address info or None
        """
        addr_info = AddressGenerator.generate_payment_address(
            mnemonic, account_index, address_index, is_external, self.network
        )
        if not addr_info:
            return None
        
        # Also get stake address
        stake_addr = AddressGenerator.generate_stake_address(mnemonic, account_index)
        if not stake_addr:
            print("⚠️  Could not generate stake address")
        
        self.addresses = [addr_info]
        self.stake_address = stake_addr
        
        result = {
            "address_info": addr_info,
            "stake_address": stake_addr
        }
        
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
        
        try:
            os.makedirs(self.wallet_path, exist_ok=True)
            
            wallet_file = os.path.join(self.wallet_path, f"{wallet_name}.json")
            
            wallet_data = {
                "addresses": self.addresses,
                "stake_address": self.stake_address
            }
            
            with open(wallet_file, 'w') as f:
                json.dump(wallet_data, f, indent=2)
            
            print(f"✓ Wallet saved: {wallet_file}")
            return True
        except Exception as e:
            print(f"✗ Error saving wallet: {e}")
            return False
    
    def export_addresses_csv(self, output_file: str = None) -> bool:
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
            os.makedirs(os.path.dirname(output_file) or '.', exist_ok=True)
            
            with open(output_file, 'w') as f:
                f.write("Index,Chain,Address\n")
                for addr in self.addresses:
                    f.write(f"{addr.get('index', 0)},{addr.get('chain', 'external')},{addr.get('address', '')}\n")
            
            print(f"✓ Addresses exported: {output_file}")
            return True
        except Exception as e:
            print(f"✗ Error exporting: {e}")
            return False
