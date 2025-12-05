"""
Core-Crypto: Verify Signature with cardano-signer
Low-level Ed25519 signature verification using cardano-signer executable
"""
import subprocess
import os
import tempfile
from pathlib import Path
from typing import Optional
import base64


class CryptoVerifier:
    """Verify Ed25519 signatures using cardano-signer"""
    
    @staticmethod
    def find_cardano_signer() -> Optional[str]:
        """
        Find cardano-signer executable in common locations
        
        Returns:
            Path to cardano-signer or None
        """
        common_paths = [
            "./tools/cardano-signer/cardano-signer.exe",
            "./tools/cardano-signer/cardano-signer",
            "./cardano-signer.exe",
            "./cardano-signer",
            "cardano-signer.exe",
            "cardano-signer",
        ]
        
        for path in common_paths:
            if os.path.exists(path):
                return os.path.abspath(path)
        
        return None
    
    @staticmethod
    def verify_ed25519_signature(
        public_key: str,
        message: str,
        signature: str,
        signer_exe: str = None
    ) -> bool:
        """
        Verify Ed25519 signature using cardano-signer
        
        Args:
            public_key: Public key (PEM format or hex)
            message: Original message
            signature: Signature (base64 or hex)
            signer_exe: Path to cardano-signer executable (auto-find if None)
            
        Returns:
            True if signature is valid, False otherwise
        """
        print("\n========== Verifying Signature ==========")
        
        # Find cardano-signer if not provided
        if not signer_exe:
            signer_exe = CryptoVerifier.find_cardano_signer()
        
        if not signer_exe or not os.path.exists(signer_exe):
            print(f"✗ cardano-signer not found at {signer_exe}")
            return False
        
        print(f"Using cardano-signer: {signer_exe}")
        
        try:
            # Create temp files for message and signature
            temp_dir = tempfile.gettempdir()
            msg_file = os.path.join(temp_dir, f"msg_{os.getpid()}.txt")
            sig_file = os.path.join(temp_dir, f"sig_{os.getpid()}.txt")
            
            # Write message
            with open(msg_file, 'w', encoding='utf-8') as f:
                f.write(message)
            
            # Write signature
            with open(sig_file, 'w', encoding='utf-8') as f:
                f.write(signature)
            
            try:
                # Run verification
                result = subprocess.run(
                    [signer_exe, "verify", "--message-file", msg_file, 
                     "--signature", signature, "--public-key", public_key],
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                
                # Check output for success indicators
                output = result.stdout.lower() + result.stderr.lower()
                
                if "true" in output or "valid" in output or result.returncode == 0:
                    print("✓ Signature valid")
                    return True
                else:
                    print("✗ Signature invalid")
                    return False
                    
            finally:
                # Cleanup temp files
                for f in [msg_file, sig_file]:
                    if os.path.exists(f):
                        try:
                            os.remove(f)
                        except:
                            pass
        
        except subprocess.TimeoutExpired:
            print("✗ Signature verification timeout")
            return False
        except Exception as e:
            print(f"✗ Error verifying signature: {e}")
            return False
    
    @staticmethod
    def sign_with_signer(
        message: str,
        skey_file: str,
        signer_exe: str = None
    ) -> Optional[str]:
        """
        Sign message using cardano-signer
        
        Args:
            message: Message to sign
            skey_file: Path to .skey file
            signer_exe: Path to cardano-signer (auto-find if None)
            
        Returns:
            Signature (base64) or None
        """
        print("\n========== Signing Message ==========")
        
        # Find cardano-signer
        if not signer_exe:
            signer_exe = CryptoVerifier.find_cardano_signer()
        
        if not signer_exe or not os.path.exists(signer_exe):
            print(f"✗ cardano-signer not found")
            return None
        
        if not os.path.exists(skey_file):
            print(f"✗ Skey file not found: {skey_file}")
            return None
        
        try:
            # Create temp file for message
            temp_dir = tempfile.gettempdir()
            msg_file = os.path.join(temp_dir, f"msg_{os.getpid()}.txt")
            
            with open(msg_file, 'w', encoding='utf-8') as f:
                f.write(message)
            
            try:
                # Run signing
                result = subprocess.run(
                    [signer_exe, "sign", "--message-file", msg_file, "--secret-key", skey_file],
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                
                if result.returncode == 0:
                    signature = result.stdout.strip()
                    print(f"✓ Signature: {signature[:60]}...")
                    return signature
                else:
                    print(f"✗ Signing failed: {result.stderr}")
                    return None
                    
            finally:
                if os.path.exists(msg_file):
                    try:
                        os.remove(msg_file)
                    except:
                        pass
        
        except subprocess.TimeoutExpired:
            print("✗ Signing timeout")
            return None
        except Exception as e:
            print(f"✗ Error signing: {e}")
            return None
