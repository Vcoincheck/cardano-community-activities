// ============================================
// REGISTRY ROUTES
// ============================================
// Manage user registry

import express from 'express';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

const userRegistry = new Map();

// Register verified user
router.post('/register', (req, res) => {
  try {
    const {
      wallet_address,
      stake_address,
      event_id,
      community_id,
      public_key
    } = req.body;

    if (!wallet_address || !community_id) {
      return res.status(400).json({ 
        error: 'wallet_address and community_id are required' 
      });
    }

    const userId = uuidv4();
    const user = {
      id: userId,
      wallet_address,
      stake_address: stake_address || null,
      event_id,
      community_id,
      public_key,
      status: 'verified',
      registration_date: new Date().toISOString(),
      verified_at: Math.floor(Date.now() / 1000)
    };

    userRegistry.set(userId, user);

    console.log(`✓ User registered: ${userId}`);
    res.status(201).json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user by ID
router.get('/:userId', (req, res) => {
  try {
    const user = userRegistry.get(req.params.userId);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all users (with filters)
router.get('/', (req, res) => {
  try {
    const { community_id, status } = req.query;
    let users = Array.from(userRegistry.values());

    if (community_id) {
      users = users.filter(u => u.community_id === community_id);
    }

    if (status) {
      users = users.filter(u => u.status === status);
    }

    res.json({
      total: users.length,
      users
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get registry statistics
router.get('/stats/summary', (req, res) => {
  try {
    const users = Array.from(userRegistry.values());
    const communities = {};

    users.forEach(user => {
      if (!communities[user.community_id]) {
        communities[user.community_id] = 0;
      }
      communities[user.community_id]++;
    });

    res.json({
      total_users: users.length,
      total_communities: Object.keys(communities).length,
      communities,
      verified: users.filter(u => u.status === 'verified').length,
      pending: users.filter(u => u.status === 'pending').length
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update user status
router.patch('/:userId/status', (req, res) => {
  try {
    const { status } = req.body;
    const user = userRegistry.get(req.params.userId);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    user.status = status;
    user.updated_at = new Date().toISOString();

    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete user
router.delete('/:userId', (req, res) => {
  try {
    if (!userRegistry.has(req.params.userId)) {
      return res.status(404).json({ error: 'User not found' });
    }

    userRegistry.delete(req.params.userId);
    res.json({ message: 'User deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
