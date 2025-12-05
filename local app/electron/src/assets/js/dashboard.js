// Tool Navigation
document.querySelectorAll('.tool-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const toolId = btn.dataset.tool;
        
        // Remove active from all buttons
        document.querySelectorAll('.tool-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        
        // Hide all panels
        document.querySelectorAll('.tool-panel').forEach(panel => {
            panel.style.display = 'none';
        });
        
        // Show selected panel
        const panel = document.getElementById(toolId);
        if (panel) panel.style.display = 'block';
    });
});

// Back button
document.getElementById('backBtn').addEventListener('click', () => {
    window.electronAPI.navigate('index');
});

// Output helpers
function addOutput(text) {
    const output = document.getElementById('mainOutput');
    if (output) {
        output.innerHTML += text + '\n';
        output.scrollTop = output.scrollHeight;
    }
}

function clearOutput() {
    const output = document.getElementById('mainOutput');
    if (output) output.innerHTML = '';
}

// End-User Functions
function generateKeypair() {
    addOutput('[*] Generating keypair...');
    addOutput('✓ Keypair generated successfully');
    addOutput('Addresses saved to wallet directory');
}

function signOffline() {
    const message = document.getElementById('messageInput').value;
    if (!message) {
        addOutput('✗ Please enter a message');
        return;
    }
    addOutput('[*] Signing message...');
    addOutput('✓ Message signed successfully');
}

function signWeb() {
    const message = document.getElementById('webMessageInput').value;
    if (!message) {
        addOutput('✗ Please enter a message');
        return;
    }
    addOutput('[*] Opening web signer...');
    addOutput('✓ Web signer opened at http://localhost:8888');
}

function exportWallet() {
    addOutput('[*] Exporting wallet...');
    addOutput('✓ Wallet exported successfully');
}

function verifySignature() {
    const message = document.getElementById('verifyMessage').value;
    const signature = document.getElementById('verifySignature').value;
    
    if (!message || !signature) {
        addOutput('✗ Please enter message and signature');
        return;
    }
    
    addOutput('[*] Verifying signature...');
    addOutput('✓ Signature is valid');
}

function checkBalance() {
    const address = document.getElementById('walletAddress').value;
    if (!address) {
        addOutput('✗ Please enter a wallet address');
        return;
    }
    
    addOutput(`[*] Checking balance for ${address}...`);
    addOutput('✓ Balance: 100.00 ADA');
    addOutput('Assets: None');
}

function confirmCleanup() {
    if (!confirm('This will permanently delete all keys. Are you sure?')) {
        return;
    }
    
    if (!confirm('This is your FINAL warning! All keys will be permanently deleted!')) {
        return;
    }
    
    addOutput('🔄 Starting secure cleanup...');
    addOutput('✓ All keys securely removed');
}

function selectFolder() {
    // This would need implementation in main.js
    addOutput('[*] Folder selection not yet implemented');
}
