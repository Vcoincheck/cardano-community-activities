# Electron App Setup & Dev Guide

## Quick Start

### 1. Install Dependencies
```bash
cd electron-app
npm install
```

### 2. Run in Development Mode

**Option A: Without Dev Server (Fastest)**
```bash
npm start
```
This loads the static HTML UI from `src/views/index.html` and connects to the Python backend.

**Option B: With React Dev Server (Hot Reload)**

First, set up your React/Vite app:
```bash
# If you haven't set up frontend yet, create a Vite React project
npm create vite@latest frontend -- --template react
cd frontend
npm install
npm run dev  # Runs on http://localhost:5173
```

Then in a separate terminal, run Electron in dev mode:
```bash
npm run dev
```
This will attempt to load your React app from the dev server and fallback to static HTML if unavailable.

### 3. Build for Production
```bash
npm run build
```

---

## File Structure

```
electron-app/
├── src/
│   ├── main.js              # Electron main process (updated for React support)
│   ├── preload.js           # IPC bridge
│   └── views/
│       ├── index.html       # Entry point (static or React mount)
│       ├── admin.html       # Admin panel (static)
│       └── end-user.html    # End-user tools (static)
├── python_backend/
│   ├── __main__.py          # Entry point (NEW - starts the backend)
│   ├── __init__.py
│   ├── modules/
│   ├── data/
│   └── utils/
├── package.json
└── README.md
```

---

## Changes Made

### `main.js` Updates

1. **Improved Python Backend Detection**
   - Tries multiple entry points: `python_backend/__main__.py`, `python/app/main_launcher.py`, or `python_backend` directory
   - Sets correct working directory for imports
   - Better error logging

2. **Dev Mode with Fallback**
   - Attempts to load React dev server on port 5173
   - Falls back to static HTML if dev server isn't running
   - No more "ERR_CONNECTION_REFUSED" crashes

3. **Production Build Support**
   - Looks for built React app at `frontend/dist/index.html`
   - Falls back to static HTML if not found

### `python_backend/__main__.py` (NEW)

- Entry point for Python backend
- Sends JSON status message when ready
- Can be expanded for FastAPI server or other services

---

## Troubleshooting

### "ERR_CONNECTION_REFUSED" on startup?
- **Normal!** Dev server isn't running. App falls back to static HTML.
- To use React hot reload: Start `npm run dev` in `frontend/` first.

### Python backend not starting?
```bash
# Test Python path
python --version

# Try manual backend start
python python_backend/__main__.py
```

### Module import errors in Python backend?
Ensure you're running from the correct directory:
```bash
cd electron-app
python -m python_backend
```

---

## Next Steps

1. **Build React Dashboard**: Create your React SPA in `frontend/` using Vite
2. **Integrate IPC Calls**: Use `window.electronAPI` (from preload.js) in React to call Python scripts
3. **Add State Management**: Use Redux/Zustand for global state in React
4. **Package for Distribution**: Use electron-builder to create installers with bundled Python

---

## Development Tips

- Keep dev tools open (`npm run dev` opens them automatically)
- Python backend logs appear in the main process console
- React dev server auto-reloads on file changes
- Use `mainWindow.webContents.openDevTools()` to inspect Electron window

