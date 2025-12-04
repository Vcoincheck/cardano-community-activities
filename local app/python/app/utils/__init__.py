"""
Utility module for cryptographic operations
"""
import hashlib
import secrets
import base64
from datetime import datetime, timedelta


class CryptographyUtils:
    """Cryptography helper functions"""
    
    @staticmethod
    def generate_nonce() -> str:
        """Generate a random nonce"""
        nonce_bytes = secrets.token_bytes(32)
        return base64.b64encode(nonce_bytes).decode('utf-8')
    
    @staticmethod
    def generate_challenge_id() -> str:
        """Generate a unique challenge ID"""
        return secrets.token_hex(16)
    
    @staticmethod
    def get_timestamp() -> int:
        """Get current Unix timestamp"""
        return int(datetime.now().timestamp())
    
    @staticmethod
    def get_expiry_timestamp(hours: int = 1) -> int:
        """Get expiry timestamp (default 1 hour from now)"""
        future = datetime.now() + timedelta(hours=hours)
        return int(future.timestamp())
    
    @staticmethod
    def hash_data(data: str, algorithm: str = 'sha256') -> str:
        """Hash data using specified algorithm"""
        if algorithm == 'sha256':
            return hashlib.sha256(data.encode()).hexdigest()
        elif algorithm == 'sha512':
            return hashlib.sha512(data.encode()).hexdigest()
        else:
            raise ValueError(f"Unsupported algorithm: {algorithm}")


class Logger:
    """Simple logging utility"""
    
    @staticmethod
    def info(message: str, prefix: str = "INFO"):
        """Log info message"""
        print(f"\n[{prefix}] {message}")
    
    @staticmethod
    def success(message: str):
        """Log success message"""
        print(f"✓ {message}")
    
    @staticmethod
    def error(message: str):
        """Log error message"""
        print(f"✗ {message}")
    
    @staticmethod
    def warning(message: str):
        """Log warning message"""
        print(f"⚠ {message}")
