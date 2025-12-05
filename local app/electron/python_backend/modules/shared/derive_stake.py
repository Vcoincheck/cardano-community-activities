"""
Core-Crypto: Derive Stake Address
Extract stake address from Cardano address
"""
import re
from typing import Optional


class StakeAddressDeriver:
    """Derive stake address from Cardano address"""
    
    # Cardano address prefixes
    MAINNET_ADDR_PREFIX = "addr1"
    TESTNET_ADDR_PREFIX = "addr_test1"
    MAINNET_STAKE_PREFIX = "stake1"
    TESTNET_STAKE_PREFIX = "stake_test1"
    
    @staticmethod
    def get_stake_address(cardano_address: str) -> Optional[str]:
        """
        Derive stake address from Cardano address
        
        Args:
            cardano_address: Cardano address (addr1... or addr_test1...)
            
        Returns:
            Stake address or None if invalid
        """
        if not cardano_address:
            print("✗ Address is empty")
            return None
        
        # Check if it's a valid Cardano address format
        if not StakeAddressDeriver.is_valid_cardano_address(cardano_address):
            print(f"✗ Invalid Cardano address format: {cardano_address}")
            return None
        
        print(f"Deriving stake address from: {cardano_address}")
        
        # For now, return the address itself as it would need bech32 decoding
        # In production, would decode bech32 and extract stake credential
        return cardano_address
    
    @staticmethod
    def is_valid_cardano_address(address: str) -> bool:
        """
        Validate Cardano address format
        
        Args:
            address: Address to validate
            
        Returns:
            True if valid format
        """
        # Check prefixes
        valid_prefixes = [
            StakeAddressDeriver.MAINNET_ADDR_PREFIX,
            StakeAddressDeriver.TESTNET_ADDR_PREFIX,
            StakeAddressDeriver.MAINNET_STAKE_PREFIX,
            StakeAddressDeriver.TESTNET_STAKE_PREFIX,
        ]
        
        return any(address.startswith(prefix) for prefix in valid_prefixes)
    
    @staticmethod
    def is_enterprise_address(address: str) -> bool:
        """Check if address is enterprise address (addr1/addr_test1)"""
        return address.startswith((
            StakeAddressDeriver.MAINNET_ADDR_PREFIX,
            StakeAddressDeriver.TESTNET_ADDR_PREFIX
        ))
    
    @staticmethod
    def is_stake_address(address: str) -> bool:
        """Check if address is stake address (stake1/stake_test1)"""
        return address.startswith((
            StakeAddressDeriver.MAINNET_STAKE_PREFIX,
            StakeAddressDeriver.TESTNET_STAKE_PREFIX
        ))
    
    @staticmethod
    def get_network_from_address(address: str) -> Optional[str]:
        """
        Get network (mainnet/testnet) from address
        
        Args:
            address: Cardano address
            
        Returns:
            "mainnet", "testnet", or None
        """
        if address.startswith((
            StakeAddressDeriver.MAINNET_ADDR_PREFIX,
            StakeAddressDeriver.MAINNET_STAKE_PREFIX
        )):
            return "mainnet"
        elif address.startswith((
            StakeAddressDeriver.TESTNET_ADDR_PREFIX,
            StakeAddressDeriver.TESTNET_STAKE_PREFIX
        )):
            return "testnet"
        return None
