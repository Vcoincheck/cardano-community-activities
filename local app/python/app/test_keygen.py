#!/usr/bin/env python3
"""
Test script for key generation flow
"""
import sys
import os

# Set proper path
sys.path.insert(0, os.path.dirname(__file__))

from modules.end_user.key_generator import KeyGenerator
from utils.bip39 import BIP39

print("[*] Testing BIP39 mnemonic generation...")
try:
    bip39 = BIP39()
    print("✓ BIP39 imported successfully")
    
    # Generate mnemonic
    mnemonic = bip39.generate_mnemonic(word_count=12)
    print(f"✓ Generated mnemonic: {mnemonic}")
    
    # Validate it
    is_valid = bip39.validate_mnemonic(mnemonic)
    print(f"✓ Mnemonic validation: {is_valid}")
    
except Exception as e:
    print(f"✗ BIP39 Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print()
print("[*] Testing KeyGenerator...")
try:
    wallet_path = "/tmp/test_cardano_wallet"
    os.makedirs(wallet_path, exist_ok=True)
    
    kg = KeyGenerator(wallet_path, network="mainnet")
    print(f"✓ KeyGenerator initialized with wallet_path: {wallet_path}")
    
    # Try to generate ONE address
    print(f"✓ Generating first address from mnemonic...")
    result = kg.generate_addresses(
        mnemonic=mnemonic,
        account_index=0,
        address_index=0,  # Just generate 1st address
        is_external=True
    )
    
    if result:
        print(f"✓ SUCCESS! Address generated:")
        print(f"  - Address: {result.get('address', 'N/A')}")
        print(f"  - Index: {result.get('index', 'N/A')}")
        print(f"  - Chain: {result.get('chain', 'N/A')}")
    else:
        print(f"✗ Result is None - likely issue with cardano-address tool")
        sys.exit(1)
        
except Exception as e:
    print(f"✗ KeyGenerator Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print()
print("=" * 60)
print("✅ All tests passed!")
print("=" * 60)
