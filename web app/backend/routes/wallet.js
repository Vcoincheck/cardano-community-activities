// ============================================
// WALLET ROUTES
// ============================================
// Wallet operations: keygen, exports, etc.

import express from 'express';
import { randomBytes } from 'crypto';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// Generate keypair (simulated - client-side in production)
router.post('/generate-keypair', (req, res) => {
  try {
    const { name = 'payment' } = req.body;

    // Simulate keypair generation
    const publicKey = randomBytes(32).toString('hex');
    const privateKey = randomBytes(32).toString('hex');

    const keypair = {
      id: uuidv4(),
      name,
      public_key: publicKey,
      private_key: `[REDACTED - Never share]`, // Never return actual private key
      created_at: new Date().toISOString(),
      type: 'ed25519'
    };

    console.log(`✓ Keypair generated: ${keypair.id}`);
    res.status(201).json({
      id: keypair.id,
      name: keypair.name,
      public_key: keypair.public_key,
      created_at: keypair.created_at,
      type: keypair.type,
      warning: 'Private key should be generated and stored locally only'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get public key (for verification purposes)
router.get('/public-key/:keyId', (req, res) => {
  try {
    // In production, fetch from database
    res.json({
      key_id: req.params.keyId,
      public_key: 'a0a1a2a3a4a5a6a7a8a9b0b1b2b3b4b5b6b7b8b9c0c1c2c3',
      type: 'ed25519'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Derive stake address from payment address
router.post('/derive-stake', (req, res) => {
  try {
    const { payment_address } = req.body;

    if (!payment_address) {
      return res.status(400).json({ error: 'payment_address is required' });
    }

    // Simulate stake address derivation
    const stakeAddress = payment_address.replace(/^addr/, 'stake');

    res.json({
      payment_address,
      stake_address: stakeAddress,
      network: 'mainnet'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Export wallet data (secured)
router.post('/export', (req, res) => {
  try {
    const { wallet_id, format = 'json' } = req.body;

    if (!wallet_id) {
      return res.status(400).json({ error: 'wallet_id is required' });
    }

    const exportData = {
      wallet_id,
      export_date: new Date().toISOString(),
      format,
      warning: 'Keep this export in a secure location',
      data: {
        public_keys: [],
        addresses: [],
        metadata: {}
      }
    };

    res.json(exportData);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get wallet info
router.get('/:walletId', (req, res) => {
  try {
    const walletInfo = {
      wallet_id: req.params.walletId,
      status: 'active',
      created_at: new Date(Date.now() - 86400000).toISOString(),
      type: 'payment',
      balance: null,
      last_activity: new Date().toISOString()
    };

    res.json(walletInfo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
