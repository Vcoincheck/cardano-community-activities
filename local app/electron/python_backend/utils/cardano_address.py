"""
Cardano-Address: Integration with cardano-address tool
Generate addresses from recovery phrases
"""
import subprocess
import os
from typing import Optional


class CardanoAddressGenerator:
    """Generate Cardano addresses using cardano-address tool"""
    
    @staticmethod
    def find_cardano_address_exe() -> Optional[str]:
        """
        Find cardano-address executable
        
        Returns:
            Path to executable or None
        """
        common_paths = [
            "./tools/cardano-addresses/cardano-address.exe",
            "./tools/cardano-addresses/cardano-address",
            "./cardano-address.exe",
            "./cardano-address",
            "cardano-address.exe",
            "cardano-address",
        ]
        
        for path in common_paths:
            if os.path.exists(path):
                return os.path.abspath(path)
        
        # Try to find in PATH
        try:
            result = subprocess.run(
                ["which" if os.name != "nt" else "where", "cardano-address"],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                return result.stdout.strip().split('\n')[0]
        except:
            pass
        
        return None
    
    @staticmethod
    def get_root_key(mnemonic: str, cardano_address_exe: str = None) -> Optional[str]:
        """
        Generate root key from mnemonic
        
        Args:
            mnemonic: BIP39 mnemonic phrase
            cardano_address_exe: Path to cardano-address
            
        Returns:
            Root key or None
        """
        if not cardano_address_exe:
            cardano_address_exe = CardanoAddressGenerator.find_cardano_address_exe()
        
        if not cardano_address_exe:
            print("✗ cardano-address not found")
            return None
        
        try:
            # Create root key from mnemonic
            result = subprocess.run(
                f"echo '{mnemonic}' | {cardano_address_exe} key from-recovery-phrase Shelley",
                shell=True,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                root_key = result.stdout.strip()
                print(f"✓ Generated root key")
                return root_key
            else:
                print(f"✗ Error generating root key: {result.stderr}")
                return None
        except Exception as e:
            print(f"✗ Error: {e}")
            return None
    
    @staticmethod
    def derive_key(root_key: str, derivation_path: str, 
                  cardano_address_exe: str = None) -> Optional[str]:
        """
        Derive key using BIP44 path
        
        Args:
            root_key: Root key
            derivation_path: BIP44 path (e.g., "1852H/1815H/0H/0/0")
            cardano_address_exe: Path to cardano-address
            
        Returns:
            Derived key or None
        """
        if not cardano_address_exe:
            cardano_address_exe = CardanoAddressGenerator.find_cardano_address_exe()
        
        if not cardano_address_exe:
            print("✗ cardano-address not found")
            return None
        
        try:
            result = subprocess.run(
                f"echo '{root_key}' | {cardano_address_exe} key child {derivation_path}",
                shell=True,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                key = result.stdout.strip()
                print(f"✓ Derived key for path {derivation_path}")
                return key
            else:
                print(f"✗ Error deriving key: {result.stderr}")
                return None
        except Exception as e:
            print(f"✗ Error: {e}")
            return None
    
    @staticmethod
    def get_public_key(private_key: str, cardano_address_exe: str = None) -> Optional[str]:
        """
        Get public key from private key
        
        Args:
            private_key: Private key
            cardano_address_exe: Path to cardano-address
            
        Returns:
            Public key or None
        """
        if not cardano_address_exe:
            cardano_address_exe = CardanoAddressGenerator.find_cardano_address_exe()
        
        if not cardano_address_exe:
            print("✗ cardano-address not found")
            return None
        
        try:
            result = subprocess.run(
                f"echo '{private_key}' | {cardano_address_exe} key public --without-chain-code",
                shell=True,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                pub_key = result.stdout.strip()
                print(f"✓ Generated public key")
                return pub_key
            else:
                print(f"✗ Error: {result.stderr}")
                return None
        except Exception as e:
            print(f"✗ Error: {e}")
            return None
    
    @staticmethod
    def get_payment_address(public_key: str, network: str = "mainnet",
                           cardano_address_exe: str = None) -> Optional[str]:
        """
        Generate payment address from public key
        
        Args:
            public_key: Payment public key
            network: "mainnet" or "testnet"
            cardano_address_exe: Path to cardano-address
            
        Returns:
            Payment address or None
        """
        if not cardano_address_exe:
            cardano_address_exe = CardanoAddressGenerator.find_cardano_address_exe()
        
        if not cardano_address_exe:
            print("✗ cardano-address not found")
            return None
        
        try:
            network_tag = "0" if network == "mainnet" else "1"
            result = subprocess.run(
                f"echo '{public_key}' | {cardano_address_exe} address payment --network-tag {network_tag}",
                shell=True,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                addr = result.stdout.strip()
                print(f"✓ Generated payment address")
                return addr
            else:
                print(f"✗ Error: {result.stderr}")
                return None
        except Exception as e:
            print(f"✗ Error: {e}")
            return None
    
    @staticmethod
    def get_delegated_address(payment_address: str, stake_key: str,
                             cardano_address_exe: str = None) -> Optional[str]:
        """
        Generate delegated address (payment + stake)
        
        Args:
            payment_address: Payment address
            stake_key: Stake key
            cardano_address_exe: Path to cardano-address
            
        Returns:
            Delegated address or None
        """
        if not cardano_address_exe:
            cardano_address_exe = CardanoAddressGenerator.find_cardano_address_exe()
        
        if not cardano_address_exe:
            print("✗ cardano-address not found")
            return None
        
        try:
            result = subprocess.run(
                f"echo '{payment_address}' | {cardano_address_exe} address delegation '{stake_key}'",
                shell=True,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                addr = result.stdout.strip()
                print(f"✓ Generated delegated address")
                return addr
            else:
                print(f"✗ Error: {result.stderr}")
                return None
        except Exception as e:
            print(f"✗ Error: {e}")
            return None
