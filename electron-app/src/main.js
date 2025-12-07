const { app, BrowserWindow, Menu, ipcMain } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const os = require('os');

let mainWindow;
let pythonProcess;
let pythonExecutable = null;

// Try to locate a usable Python executable on the host
function findPythonExecutable() {
  const { spawnSync } = require('child_process');
  const candidates = process.platform === 'win32'
    ? ['python.exe', 'python', 'py']
    : ['python3', 'python'];

  for (const cmd of candidates) {
    try {
      const res = spawnSync(cmd, ['--version']);
      if (res && res.status === 0) return cmd;
    } catch (e) {
      // ignore
    }
  }
  return null;
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false
    },
    icon: path.join(__dirname, '../assets/icon.png')
  });

  const isDev = process.argv.includes('--dev');
  if (isDev) {
    // Try to load from Vite dev server, fallback to static HTML if not available
    const devServerUrl = 'http://localhost:5173';
    mainWindow.loadURL(devServerUrl).catch(() => {
      console.log('Dev server not running. Loading static HTML instead.');
      mainWindow.loadFile(path.join(__dirname, 'views/index.html'));
    });
    mainWindow.webContents.openDevTools();
  } else {
    const reactBuildPath = path.join(__dirname, '../frontend/dist/index.html');
    if (require('fs').existsSync(reactBuildPath)) {
      mainWindow.loadFile(reactBuildPath);
    } else {
      mainWindow.loadFile(path.join(__dirname, 'views/index.html'));
    }
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// Start Python backend
function startPythonBackend() {
  if (!pythonExecutable) {
    console.warn('Python executable not found. Skipping backend start.');
    return;
  }

  // Try multiple python entry points (in priority order)
  const candidates = [
    path.join(__dirname, '../python_backend/__main__.py'),
    path.join(__dirname, '../python/app/main_launcher.py'),
    path.join(__dirname, '../python_backend')  // As module: python -m python_backend
  ];

  let pythonScript = null;
  let isModule = false;
  
  for (const candidate of candidates) {
    if (require('fs').existsSync(candidate)) {
      pythonScript = candidate;
      isModule = candidate.endsWith('python_backend');
      break;
    }
  }

  if (!pythonScript) {
    console.warn('No Python backend entry point found. Skipping backend start.');
    return;
  }

  console.log(`Starting Python backend: ${pythonScript}`);
  
  // Build spawn args
  let spawnArgs = [];
  if (isModule) {
    spawnArgs = ['-m', 'python_backend'];
  } else {
    spawnArgs = [pythonScript];
  }
  
  pythonProcess = spawn(pythonExecutable, spawnArgs, {
    env: Object.assign({}, process.env),
    stdio: ['pipe', 'pipe', 'pipe'],
    cwd: path.join(__dirname, '..')
  });

  pythonProcess.stdout.on('data', (data) => {
    const lines = data.toString().split('\n').filter(l => l.trim());
    
    for (const line of lines) {
      console.log(`Python stdout: ${line}`);
      try {
        const obj = JSON.parse(line);
        
        if (obj.status === 'ready') {
          console.log('✓ Python backend is ready');
        } else if (obj.status === 'response' && obj.id) {
          // Handle API response
          const pending = pendingRequests.get(obj.id);
          if (pending) {
            if (obj.success) {
              pending.resolve(obj);
            } else {
              pending.reject(new Error(obj.error || 'Unknown error'));
            }
            pendingRequests.delete(obj.id);
          }
        } else if (obj.status === 'error') {
          console.error('Python error:', obj.message);
        }
        
        if (mainWindow) mainWindow.webContents.send('python-message', obj);
      } catch (e) {
        // not JSON — log as-is
      }
    }
  });

  pythonProcess.stderr.on('data', (data) => {
    console.error(`Python stderr: ${data.toString()}`);
  });

  pythonProcess.on('error', (err) => {
    console.error(`Failed to start Python backend: ${err.message}`);
  });

  pythonProcess.on('close', (code) => {
    if (code === 0) {
      console.log('Python backend exited cleanly');
    } else {
      console.error(`Python process exited with code ${code}`);
    }
    pythonProcess = null;
  });
}

// IPC Handlers
let requestIdCounter = 0;
const pendingRequests = new Map();

ipcMain.handle('call-python-api', async (event, action, params) => {
  return new Promise((resolve, reject) => {
    if (!pythonProcess) {
      return reject(new Error('Python backend not running'));
    }

    const requestId = ++requestIdCounter;
    const command = {
      id: requestId,
      action: action,
      params: params || {}
    };

    // Setup timeout
    const timeout = setTimeout(() => {
      pendingRequests.delete(requestId);
      reject(new Error(`Python API call timeout: ${action}`));
    }, 30000);

    // Store the resolve/reject handlers
    pendingRequests.set(requestId, {
      resolve: (data) => {
        clearTimeout(timeout);
        resolve(data);
      },
      reject: (err) => {
        clearTimeout(timeout);
        reject(err);
      }
    });

    // Send command to Python backend via stdin
    pythonProcess.stdin.write(JSON.stringify(command) + '\n');
  });
});

// Listen for responses from Python backend
ipcMain.handle('python-api-response', async (event, requestId, data) => {
  const pending = pendingRequests.get(requestId);
  if (pending) {
    pending.resolve(data);
    pendingRequests.delete(requestId);
  }
});

// For React SPA, navigation is handled in the renderer
ipcMain.on('navigate', (event, page) => {
  if (mainWindow) {
    mainWindow.webContents.send('navigate', page);
  }
});

app.on('ready', () => {
  createWindow();
  // Detect python executable and start backend if available
  pythonExecutable = findPythonExecutable();
  if (pythonExecutable) {
    console.log(`Found python: ${pythonExecutable} — starting backend`);
    startPythonBackend();
  } else {
    console.warn('Python not detected — Python backend disabled');
  }
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
  if (pythonProcess) {
    pythonProcess.kill();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});

// Menu
const template = [
  {
    label: 'File',
    submenu: [
      {
        label: 'Exit',
        accelerator: 'CmdOrCtrl+Q',
        click: () => {
          app.quit();
        }
      }
    ]
  },
  {
    label: 'Edit',
    submenu: [
      { role: 'undo' },
      { role: 'redo' }
    ]
  },
  {
    label: 'Help',
    submenu: [
      {
        label: 'About',
        click: () => {
          // Show about dialog
        }
      }
    ]
  }
];

const menu = Menu.buildFromTemplate(template);
Menu.setApplicationMenu(menu);
