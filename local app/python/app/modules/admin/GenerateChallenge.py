import uuid
import base64
import time
from datetime import datetime

def generate_signing_challenge(community_id="cardano-community", action="verify_membership", custom_message=None):
    challenge_id = str(uuid.uuid4())
    nonce = base64.b64encode(f"{uuid.uuid4()}{int(time.time())}".encode()).decode()
    timestamp = int(time.time())
    expiry = timestamp + 3600
    message = custom_message or f"I hereby verify my membership and sign this challenge for {community_id}"
    challenge = {
        "challenge_id": challenge_id,
        "community_id": community_id,
        "nonce": nonce,
        "timestamp": timestamp,
        "action": action,
        "message": message,
        "expiry": expiry
    }
    print(f"✓ Challenge generated:\n  Challenge ID: {challenge_id}\n  Community: {community_id}\n  Action: {action}\n  Message: {message}\n  Expires: {datetime.fromtimestamp(expiry)}")
    return challenge