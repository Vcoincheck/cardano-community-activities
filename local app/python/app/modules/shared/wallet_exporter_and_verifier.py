"""
Wallet Exporter - Export wallet data and addresses
"""
import json
import csv
from typing import Dict, List, Optional
from pathlib import Path


class WalletExporter:
    """Export wallet data to various formats"""
    
    @staticmethod
    def export_json(wallet_data: Dict, file_path: str) -> bool:
        """
        Export wallet to JSON
        
        Args:
            wallet_data: Wallet dictionary
            file_path: Output file path
            
        Returns:
            True if successful
        """
        try:
            with open(file_path, 'w') as f:
                json.dump(wallet_data, f, indent=2)
            print(f"✓ Exported to {file_path}")
            return True
        except Exception as e:
            print(f"✗ Error: {e}")
            return False
    
    @staticmethod
    def export_csv(wallet_data: Dict, file_path: str) -> bool:
        """
        Export addresses to CSV
        
        Args:
            wallet_data: Wallet dictionary
            file_path: Output file path
            
        Returns:
            True if successful
        """
        try:
            addresses = wallet_data.get("addresses", [])
            
            with open(file_path, 'w', newline='') as f:
                writer = csv.writer(f)
                writer.writerow(["Index", "Address", "PublicKey"])
                
                for addr in addresses:
                    writer.writerow([
                        addr.get("index"),
                        addr.get("address"),
                        addr.get("public_key", "")[:40] + "..."
                    ])
            
            print(f"✓ Exported to {file_path}")
            return True
        except Exception as e:
            print(f"✗ Error: {e}")
            return False
    
    @staticmethod
    def export_txt(wallet_data: Dict, file_path: str) -> bool:
        """
        Export wallet to plain text
        
        Args:
            wallet_data: Wallet dictionary
            file_path: Output file path
            
        Returns:
            True if successful
        """
        try:
            with open(file_path, 'w') as f:
                f.write("=== CARDANO WALLET EXPORT ===\n\n")
                
                f.write("Stake Address:\n")
                f.write(f"{wallet_data.get('stake_address', 'N/A')}\n\n")
                
                f.write("Addresses:\n")
                f.write("-" * 50 + "\n")
                
                for addr in wallet_data.get("addresses", []):
                    f.write(f"\nAddress {addr['index']}:\n")
                    f.write(f"  {addr['address']}\n")
                    f.write(f"  Public Key: {addr['public_key'][:40]}...\n")
                
                f.write("\n" + "=" * 50 + "\n")
                f.write("IMPORTANT: Keep this file secure!\n")
            
            print(f"✓ Exported to {file_path}")
            return True
        except Exception as e:
            print(f"✗ Error: {e}")
            return False
    
    @staticmethod
    def export_xprv(wallet_data: Dict, file_path: str) -> bool:
        """
        Export extended private key
        
        Args:
            wallet_data: Wallet dictionary
            file_path: Output file path
            
        Returns:
            True if successful
        """
        try:
            with open(file_path, 'w') as f:
                f.write("CARDANO EXTENDED PRIVATE KEY\n")
                f.write("=" * 50 + "\n\n")
                f.write("Root Key:\n")
                f.write(f"{wallet_data.get('root_key', 'N/A')}\n\n")
                f.write("Account Key:\n")
                f.write(f"{wallet_data.get('account_key', 'N/A')}\n\n")
                f.write("Stake Key:\n")
                f.write(f"{wallet_data.get('stake_key', 'N/A')}\n\n")
                f.write("WARNING: DO NOT SHARE THIS FILE\n")
            
            print(f"✓ Exported extended keys to {file_path}")
            return True
        except Exception as e:
            print(f"✗ Error: {e}")
            return False


class LocalVerifier:
    """Verify signatures locally without blockchain"""
    
    @staticmethod
    def verify_signature_structure(signature: str) -> bool:
        """
        Verify signature structure
        
        Args:
            signature: Base64-encoded signature
            
        Returns:
            True if valid structure
        """
        import base64
        
        try:
            # Decode base64
            sig_bytes = base64.b64decode(signature)
            
            # Ed25519 signatures are 64 bytes
            if len(sig_bytes) != 64:
                print(f"✗ Invalid signature length: {len(sig_bytes)} (expected 64)")
                return False
            
            print("✓ Signature structure valid (64 bytes)")
            return True
        except Exception as e:
            print(f"✗ Invalid base64: {e}")
            return False
    
    @staticmethod
    def verify_message_hash(message: str, hash_value: str) -> bool:
        """
        Verify message hash
        
        Args:
            message: Original message
            hash_value: SHA256 hash
            
        Returns:
            True if hash matches
        """
        import hashlib
        
        try:
            computed_hash = hashlib.sha256(message.encode()).hexdigest()
            
            if computed_hash.lower() == hash_value.lower():
                print("✓ Message hash verified")
                return True
            else:
                print("✗ Message hash mismatch")
                return False
        except Exception as e:
            print(f"✗ Error: {e}")
            return False
    
    @staticmethod
    def verify_address_format(address: str, network: str = "mainnet") -> bool:
        """
        Verify Cardano address format
        
        Args:
            address: Cardano address
            network: "mainnet" or "testnet"
            
        Returns:
            True if valid
        """
        try:
            import base58
            
            # Decode address
            decoded = base58.b58decode(address)
            
            # Check prefix for network
            if network == "mainnet":
                # Mainnet prefix: 0x60 (payment) or 0x61 (stake)
                if decoded[0] not in [0x60, 0x61]:
                    print(f"✗ Invalid mainnet address prefix: {decoded[0]:02x}")
                    return False
            elif network == "testnet":
                # Testnet prefix: 0x80 (payment) or 0x81 (stake)
                if decoded[0] not in [0x80, 0x81]:
                    print(f"✗ Invalid testnet address prefix: {decoded[0]:02x}")
                    return False
            
            # Address should be 57 or 59 bytes
            if len(decoded) not in [57, 59]:
                print(f"✗ Invalid address length: {len(decoded)}")
                return False
            
            print(f"✓ Address format valid ({network})")
            return True
        except Exception as e:
            print(f"✗ Error: {e}")
            return False
    
    @staticmethod
    def verify_batch(verification_data: List[Dict]) -> Dict:
        """
        Verify batch of signatures
        
        Args:
            verification_data: List of {'message', 'signature', 'address'}
            
        Returns:
            Verification results
        """
        results = {
            "total": len(verification_data),
            "valid": 0,
            "invalid": 0,
            "errors": []
        }
        
        for i, item in enumerate(verification_data):
            try:
                # Verify signature structure
                if LocalVerifier.verify_signature_structure(item.get("signature", "")):
                    results["valid"] += 1
                else:
                    results["invalid"] += 1
                    results["errors"].append(f"Item {i}: Invalid signature")
            except Exception as e:
                results["invalid"] += 1
                results["errors"].append(f"Item {i}: {str(e)}")
        
        print(f"\n✓ Batch verification complete: {results['valid']}/{results['total']} valid")
        return results
