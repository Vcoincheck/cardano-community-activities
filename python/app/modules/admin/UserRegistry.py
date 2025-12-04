import os
import json
import uuid
from datetime import datetime

REGISTRY_PATH = "./data/user_registry.json"

def register_verified_user(wallet_address, stake_address, challenge_id, community_id):
    user = {
        "id": str(uuid.uuid4()),
        "walletAddress": wallet_address,
        "stakeAddress": stake_address,
        "challengeId": challenge_id,
        "communityId": community_id,
        "verificationDate": datetime.now().isoformat(),
        "status": "verified"
    }
    users = []
    if os.path.exists(REGISTRY_PATH):
        with open(REGISTRY_PATH, "r", encoding="utf-8") as f:
            users = json.load(f)
    users.append(user)
    os.makedirs(os.path.dirname(REGISTRY_PATH), exist_ok=True)
    with open(REGISTRY_PATH, "w", encoding="utf-8") as f:
        json.dump(users, f, ensure_ascii=False, indent=2)
    print(f"✓ User registered (ID: {user['id']})")
    return user

def get_registry_stats():
    if not os.path.exists(REGISTRY_PATH):
        return {"TotalUsers": 0, "Communities": {}}
    with open(REGISTRY_PATH, "r", encoding="utf-8") as f:
        users = json.load(f)
    stats = {
        "TotalUsers": len(users),
        "VerifiedUsers": sum(1 for u in users if u.get("status") == "verified"),
        "Communities": {}
    }
    for u in users:
        cid = u.get("communityId")
        stats["Communities"][cid] = stats["Communities"].get(cid, 0) + 1
    return stats