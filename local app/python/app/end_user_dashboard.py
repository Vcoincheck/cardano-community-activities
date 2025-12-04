"""
End-User App Dashboard - PySide6 GUI
Giao diện công cụ cho người dùng cuối
"""
import sys
import json
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QPushButton, QLabel, QTextEdit, QDialog, QLineEdit, QFileDialog,
    QMessageBox
)
from PySide6.QtGui import QFont
from PySide6.QtCore import Qt

from app.modules.key_generator import KeyGenerator
from app.modules.message_signer import MessageSigner
from app.utils.crypto import Logger


class EndUserDashboard(QMainWindow):
    """Main End-User Dashboard Window"""
    
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Cardano End-User Tools")
        self.setGeometry(100, 100, 850, 650)
        
        # Initialize modules
        self.key_generator = KeyGenerator()
        self.message_signer = MessageSigner()
        self.current_keys = None
        
        # Setup UI
        self._setup_ui()
    
    def _setup_ui(self):
        """Setup main window UI"""
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        
        main_layout = QHBoxLayout(main_widget)
        
        # Left panel - Buttons
        left_panel = QVBoxLayout()
        
        # Header
        header = QLabel("🔐 Cardano End-User Tools")
        header_font = QFont("Arial", 14, QFont.Bold)
        header.setFont(header_font)
        header.setStyleSheet("color: cyan;")
        left_panel.addWidget(header)
        
        left_panel.addSpacing(20)
        
        # Buttons
        btn_keygen = self._create_button(
            "1. Generate Keypair",
            "#326496",
            self._on_generate_keypair
        )
        left_panel.addWidget(btn_keygen)
        
        btn_sign_offline = self._create_button(
            "2. Sign Message (Offline)",
            "#326496",
            self._on_sign_offline
        )
        left_panel.addWidget(btn_sign_offline)
        
        btn_sign_web = self._create_button(
            "3. Sign Message (Web)",
            "#326496",
            self._on_sign_web
        )
        left_panel.addWidget(btn_sign_web)
        
        btn_verify = self._create_button(
            "4. Verify Local",
            "#326496",
            self._on_verify_local
        )
        left_panel.addWidget(btn_verify)
        
        btn_export = self._create_button(
            "5. Export Wallet",
            "#326496",
            self._on_export_wallet
        )
        left_panel.addWidget(btn_export)
        
        left_panel.addSpacing(20)
        
        btn_load_keys = self._create_button(
            "Load Keys from File",
            "#966432",
            self._on_load_keys
        )
        left_panel.addWidget(btn_load_keys)
        
        left_panel.addStretch()
        
        # Right panel - Output
        self.output_text = QTextEdit()
        self.output_text.setReadOnly(True)
        self.output_text.setStyleSheet(
            "background-color: #141414; color: #00FF00; font-family: 'Courier New'; padding: 10px;"
        )
        
        # Combine panels
        main_layout.addLayout(left_panel, 1)
        main_layout.addWidget(self.output_text, 2)
        
        # Styling
        main_widget.setStyleSheet("background-color: #1e1e1e;")
    
    def _create_button(self, text: str, color: str, callback) -> QPushButton:
        """Create a styled button"""
        btn = QPushButton(text)
        btn.setMinimumHeight(45)
        btn.setStyleSheet(
            f"background-color: {color}; color: white; font-weight: bold; "
            "border-radius: 4px; padding: 8px;"
        )
        btn.clicked.connect(callback)
        return btn
    
    def _append_output(self, text: str):
        """Append text to output panel"""
        current = self.output_text.toPlainText()
        if current:
            self.output_text.setPlainText(current + "\n" + text)
        else:
            self.output_text.setPlainText(text)
        # Scroll to bottom
        self.output_text.verticalScrollBar().setValue(
            self.output_text.verticalScrollBar().maximum()
        )
    
    def _on_generate_keypair(self):
        """Generate keypair"""
        try:
            result = self.key_generator.generate_keypair("./keys")
            self.current_keys = result
            
            output = f"""✓ Keypair generated successfully!

Private Key (first 50 chars):
{result['private_key'][:100]}...

Public Key:
{result['public_key'][:200]}...

Files saved to:
  - {result['private_path']}
  - {result['public_path']}
"""
            self._append_output(output)
            QMessageBox.information(self, "Success", "Keypair generated successfully!\nCheck output panel for details.")
        
        except Exception as e:
            self._append_output(f"✗ Error: {str(e)}")
            QMessageBox.critical(self, "Error", f"Failed to generate keypair: {str(e)}")
    
    def _on_sign_offline(self):
        """Sign message offline"""
        dialog = SignMessageDialog(self)
        if dialog.exec() == QDialog.Accepted:
            message = dialog.message_input.toPlainText()
            
            if not self.current_keys:
                self._append_output("✗ No keys loaded. Generate keypair first or load from file.")
                return
            
            try:
                result = self.message_signer.sign_message(
                    message,
                    self.current_keys['private_key']
                )
                
                output = f"""✓ Message signed successfully!

Message: {result['message']}

Signature:
{result['signature']}

Public Key:
{result['public_key'][:150]}...
"""
                self._append_output(output)
            
            except Exception as e:
                self._append_output(f"✗ Error: {str(e)}")
    
    def _on_sign_web(self):
        """Sign message via web - placeholder"""
        self._append_output("Sign Message (Web): Not yet implemented\n(Would integrate with web-based signing)")
    
    def _on_verify_local(self):
        """Verify message locally"""
        dialog = VerifyMessageDialog(self)
        if dialog.exec() == QDialog.Accepted:
            message = dialog.message_input.toPlainText()
            signature = dialog.signature_input.toPlainText()
            public_key = dialog.public_key_input.toPlainText()
            
            try:
                is_valid = self.message_signer.verify_signature(message, signature, public_key)
                
                if is_valid:
                    self._append_output("✓ Signature is VALID!")
                else:
                    self._append_output("✗ Signature is INVALID!")
            
            except Exception as e:
                self._append_output(f"✗ Error: {str(e)}")
    
    def _on_export_wallet(self):
        """Export wallet - placeholder"""
        self._append_output("Export Wallet: Not yet implemented")
    
    def _on_load_keys(self):
        """Load keys from file"""
        file_path, _ = QFileDialog.getOpenFileName(
            self,
            "Open Private Key File",
            "./keys",
            "PEM Files (*.pem)"
        )
        
        if file_path:
            try:
                with open(file_path, 'r') as f:
                    private_key_pem = f.read()
                
                # Store keys
                self.current_keys = {
                    'private_key': private_key_pem,
                    'private_path': file_path
                }
                
                self._append_output(f"✓ Private key loaded from:\n{file_path}")
                QMessageBox.information(self, "Success", "Private key loaded successfully!")
            
            except Exception as e:
                self._append_output(f"✗ Error loading file: {str(e)}")
                QMessageBox.critical(self, "Error", f"Failed to load keys: {str(e)}")


