# Python API Integration Guide

## Architecture

```
Electron App
    ↓
preload.js (electronAPI.callPythonAPI)
    ↓
main.js (IPC Handler 'call-python-api')
    ↓
pythonProcess.stdin (JSON command)
    ↓
python_backend/__main__.py (listens on stdin)
    ↓
python_backend/api.py (executes action)
    ↓
Responses back via stdout → IPC → UI
```

## Files Created/Modified

### 1. **python_backend/api.py** (NEW)
- Exposes all Python functions as an API
- Methods: `generate_keypair`, `sign_message`, `verify_signature`, `get_balance`, `export_wallet`, `cleanup_keys`
- Returns `{"success": true/false, "data": ..., "error": ...}`

### 2. **python_backend/__main__.py** (UPDATED)
- Entry point for Python backend
- Listens for JSON commands on stdin from Electron
- Calls API methods and sends responses via stdout
- Handles errors and timeouts gracefully

### 3. **src/main.js** (UPDATED)
- `ipcMain.handle('call-python-api', ...)` - Handles API calls from renderer
- Sends commands to Python via `pythonProcess.stdin`
- Listens for responses and resolves promises
- Request ID system for matching responses to calls

### 4. **src/preload.js** (UPDATED)
- Exposes `window.electronAPI.callPythonAPI(action, params)`
- Simplified API: `const result = await electronAPI.callPythonAPI('generate_keypair', {...})`

### 5. **src/hooks/usePythonAPI.js** (NEW)
- React hook: `const { call, loading, error } = usePythonAPI()`
- Auto handles loading/error states
- `usePythonReady()` - Check if backend is ready
- `usePythonMessages(callback)` - Listen for backend messages

### 6. **src/views/EndUserDashboard.jsx** (UPDATED)
- Fully functional React component
- Uses `usePythonAPI` hook for all operations
- State management for form inputs
- Real-time output logging
- Loading and error handling

## How to Use in React

### Example 1: Simple API Call

```jsx
import { usePythonAPI } from '../hooks/usePythonAPI';

function MyComponent() {
  const { call, loading, error } = usePythonAPI();
  
  const handleClick = async () => {
    try {
      const result = await call('generate_keypair', {
        mnemonic: 'abandon abandon abandon...',
        wallet_path: '/path/to/wallet'
      });
      console.log('Success!', result.data);
    } catch (err) {
      console.error('Error:', err.message);
    }
  };
  
  return (
    <div>
      <button onClick={handleClick} disabled={loading}>
        {loading ? 'Loading...' : 'Generate'}
      </button>
      {error && <p className="text-red-500">{error}</p>}
    </div>
  );
}
```

### Example 2: With Multiple Calls

```jsx
const { call, loading } = usePythonAPI();

const handleSign = async () => {
  // Call 1: Generate keypair
  const kp = await call('generate_keypair', {});
  
  // Call 2: Sign message
  const sig = await call('sign_message', {
    message: 'Hello',
    skey_path: kp.data.skey_path
  });
  
  console.log('Signed:', sig.signature);
};
```

## API Reference

### generate_keypair(mnemonic?, wallet_path?)
```python
# Request
{
  "action": "generate_keypair",
  "params": {
    "mnemonic": "word1 word2... (optional)",
    "wallet_path": "/path/to/wallet (optional)"
  }
}

# Response
{
  "success": true,
  "data": {
    "public_key": "...",
    "address": "addr1...",
    "skey_path": "..."
  }
}
```

### sign_message(message, skey_path)
```python
# Request
{
  "action": "sign_message",
  "params": {
    "message": "text to sign",
    "skey_path": "/path/to/skey"
  }
}

# Response
{
  "success": true,
  "signature": "hex_string",
  "message": "text to sign"
}
```

### verify_signature(message, signature, pubkey)
```python
# Request
{
  "action": "verify_signature",
  "params": {
    "message": "original message",
    "signature": "hex_signature",
    "pubkey": "public_key_hex"
  }
}

# Response
{
  "success": true,
  "valid": true/false
}
```

### get_balance(address)
```python
# Request
{
  "action": "get_balance",
  "params": {
    "address": "addr1..."
  }
}

# Response
{
  "success": true,
  "balance": {
    "lovelace": 1000000,
    "assets": []
  }
}
```

### export_wallet(wallet_path?)
```python
# Request
{
  "action": "export_wallet",
  "params": {
    "wallet_path": "/path/to/wallet (optional)"
  }
}

# Response
{
  "success": true,
  "backup": { ... }
}
```

### cleanup_keys(wallet_path?)
```python
# Request
{
  "action": "cleanup_keys",
  "params": {
    "wallet_path": "/path/to/wallet (optional)"
  }
}

# Response
{
  "success": true,
  "message": "All keys cleaned up"
}
```

## Testing the Integration

### 1. Start Electron App
```bash
npm start
```

### 2. Open DevTools (F12) and try:
```javascript
await window.electronAPI.callPythonAPI('generate_keypair', {})
  .then(r => console.log(r))
  .catch(e => console.error(e))
```

### 3. Check Python Backend Logs
```bash
# View stderr in Electron console
```

## Troubleshooting

### "Python backend not running"
- Check if `python_backend/__main__.py` exists
- Make sure Python can import the backend modules
- Check console for Python stderr

### Timeout errors
- API call takes too long (default: 30s)
- Check Python logs for errors
- May need to increase timeout in `main.js`

### Module import errors in Python
- Ensure working directory is set correctly (`cwd: path.join(__dirname, '..')`)
- Python backend modules must be importable

## Next Steps

1. **Implement backend modules**: `key_generator.py`, `signing.py`, `blockchain.py`, etc.
2. **Add more API endpoints**: Can add any Python function easily
3. **Error handling**: Add specific error types and better messages
4. **Logging**: Add comprehensive logging for debugging
5. **Testing**: Create unit tests for both IPC and Python APIs

