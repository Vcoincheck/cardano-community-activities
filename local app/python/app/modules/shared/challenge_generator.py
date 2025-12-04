"""
Community Admin - Generate Challenge Module
Tạo các thử thách mã hóa với nonce và community ID
"""
from datetime import datetime
from app.utils.crypto import CryptographyUtils, Logger


class ChallengeGenerator:
    """Generate cryptographic challenges for community verification"""
    
    @staticmethod
    def generate_signing_challenge(
        community_id: str = "cardano-community",
        action: str = "verify_membership",
        custom_message: str = None
    ) -> dict:
        """
        Generate a signing challenge
        
        Args:
            community_id: Community identifier
            action: Action to perform (verify_membership, etc.)
            custom_message: Custom message (optional)
        
        Returns:
            Dictionary containing challenge data
        """
        Logger.info("========== Challenge Generation ==========", "CHALLENGE")
        
        challenge_id = CryptographyUtils.generate_challenge_id()
        nonce = CryptographyUtils.generate_nonce()
        timestamp = CryptographyUtils.get_timestamp()
        expiry = CryptographyUtils.get_expiry_timestamp(hours=1)
        
        if not custom_message:
            message = f"I hereby verify my membership and sign this challenge for {community_id}"
        else:
            message = custom_message
        
        challenge = {
            'challenge_id': challenge_id,
            'community_id': community_id,
            'nonce': nonce,
            'timestamp': timestamp,
            'action': action,
            'message': message,
            'expiry': expiry
        }
        
        expiry_time = datetime.fromtimestamp(expiry).strftime('%Y-%m-%d %H:%M:%S')
        
        Logger.success("Challenge generated:")
        print(f"  Challenge ID: {challenge_id}")
        print(f"  Community: {community_id}")
        print(f"  Action: {action}")
        print(f"  Message: {message}")
        print(f"  Expires: {expiry_time}")
        
        return challenge
