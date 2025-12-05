"""
END-USER-APP: GUI Interface (PySide6)
Cardano End-User Tools - Python version
"""
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
    QTextEdit, QInputDialog, QMessageBox, QFileDialog
)
from PySide6.QtGui import QFont
from PySide6.QtCore import Qt
import sys
import os

# Add to path for standalone imports
sys.path.insert(0, os.path.dirname(__file__))

from tracking_so_du_paymentkey import get_payment_address_info
from tracking_so_du_stakekey import check_stake_balance
from key_generator import KeyGenerator
from offline_signing_dialog import OfflineSigningDialog
from web_signing_server import WebSigningServer
import threading

class EndUserDashboard(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Cardano End-User Tool")
        self.setGeometry(100, 100, 800, 500)
        self.setStyleSheet("""
            QMainWindow { background-color: #1e1e1e; }
            QLabel { color: #00ffff; }
            QPushButton {
                background-color: #326496;
                color: white;
                padding: 8px;
                border-radius: 4px;
                font-weight: bold;
            }
            QPushButton:hover { background-color: #3d7b00; }
            QPushButton:pressed { background-color: #2d6b00; }
            QTextEdit {
                background-color: #0a0a0a;
                color: #00ff00;
                font-family: 'Courier New';
                border: 1px solid #333;
            }
        """)
        self.setup_ui()

    def setup_ui(self):
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        main_layout = QHBoxLayout(main_widget)

        # Left panel - buttons
        left_layout = QVBoxLayout()
        title = QLabel("🔐 Cardano End-User Tools")
        title.setFont(QFont("Arial", 16, QFont.Bold))
        left_layout.addWidget(title)
        left_layout.addSpacing(20)

        btn_keygen = QPushButton("1. Generate/Restore Keypair")
        btn_keygen.setMinimumHeight(40)
        btn_keygen.clicked.connect(self.on_keygen)
        left_layout.addWidget(btn_keygen)

        btn_sign = QPushButton("2. Sign Message")
        btn_sign.setMinimumHeight(40)
        btn_sign.clicked.connect(self.on_sign)
        left_layout.addWidget(btn_sign)

        btn_export = QPushButton("3. Export Wallet")
        btn_export.setMinimumHeight(40)
        btn_export.clicked.connect(self.on_export)
        left_layout.addWidget(btn_export)

        btn_verify = QPushButton("4. Verify Signature")
        btn_verify.setMinimumHeight(40)
        btn_verify.clicked.connect(self.on_verify)
        left_layout.addWidget(btn_verify)

        btn_check_balance = QPushButton("5. Check Balance/Assets")
        btn_check_balance.setMinimumHeight(40)
        btn_check_balance.setStyleSheet("background-color: #329664;")
        btn_check_balance.clicked.connect(self.on_check_balance)
        left_layout.addWidget(btn_check_balance)

        btn_clean = QPushButton("🗑 Clean All Keys")
        btn_clean.setMinimumHeight(40)
        btn_clean.setStyleSheet("background-color: #964646;")
        btn_clean.clicked.connect(self.on_clean)
        left_layout.addWidget(btn_clean)

        left_layout.addStretch()

        # Right panel - output
        self.output_text = QTextEdit()
        self.output_text.setReadOnly(True)
        self.output_text.setMinimumWidth(400)
        main_layout.addLayout(left_layout, 1)
        main_layout.addWidget(self.output_text, 2)

    def append_output(self, text: str):
        self.output_text.append(text)
        self.output_text.verticalScrollBar().setValue(
            self.output_text.verticalScrollBar().maximum()
        )

    def on_keygen(self):
        """Generate keypair with multi-address support like PS1 version"""
        from PySide6.QtWidgets import QDialog, QVBoxLayout, QPushButton, QLabel, QSpinBox
        
        # Step 1: Choose word count (12/15/24)
        word_count_dialog = QDialog(self)
        word_count_dialog.setWindowTitle("Select Mnemonic Length")
        word_count_dialog.setGeometry(200, 200, 400, 250)
        word_count_dialog.setStyleSheet("""
            QDialog { background-color: #1e1e1e; }
            QLabel { color: #00ffff; font-size: 12pt; }
            QPushButton { 
                background-color: #3d7ba4; 
                color: white; 
                padding: 10px; 
                border-radius: 4px; 
                font-weight: bold;
            }
        """)
        
        layout = QVBoxLayout(word_count_dialog)
        layout.addWidget(QLabel("Choose mnemonic word count:"))
        layout.addSpacing(20)
        
        selected_count = None
        
        def select_count(count):
            nonlocal selected_count
            selected_count = count
            word_count_dialog.close()
        
        btn12 = QPushButton("12 Words")
        btn12.clicked.connect(lambda: select_count(12))
        layout.addWidget(btn12)
        
        btn15 = QPushButton("15 Words")
        btn15.clicked.connect(lambda: select_count(15))
        layout.addWidget(btn15)
        
        btn24 = QPushButton("24 Words")
        btn24.clicked.connect(lambda: select_count(24))
        layout.addWidget(btn24)
        
        layout.addStretch()
        word_count_dialog.exec()
        
        if not selected_count:
            self.append_output("❌ Cancelled")
            return
        
        # Load wordlist for autocomplete
        wordlist = []
        try:
            wordlist_path = os.path.join(os.path.dirname(__file__), '../../wordlist.txt')
            if os.path.exists(wordlist_path):
                with open(wordlist_path, 'r') as f:
                    wordlist = [line.strip() for line in f if line.strip()]
            else:
                self.append_output("⚠️ wordlist.txt not found, autocomplete disabled")
        except Exception as e:
            self.append_output(f"⚠️ Error loading wordlist: {e}")
        
        # Step 2: Input mnemonic with dynamic textboxes and autocomplete
        mnemonic_dialog = QDialog(self)
        mnemonic_dialog.setWindowTitle(f"Enter Mnemonic - {selected_count} Words")
        mnemonic_dialog.setGeometry(100, 50, 900, 700)
        mnemonic_dialog.setStyleSheet("""
            QDialog { background-color: #1e1e1e; }
            QLabel { color: #00ffff; }
            QLineEdit { 
                background-color: #0a0a0a; 
                color: #00ff00; 
                border: 1px solid #333;
                padding: 5px;
            }
            QPushButton { 
                background-color: #3d7ba4; 
                color: white; 
                padding: 8px; 
                border-radius: 4px;
            }
        """)
        
        main_layout = QVBoxLayout(mnemonic_dialog)
        main_layout.addWidget(QLabel(f"Enter your {selected_count}-word mnemonic:"))
        
        # Create grid of textboxes
        from PySide6.QtWidgets import QScrollArea, QGridLayout, QLineEdit
        from PySide6.QtCore import Qt, QStringListModel
        from PySide6.QtGui import QCompleter
        
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll_widget = QWidget()
        grid_layout = QGridLayout(scroll_widget)
        
        text_boxes = []
        cols = 3
        rows = (selected_count + cols - 1) // cols
        
        for i in range(selected_count):
            row = i // cols
            col = i % cols
            
            # Label
            label = QLabel(f"{i+1}:")
            label.setStyleSheet("color: #888;")
            grid_layout.addWidget(label, row, col * 2)
            
            # Textbox with autocomplete
            txt = QLineEdit()
            txt.setPlaceholderText("word")
            txt.setMaxLength(50)
            
            # Add autocomplete
            if wordlist:
                completer = QCompleter(wordlist)
                completer.setCaseSensitivity(Qt.CaseInsensitive)
                completer.setCompletionMode(QCompleter.PopupCompletion)
                txt.setCompleter(completer)
            
            grid_layout.addWidget(txt, row, col * 2 + 1)
            text_boxes.append(txt)
        
        scroll.setWidget(scroll_widget)
        main_layout.addWidget(scroll)
        
        # Buttons
        btn_layout = QHBoxLayout()
        btn_generate = QPushButton("Generate")
        btn_cancel = QPushButton("Cancel")
        btn_layout.addWidget(btn_generate)
        btn_layout.addWidget(btn_cancel)
        main_layout.addLayout(btn_layout)
        
        mnemonic = None
        
        def on_generate():
            nonlocal mnemonic
            words = []
            for txt in text_boxes:
                word = txt.text().strip().lower()
                if not word:
                    QMessageBox.warning(mnemonic_dialog, "Error", f"All {selected_count} words must be filled")
                    return
                words.append(word)
            mnemonic = " ".join(words)
            mnemonic_dialog.close()
        
        btn_generate.clicked.connect(on_generate)
        btn_cancel.clicked.connect(mnemonic_dialog.close)
        
        mnemonic_dialog.exec()
        
        if not mnemonic:
            self.append_output("❌ Cancelled")
            return
        
        # Step 3: Choose mode (Auto / Manual)
        mode_dialog = QDialog(self)
        mode_dialog.setWindowTitle("Generate Keypair Mode")
        mode_dialog.setGeometry(200, 200, 400, 250)
        mode_dialog.setStyleSheet("""
            QDialog { background-color: #1e1e1e; }
            QLabel { color: #00ffff; font-size: 11pt; }
            QPushButton { 
                background-color: #3d7ba4; 
                color: white; 
                padding: 12px; 
                border-radius: 4px; 
                font-weight: bold;
            }
        """)
        
        layout = QVBoxLayout(mode_dialog)
        layout.addWidget(QLabel("Choose generation mode:"))
        layout.addSpacing(20)
        
        mode = None
        
        def select_mode(m):
            nonlocal mode
            mode = m
            mode_dialog.close()
        
        btn_auto = QPushButton("Auto (1 external + 1 internal)")
        btn_auto.clicked.connect(lambda: select_mode("auto"))
        layout.addWidget(btn_auto)
        
        btn_manual = QPushButton("Manual (specify count)")
        btn_manual.clicked.connect(lambda: select_mode("manual"))
        layout.addWidget(btn_manual)
        
        layout.addStretch()
        mode_dialog.exec()
        
        if not mode:
            self.append_output("❌ Cancelled")
            return
        
        # Step 4: Get counts and wallet path
        ext_count = 1
        int_count = 1
        
        if mode == "manual":
            manual_dialog = QDialog(self)
            manual_dialog.setWindowTitle("Specify Address Counts")
            manual_dialog.setGeometry(200, 200, 400, 300)
            manual_dialog.setStyleSheet("""
                QDialog { background-color: #1e1e1e; }
                QLabel { color: #00ffff; }
                QSpinBox { background-color: #0a0a0a; color: #00ff00; }
                QPushButton { 
                    background-color: #3d7ba4; 
                    color: white; 
                    padding: 8px; 
                    border-radius: 4px;
                }
            """)
            
            layout = QVBoxLayout(manual_dialog)
            layout.addWidget(QLabel("External addresses:"))
            spin_ext = QSpinBox()
            spin_ext.setValue(5)
            spin_ext.setMinimum(0)
            layout.addWidget(spin_ext)
            
            layout.addWidget(QLabel("Internal addresses:"))
            spin_int = QSpinBox()
            spin_int.setValue(3)
            spin_int.setMinimum(0)
            layout.addWidget(spin_int)
            
            btn_layout = QHBoxLayout()
            btn_ok = QPushButton("Generate")
            btn_cancel = QPushButton("Cancel")
            btn_layout.addWidget(btn_ok)
            btn_layout.addWidget(btn_cancel)
            layout.addLayout(btn_layout)
            layout.addStretch()
            
            def on_ok():
                nonlocal ext_count, int_count
                ext_count = spin_ext.value()
                int_count = spin_int.value()
                manual_dialog.close()
            
            btn_ok.clicked.connect(on_ok)
            btn_cancel.clicked.connect(manual_dialog.close)
            
            manual_dialog.exec()
        
        # Select wallet output path
        wallet_path = QFileDialog.getExistingDirectory(self, "Select wallet output directory")
        if not wallet_path:
            self.append_output("❌ Cancelled")
            return
        
        # Step 5: Generate addresses
        self.append_output(f"\n========== Multi-Address Generation ==========")
        self.append_output(f"Mode: {mode}")
        self.append_output(f"External addresses: {ext_count}")
        self.append_output(f"Internal addresses: {int_count}")
        self.append_output(f"Output: {wallet_path}\n")
        
        try:
            gen = KeyGenerator(wallet_path)
            # Generate external addresses (path: 1852H/1815H/0H/0/$i)
            for i in range(ext_count):
                result = gen.generate_addresses(mnemonic, account_index=0, address_index=i, is_external=True)
                if result:
                    self.append_output(f"✓ External address {i}: {result['address'][:40]}...")
            
            # Generate internal addresses (path: 1852H/1815H/0H/1/$i)
            for i in range(int_count):
                result = gen.generate_addresses(mnemonic, account_index=0, address_index=i, is_external=False)
                if result:
                    self.append_output(f"✓ Internal address {i}: {result['address'][:40]}...")
            
            self.append_output(f"\n✅ Generation complete!")
            self.append_output(f"Total: {ext_count + int_count} addresses created")
            self.append_output(f"Location: {wallet_path}\n")
        except Exception as e:
            self.append_output(f"✗ Error: {e}")

    def on_sign(self):
        """Combined sign dialog - choose between offline and web wallet"""
        from PySide6.QtWidgets import QDialog, QVBoxLayout, QPushButton, QLabel
        
        sign_mode_dialog = QDialog(self)
        sign_mode_dialog.setWindowTitle("Chọn Cách Ký")
        sign_mode_dialog.setGeometry(200, 200, 400, 250)
        sign_mode_dialog.setStyleSheet("""
            QDialog { background-color: #1e1e1e; }
            QLabel { color: #00ffff; font-size: 11pt; }
            QPushButton { 
                background-color: #3d7ba4; 
                color: white; 
                padding: 12px; 
                border-radius: 4px; 
                font-weight: bold;
            }
        """)
        
        layout = QVBoxLayout(sign_mode_dialog)
        layout.addWidget(QLabel("Chọn cách ký thông điệp:"))
        layout.addSpacing(20)
        
        mode = None
        
        def select_mode(m):
            nonlocal mode
            mode = m
            sign_mode_dialog.close()
        
        btn_offline = QPushButton("🔐 Ký Offline (Khóa Riêng Cục Bộ)")
        btn_offline.setMinimumHeight(50)
        btn_offline.clicked.connect(lambda: select_mode("offline"))
        layout.addWidget(btn_offline)
        
        btn_web = QPushButton("🌐 Ký Qua Ví Web (Yoroi/Nami)")
        btn_web.setMinimumHeight(50)
        btn_web.setStyleSheet("""
            QPushButton { 
                background-color: #3d7ba4; 
                color: white; 
                padding: 12px; 
                border-radius: 4px; 
                font-weight: bold;
            }
            QPushButton:hover { background-color: #4d8bb4; }
        """)
        btn_web.clicked.connect(lambda: select_mode("web"))
        layout.addWidget(btn_web)
        
        layout.addStretch()
        sign_mode_dialog.exec()
        
        if mode == "offline":
            self.on_sign_offline()
        elif mode == "web":
            self.on_sign_web()
    
    def on_sign_offline(self):
        """Sign message with offline key"""
        dialog = OfflineSigningDialog(self)
        dialog.exec()
        if dialog.signature:
            self.append_output(f"✓ Đã ký thành công!\nSignature: {dialog.signature}")
        else:
            self.append_output("✗ Ký thất bại hoặc bị hủy.")

    def on_sign_web(self):
        """Sign message via web wallet (Yoroi/Nami/etc)"""
        # Nhập message
        message, ok = QInputDialog.getMultiLineText(self, "Nhập thông điệp", "Nhập thông điệp cần ký:")
        if not ok or not message.strip():
            return
        self.append_output("[*] Đang khởi động server ký web...")
        def run_server():
            server = WebSigningServer(port=8888)
            server.message_to_sign = message.strip()
            import uvicorn
            uvicorn.run(server.app, host="127.0.0.1", port=8888, log_level="warning")
        threading.Thread(target=run_server, daemon=True).start()
        import webbrowser
        webbrowser.open("http://127.0.0.1:8888/")
        self.append_output("✓ Đã mở trình duyệt để ký qua ví web (Yoroi/Nami/Eternl/Lace)...")
        self.append_output("Tìm kiếm ví được cài đặt trên trình duyệt của bạn")

    def on_export(self):
        self.append_output("[Export] Chức năng này chưa được triển khai trong bản Python.")

    def on_verify(self):
        self.append_output("[Verify] Chức năng này chưa được triển khai trong bản Python.")

    def on_check_balance(self):
        address, ok = QInputDialog.getText(self, "Check Balance/Assets", "Nhập địa chỉ ví (addr1... hoặc stake1...):")
        if not ok or not address.strip():
            return
        address = address.strip()
        self.append_output(f"\n========== Check Balance/Assets ==========")
        self.append_output(f"Địa chỉ: {address}")
        if address.startswith("addr1"):
            self.append_output("Đang kiểm tra Payment Address...\n")
            result = get_payment_address_info(address)
            if result.get('Success'):
                self.append_output(f"✓ Kết quả:\n")
                self.append_output(f"Payment Address:\n  {result['PaymentAddress']}")
                self.append_output(f"Stake Address:\n  {result['StakeAddress']}")
                self.append_output(f"Số dư ADA: {result['ADABalance']} ₳")
                if result['Assets']:
                    self.append_output("Danh sách Token:")
                    for asset in result['Assets']:
                        self.append_output(f"  - {asset[0]}: {asset[1]}")
                else:
                    self.append_output("Token: không có")
            else:
                self.append_output(f"✗ Lỗi: {result.get('Error', 'Unknown error')}")
        elif address.startswith("stake1"):
            self.append_output("Đang kiểm tra Stake Account (toàn bộ ví)...\n")
            message = check_stake_balance(address)
            self.append_output(message)
        else:
            self.append_output("✗ Địa chỉ không hợp lệ! Phải bắt đầu bằng 'addr1' hoặc 'stake1'")
        self.append_output("\n========================================\n")

    def on_clean(self):
        reply = QMessageBox.question(self, "Confirm Cleanup", "This will permanently delete all generated wallets and keys from this device.\n\nThis action cannot be undone!\n\nAre you sure?", QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
        if reply == QMessageBox.No:
            self.append_output("❌ Cleanup cancelled by user")
            return
        # Second confirmation
        reply2 = QMessageBox.question(self, "FINAL Confirmation", "Are you absolutely sure?\n\nAll wallets, keys, and signing certificates will be permanently removed.\n\nThis is your FINAL warning!", QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
        if reply2 == QMessageBox.No:
            self.append_output("❌ Cleanup cancelled by user")
            return
        self.append_output("🔄 Starting secure cleanup...")
        # Cleanup paths
        paths_to_clean = [
            os.path.join(os.getcwd(), "wallets"),
            os.path.join(os.getcwd(), "generated_keys"),
            os.path.join(os.getcwd(), "keys"),
            os.path.join(os.getcwd(), "wallet")
        ]
        total_items_deleted = 0
        for path in paths_to_clean:
            if os.path.exists(path):
                self.append_output(f"📁 Cleaning: {path}")
                try:
                    for root, dirs, files in os.walk(path, topdown=False):
                        for name in files:
                            try:
                                file_path = os.path.join(root, name)
                                with open(file_path, "wb") as f:
                                    f.write(b"\x00" * os.path.getsize(file_path))
                                os.remove(file_path)
                                total_items_deleted += 1
                                self.append_output(f"  🔒 Secure wipe: {name}")
                            except Exception as e:
                                self.append_output(f"  ⚠️ Could not overwrite {name}: {e}")
                        for name in dirs:
                            try:
                                os.rmdir(os.path.join(root, name))
                            except Exception:
                                pass
                    os.rmdir(path)
                    self.append_output("  ✓ Directory deleted")
                except Exception as e:
                    self.append_output(f"  ⚠️ Error cleaning {path}: {e}")
        self.append_output("\n✅ CLEANUP COMPLETE - All keys securely removed")
        self.append_output("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        self.append_output(f"Total files processed: {total_items_deleted}")
        self.append_output("Device is now clean - keys cannot be recovered\n")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = EndUserDashboard()
    window.show()
    sys.exit(app.exec())
