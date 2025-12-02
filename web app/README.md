# Cardano Community Suite - Web Version

Complete web application version of Cardano Community Suite built with Node.js/Express backend and React frontend.

## 🏗️ Architecture

```
cardano-web-suite/
├── backend/                    # Express.js REST API
│   ├── server.js              # Main server
│   ├── routes/
│   │   ├── event.js           # Event generation & validation
│   │   ├── signature.js       # Signature verification
│   │   ├── registry.js        # User management
│   │   ├── wallet.js          # Wallet operations
│   │   └── reports.js         # Reports & analytics
│   ├── middleware/            # Express middleware
│   ├── services/              # Business logic
│   ├── db/                    # Database layer
│   └── package.json
│
├── frontend/                   # React + Vite
│   ├── src/
│   │   ├── main.jsx           # Main React component
│   │   ├── pages/             # Page components
│   │   └── components/        # Reusable components
│   ├── public/
│   │   └── index.html         # HTML entry point
│   ├── vite.config.js         # Vite configuration
│   └── package.json
│
└── docs/                      # Documentation
```

## 🚀 Quick Start

### Backend Setup
```bash
cd backend
npm install
npm run dev
# Server runs on http://localhost:3000
```

### Frontend Setup
```bash
cd frontend
npm install
npm run dev
# Frontend runs on http://localhost:5173
```

## 📡 API Endpoints

### Events
- `POST /api/events/generate` - Create event
- `GET /api/events/:eventId` - Get event
- `GET /api/events/:eventId/validate` - Validate event

### Signatures
- `POST /api/signatures/verify` - Verify signature
- `POST /api/signatures/verify-batch` - Batch verify
- `GET /api/signatures/:signatureId` - Get signature

### Registry
- `POST /api/registry/register` - Register user
- `GET /api/registry/:userId` - Get user
- `GET /api/registry/stats/summary` - Get stats

### Wallet
- `POST /api/wallet/generate-keypair` - Generate keypair
- `POST /api/wallet/derive-stake` - Derive stake address
- `POST /api/wallet/export` - Export wallet

### Reports
- `POST /api/reports/community` - Generate community report
- `GET /api/reports/verification-log` - Get verification log
- `GET /api/reports/dashboard/stats` - Get dashboard stats

## 🔐 Security Features

- ✅ CORS enabled for frontend communication
- ✅ Request validation on all endpoints
- ✅ Error handling and logging
- ✅ Private key handling (never transmitted)
- ✅ Event-response authentication
- ✅ Replay protection with nonce

## 📦 Technologies

### Backend
- Express.js (REST API framework)
- Node.js (Runtime)
- SQLite (Database - optional)
- Axios (HTTP client)
- UUID (Unique identifiers)

### Frontend
- React 18 (UI library)
- Vite (Build tool)
- React Router (Navigation)
- Axios (API client)

## 🎯 Features

### End-User Portal
- Generate Cardano keypairs
- Sign messages offline
- Verify signatures locally
- Export wallet data
- View transaction history

### Admin Dashboard
- Generate verification events
- Verify user signatures
- Manage user registry
- Check on-chain data
- Generate reports
- View community statistics

## 📊 Data Models

### Event
```json
{
  "event_id": "uuid",
  "community_id": "string",
  "nonce": "base64",
  "timestamp": "unix",
  "action": "verify_membership",
  "message": "string",
  "expiry": "unix"
}
```

### User
```json
{
  "id": "uuid",
  "wallet_address": "addr1q...",
  "stake_address": "stake1...",
  "community_id": "string",
  "status": "verified",
  "registration_date": "iso8601"
}
```

## 📋 Workflow

1. **Event Generation**
   - Admin creates event
   - Event sent to user

2. **Message Signing**
   - User signs with private key (locally)
   - Signature submitted to backend

3. **Verification**
   - Backend verifies signature
   - User registered in system

4. **On-Chain (Optional)**
   - Backend queries on-chain data
   - Stake verified

## 🚢 Deployment

### Docker (Recommended)
```dockerfile
# Backend
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["npm", "run", "dev"]
```

### Environment Variables
```
PORT=3000
NODE_ENV=production
DATABASE_URL=./data/registry.db
CORS_ORIGIN=http://localhost:5173
```

## 📝 Development

### Adding New Endpoint
1. Create route in `routes/`
2. Add business logic in `services/`
3. Export router in `server.js`

### Adding New Component
1. Create component in `frontend/src/components/`
2. Import in main component
3. Style with inline or CSS modules

## 🧪 Testing

```bash
# Backend tests
cd backend
npm test

# Frontend tests
cd frontend
npm test
```

## 📚 API Documentation

Full API docs generated from code comments. See comments in route files for:
- Request parameters
- Response format
- Error handling
- Example usage

## 🔐 Security Considerations

- All private keys handled client-side
- Event expiry prevents replay attacks
- Nonce validation per event
- HTTPS recommended for production
- Rate limiting recommended
- SQL injection prevention via parameterized queries

## 🎓 Learning Resources

- See `docs/` for detailed guides
- API comments in route files
- Component props documented inline
- Error messages provide guidance

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Follow code style
4. Add tests
5. Submit PR

## 📜 License

MIT License

## 🙋 Support

See main project docs for support resources.

**Built with ❤️ for Cardano**
