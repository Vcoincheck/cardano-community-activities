"""
Multi-Address Key Generator
Generate multiple addresses from BIP39 mnemonic

This module provides a high-level interface for key generation.
It uses modular utilities from utils/ folder.
"""
import os
import sys
from typing import Dict, Optional

# Add paths for standalone imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../..'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from utils.bip39 import BIP39
from utils.multi_address_generator import MultiAddressGenerator


class KeyGenerator:
    """Generate multiple Cardano addresses from mnemonic
    
    This is a wrapper class that uses MultiAddressGenerator from utils/
    """
    
    def __init__(self, wallet_path: str, network: str = "mainnet"):
        """
        Initialize key generator
        
        Args:
            wallet_path: Path to wallet directory
            network: "mainnet" or "testnet"
        """
        self.wallet_path = wallet_path
        self.network = network
        self.multi_gen = MultiAddressGenerator(wallet_path, network)
        self.addresses = []
        
    def generate_addresses(self, mnemonic: str, account_index: int = 0,
                          address_count: int = 5, address_index: int = -1, 
                          is_external: bool = True) -> Optional[Dict]:
        """
        Generate addresses from mnemonic
        
        Args:
            mnemonic: BIP39 mnemonic (12, 15, or 24 words)
            account_index: BIP44 account index (default 0)
            address_count: Number of addresses to generate (default 5)
            address_index: Specific address index (if >= 0, generates single address)
            is_external: True for external addresses (0/i), False for internal (1/i)
            
        Returns:
            Dict with generated addresses and stake address
        """
        # Validate mnemonic
        bip39 = BIP39()
        if not bip39.validate_mnemonic(mnemonic):
            print("✗ Invalid mnemonic")
            return None
        
        # Normalize mnemonic
        mnemonic = bip39.normalize_mnemonic(mnemonic)
        
        # Generate addresses
        if address_index >= 0:
            # Single address
            result = self.multi_gen.generate_single_address(mnemonic, account_index, address_index, is_external)
        else:
            # Multiple addresses
            result = self.multi_gen.generate_multiple_addresses(mnemonic, account_index, address_count, is_external)
        
        if result:
            self.addresses = self.multi_gen.addresses
        
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
        
        result = self.multi_gen.save_wallet(wallet_name)
        return result is not None
    
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
        
        result = self.multi_gen.export_addresses_csv(output_file)
        return result is not None
