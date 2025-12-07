"""
Skey Handler: Load and parse Cardano signing keys
"""
import os
import json
from typing import Optional, Dict


class SkeyHandler:
    """Handle .skey (signing key) files"""
    
    @staticmethod
    def load_skey(file_path: str) -> Optional[str]:
        """
        Load skey file content
        
        Args:
            file_path: Path to .skey file
            
        Returns:
            Skey content or None if error
        """
        if not os.path.exists(file_path):
            print(f"✗ Skey file not found: {file_path}")
            return None
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read().strip()
            print(f"✓ Loaded skey: {file_path}")
            return content
        except Exception as e:
            print(f"✗ Error loading skey: {e}")
            return None
    
    @staticmethod
    def validate_skey(skey_content: str) -> bool:
        """
        Validate skey format
        
        Args:
            skey_content: Skey file content
            
        Returns:
            True if valid
        """
        if not skey_content:
            print("✗ Skey content is empty")
            return False
        
        # Check if it's valid JSON (Cardano skey is usually JSON)
        try:
            if skey_content.startswith('{'):
                json.loads(skey_content)
                print("✓ Valid JSON skey format")
                return True
        except json.JSONDecodeError:
            pass
        
        # Check if it looks like hex or base64
        if len(skey_content) > 50:
            print("✓ Skey appears to be valid format")
            return True
        
        print("✗ Skey format invalid")
        return False
    
    @staticmethod
    def parse_json_skey(skey_content: str) -> Optional[Dict]:
        """
        Parse JSON skey file
        
        Args:
            skey_content: Skey JSON content
            
        Returns:
            Parsed skey dict or None
        """
        try:
            skey = json.loads(skey_content)
            print(f"✓ Parsed skey: {skey.get('type', 'unknown')} key")
            return skey
        except Exception as e:
            print(f"✗ Error parsing skey: {e}")
            return None
    
    @staticmethod
    def extract_signing_key(skey_content: str) -> Optional[str]:
        """
        Extract actual signing key from skey file
        
        Args:
            skey_content: Skey content (JSON or raw)
            
        Returns:
            Signing key string or None
        """
        # Try JSON first
        try:
            if skey_content.startswith('{'):
                skey_dict = json.loads(skey_content)
                # Look for common keys in Cardano skey JSON
                for key_name in ['cborHex', 'cbor_hex', 'key', 'privateKey']:
                    if key_name in skey_dict:
                        return skey_dict[key_name]
                # Return whole content if structure unknown
                return skey_content
        except:
            pass
        
        # Return as-is if not JSON
        return skey_content
