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

        btn_sign = QPushButton("2. Sign Message (Offline)")
        btn_sign.setMinimumHeight(40)
        btn_sign.clicked.connect(self.on_sign_offline)
        left_layout.addWidget(btn_sign)

        btn_sign_web = QPushButton("3. Sign Message (Web Wallet)")
        btn_sign_web.setMinimumHeight(40)
        btn_sign_web.clicked.connect(self.on_sign_web)
        left_layout.addWidget(btn_sign_web)

        btn_export = QPushButton("4. Export Wallet")
        btn_export.setMinimumHeight(40)
        btn_export.clicked.connect(self.on_export)
        left_layout.addWidget(btn_export)

        btn_verify = QPushButton("5. Verify Signature")
        btn_verify.setMinimumHeight(40)
        btn_verify.clicked.connect(self.on_verify)
        left_layout.addWidget(btn_verify)

        btn_check_balance = QPushButton("6. Check Balance/Assets")
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
        # Simple dialog for mnemonic input
        mnemonic, ok = QInputDialog.getMultiLineText(self, "Nhập mnemonic", "Nhập BIP39 mnemonic (12/15/24 từ):")
        if not ok or not mnemonic.strip():
            return
        wallet_path = QFileDialog.getExistingDirectory(self, "Chọn thư mục lưu wallet")
        if not wallet_path:
            return
        try:
            gen = KeyGenerator(wallet_path)
            result = gen.generate_addresses(mnemonic.strip(), account_index=0, address_count=5)
            if result:
                self.append_output(f"✓ Đã sinh địa chỉ và stake address. Lưu tại: {wallet_path}")
                self.append_output(str(result))
            else:
                self.append_output("✗ Lỗi khi sinh địa chỉ hoặc mnemonic không hợp lệ.")
        except Exception as e:
            self.append_output(f"✗ Lỗi: {e}")

    def on_sign_offline(self):
        dialog = OfflineSigningDialog(self)
        dialog.exec()
        if dialog.signature:
            self.append_output(f"✓ Đã ký thành công!\nSignature: {dialog.signature}")
        else:
            self.append_output("✗ Ký thất bại hoặc bị hủy.")

    def on_sign_web(self):
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
        self.append_output("Đã mở trình duyệt để ký qua ví web (Yoroi/Nami)...")

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
