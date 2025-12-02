# ============================================
# END-USER-APP: Web-based Message Signing
# ============================================
# Sign Cardano messages through browser with Yoroi wallet integration

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Net.Http
Add-Type -AssemblyName System.Web

# Global variables
$script:WebServerPort = 8888
$script:WebServer = $null
$script:SignatureResult = $null
$script:IsSigningComplete = $false

function Start-SigningWebServer {
    param(
        [string]$Message = ""
    )
    
    Write-Host "`n📡 Khởi động server ký..." -ForegroundColor Yellow
    Write-Host "Message: $Message" -ForegroundColor Cyan
    Write-Host "Đang lắng nghe trên http://localhost:$script:WebServerPort" -ForegroundColor Cyan
    
    # Store message in script scope
    $script:MessageToSign = $Message
    
    # Create HTTP listener
    $script:WebServer = [System.Net.HttpListener]::new()
    $script:WebServer.Prefixes.Add("http://localhost:$script:WebServerPort/")
    
    try {
        $script:WebServer.Start()
        Write-Host "✓ Server khởi động thành công" -ForegroundColor Green
    } catch {
        Write-Host "✗ Lỗi khởi động server: $_" -ForegroundColor Red
        return $null
    }
    
    # Start listening in background
    $asyncResult = $script:WebServer.BeginGetContext($null, $null)
    
    # Generate HTML page - pass stored message
    $htmlContent = Get-SigningPageHTML -Message $script:MessageToSign
    
    # Open browser
    Start-Process "http://localhost:$script:WebServerPort"
    Write-Host "✓ Mở trình duyệt" -ForegroundColor Green
    Write-Host "⏳ Đang chờ chữ ký (tối đa 5 phút)..." -ForegroundColor Yellow
    
    $timeout = [DateTime]::Now.AddMinutes(5)
    $script:IsSigningComplete = $false
    $script:SignatureResult = $null
    
    # Wait for requests
    while ([DateTime]::Now -lt $timeout) {
        if ($asyncResult.IsCompleted) {
            try {
                $context = $script:WebServer.EndGetContext($asyncResult)
                $request = $context.Request
                $response = $context.Response
                
                # Log request
                Write-Host "📨 $($request.HttpMethod) $($request.RawUrl)" -ForegroundColor Gray
                
                # Handle different routes
                if ($request.RawUrl -eq "/") {
                    # Serve HTML page
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($htmlContent)
                    $response.ContentLength64 = $bytes.Length
                    $response.OutputStream.Write($bytes, 0, $bytes.Length)
                    $response.OutputStream.Close()
                    
                } elseif ($request.RawUrl -eq "/api/sign") {
                    # Handle signature submission
                    if ($request.HttpMethod -eq "POST") {
                        $reader = [System.IO.StreamReader]::new($request.InputStream)
                        $body = $reader.ReadToEnd()
                        $reader.Close()
                        
                        $json = ConvertFrom-Json $body
                        
                        if ($json.signature) {
                            Write-Host "✓ Nhận được chữ ký!" -ForegroundColor Green
                            $script:SignatureResult = $json
                            $script:IsSigningComplete = $true
                            
                            # Send success response
                            $successResponse = @{
                                status = "success"
                                message = "Nhận chữ ký thành công"
                            } | ConvertTo-Json
                            
                            $bytes = [System.Text.Encoding]::UTF8.GetBytes($successResponse)
                            $response.ContentType = "application/json"
                            $response.ContentLength64 = $bytes.Length
                            $response.OutputStream.Write($bytes, 0, $bytes.Length)
                        } else {
                            $errorResponse = @{
                                status = "error"
                                message = "Không có chữ ký"
                            } | ConvertTo-Json
                            
                            $bytes = [System.Text.Encoding]::UTF8.GetBytes($errorResponse)
                            $response.StatusCode = 400
                            $response.ContentType = "application/json"
                            $response.ContentLength64 = $bytes.Length
                            $response.OutputStream.Write($bytes, 0, $bytes.Length)
                        }
                    }
                    $response.OutputStream.Close()
                    
                } else {
                    # 404
                    $response.StatusCode = 404
                    $response.OutputStream.Close()
                }
                
                # Check if signing is complete
                if ($script:IsSigningComplete) {
                    Write-Host "✓ Hoàn tất ký!" -ForegroundColor Green
                    break
                }
                
                # Start listening again
                $asyncResult = $script:WebServer.BeginGetContext($null, $null)
                
            } catch {
                Write-Host "⚠ Lỗi xử lý request: $_" -ForegroundColor Yellow
                $asyncResult = $script:WebServer.BeginGetContext($null, $null)
            }
        }
        
        Start-Sleep -Milliseconds 500
    }
    
    # Cleanup
    Stop-SigningWebServer
    
    if ($script:SignatureResult) {
        return $script:SignatureResult
    } else {
        Write-Host "✗ Hết thời gian: Không nhận được chữ ký trong 5 phút" -ForegroundColor Red
        return $null
    }
}

