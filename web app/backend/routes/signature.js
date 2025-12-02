// ============================================
// SIGNATURE ROUTES
// ============================================
// Verify and manage signatures

import express from 'express';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

const signatures = new Map();
const events = new Map(); // Reference to events

// Verify signature
router.post('/verify', (req, res) => {
  try {
    const { 
      event_id, 
      wallet_address, 
      public_key, 
      signature, 
      signing_method = 'cip30'
    } = req.body;

    // Validate input
    if (!event_id || !wallet_address || !public_key || !signature) {
      return res.status(400).json({ 
        error: 'Missing required fields: event_id, wallet_address, public_key, signature' 
      });
    }

    // In production, verify with ed25519 crypto
    // For now, simulate verification
    const isValid = signature.length > 10; // Simple check

    const signatureId = uuidv4();
    const signatureData = {
      signature_id: signatureId,
      event_id,
      wallet_address,
      public_key,
      signature,
      signing_method,
      timestamp: Math.floor(Date.now() / 1000),
      verified: isValid,
      created_at: new Date().toISOString()
    };

    signatures.set(signatureId, signatureData);

    res.status(201).json({
      signature_id: signatureId,
      valid: isValid,
      message: isValid ? 'Signature verified' : 'Signature verification failed'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get signature
router.get('/:signatureId', (req, res) => {
  try {
    const signature = signatures.get(req.params.signatureId);

    if (!signature) {
      return res.status(404).json({ error: 'Signature not found' });
    }

    res.json(signature);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// List all signatures (admin)
router.get('/', (req, res) => {
  try {
    const { verified = null } = req.query;
    let allSignatures = Array.from(signatures.values());

    if (verified !== null) {
      allSignatures = allSignatures.filter(s => s.verified === (verified === 'true'));
    }

    res.json({
      total: allSignatures.length,
      signatures: allSignatures
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Batch verify multiple signatures
router.post('/verify-batch', (req, res) => {
  try {
    const { signatures: sigs } = req.body;

    if (!Array.isArray(sigs)) {
      return res.status(400).json({ error: 'signatures must be an array' });
    }

    const results = sigs.map(sig => ({
      signature: sig.signature.substring(0, 20) + '...',
      valid: sig.signature.length > 10
    }));

    res.json({
      total: results.length,
      verified: results.filter(r => r.valid).length,
      failed: results.filter(r => !r.valid).length,
      results
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
