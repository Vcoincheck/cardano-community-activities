// ============================================
// EVENT ROUTES
// ============================================
// Generate and manage signing events

import express from 'express';
import { v4 as uuidv4 } from 'uuid';
import { randomBytes } from 'crypto';

const router = express.Router();

// In-memory storage (in production, use database)
const events = new Map();

// Generate event
router.post('/generate', (req, res) => {
  try {
    const { communityId, action = 'verify_membership', customMessage = null } = req.body;

    if (!communityId) {
      return res.status(400).json({ error: 'communityId is required' });
    }

    const eventId = uuidv4();
    const nonce = randomBytes(32).toString('base64');
    const timestamp = Math.floor(Date.now() / 1000);
    const expiry = timestamp + 3600; // 1 hour

    const message = customMessage || 
      `I hereby verify my membership and sign this event for ${communityId}`;

    const event = {
      event_id: eventId,
      community_id: communityId,
      nonce,
      timestamp,
      action,
      message,
      expiry,
      created_at: new Date().toISOString()
    };

    events.set(eventId, event);

    console.log(`✓ Event generated: ${eventId}`);
    res.status(201).json(event);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get event
router.get('/:eventId', (req, res) => {
  try {
    const event = events.get(req.params.eventId);

    if (!event) {
      return res.status(404).json({ error: 'Event not found' });
    }

    res.json(event);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Verify event still valid
router.get('/:eventId/validate', (req, res) => {
  try {
    const event = events.get(req.params.eventId);

    if (!event) {
      return res.status(404).json({ 
        valid: false, 
        error: 'Event not found' 
      });
    }

    const now = Math.floor(Date.now() / 1000);
    const isValid = now <= event.expiry;

    res.json({
      valid: isValid,
      event_id: event.event_id,
      expired: !isValid,
      time_remaining: Math.max(0, event.expiry - now)
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// List all events (admin only)
router.get('/', (req, res) => {
  try {
    const allEvents = Array.from(events.values());
    res.json({
      total: allEvents.length,
      events: allEvents
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
