#!/usr/bin/env python3
"""
Key Generation CLI - Test script for generating Cardano keys
Direct call from python/app folder
"""

import sys
import os
import argparse
import json

# Add app directory to path
sys.path.insert(0, os.path.dirname(__file__))

from modules.end_user.key_generator import KeyGenerator
from utils.bip39 import BIP39


def generate_new_keypair(wallet_path, account_index=0, address_count=5):
    """Generate new keypair"""
    print("[*] Generating new mnemonic...")
    
    bip39 = BIP39()
    mnemonic = bip39.generate_mnemonic()
    
    print(f"✓ Generated mnemonic: {mnemonic}")
    print()
    
    return generate_from_mnemonic(mnemonic, wallet_path, account_index, address_count)


def generate_from_mnemonic(mnemonic, wallet_path, account_index=0, address_count=5):
    """Generate from existing mnemonic"""
    print(f"[*] Generating from mnemonic...")
    print(f"    Wallet path: {wallet_path}")
    print(f"    Account: {account_index}")
    print(f"    Address count: {address_count}")
    print()
    
    # Create wallet directory
    os.makedirs(wallet_path, exist_ok=True)
    
    kg = KeyGenerator(wallet_path, network="mainnet")
    
    try:
        result = kg.generate_addresses(
            mnemonic=mnemonic,
            account_index=account_index,
            address_count=address_count,
            is_external=True
        )
        
        if result:
            print()
            print("=" * 60)
            print("✓ KEY GENERATION SUCCESSFUL")
            print("=" * 60)
            print()
            print(f"Mnemonic: {result.get('mnemonic', 'N/A')}")
            print(f"Network: {result.get('network', 'mainnet')}")
            print(f"Stake Address: {result.get('stake_address', 'N/A')}")
            print()
            print(f"Generated {len(result.get('addresses', []))} addresses:")
            for addr_info in result.get('addresses', []):
                print(f"  [{addr_info['index']}] {addr_info['address']}")
            
            # Save to file
            result_file = os.path.join(wallet_path, 'result.json')
            with open(result_file, 'w') as f:
                json.dump(result, f, indent=2)
            print()
            print(f"✓ Saved to: {result_file}")
            
            return result
        else:
            print("✗ Failed to generate addresses")
            return None
    
    except Exception as e:
        print(f"✗ Error: {e}")
        import traceback
        traceback.print_exc()
        return None


def main():
    parser = argparse.ArgumentParser(
        description="Cardano Key Generator CLI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Generate new keypair with 5 addresses
  python keygen.py --new --path ~/cardano_wallet
  
  # Generate from existing mnemonic
  python keygen.py --mnemonic "word1 word2 ... word12" --path ~/cardano_wallet
  
  # Generate 10 addresses
  python keygen.py --new --path ~/cardano_wallet --count 10
        """
    )
    
    parser.add_argument('--new', action='store_true', 
                        help='Generate new mnemonic')
    parser.add_argument('--mnemonic', type=str, 
                        help='BIP39 mnemonic (12, 15, or 24 words)')
    parser.add_argument('--path', type=str, default='/tmp/cardano_wallet',
                        help='Wallet directory path (default: /tmp/cardano_wallet)')
    parser.add_argument('--count', type=int, default=5,
                        help='Number of addresses to generate (default: 5)')
    parser.add_argument('--account', type=int, default=0,
                        help='BIP44 account index (default: 0)')
    
    args = parser.parse_args()
    
    if args.new:
        generate_new_keypair(args.path, args.account, args.count)
    elif args.mnemonic:
        generate_from_mnemonic(args.mnemonic, args.path, args.account, args.count)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