class SignMessageDialog(QDialog):
    """Dialog for signing messages"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Sign Message (Offline)")
        self.setGeometry(150, 150, 500, 350)
        self._setup_ui()
    
    def _setup_ui(self):
        """Setup dialog UI"""
        layout = QVBoxLayout()
        
        title = QLabel("Sign Message")
        title_font = QFont("Arial", 12, QFont.Bold)
        title.setFont(title_font)
        title.setStyleSheet("color: cyan;")
        layout.addWidget(title)
        
        layout.addWidget(QLabel("Enter message to sign:"))
        self.message_input = QTextEdit()
        self.message_input.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        self.message_input.setMaximumHeight(150)
        layout.addWidget(self.message_input)
        
        # Buttons
        btn_layout = QHBoxLayout()
        
        ok_btn = QPushButton("Sign")
        ok_btn.setStyleSheet("background-color: #649632; color: white; padding: 8px;")
        ok_btn.clicked.connect(self.accept)
        btn_layout.addWidget(ok_btn)
        
        cancel_btn = QPushButton("Cancel")
        cancel_btn.setStyleSheet("background-color: #963232; color: white; padding: 8px;")
        cancel_btn.clicked.connect(self.reject)
        btn_layout.addWidget(cancel_btn)
        
        layout.addLayout(btn_layout)
        
        self.setStyleSheet("background-color: #1e1e1e; color: white;")
        self.setLayout(layout)


class VerifyMessageDialog(QDialog):
    """Dialog for verifying messages"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Verify Message")
        self.setGeometry(150, 150, 550, 450)
        self._setup_ui()
    
    def _setup_ui(self):
        """Setup dialog UI"""
        layout = QVBoxLayout()
        
        title = QLabel("Verify Message Signature")
        title_font = QFont("Arial", 12, QFont.Bold)
        title.setFont(title_font)
        title.setStyleSheet("color: cyan;")
        layout.addWidget(title)
        
        layout.addWidget(QLabel("Original Message:"))
        self.message_input = QTextEdit()
        self.message_input.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        self.message_input.setMaximumHeight(80)
        layout.addWidget(self.message_input)
        
        layout.addWidget(QLabel("Signature (base64):"))
        self.signature_input = QTextEdit()
        self.signature_input.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        self.signature_input.setMaximumHeight(80)
        layout.addWidget(self.signature_input)
        
        layout.addWidget(QLabel("Public Key (PEM):"))
        self.public_key_input = QTextEdit()
        self.public_key_input.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        self.public_key_input.setMaximumHeight(120)
        layout.addWidget(self.public_key_input)
        
        # Buttons
        btn_layout = QHBoxLayout()
        
        ok_btn = QPushButton("Verify")
        ok_btn.setStyleSheet("background-color: #649632; color: white; padding: 8px;")
        ok_btn.clicked.connect(self.accept)
        btn_layout.addWidget(ok_btn)
        
        cancel_btn = QPushButton("Cancel")
        cancel_btn.setStyleSheet("background-color: #963232; color: white; padding: 8px;")
        cancel_btn.clicked.connect(self.reject)
        btn_layout.addWidget(cancel_btn)
        
        layout.addLayout(btn_layout)
        
        self.setStyleSheet("background-color: #1e1e1e; color: white;")
        self.setLayout(layout)


def main():
    """Main entry point"""
    app = QApplication(sys.argv)
    
    # Set dark theme
    app.setStyle('Fusion')
    
    dashboard = EndUserDashboard()
    dashboard.show()
    
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
