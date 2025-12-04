"""
Web-Based Message Signing Server
Sign Cardano messages through browser with Yoroi wallet integration
"""
import asyncio
import json
import webbrowser
import threading
from typing import Optional, Dict
from datetime import datetime
from pathlib import Path
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import uvicorn


class WebSigningServer:
    """HTTP server for web-based message signing"""
    
    def __init__(self, port: int = 8888):
        self.port = port
        self.app = FastAPI()
        self.message_to_sign = None
        self.signature_result = None
        self.is_complete = False
        self.setup_routes()
    
    def setup_routes(self):
        """Setup API routes"""
        
        @self.app.get("/", response_class=HTMLResponse)
        async def get_signing_page():
            """Serve HTML signing page"""
            return self.get_signing_html()
        
        @self.app.post("/api/sign")
        async def handle_signature(request: Request):
            """Handle signature submission"""
            try:
                body = await request.json()
                
                if not body.get("signature"):
                    return JSONResponse(
                        {"status": "error", "message": "No signature provided"},
                        status_code=400
                    )
                
                self.signature_result = {
                    "message": self.message_to_sign,
                    "signature": body.get("signature"),
                    "address": body.get("address"),
                    "wallet": body.get("wallet", "unknown"),
                    "timestamp": datetime.now().isoformat()
                }
                self.is_complete = True
                
                return JSONResponse(
                    {"status": "success", "message": "Signature received"}
                )
            except Exception as e:
                return JSONResponse(
                    {"status": "error", "message": str(e)},
                    status_code=400
                )
        
        @self.app.get("/api/status")
        async def get_status():
            """Get signing status"""
            return JSONResponse({
                "is_complete": self.is_complete,
                "signature": self.signature_result
            })
    
    def get_signing_html(self) -> str:
        """Generate HTML signing page"""
        message = self.message_to_sign or ""
        
        # Convert message to hex
        hex_message = message.encode().hex()
        
        html = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Message - Cardano</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1e1e2e 0%, #2d2d3d 100%);
            color: #e0e0e0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }}
        .container {{
            background: #2d2d3d;
            border: 2px solid #00ffff;
            border-radius: 12px;
            padding: 40px;
            max-width: 700px;
            width: 100%;
            box-shadow: 0 0 30px rgba(0, 255, 255, 0.4);
        }}
        h1 {{
            color: #00ffff;
            margin-bottom: 30px;
            text-align: center;
            font-size: 28px;
        }}
        .message-box {{
            background: #1e1e2e;
            border: 1px solid #00ff00;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }}
        .message-label {{
            color: #00ffff;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 10px;
        }}
        .message-content {{
            color: #00ff00;
            font-family: 'Courier New', monospace;
            font-size: 13px;
            background: #161620;
            padding: 12px;
            border-radius: 4px;
            border: 1px solid #00aa00;
            word-wrap: break-word;
            max-height: 150px;
            overflow-y: auto;
        }}
        .hex-display {{
            margin-top: 12px;
            padding-top: 12px;
            border-top: 1px solid #00aa00;
            color: #888;
            font-size: 11px;
        }}
        .wallet-selector {{
            margin: 25px 0;
        }}
        .wallet-label {{
            color: #00ffff;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 12px;
            display: block;
        }}
        .wallet-buttons {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }}
        .wallet-btn {{
            padding: 12px;
            border: 2px solid #00ffff;
            border-radius: 6px;
            background: #1e1e2e;
            color: #00ffff;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }}
        .wallet-btn:hover {{
            background: #00ffff;
            color: #1e1e2e;
            box-shadow: 0 0 15px rgba(0, 255, 255, 0.5);
        }}
        .wallet-btn.active {{
            background: #00ffff;
            color: #1e1e2e;
        }}
        .button-group {{
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }}
        .sign-btn {{
            flex: 1;
            padding: 12px;
            background: #00aa00;
            color: #000;
            border: 2px solid #00ff00;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
        }}
        .sign-btn:hover:not(:disabled) {{
            background: #00ff00;
            box-shadow: 0 0 20px rgba(0, 255, 0, 0.6);
        }}
        .sign-btn:disabled {{
            opacity: 0.5;
            cursor: not-allowed;
        }}
        #cancelBtn {{
            flex: 1;
            padding: 12px;
            background: #444;
            color: #ccc;
            border: none;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
        }}
        .status {{
            margin-top: 20px;
            padding: 15px;
            border-radius: 6px;
            text-align: center;
            display: none;
            font-size: 13px;
        }}
        .status.success {{
            background: #1e3a1e;
            border: 1px solid #00aa00;
            color: #00ff00;
            display: block;
        }}
        .status.error {{
            background: #3a1e1e;
            border: 1px solid #aa0000;
            color: #ff6666;
            display: block;
        }}
        .status.info {{
            background: #1e2a3a;
            border: 1px solid #0077ff;
            color: #88ccff;
            display: block;
        }}
        .spinner {{
            display: inline-block;
            width: 12px;
            height: 12px;
            border: 2px solid #666;
            border-top-color: #00ffff;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
            margin-right: 8px;
        }}
        @keyframes spin {{
            to {{ transform: rotate(360deg); }}
        }}
        .signature-box {{
            background: #1e1e2e;
            border: 1px solid #00ff00;
            padding: 15px;
            margin-top: 20px;
            border-radius: 6px;
            display: none;
        }}
        .signature-box.show {{
            display: block;
        }}
        .signature-value {{
            color: #00ff00;
            font-family: 'Courier New', monospace;
            font-size: 11px;
            word-break: break-all;
            max-height: 100px;
            overflow-y: auto;
            background: #161620;
            padding: 8px;
            border: 1px solid #00aa00;
            border-radius: 4px;
            margin-top: 8px;
        }}
        .copy-btn {{
            background: #333;
            color: #00ffff;
            padding: 8px 12px;
            border: 1px solid #00ffff;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            margin-top: 8px;
            display: block;
            width: 100%;
        }}
        .copy-btn:hover {{
            background: #444;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 Sign Message</h1>
        
        <div class="message-box">
            <div class="message-label">📝 Message:</div>
            <div class="message-content">{message}</div>
            <div class="hex-display">
                <strong>Hex:</strong> {hex_message}
            </div>
        </div>
        
        <div class="wallet-selector">
            <label class="wallet-label">🌐 Select Wallet:</label>
            <div class="wallet-buttons">
                <button class="wallet-btn" data-wallet="nami">Nami</button>
                <button class="wallet-btn" data-wallet="eternl">Eternl</button>
                <button class="wallet-btn" data-wallet="flint">Flint</button>
                <button class="wallet-btn" data-wallet="yoroi">Yoroi</button>
            </div>
        </div>
        
        <div class="button-group">
            <button id="signBtn" class="sign-btn">✅ Sign Message</button>
            <button id="cancelBtn">Cancel</button>
        </div>
        
        <div id="status" class="status"></div>
        
        <div id="signatureBox" class="signature-box">
            <div class="message-label">✓ Signature (Base64):</div>
            <div class="signature-value" id="signatureValue"></div>
            <button class="copy-btn" id="copyBtn">📋 Copy Signature</button>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/@meshsdk/core@latest/dist/index.js"></script>
    <script>
        const {{ BrowserWallet }} = window.MeshSDK;
        let selectedWallet = null;
        
        // Wallet selection
        document.querySelectorAll('.wallet-btn').forEach(btn => {{
            btn.addEventListener('click', () => {{
                document.querySelectorAll('.wallet-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                selectedWallet = btn.dataset.wallet;
            }});
        }});
        
        // Sign button
        document.getElementById('signBtn').addEventListener('click', async () => {{
            if (!selectedWallet) {{
                showStatus('Please select a wallet', 'error');
                return;
            }}
            
            try {{
                showStatus('Connecting wallet...', 'info');
                
                const wallet = await BrowserWallet.enable(selectedWallet);
                const address = await wallet.getChangeAddress();
                const message = new TextEncoder().encode("{message}");
                
                showStatus('Signing message...', 'info');
                const signature = await wallet.signMessage(address, message);
                
                showStatus('Signature created!', 'success');
                
                // Display signature
                document.getElementById('signatureValue').textContent = signature;
                document.getElementById('signatureBox').classList.add('show');
                
                // Send to server
                await fetch('/api/sign', {{
                    method: 'POST',
                    headers: {{'Content-Type': 'application/json'}},
                    body: JSON.stringify({{
                        signature: signature,
                        address: address,
                        wallet: selectedWallet
                    }})
                }});
            }} catch (error) {{
                showStatus('Error: ' + error.message, 'error');
            }}
        }});
        
        // Copy button
        document.getElementById('copyBtn').addEventListener('click', () => {{
            const sig = document.getElementById('signatureValue').textContent;
            navigator.clipboard.writeText(sig).then(() => {{
                showStatus('Copied to clipboard!', 'success');
            }});
        }});
        
        // Cancel button
        document.getElementById('cancelBtn').addEventListener('click', () => {{
            window.close();
        }});
        
        function showStatus(msg, type) {{
            const status = document.getElementById('status');
            status.textContent = msg;
            status.className = 'status ' + type;
        }}
    </script>
</body>
</html>
        """
        return html
    
    def start(self, message: str, timeout_seconds: int = 300) -> Optional[Dict]:
        """
        Start web server and wait for signature
        
        Args:
            message: Message to sign
            timeout_seconds: Max wait time
            
        Returns:
            Signature result or None
        """
        self.message_to_sign = message
        self.is_complete = False
        self.signature_result = None
        
        print(f"[*] Starting signing server on port {self.port}...")
        
        # Start server in background thread
        def run_server():
            uvicorn.run(self.app, host="0.0.0.0", port=self.port, log_level="critical")
        
        server_thread = threading.Thread(target=run_server, daemon=True)
        server_thread.start()
        
        # Wait for server to start
        import time
        time.sleep(2)
        
        # Open browser
        url = f"http://localhost:{self.port}"
        print(f"✓ Opening browser: {url}")
        webbrowser.open(url)
        
        # Wait for signature
        start_time = datetime.now()
        while (datetime.now() - start_time).total_seconds() < timeout_seconds:
            if self.is_complete:
                print("✓ Signature received!")
                return self.signature_result
            
            import time
            time.sleep(0.5)
        
        print("✗ Timeout: No signature received")
        return None
