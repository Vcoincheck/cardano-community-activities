const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  // Call Python API
  callPythonAPI: (action, params = {}) => 
    ipcRenderer.invoke('call-python-api', action, params),
  
  // Navigation
  navigate: (page) => 
    ipcRenderer.send('navigate', page),
  
  // Python communication
  onPythonMessage: (callback) => 
    ipcRenderer.on('python-message', (event, data) => callback(data)),
  
  // Get Python messages
  onPythonReady: (callback) => {
    ipcRenderer.on('python-message', (event, data) => {
      if (data.status === 'ready') callback();
    });
  }
});
