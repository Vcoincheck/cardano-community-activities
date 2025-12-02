# Cardano Community Suite - Web Setup Guide

## 🚀 Quick Start (5 minutes)

### Prerequisites
- Node.js 16+ ([Download](https://nodejs.org/))
- npm 8+
- Git

### Installation

```bash
# Clone repository
git clone https://github.com/your-org/cardano-community-suite
cd cardano-web-suite

# Install backend dependencies
cd backend
npm install

# Install frontend dependencies
cd ../frontend
npm install
cd ..
```

### Run Development Servers

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
# Server: http://localhost:3000
# API: http://localhost:3000/api
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
# Frontend: http://localhost:5173
```

Open browser: **http://localhost:5173**

## 📋 Project Structure

```
backend/
├── server.js              # Express app
├── routes/                # API endpoints
│   ├── event.js
│   ├── signature.js
│   ├── registry.js
│   ├── wallet.js
│   └── reports.js
├── services/              # Business logic
├── middleware/            # Custom middleware
├── db/                    # Database models
└── package.json

frontend/
├── src/
│   ├── main.jsx          # React root
│   ├── pages/            # Page components
│   └── components/       # Reusable components
├── public/
│   └── index.html        # HTML template
├── vite.config.js        # Vite config
└── package.json
```

## 🔧 Configuration

### Backend (.env)
```
PORT=3000
NODE_ENV=development
CORS_ORIGIN=http://localhost:5173
DATABASE_URL=./data/registry.db
```

### Frontend (vite.config.js)
```javascript
proxy: {
  '/api': {
    target: 'http://localhost:3000',
    changeOrigin: true
  }
}
```

## 🛠️ Available Commands

### Backend
```bash
npm run dev      # Development with hot reload
npm start        # Production
npm test         # Run tests
```

### Frontend
```bash
npm run dev      # Development server
npm run build    # Production build
npm run preview  # Preview production build
```

## 📡 API Testing

### Using cURL

**Generate Event:**
```bash
curl -X POST http://localhost:3000/api/events/generate \
  -H "Content-Type: application/json" \
  -d '{"communityId": "cardano-devs-ph"}'
```

**Verify Signature:**
```bash
curl -X POST http://localhost:3000/api/signatures/verify \
  -H "Content-Type: application/json" \
  -d '{
    "event_id": "...",
    "wallet_address": "addr1q...",
    "public_key": "...",
    "signature": "..."
  }'
```

### Using Postman

1. Import collection from `docs/postman-collection.json` (if available)
2. Set variables:
   - `base_url`: http://localhost:3000
   - `event_id`: Generated event ID
3. Test endpoints

### Using REST Client (VS Code)

Create `test.rest`:
```http
### Health Check
GET http://localhost:3000/api/health

### Generate Event
POST http://localhost:3000/api/events/generate
Content-Type: application/json

{
  "communityId": "cardano-devs-ph"
}
```

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>
```

### CORS Errors
- Check backend CORS configuration
- Verify frontend proxy settings
- Ensure both servers are running

### Module Not Found
```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Database Errors
```bash
# Reset database
rm -f data/registry.db
npm run db:init
```

## 📦 Building for Production

### Backend
```bash
# Production build
npm install --production

# Run
NODE_ENV=production npm start
```

### Frontend
```bash
# Production build
npm run build

# Output in dist/ directory
```

### Docker Deployment

```bash
# Build images
docker build -t cardano-backend backend/
docker build -t cardano-frontend frontend/

# Run containers
docker run -p 3000:3000 cardano-backend
docker run -p 5173:5173 cardano-frontend
```

## 🔐 Security Checklist

Before deployment:
- [ ] Environment variables set
- [ ] HTTPS enabled
- [ ] CORS configured properly
- [ ] Input validation enabled
- [ ] SQL injection prevention active
- [ ] Rate limiting configured
- [ ] Logging enabled
- [ ] Error handling in place
- [ ] Private keys never logged
- [ ] Database backed up

## 📊 Monitoring

### Logs
```bash
# Backend logs
tail -f logs/app.log

# Frontend console
# Open DevTools (F12)
```

### Performance
```bash
# Lighthouse audit
npm run audit

# Bundle size
npm run build:analyze
```

## 🚀 Deployment Platforms

### Heroku
```bash
heroku create cardano-community-api
git push heroku main
```

### AWS
- EC2 instance
- RDS for database
- CloudFront for frontend
- See AWS docs

### Railway
```bash
railway link
railway up
```

### Vercel (Frontend only)
```bash
npm i -g vercel
vercel
```

## 📚 Additional Resources

- [Express.js Docs](https://expressjs.com/)
- [React Docs](https://react.dev/)
- [Vite Docs](https://vitejs.dev/)
- [Node.js Docs](https://nodejs.org/docs/)

## 🆘 Getting Help

1. Check `README.md` for overview
2. Review API documentation
3. Check error messages
4. Search GitHub issues
5. Ask in discussions

## 🎉 Next Steps

1. ✅ Setup complete!
2. Explore API endpoints
3. Create user interface
4. Add authentication
5. Deploy to production

**Happy coding! 🚀**
