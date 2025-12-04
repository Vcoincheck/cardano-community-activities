"""
End-User App - Sign Message Module
Ký tin nhắn với khóa riêng
"""
from cryptography.hazmat.primitives.asymmetric import ed25519
from cryptography.hazmat.primitives import serialization, hashes
import base64
from app.utils.crypto import Logger


class MessageSigner:
    """Sign and verify messages"""
    
    @staticmethod
    def sign_message(message: str, private_key_pem: str) -> dict:
        """
        Sign a message with private key
        
        Args:
            message: Message to sign
            private_key_pem: Private key in PEM format
        
        Returns:
            Dictionary with signature and details
        """
        Logger.info("========== Signing Message ==========", "SIGN")
        
        try:
            # Load private key
            private_key = serialization.load_pem_private_key(
                private_key_pem.encode() if isinstance(private_key_pem, str) else private_key_pem,
                password=None
            )
            
            # Sign message
            signature = private_key.sign(message.encode())
            signature_b64 = base64.b64encode(signature).decode('utf-8')
            
            # Get public key for reference
            public_key = private_key.public_key()
            public_pem = public_key.public_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PublicFormat.SubjectPublicKeyInfo
            ).decode('utf-8')
            
            Logger.success("Message signed successfully!")
            print(f"  Message: {message}")
            print(f"  Signature: {signature_b64[:50]}...")
            
            return {
                'message': message,
                'signature': signature_b64,
                'public_key': public_pem,
                'signed': True
            }
        
        except Exception as e:
            Logger.error(f"Error signing message: {str(e)}")
            return {'signed': False, 'error': str(e)}
    
    @staticmethod
    def verify_signature(message: str, signature_b64: str, public_key_pem: str) -> bool:
        """
        Verify message signature
        
        Args:
            message: Original message
            signature_b64: Signature in base64
            public_key_pem: Public key in PEM format
        
        Returns:
            True if signature is valid
        """
        Logger.info("========== Verifying Signature ==========", "VERIFY")
        
        try:
            # Load public key
            public_key = serialization.load_pem_public_key(
                public_key_pem.encode() if isinstance(public_key_pem, str) else public_key_pem
            )
            
            # Verify signature
            signature = base64.b64decode(signature_b64)
            public_key.verify(signature, message.encode())
            
            Logger.success("Signature verified successfully!")
            return True
        
        except Exception as e:
            Logger.error(f"Signature verification failed: {str(e)}")
            return False
