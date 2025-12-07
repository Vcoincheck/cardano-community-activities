# Quick Start - Using Python API from React

## Basic Usage Pattern

```jsx
import { usePythonAPI } from '../hooks/usePythonAPI';

export function MyTool() {
  const { call, loading, error } = usePythonAPI();
  const [result, setResult] = useState(null);
  
  const handleAction = async () => {
    try {
      const data = await call('action_name', {
        param1: 'value1',
        param2: 'value2'
      });
      setResult(data);
    } catch (err) {
      console.error(err);
    }
  };
  
  return (
    <div>
      <button onClick={handleAction} disabled={loading}>
        {loading ? 'Processing...' : 'Do Action'}
      </button>
      {error && <p>{error}</p>}
      {result && <pre>{JSON.stringify(result, null, 2)}</pre>}
    </div>
  );
}
```

## Currently Available Actions

| Action | Parameters | Returns |
|--------|-----------|---------|
| `generate_keypair` | `mnemonic?`, `wallet_path?` | `{ success, data }` |
| `sign_message` | `message`, `skey_path` | `{ success, signature }` |
| `verify_signature` | `message`, `signature`, `pubkey` | `{ success, valid }` |
| `get_balance` | `address` | `{ success, balance }` |
| `export_wallet` | `wallet_path?` | `{ success, backup }` |
| `cleanup_keys` | `wallet_path?` | `{ success, message }` |

## Example: Generate Keypair

```jsx
const handleGenerate = async () => {
  const result = await call('generate_keypair', {
    mnemonic: '', // Leave empty to generate new
    wallet_path: '/home/user/cardano_wallet'
  });
  
  console.log('Public Key:', result.data.public_key);
  console.log('Address:', result.data.address);
};
```

## Example: Sign and Verify

```jsx
// Sign
const signResult = await call('sign_message', {
  message: 'Important message',
  skey_path: '/path/to/key.skey'
});

// Verify
const verifyResult = await call('verify_signature', {
  message: 'Important message',
  signature: signResult.signature,
  pubkey: '...'
});

console.log('Valid?', verifyResult.valid);
```

## Implementing New Actions

1. **Add method to `python_backend/api.py`:**
```python
@staticmethod
def my_action(param1: str, param2: int) -> Dict[str, Any]:
    try:
        result = do_something(param1, param2)
        return { "success": True, "data": result }
    except Exception as e:
        return { "success": False, "error": str(e) }
```

2. **Register in `call_api()` function:**
```python
methods = {
    "generate_keypair": api.generate_keypair,
    "sign_message": api.sign_message,
    "my_action": api.my_action,  # Add here
    ...
}
```

3. **Use in React:**
```jsx
const result = await call('my_action', {
  param1: 'value1',
  param2: 42
});
```

That's it! The Python function is now callable from React.

## Checking Backend Status

```jsx
import { usePythonReady } from '../hooks/usePythonAPI';

export function App() {
  const ready = usePythonReady();
  
  return (
    <div>
      {ready ? (
        <p className="text-green-500">✓ Backend Ready</p>
      ) : (
        <p className="text-yellow-500">⏳ Connecting...</p>
      )}
    </div>
  );
}
```

## Error Handling

```jsx
const handleAction = async () => {
  try {
    const result = await call('some_action', params);
    if (!result.success) {
      // API error
      console.error('API Error:', result.error);
    } else {
      // Success
      console.log('Result:', result.data);
    }
  } catch (err) {
    // Network/timeout error
    console.error('Connection Error:', err.message);
  }
};
```

## Debugging

### View Python Logs
- Open DevTools (F12) in Electron
- Python stderr appears in the console

### Test API Call in Console
```javascript
window.electronAPI.callPythonAPI('generate_keypair', {})
  .then(r => console.log(r))
  .catch(e => console.error(e));
```

### Check Python Backend Status
```bash
# In Electron console
window.electronAPI.onPythonMessage(msg => console.log('Python:', msg));
```

