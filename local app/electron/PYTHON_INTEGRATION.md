# Python ↔ Electron Integration Guide

## Architecture

```
Electron UI (JavaScript)
    ↓↑ IPC (preload.js)
Electron Main (Node.js)
    ↓↑ spawn() / child_process
Python Backend (Python)
```

## How It Works

### 1. User clicks button in UI
```javascript
// src/assets/js/dashboard.js
function generateKeypair() {
  const result = await window.electronAPI.runPythonScript(
    'end_user/key_generator.py',
    ['--mnemonic', mnemonic, '--path', walletPath]
  );
}
```

### 2. IPC sends to main process
```javascript
// src/preload.js
window.electronAPI.runPythonScript = (scriptName, args) =>
  ipcRenderer.invoke('run-python-script', scriptName, args);
```

### 3. Main process executes Python
```javascript
// src/main.js
ipcMain.handle('run-python-script', async (event, scriptName, args) => {
  const process = spawn('python3', [scriptPath, ...args]);
  // Capture output
  return output;
});
```

### 4. Result sent back to UI
```javascript
// Result displays in output panel
addOutput(result);
```

## Python Script Requirements

Your Python scripts should:

### 1. Accept CLI arguments
```python
import sys
if __name__ == '__main__':
    mnemonic = sys.argv[1]
    wallet_path = sys.argv[2]
```

### 2. Output JSON for responses
```python
import json
result = {
    'success': True,
    'addresses': [...],
    'stake_address': '...'
}
print(json.dumps(result))
```

### 3. Use exit codes
```python
sys.exit(0)  # Success
sys.exit(1)  # Error
```

## Implementation Examples

### End-User: Generate Keypair

**HTML Button:**
```html
<button onclick="generateKeypair()">Generate Addresses</button>
```

**JavaScript Handler:**
```javascript
async function generateKeypair() {
  const mnemonic = document.getElementById('mnemonicInput').value;
  const walletPath = document.getElementById('walletPath').value;
  
  try {
    const result = await window.electronAPI.runPythonScript(
      'end_user/key_generator.py',
      ['--mnemonic', mnemonic, '--path', walletPath]
    );
    
    addOutput('✓ Keypair generated: ' + result);
  } catch (error) {
    addOutput('✗ Error: ' + error.message);
  }
}
```

**Python Script (key_generator.py):**
```python
#!/usr/bin/env python3
import sys
import json
from key_generator import KeyGenerator

if __name__ == '__main__':
    mnemonic = sys.argv[1]
    wallet_path = sys.argv[2]
    
    gen = KeyGenerator(wallet_path)
    result = gen.generate_addresses(mnemonic, account_index=0)
    
    print(json.dumps(result))
    sys.exit(0)
```

### Admin: Generate Challenge

**HTML:**
```html
<input type="number" id="participantCount">
<button onclick="generateChallenge()">Generate</button>
```

**JavaScript:**
```javascript
async function generateChallenge() {
  const count = document.getElementById('participantCount').value;
  
  try {
    const result = await window.electronAPI.runPythonScript(
      'admin/GenerateChallenge.py',
      ['--count', count]
    );
    
    addOutput('✓ Generated: ' + result);
  } catch (error) {
    addOutput('✗ Error: ' + error.message);
  }
}
```

**Python Script (GenerateChallenge.py wrapper):**
```python
#!/usr/bin/env python3
import sys
import json
from GenerateChallenge import generate_signing_challenge

if __name__ == '__main__':
    count = int(sys.argv[1])
    
    challenges = []
    for i in range(count):
        challenge = generate_signing_challenge()
        challenges.append(challenge)
    
    print(json.dumps(challenges))
    sys.exit(0)
```

## Data Flow Examples

### Input → Python → Output

```
User Input (HTML)
    ↓
JavaScript Handler
    ↓
IPC invoke('run-python-script', ...)
    ↓
Main process spawn(python, [script, args])
    ↓
Python script execution
    ↓
print(json.dumps(result))
    ↓
Capture stdout
    ↓
IPC resolve(output)
    ↓
JavaScript receives result
    ↓
Display in UI
```

## Error Handling

### JavaScript
```javascript
try {
  const result = await window.electronAPI.runPythonScript(...);
} catch (error) {
  console.error('Python Error:', error.message);
  addOutput('✗ Error: ' + error.message);
}
```

### Python
```python
try:
    # Process
except Exception as e:
    print(json.dumps({'error': str(e)}))
    sys.exit(1)
```

## File Paths

When referencing Python modules from Electron:

```javascript
// From main.js
const scriptPath = path.join(__dirname, '../python/app/modules', scriptName);
// → /workspace/.../python/app/modules/end_user/key_generator.py
```

## Tips & Tricks

1. **Always use absolute paths in Python**
   ```python
   import os
   script_dir = os.path.dirname(os.path.abspath(__file__))
   ```

2. **Return structured data**
   ```python
   result = {
       'status': 'success',
       'data': {...},
       'timestamp': datetime.now().isoformat()
   }
   print(json.dumps(result))
   ```

3. **Handle large outputs**
   ```javascript
   // Split large outputs
   const lines = output.split('\n');
   lines.forEach(line => addOutput(line));
   ```

4. **Timeout for long operations**
   ```javascript
   const timeout = setTimeout(() => {
       addOutput('⏱ Operation taking too long...');
   }, 30000);
   ```

## Testing

### Test Python script directly
```bash
python3 python/app/modules/end_user/key_generator.py --mnemonic "..." --path "."
```

### Test IPC in DevTools
```javascript
// In DevTools console
await window.electronAPI.runPythonScript('test.py', ['arg1', 'arg2'])
```

---

**Next**: Implement Python adapters for each tool following these patterns.
