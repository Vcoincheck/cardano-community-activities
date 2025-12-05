def verify_user_signature(challenge, signature_data, check_expiry=True):
    import time
    now = int(time.time())
    if check_expiry and now > challenge["expiry"]:
        print("✗ Challenge expired")
        return False
    if signature_data.get("challenge_id") != challenge.get("challenge_id"):
        print("✗ Challenge ID mismatch")
        return False
    # TODO: Implement Ed25519 signature verification using a crypto library
    # Example: nacl.signing.VerifyKey(public_key).verify(message, signature)
    print("✓ Signature valid and challenge verified! (Demo only, implement real check)")
    return True