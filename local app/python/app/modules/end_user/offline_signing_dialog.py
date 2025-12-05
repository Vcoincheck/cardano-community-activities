"""
Offline Message Signing Dialog
Sign messages using cardano-signer with Skey file
"""
import json
import os
import sys
from typing import Optional, Dict
from PySide6.QtWidgets import (
    QDialog, QVBoxLayout, QHBoxLayout, QLabel, QTextEdit, QPushButton,
    QFileDialog, QMessageBox, QProgressBar
)
from PySide6.QtCore import Qt, QThread, Signal
from PySide6.QtGui import QFont, QColor

# Add paths for standalone imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../..'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from shared.crypto_verifier import CryptoVerifier
from utils.skey_handler import SkeyHandler



class SigningWorker(QThread):
    """Background worker for signing"""
    finished = Signal(dict)
    error = Signal(str)
    
    def __init__(self, message: str, skey_path: str):
        super().__init__()
        self.message = message
        self.skey_path = skey_path
    
    def run(self):
        try:
            verifier = CryptoVerifier()
            signature = verifier.sign_with_signer(self.message, self.skey_path)
            
            if signature:
                self.finished.emit({
                    "message": self.message,
                    "signature": signature,
                    "skey_path": self.skey_path
                })
            else:
                self.error.emit("Failed to create signature")
        except Exception as e:
            self.error.emit(f"Error: {str(e)}")


class OfflineSigningDialog(QDialog):
    """Dialog for signing messages offline"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.skey_path = None
        self.signature = None
        self.setup_ui()
    
    def setup_ui(self):
        """Create UI elements"""
        self.setWindowTitle("Sign Message Offline")
        self.setGeometry(100, 100, 600, 500)
        self.setStyleSheet("""
            QDialog { background-color: #1e1e1e; }
            QLabel { color: #00ffff; font-size: 11pt; }
            QTextEdit { background-color: #2d2d2d; color: #00ff00; border: 1px solid #444; }
            QPushButton { background-color: #3d7ba4; color: white; padding: 5px; border-radius: 3px; }
            QPushButton:hover { background-color: #4d8bb4; }
            QPushButton:pressed { background-color: #2d6b94; }
        """)
        
        layout = QVBoxLayout()
        
        # Title
        title = QLabel("Sign Message Offline")
        title.setFont(QFont("Arial", 14, QFont.Bold))
        layout.addWidget(title)
        
        # Message input
        msg_label = QLabel("Message to sign:")
        layout.addWidget(msg_label)
        
        self.message_input = QTextEdit()
        self.message_input.setPlaceholderText("Enter message...")
        self.message_input.setMinimumHeight(150)
        layout.addWidget(self.message_input)
        
        # Key file selection
        key_layout = QHBoxLayout()
        key_label = QLabel("Signing Key:")
        key_layout.addWidget(key_label)
        
        self.key_display = QLabel("[No key selected]")
        self.key_display.setStyleSheet("color: #ffaa00; word-wrap: break-word;")
        key_layout.addWidget(self.key_display)
        
        btn_select_key = QPushButton("Browse...")
        btn_select_key.clicked.connect(self.select_key_file)
        key_layout.addWidget(btn_select_key)
        
        layout.addLayout(key_layout)
        
        # Progress bar
        self.progress = QProgressBar()
        self.progress.setVisible(False)
        layout.addWidget(self.progress)
        
        # Signature output
        sig_label = QLabel("Signature:")
        layout.addWidget(sig_label)
        
        self.signature_output = QTextEdit()
        self.signature_output.setReadOnly(True)
        self.signature_output.setMinimumHeight(80)
        layout.addWidget(self.signature_output)
        
        # Buttons
        btn_layout = QHBoxLayout()
        
        btn_sign = QPushButton("Sign")
        btn_sign.clicked.connect(self.sign_message)
        btn_layout.addWidget(btn_sign)
        
        btn_copy = QPushButton("Copy Signature")
        btn_copy.clicked.connect(self.copy_signature)
        btn_layout.addWidget(btn_copy)
        
        btn_save = QPushButton("Save")
        btn_save.clicked.connect(self.save_result)
        btn_layout.addWidget(btn_save)
        
        btn_close = QPushButton("Close")
        btn_close.clicked.connect(self.accept)
        btn_layout.addWidget(btn_close)
        
        layout.addLayout(btn_layout)
        
        self.setLayout(layout)
    
    def select_key_file(self):
        """Open file dialog to select signing key"""
        file_path, _ = QFileDialog.getOpenFileName(
            self,
            "Select Signing Key",
            ".",
            "Key files (*.skey *.xsk);;All files (*.*)"
        )
        
        if file_path:
            self.skey_path = file_path
            display_name = file_path.split('/')[-1]
            self.key_display.setText(display_name)
    
    def sign_message(self):
        """Sign the message"""
        message = self.message_input.toPlainText().strip()
        
        if not message:
            QMessageBox.warning(self, "Error", "Please enter a message")
            return
        
        if not self.skey_path:
            QMessageBox.warning(self, "Error", "Please select a signing key")
            return
        
        self.progress.setVisible(True)
        self.progress.setValue(0)
        
        # Sign in background
        self.worker = SigningWorker(message, self.skey_path)
        self.worker.finished.connect(self.on_sign_finished)
        self.worker.error.connect(self.on_sign_error)
        self.worker.start()
    
    def on_sign_finished(self, result: Dict):
        """Handle signing completion"""
        self.progress.setVisible(False)
        self.signature = result
        self.signature_output.setText(result["signature"])
        QMessageBox.information(self, "Success", "✓ Message signed successfully")
    
    def on_sign_error(self, error_msg: str):
        """Handle signing error"""
        self.progress.setVisible(False)
        QMessageBox.critical(self, "Error", f"✗ {error_msg}")
    
    def copy_signature(self):
        """Copy signature to clipboard"""
        from PySide6.QtGui import QApplication
        sig = self.signature_output.toPlainText().strip()
        if sig:
            QApplication.clipboard().setText(sig)
            QMessageBox.information(self, "Info", "Signature copied to clipboard")
    
    def save_result(self):
        """Save signing result to JSON"""
        if not self.signature:
            QMessageBox.warning(self, "Error", "No signature to save")
            return
        
        file_path, _ = QFileDialog.getSaveFileName(
            self,
            "Save Signature",
            "signature.json",
            "JSON files (*.json);;All files (*.*)"
        )
        
        if file_path:
            try:
                with open(file_path, 'w') as f:
                    json.dump(self.signature, f, indent=2)
                QMessageBox.information(self, "Success", f"✓ Saved to {file_path}")
            except Exception as e:
                QMessageBox.critical(self, "Error", f"✗ Failed to save: {e}")
