"""
End-User App - Key Generation Module
Tạo cặp khóa mã hóa cho người dùng
"""
from cryptography.hazmat.primitives.asymmetric import ed25519
from cryptography.hazmat.primitives import serialization
import os
from app.utils.crypto import Logger


class KeyGenerator:
    """Generate cryptographic key pairs"""
    
    @staticmethod
    def generate_keypair(save_path: str = "./keys") -> dict:
        """
        Generate Ed25519 keypair
        
        Args:
            save_path: Directory to save keys
        
        Returns:
            Dictionary with keys and file paths
        """
        Logger.info("========== Generating Keypair ==========", "KEYGEN")
        
        os.makedirs(save_path, exist_ok=True)
        
        # Generate private key
        private_key = ed25519.Ed25519PrivateKey.generate()
        public_key = private_key.public_key()
        
        # Serialize keys
        private_pem = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )
        
        public_pem = public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        
        # Save to files
        import datetime
        timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
        
        private_path = os.path.join(save_path, f"private_key_{timestamp}.pem")
        public_path = os.path.join(save_path, f"public_key_{timestamp}.pem")
        
        with open(private_path, 'wb') as f:
            f.write(private_pem)
        
        with open(public_path, 'wb') as f:
            f.write(public_pem)
        
        Logger.success("Keypair generated successfully!")
        print(f"  Private Key: {private_path}")
        print(f"  Public Key: {public_path}")
        
        return {
            'private_key': private_pem.decode('utf-8'),
            'public_key': public_pem.decode('utf-8'),
            'private_path': private_path,
            'public_path': public_path,
            'timestamp': timestamp
        }
