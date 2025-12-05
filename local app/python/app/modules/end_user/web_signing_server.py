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
        """Generate HTML signing page with auto-detect wallets"""
        message = self.message_to_sign or ""
        
        # Convert message to hex
        hex_message = message.encode().hex()
        
        html = f"""
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ký Thông Điệp Cardano</title>
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
            margin-bottom: 10px;
            text-align: center;
            font-size: 28px;
            font-weight: 700;
        }}
        .subtitle {{
            color: #00ff00;
            text-align: center;
            margin-bottom: 30px;
            font-size: 14px;
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
            font-size: 14px;
            background: #161620;
            padding: 12px;
            border-radius: 4px;
            border: 1px solid #00aa00;
            word-wrap: break-word;
            max-height: 150px;
            overflow-y: auto;
            line-height: 1.4;
        }}
        .hex-display {{
            margin-top: 12px;
            padding-top: 12px;
            border-top: 1px solid #00aa00;
        }}
        .hex-label {{
            color: #888;
            font-size: 11px;
            margin-bottom: 5px;
        }}
        .hex-value {{
            color: #888;
            font-family: 'Courier New', monospace;
            font-size: 11px;
            background: #161620;
            padding: 8px;
            border-radius: 4px;
            border: 1px solid #444;
            word-wrap: break-word;
            max-height: 80px;
            overflow-y: auto;
        }}
        .info-box {{
            background: #1e2a3a;
            border-left: 4px solid #0077ff;
            padding: 15px;
            margin-bottom: 25px;
            border-radius: 4px;
            font-size: 13px;
            color: #aaa;
        }}
        .wallet-selector {{
            margin-bottom: 20px;
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
            min-height: 40px;
        }}
        .wallet-btn:hover:not(:disabled) {{
            background: #00ffff;
            color: #1e1e2e;
            box-shadow: 0 0 15px rgba(0, 255, 255, 0.5);
        }}
        .wallet-btn:disabled {{
            opacity: 0.3;
            cursor: not-allowed;
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
            transition: all 0.3s ease;
        }}
        #cancelBtn:hover {{
            background: #555;
        }}
        .status {{
            margin-top: 20px;
            padding: 15px;
            border-radius: 6px;
            font-size: 13px;
            text-align: center;
            display: none;
            animation: slideIn 0.3s ease;
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
        @keyframes slideIn {{
            from {{ transform: translateY(-10px); opacity: 0; }}
            to {{ transform: translateY(0); opacity: 1; }}
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
        .signature-label {{
            color: #00ffff;
            font-size: 12px;
            margin-bottom: 8px;
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
        .no-wallets {{
            color: #ff6666;
            grid-column: 1/-1;
            text-align: center;
            padding: 15px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 Ký Thông Điệp Cardano</h1>
        <div class="subtitle">Ký thông điệp bằng ví Cardano của bạn</div>
        
        <div class="message-box">
            <div class="message-label">📝 Thông Điệp:</div>
            <div class="message-content">{message}</div>
            <div class="hex-display">
                <div class="hex-label">Hex (dùng để ký):</div>
                <div class="hex-value">{hex_message}</div>
            </div>
        </div>
        
        <div class="info-box">
            <strong>ℹ️ Hướng Dẫn:</strong> Nhấp vào nút ví bên dưới để chọn ví của bạn, sau đó ký thông điệp.
        </div>
        
        <div class="wallet-selector">
            <label class="wallet-label">🌐 Chọn Ví:</label>
            <div class="wallet-buttons" id="walletButtons">
                <!-- Buttons will be generated by JS -->
            </div>
        </div>
        
        <div class="button-group">
            <button id="signBtn" class="sign-btn">✅ Ký Thông Điệp</button>
            <button id="cancelBtn">Hủy</button>
        </div>
        
        <div id="status" class="status"></div>
        
        <div id="signatureBox" class="signature-box">
            <div class="signature-label">✓ Chữ Ký (Base64):</div>
            <div class="signature-value" id="signatureValue"></div>
            <button class="copy-btn" id="copyBtn">📋 Sao Chép Chữ Ký</button>
        </div>
    </div>
    
    <script>
        // Auto-detect installed wallets
        const walletConfig = {{
            'yoroi': {{'name': 'Yoroi', 'icon': '🦊', 'enabled': false}},
            'nami': {{'name': 'Nami', 'icon': '🔐', 'enabled': false}},
            'eternl': {{'name': 'Eternl', 'icon': '♾️', 'enabled': false}},
            'lace': {{'name': 'Lace', 'icon': '✨', 'enabled': false}},
            'flint': {{'name': 'Flint', 'icon': '🎯', 'enabled': false}},
            'typhon': {{'name': 'Typhon', 'icon': '⚡', 'enabled': false}}
        }};
        
        let selectedWallet = null;
        
        function showStatus(message, type) {{
            const statusEl = document.getElementById('status');
            statusEl.innerHTML = message;
            statusEl.className = 'status ' + type;
        }}
        
        async function detectWallets() {{
            console.log('Detecting wallets...');
            const detected = [];
            
            for (const [key, config] of Object.entries(walletConfig)) {{
                if (window.cardano && window.cardano[key]) {{
                    console.log('✓ Found wallet:', key);
                    detected.push({{
                        key: key,
                        name: config.name,
                        icon: config.icon
                    }});
                }}
            }}
            
            console.log('Total wallets detected:', detected.length);
            return detected;
        }}
        
        async function createWalletButtons() {{
            const wallets = await detectWallets();
            const container = document.getElementById('walletButtons');
            
            if (wallets.length === 0) {{
                container.innerHTML = '<div class="no-wallets">❌ Không tìm thấy ví Cardano. Vui lòng cài đặt: Yoroi, Nami, Eternl, Lace, Flint hoặc Typhon.</div>';
                console.warn('No wallets detected');
                return;
            }}
            
            wallets.forEach(wallet => {{
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'wallet-btn';
                btn.textContent = wallet.icon + ' ' + wallet.name;
                btn.dataset.wallet = wallet.key;
                btn.addEventListener('click', () => {{
                    console.log('Selected wallet:', wallet.key);
                    document.querySelectorAll('.wallet-btn').forEach(b => b.style.opacity = '0.5');
                    btn.style.opacity = '1';
                    selectedWallet = wallet.key;
                }});
                container.appendChild(btn);
            }});
        }}
        
        async function signWithWallet(walletKey) {{
            try {{
                showStatus('<span class="spinner"></span> Đang kết nối ' + walletKey + '...', 'info');
                console.log('Signing with wallet:', walletKey);
                
                if (!window.cardano || !window.cardano[walletKey]) {{
                    showStatus('❌ Ví ' + walletKey + ' không tìm thấy', 'error');
                    return;
                }}
                
                const walletAPI = await window.cardano[walletKey].enable();
                console.log('✓ Wallet enabled');
                
                showStatus('<span class="spinner"></span> Đang lấy địa chỉ...', 'info');
                
                const addresses = await walletAPI.getUsedAddresses();
                if (!addresses || addresses.length === 0) {{
                    showStatus('❌ Ví không có địa chỉ', 'error');
                    return;
                }}
                
                const address = addresses[0];
                console.log('Using address:', address);
                
                showStatus('<span class="spinner"></span> Đang ký thông điệp...', 'info');
                
                // Sign data with hex message
                const signature = await walletAPI.signData(address, '{hex_message}');
                console.log('Signature received:', signature);
                
                if (!signature.signature) {{
                    showStatus('❌ Lỗi ký thông điệp', 'error');
                    return;
                }}
                
                // Display signature
                document.getElementById('signatureValue').textContent = signature.signature;
                document.getElementById('signatureBox').classList.add('show');
                showStatus('✓ Ký thành công bằng ' + walletKey + '!', 'success');
                
                // Send to server
                try {{
                    const response = await fetch('/api/sign', {{
                        method: 'POST',
                        headers: {{'Content-Type': 'application/json'}},
                        body: JSON.stringify({{
                            signature: signature.signature,
                            address: address,
                            wallet: walletKey
                        }})
                    }});
                    console.log('Signature sent to server');
                }} catch (e) {{
                    console.error('Send error:', e);
                }}
                
            }} catch (error) {{
                console.error('Error:', error);
                showStatus('❌ Lỗi: ' + error.message, 'error');
            }}
        }}
        
        // Event listeners
        document.getElementById('signBtn').addEventListener('click', async () => {{
            if (!selectedWallet) {{
                const wallets = await detectWallets();
                if (wallets.length === 0) {{
                    showStatus('❌ Không tìm thấy ví Cardano', 'error');
                    return;
                }}
                // Auto-sign with first wallet
                selectedWallet = wallets[0].key;
            }}
            
            await signWithWallet(selectedWallet);
        }});
        
        document.getElementById('cancelBtn').addEventListener('click', () => {{
            if (confirm('Bạn có chắc muốn hủy không?')) {{
                window.close();
            }}
        }});
        
        document.getElementById('copyBtn').addEventListener('click', () => {{
            const signature = document.getElementById('signatureValue').textContent;
            navigator.clipboard.writeText(signature).then(() => {{
                showStatus('✓ Sao chép thành công!', 'success');
            }});
        }});
        
        // Initialize on page load
        window.addEventListener('load', async () => {{
            console.log('Page loaded, creating wallet buttons...');
            const wallets = await detectWallets();
            if (wallets.length > 0) {{
                showStatus('✓ Tìm thấy ' + wallets.length + ' ví: ' + wallets.map(w => w.name).join(', '), 'success');
            }} else {{
                showStatus('⚠️ Chưa tìm thấy ví. Làm mới trang nếu bạn vừa cài ví.', 'info');
            }}
            createWalletButtons();
        }});
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
