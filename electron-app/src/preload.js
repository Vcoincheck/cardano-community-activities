const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  // Run Python script
  runPythonScript: (scriptName, args = []) => 
    ipcRenderer.invoke('run-python-script', scriptName, args),
  
  // Navigation
  navigate: (page) => 
    ipcRenderer.send('navigate', page),
  
  // Python communication
  onPythonMessage: (callback) => 
    ipcRenderer.on('python-message', (event, data) => callback(data)),
  
  sendToPython: (message, data) => 
    ipcRenderer.send('to-python', message, data)
});
