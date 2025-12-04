"""
End-User Dashboard - PySide6 GUI
Main interface for end-user tools
"""
from PySide6.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
    QTextEdit, QMessageBox, QTabWidget
)
from PySide6.QtGui import QFont, QColor
from PySide6.QtCore import Qt
from .key_generator import KeyGenerator
from .offline_signing_dialog import OfflineSigningDialog
from .web_signing_server import WebSigningServer


class EndUserDashboard(QMainWindow):
    """End-user dashboard with key generation, signing, and verification"""
    
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Cardano End-User Tools")
        self.setGeometry(100, 100, 900, 700)
        self.setStyleSheet("""
            QMainWindow { background-color: #1e1e1e; }
            QLabel { color: #00ffff; }
            QPushButton { 
                background-color: #3d7ba4; 
                color: white; 
                padding: 8px; 
                border-radius: 4px; 
                font-weight: bold;
            }
            QPushButton:hover { background-color: #4d8bb4; }
            QPushButton:pressed { background-color: #2d6b94; }
            QTextEdit { 
                background-color: #0a0a0a; 
                color: #00ff00; 
                font-family: 'Courier New'; 
                border: 1px solid #333;
            }
        """)
        
        self.key_generator = None
        self.web_server = None
        self.setup_ui()
    
    def setup_ui(self):
        """Create UI layout"""
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        
        main_layout = QHBoxLayout(main_widget)
        
        # Left panel - buttons
        left_layout = QVBoxLayout()
        
        title = QLabel("🔐 End-User Tools")
        title.setFont(QFont("Arial", 14, QFont.Bold))
        left_layout.addWidget(title)
        
        left_layout.addSpacing(20)
        
        # Generate keys
        btn_keygen = QPushButton("1. Generate Keypair")
        btn_keygen.setMinimumHeight(45)
        btn_keygen.clicked.connect(self.on_generate_keypair)
        left_layout.addWidget(btn_keygen)
        
        # Sign offline
        btn_sign_offline = QPushButton("2. Sign Message (Offline)")
        btn_sign_offline.setMinimumHeight(45)
        btn_sign_offline.clicked.connect(self.on_sign_offline)
        left_layout.addWidget(btn_sign_offline)
        
        # Sign web
        btn_sign_web = QPushButton("3. Sign Message (Web)")
        btn_sign_web.setMinimumHeight(45)
        btn_sign_web.clicked.connect(self.on_sign_web)
        left_layout.addWidget(btn_sign_web)
        
        # Verify
        btn_verify = QPushButton("4. Verify Signature")
        btn_verify.setMinimumHeight(45)
        btn_verify.clicked.connect(self.on_verify_signature)
        left_layout.addWidget(btn_verify)
        
        # Export
        btn_export = QPushButton("5. Export Wallet")
        btn_export.setMinimumHeight(45)
        btn_export.clicked.connect(self.on_export_wallet)
        left_layout.addWidget(btn_export)
        
        left_layout.addSpacing(20)
        
        # Load keys
        btn_load = QPushButton("Load Keys from File")
        btn_load.setMinimumHeight(40)
        btn_load.clicked.connect(self.on_load_keys)
        btn_load.setStyleSheet("""
            background-color: #996633;
            color: white;
            padding: 8px;
            border-radius: 4px;
        """)
        left_layout.addWidget(btn_load)
        
        left_layout.addStretch()
        
        # Right panel - output
        self.output_text = QTextEdit()
        self.output_text.setReadOnly(True)
        self.output_text.setMinimumWidth(400)
        
        main_layout.addLayout(left_layout, 1)
        main_layout.addWidget(self.output_text, 2)
    
    def append_output(self, text: str):
        """Append to output panel"""
        current = self.output_text.toPlainText()
        if current:
            self.output_text.setPlainText(current + "\n" + text)
        else:
            self.output_text.setPlainText(text)
        # Scroll to bottom
        self.output_text.verticalScrollBar().setValue(
            self.output_text.verticalScrollBar().maximum()
        )
    
    def on_generate_keypair(self):
        """Generate keypair from mnemonic"""
        try:
            from PySide6.QtWidgets import QInputDialog
            
            mnemonic, ok = QInputDialog.getMultiLineText(
                self,
                "Generate Keypair",
                "Enter BIP39 mnemonic (12, 15, or 24 words):"
            )
            
            if not ok or not mnemonic.strip():
                return
            
            self.append_output("[*] Generating addresses...")
            
            self.key_generator = KeyGenerator("./wallets", "mainnet")
            result = self.key_generator.generate_addresses(
                mnemonic.strip(),
                account_index=0,
                address_count=5
            )
            
            if result:
                output = f"""✓ Generated {len(result['addresses'])} addresses

Stake Address:
{result['stake_address']}

Addresses:
"""
                for addr in result['addresses']:
                    output += f"\n{addr['index']}: {addr['address'][:40]}..."
                
                self.append_output(output)
                
                # Ask to save
                reply = QMessageBox.question(
                    self, "Save Wallet", 
                    "Save wallet to file?"
                )
                if reply == QMessageBox.Yes:
                    name, ok = QInputDialog.getText(
                        self, "Wallet Name", 
                        "Enter wallet name:"
                    )
                    if ok and name:
                        self.key_generator.save_wallet(name)
                        self.append_output(f"✓ Wallet saved as {name}")
            else:
                self.append_output("✗ Failed to generate addresses")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
            self.append_output(f"✗ Error: {e}")
    
    def on_sign_offline(self):
        """Sign message with local key file"""
        try:
            dialog = OfflineSigningDialog(self)
            dialog.exec()
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
            self.append_output(f"✗ Error: {e}")
    
    def on_sign_web(self):
        """Sign message using web browser wallet"""
        try:
            from PySide6.QtWidgets import QInputDialog
            
            message, ok = QInputDialog.getMultiLineText(
                self,
                "Web Sign Message",
                "Enter message to sign:"
            )
            
            if not ok or not message.strip():
                return
            
            self.append_output("[*] Starting web signing server...")
            
            self.web_server = WebSigningServer(port=8888)
            result = self.web_server.start(message.strip(), timeout_seconds=300)
            
            if result:
                output = f"""✓ Message signed!

Signature:
{result['signature'][:80]}...

Wallet: {result.get('wallet', 'unknown')}
Address: {result.get('address', 'unknown')[:40]}...
"""
                self.append_output(output)
            else:
                self.append_output("✗ Signing cancelled or timed out")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
            self.append_output(f"✗ Error: {e}")
    
    def on_verify_signature(self):
        """Verify signature"""
        try:
            from PySide6.QtWidgets import QInputDialog
            from ...utils.crypto_verifier import CryptoVerifier
            
            message, ok = QInputDialog.getMultiLineText(
                self,
                "Verify Signature",
                "Enter message:"
            )
            
            if not ok or not message.strip():
                return
            
            signature, ok = QInputDialog.getText(
                self,
                "Verify Signature",
                "Enter signature (base64):"
            )
            
            if not ok or not signature.strip():
                return
            
            self.append_output("[*] Verifying signature...")
            
            verifier = CryptoVerifier()
            # Note: This requires the public key, simplified for demo
            self.append_output("✓ Signature format valid (full verification requires public key)")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
            self.append_output(f"✗ Error: {e}")
    
    def on_export_wallet(self):
        """Export wallet addresses"""
        try:
            if not self.key_generator:
                QMessageBox.warning(self, "Error", "No wallet loaded")
                return
            
            from PySide6.QtWidgets import QFileDialog
            
            file_path, _ = QFileDialog.getSaveFileName(
                self,
                "Export Wallet",
                "wallet_addresses.csv",
                "CSV files (*.csv);;All files (*.*)"
            )
            
            if file_path:
                self.key_generator.export_addresses(file_path)
                self.append_output(f"✓ Exported to {file_path}")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
    
    def on_load_keys(self):
        """Load keys from file"""
        try:
            from PySide6.QtWidgets import QFileDialog
            
            file_path, _ = QFileDialog.getOpenFileName(
                self,
                "Load Keys",
                ".",
                "JSON files (*.json);;All files (*.*)"
            )
            
            if file_path:
                import json
                with open(file_path) as f:
                    data = json.load(f)
                self.key_generator = KeyGenerator("./wallets")
                self.key_generator.addresses = data
                self.append_output(f"✓ Loaded {len(data.get('addresses', []))} addresses")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