function Stop-SigningWebServer {
    if ($script:WebServer) {
        try {
            $script:WebServer.Stop()
            $script:WebServer.Close()
            $script:WebServer.Dispose()
            $script:WebServer = $null
            Write-Host "✓ Server stopped" -ForegroundColor Green
        } catch {
            Write-Host "⚠ Error stopping server: $_" -ForegroundColor Yellow
        }
    }
}

function Get-SigningPageHTML {
    param(
        [string]$Message = ""
    )
    
    Write-Host "DEBUG: Message passed to HTML: $Message" -ForegroundColor Magenta
    
    # Convert message to hex
    $messageBytes = [System.Text.Encoding]::UTF8.GetBytes($Message)
    $hexMessage = ($messageBytes | ForEach-Object { $_.ToString("x2") }) -join ""
    
    # Escape message for HTML - CRITICAL for JavaScript
    $MessageEscaped = [System.Web.HttpUtility]::HtmlEncode($Message)
    $hexMessageEscaped = [System.Web.HttpUtility]::HtmlEncode($hexMessage)
    
    Write-Host "DEBUG: Escaped Message: $MessageEscaped" -ForegroundColor Magenta
    Write-Host "DEBUG: Hex Message: $hexMessageEscaped" -ForegroundColor Magenta
    
    $html = @"
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ký Thông Điệp Cardano</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1e1e2e 0%, #2d2d3d 100%);
            color: #e0e0e0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container {
            background: #2d2d3d;
            border: 2px solid #00ffff;
            border-radius: 12px;
            padding: 40px;
            max-width: 700px;
            width: 100%;
            box-shadow: 0 0 30px rgba(0, 255, 255, 0.4);
        }
        h1 {
            color: #00ffff;
            margin-bottom: 10px;
            text-align: center;
            font-size: 28px;
            font-weight: 700;
        }
        .subtitle {
            color: #00ff00;
            text-align: center;
            margin-bottom: 30px;
            font-size: 14px;
            font-weight: 500;
        }
        .message-box {
            background: #1e1e2e;
            border: 1px solid #00ff00;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .message-label {
            color: #00ffff;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .message-content {
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
        }
        .hex-display {
            margin-top: 12px;
            padding-top: 12px;
            border-top: 1px solid #00aa00;
        }
        .hex-label {
            color: #888;
            font-size: 11px;
            margin-bottom: 5px;
        }
        .hex-value {
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
        }
        .info-box {
            background: #1e2a3a;
            border-left: 4px solid #0077ff;
            padding: 15px;
            margin-bottom: 25px;
            border-radius: 4px;
            font-size: 13px;
            color: #aaa;
        }
        .wallet-selector {
            margin-bottom: 20px;
        }
        .wallet-label {
            color: #00ffff;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 12px;
            display: block;
        }
        .wallet-buttons {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }
        .wallet-btn {
            padding: 12px;
            border: 2px solid #00ffff;
            border-radius: 6px;
            background: #1e1e2e;
            color: #00ffff;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .wallet-btn:hover:not(:disabled) {
            background: #00ffff;
            color: #1e1e2e;
            box-shadow: 0 0 15px rgba(0, 255, 255, 0.5);
        }
        .wallet-btn:disabled {
            opacity: 0.3;
            cursor: not-allowed;
        }
        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        .sign-btn {
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
        }
        .sign-btn:hover:not(:disabled) {
            background: #00ff00;
            box-shadow: 0 0 20px rgba(0, 255, 0, 0.6);
        }
        .sign-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        #cancelBtn {
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
        }
        #cancelBtn:hover {
            background: #555;
        }
        .status {
            margin-top: 20px;
            padding: 15px;
            border-radius: 6px;
            font-size: 13px;
            text-align: center;
            display: none;
            animation: slideIn 0.3s ease;
        }
        .status.success {
            background: #1e3a1e;
            border: 1px solid #00aa00;
            color: #00ff00;
            display: block;
        }
        .status.error {
            background: #3a1e1e;
            border: 1px solid #aa0000;
            color: #ff6666;
            display: block;
        }
        .status.info {
            background: #1e2a3a;
            border: 1px solid #0077ff;
            color: #88ccff;
            display: block;
        }
        .spinner {
            display: inline-block;
            width: 12px;
            height: 12px;
            border: 2px solid #666;
            border-top-color: #00ffff;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
            margin-right: 8px;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        @keyframes slideIn {
            from { transform: translateY(-10px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        .signature-box {
            background: #1e1e2e;
            border: 1px solid #00ff00;
            padding: 15px;
            margin-top: 20px;
            border-radius: 6px;
            display: none;
        }
        .signature-box.show {
            display: block;
        }
        .signature-label {
            color: #00ffff;
            font-size: 12px;
            margin-bottom: 8px;
        }
        .signature-value {
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
        }
        .copy-btn {
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
        }
        .copy-btn:hover {
            background: #444;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 Ký Thông Điệp Cardano</h1>
        <div class="subtitle">Ký thông điệp bằng ví Cardano của bạn</div>
        
        <div class="message-box">
            <div class="message-label">📝 Thông Điệp:</div>
            <div class="message-content">$MessageEscaped</div>
            <div class="hex-display">
                <div class="hex-label">Hex (dùng để ký):</div>
                <div class="hex-value">$hexMessageEscaped</div>
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
    
    <script src="https://cdn.jsdelivr.net/npm/@meshsdk/core@latest/dist/index.js"></script>
    <script>
        // Initialize Mesh SDK
        const { BrowserWallet } = window.MeshSDK;
        
        // Debug: Check if message loaded
        console.log('Page loaded');
        console.log('Message Escaped: $MessageEscaped');
        console.log('Hex Escaped: $hexMessageEscaped');
        console.log('Mesh SDK loaded:', !!window.MeshSDK);
        
        // Decode HTML entities for proper display
        function decodeHtmlEntity(str) {
            const textarea = document.createElement('textarea');
            textarea.innerHTML = str;
            return textarea.value;
        }
        
        // Set message content from escaped values
        const MESSAGE_ENCODED = '$MessageEscaped';
        const HEX_MESSAGE_ENCODED = '$hexMessageEscaped';
        
        const MESSAGE = decodeHtmlEntity(MESSAGE_ENCODED);
        const HEX_MESSAGE = decodeHtmlEntity(HEX_MESSAGE_ENCODED);
        
        console.log('Final MESSAGE:', MESSAGE);
        console.log('Final HEX_MESSAGE:', HEX_MESSAGE);
        
        function showStatus(message, type) {
            const statusEl = document.getElementById('status');
            statusEl.innerHTML = message;
            statusEl.className = 'status ' + type;
        }
        
        async function detectWallets() {
            const wallets = [];
            console.log('Detecting wallets using BrowserWallet...');
            
            try {
                const availableWallets = BrowserWallet.getAvailableWallets();
                console.log('Available wallets:', availableWallets);
                
                if (availableWallets && availableWallets.length > 0) {
                    availableWallets.forEach(wallet => {
                        console.log('✓ Wallet detected:', wallet.name);
                        wallets.push({
                            name: wallet.name,
                            key: wallet.name.toLowerCase(),
                            icon: wallet.icon || '💼'
                        });
                    });
                } else {
                    console.log('No wallets found via BrowserWallet');
                    // Fallback: check window.cardano directly
                    if (window.cardano) {
                        if (window.cardano.yoroi) wallets.push({ name: 'Yoroi', key: 'yoroi', icon: '🦊' });
                        if (window.cardano.nami) wallets.push({ name: 'Nami', key: 'nami', icon: '🔐' });
                        if (window.cardano.eternl) wallets.push({ name: 'Eternl', key: 'eternl', icon: '♾️' });
                        if (window.cardano.lace) wallets.push({ name: 'Lace', key: 'lace', icon: '✨' });
                    }
                }
            } catch (e) {
                console.error('Error detecting wallets:', e);
                // Fallback
                if (window.cardano) {
                    if (window.cardano.yoroi) wallets.push({ name: 'Yoroi', key: 'yoroi', icon: '🦊' });
                    if (window.cardano.nami) wallets.push({ name: 'Nami', key: 'nami', icon: '🔐' });
                    if (window.cardano.eternl) wallets.push({ name: 'Eternl', key: 'eternl', icon: '♾️' });
                    if (window.cardano.lace) wallets.push({ name: 'Lace', key: 'lace', icon: '✨' });
                }
            }
            
            console.log('Total wallets found:', wallets.length);
            return wallets;
        }
        
        async function createWalletButtons() {
            const wallets = await detectWallets();
            const container = document.getElementById('walletButtons');
            
            if (wallets.length === 0) {
                container.innerHTML = '<p style="color: #ff6666; grid-column: 1/-1; text-align: center;">❌ Không tìm thấy ví. Vui lòng cài đặt: Yoroi, Nami, Eternl hoặc Lace.</p>';
                console.warn('No wallets detected');
                return;
            }
            
            // Create buttons for each wallet
            wallets.forEach(wallet => {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'wallet-btn';
                btn.textContent = wallet.icon + ' ' + wallet.name;
                btn.addEventListener('click', () => {
                    console.log('Selected wallet:', wallet.key);
                    signWithWallet(wallet.key);
                });
                container.appendChild(btn);
                console.log('Created button for:', wallet.name);
            });
        }
        
        async function signWithWallet(walletKey) {
            try {
                showStatus('<span class="spinner"></span> Đang kết nối ' + walletKey + '...', 'info');
                console.log('Signing with wallet:', walletKey);
                
                let walletAPI = null;
                
                try {
                    // Use BrowserWallet from Mesh SDK
                    const browserWallet = new BrowserWallet({ name: walletKey });
                    walletAPI = await browserWallet.enable();
                    console.log('✓ Wallet enabled via Mesh SDK:', walletKey);
                    console.log('Wallet API methods:', Object.keys(walletAPI));
                } catch (e) {
                    console.log('Mesh SDK enable failed, trying direct wallet access...');
                    // Fallback: direct wallet access
                    if (!window.cardano || !window.cardano[walletKey]) {
                        showStatus('❌ Ví ' + walletKey + ' không tìm thấy.', 'error');
                        console.error('Wallet not found:', walletKey);
                        return;
                    }
                    
                    try {
                        walletAPI = await window.cardano[walletKey].enable();
                        console.log('✓ Wallet enabled via direct access:', walletKey);
                    } catch (e2) {
                        showStatus('❌ Lỗi kích hoạt ' + walletKey + ': ' + e2.message, 'error');
                        console.error('Enable error:', e2);
                        return;
                    }
                }
                
                showStatus('<span class="spinner"></span> Đang lấy địa chỉ từ ví ' + walletKey + '...', 'info');
                
                let addresses = [];
                try {
                    // Try getUsedAddresses first (CIP-30 standard)
                    const usedAddrs = await walletAPI.getUsedAddresses();
                    console.log('Raw addresses from getUsedAddresses:', usedAddrs);
                    
                    if (usedAddrs && usedAddrs.length > 0) {
                        addresses = Array.isArray(usedAddrs) ? usedAddrs : [usedAddrs];
                        console.log('✓ Got used addresses:', addresses.length);
                        console.log('First address (Bech32):', addresses[0]);
                    } else {
                        // Fallback: try getRewardAddresses
                        console.log('getUsedAddresses empty, trying getRewardAddresses...');
                        try {
                            const rewardAddrs = await walletAPI.getRewardAddresses();
                            console.log('Addresses from getRewardAddresses:', rewardAddrs);
                            
                            if (rewardAddrs && rewardAddrs.length > 0) {
                                addresses = Array.isArray(rewardAddrs) ? rewardAddrs : [rewardAddrs];
                                console.log('✓ Got reward addresses:', addresses.length);
                            }
                        } catch (e2) {
                            console.log('getRewardAddresses failed, trying getChangeAddress...');
                            try {
                                const changeAddr = await walletAPI.getChangeAddress();
                                console.log('Address from getChangeAddress:', changeAddr);
                                
                                if (changeAddr) {
                                    addresses = [changeAddr];
                                    console.log('✓ Got change address');
                                }
                            } catch (e3) {
                                console.error('All address methods failed:', {
                                    getUsedAddresses: 'empty',
                                    getRewardAddresses: e2.message,
                                    getChangeAddress: e3.message
                                });
                            }
                        }
                    }
                } catch (e) {
                    showStatus('❌ Không thể lấy địa chỉ từ ' + walletKey + ': ' + e.message, 'error');
                    console.error('Address error:', e);
                    console.error('Error stack:', e.stack);
                    return;
                }
                
                if (!addresses || addresses.length === 0) {
                    showStatus('❌ Ví ' + walletKey + ' không có địa chỉ. Vui lòng tạo ít nhất 1 địa chỉ trong ví.', 'error');
                    console.error('No addresses found in wallet');
                    return;
                }
                
                const address = addresses[0];
                console.log('✓ Using address:', address);
                showStatus('<span class="spinner"></span> Đang ký thông điệp với ' + walletKey + '...', 'info');
                
                let signature = null;
                try {
                    console.log('Calling signData with:');
                    console.log('  - Address:', address);
                    console.log('  - Hex Message:', HEX_MESSAGE);
                    console.log('  - Message length:', HEX_MESSAGE.length);
                    
                    signature = await walletAPI.signData(address, HEX_MESSAGE);
                    console.log('✓ Signature received:', signature);
                    console.log('  - signature.signature:', signature.signature ? signature.signature.substring(0, 50) + '...' : 'N/A');
                    console.log('  - signature.key:', signature.key ? signature.key.substring(0, 50) + '...' : 'N/A');
                } catch (e) {
                    showStatus('❌ Lỗi ký thông điệp: ' + e.message, 'error');
                    console.error('Sign error:', e);
                    console.error('Error details:', {
                        name: e.name,
                        message: e.message,
                        code: e.code,
                        stack: e.stack
                    });
                    return;
                }
                
                if (!signature || !signature.signature) {
                    showStatus('❌ Không thể ký thông điệp. Response: ' + JSON.stringify(signature), 'error');
                    console.error('Invalid signature response:', signature);
                    return;
                }
                
                document.getElementById('signatureValue').textContent = signature.signature;
                document.getElementById('signatureBox').classList.add('show');
                showStatus('✓ Ký thành công bằng ' + walletKey + '!', 'success');
                console.log('✓ Signature display updated');
                
                try {
                    const payload = {
                        message: MESSAGE,
                        hexMessage: HEX_MESSAGE,
                        address: address,
                        signature: signature.signature,
                        key: signature.key,
                        wallet: walletKey,
                        timestamp: new Date().toISOString()
                    };
                    
                    console.log('Sending to server:', payload);
                    
                    const response = await fetch('/api/sign', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(payload)
                    });
                    
                    console.log('✓ Signature sent to server, response status:', response.status);
                    
                    setTimeout(() => {
                        showStatus('✓ Chữ ký đã gửi! Bạn có thể đóng cửa sổ này.', 'success');
                    }, 1000);
                } catch (e) {
                    console.error('Send error:', e);
                    showStatus('⚠️ Ký thành công nhưng lỗi gửi dữ liệu: ' + e.message, 'error');
                }
                
            } catch (error) {
                console.error('Unexpected error:', error);
                showStatus('❌ Lỗi: ' + error.message, 'error');
            }
        }
        
        document.getElementById('cancelBtn').addEventListener('click', () => {
            if (confirm('Bạn có chắc muốn hủy không?')) {
                window.close();
            }
        });
        
        document.getElementById('signBtn').addEventListener('click', async () => {
            showStatus('<span class="spinner"></span> Đang tìm tất cả ví...', 'info');
            console.log('Sign button clicked');
            
            const wallets = await detectWallets();
            console.log('Detected wallets:', wallets.map(w => w.name));
            
            if (wallets.length === 0) {
                showStatus('❌ Không tìm thấy ví nào. Vui lòng cài đặt: Yoroi, Nami, Eternl hoặc Lace.', 'error');
                return;
            }
            
            // Show message about available wallets
            const walletNames = wallets.map(w => w.name).join(', ');
            showStatus('<span class="spinner"></span> Tìm thấy: ' + walletNames + '. Đang kết nối...', 'info');
            
            // Auto-sign with first found wallet
            if (wallets.length > 0) {
                const firstWallet = wallets[0];
                console.log('Auto-signing with first wallet:', firstWallet.name);
                await signWithWallet(firstWallet.key);
            }
        });
        
        document.getElementById('copyBtn').addEventListener('click', () => {
            const signature = document.getElementById('signatureValue').textContent;
            navigator.clipboard.writeText(signature).then(() => {
                showStatus('✓ Sao chép thành công!', 'success');
            });
        });
        
        // Initialize: detect and show ALL wallets at page load
        window.addEventListener('load', async () => {
            console.log('Window loaded, detecting wallets...');
            const wallets = await detectWallets();
            console.log('Wallets at load:', wallets.map(w => w.name));
            
            if (wallets.length > 0) {
                showStatus('✓ Tìm thấy ' + wallets.length + ' ví: ' + wallets.map(w => w.name).join(', '), 'success');
            } else {
                showStatus('⚠️ Chưa tìm thấy ví. Nếu bạn có ví Cardano, hãy làm mới trang.', 'info');
            }
            
            createWalletButtons();
        });
    </script>
</body>
</html>
"@
    
    return $html
}

function Sign-MessageWeb {
    param(
        [string]$Message = ""
    )
    
    Write-Host "`n========== Ký Thông Điệp Qua Ví ==========" -ForegroundColor Cyan
    
    # If message not provided, ask user
    if ([string]::IsNullOrEmpty($Message)) {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Nhập Thông Điệp Cần Ký"
        $form.Size = New-Object System.Drawing.Size(550, 350)
        $form.StartPosition = "CenterScreen"
        $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
        $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
        $form.MaximizeBox = $false
        
        $lblTitle = New-Object System.Windows.Forms.Label
        $lblTitle.Text = "📝 Nhập thông điệp cần ký:"
        $lblTitle.AutoSize = $true
        $lblTitle.ForeColor = [System.Drawing.Color]::Cyan
        $lblTitle.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
        $lblTitle.Location = New-Object System.Drawing.Point(15, 15)
        $form.Controls.Add($lblTitle)
        
        $txtMessage = New-Object System.Windows.Forms.TextBox
        $txtMessage.Multiline = $true
        $txtMessage.Size = New-Object System.Drawing.Size(510, 200)
        $txtMessage.Location = New-Object System.Drawing.Point(15, 45)
        $txtMessage.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
        $txtMessage.ForeColor = [System.Drawing.Color]::Lime
        $txtMessage.Font = New-Object System.Drawing.Font("Courier New", 10)
        $txtMessage.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        $form.Controls.Add($txtMessage)
        
        $btnOK = New-Object System.Windows.Forms.Button
        $btnOK.Text = "Tiếp Tục"
        $btnOK.Size = New-Object System.Drawing.Size(100, 35)
        $btnOK.Location = New-Object System.Drawing.Point(300, 260)
        $btnOK.BackColor = [System.Drawing.Color]::FromArgb(50, 120, 180)
        $btnOK.ForeColor = [System.Drawing.Color]::White
        $btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Controls.Add($btnOK)
        
        $btnCancel = New-Object System.Windows.Forms.Button
        $btnCancel.Text = "Hủy"
        $btnCancel.Size = New-Object System.Drawing.Size(100, 35)
        $btnCancel.Location = New-Object System.Drawing.Point(410, 260)
        $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
        $btnCancel.ForeColor = [System.Drawing.Color]::White
        $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.Controls.Add($btnCancel)
        
        $result = $form.ShowDialog()
        $Message = $txtMessage.Text.Trim()
        $form.Dispose()
        
        if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
            Write-Host "✗ Bị hủy bởi người dùng" -ForegroundColor Yellow
            return $null
        }
    }
    
    if ([string]::IsNullOrEmpty($Message)) {
        Write-Host "✗ Thông điệp không được trống" -ForegroundColor Red
        return $null
    }
    
    Write-Host "✓ Thông điệp: $Message" -ForegroundColor Green
    
    # Start web server with message
    $result = Start-SigningWebServer -Message $Message
    
    if ($result) {
        Write-Host "`n✓ Ký thành công!" -ForegroundColor Green
        Write-Host "Thông điệp: $($result.message)" -ForegroundColor Cyan
        Write-Host "Chữ ký: $($result.signature)" -ForegroundColor Green
        Write-Host "Ví: $($result.wallet)" -ForegroundColor Yellow
        
        return @{
            Message = $result.message
            HexMessage = $result.hexMessage
            Address = $result.address
            Signature = $result.signature
            Key = $result.key
            Wallet = $result.wallet
            Timestamp = $result.timestamp
        }
    } else {
        Write-Host "✗ Ký thất bại hoặc bị hủy" -ForegroundColor Red
        return $null
    }
}

# Cleanup on script exit
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Stop-SigningWebServer -ErrorAction SilentlyContinue
} -ErrorAction SilentlyContinue
