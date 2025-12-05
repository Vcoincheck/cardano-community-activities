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

// Admin Functions
function refreshStats() {
    addOutput('[*] Loading statistics...');
    
    // Simulate stats loading
    setTimeout(() => {
        document.getElementById('totalUsers').textContent = '3420';
        document.getElementById('verifiedUsers').textContent = '2890';
        document.getElementById('pendingUsers').textContent = '530';
        document.getElementById('totalCommunities').textContent = '15';
        
        addOutput('✓ Statistics loaded successfully');
    }, 500);
}

function createEvent() {
    const name = document.getElementById('eventName').value;
    const desc = document.getElementById('eventDesc').value;
    const community = document.getElementById('communityId').value;
    
    if (!name || !desc || !community) {
        addOutput('✗ Please fill all fields');
        return;
    }
    
    addOutput(`[*] Creating event: ${name}...`);
    addOutput('✓ Event created successfully');
    addOutput(`Event ID: evt_${Date.now()}`);
}

function generateChallenge() {
    const count = document.getElementById('participantCount').value || 10;
    
    addOutput(`[*] Generating ${count} challenges...`);
    
    // Simulate generation
    setTimeout(() => {
        addOutput(`✓ Generated ${count} challenges`);
        addOutput('Sample Challenge ID: chg_' + Math.random().toString(36).substr(2, 9));
    }, 1000);
}

function verifySigs() {
    const file = document.getElementById('signatureFile').files[0];
    
    if (!file) {
        addOutput('✗ Please select a signature file');
        return;
    }
    
    addOutput(`[*] Verifying signatures from ${file.name}...`);
    
    // Simulate verification
    setTimeout(() => {
        addOutput('✓ Verification complete');
        addOutput('Valid signatures: 95');
        addOutput('Invalid signatures: 5');
    }, 1000);
}

function exportResults() {
    const format = document.getElementById('exportFormat').value;
    
    addOutput(`[*] Exporting results as ${format.toUpperCase()}...`);
    
    setTimeout(() => {
        addOutput(`✓ Results exported successfully`);
        addOutput(`File: results_${Date.now()}.${format}`);
    }, 500);
}

// Load initial stats on page load
document.addEventListener('DOMContentLoaded', () => {
    refreshStats();
});
