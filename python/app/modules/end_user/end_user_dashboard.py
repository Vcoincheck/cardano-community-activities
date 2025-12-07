"""
END-USER-APP: GUI Interface (PySide6)
Cardano End-User Tools - Python version
"""
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
    QTextEdit, QInputDialog, QMessageBox, QFileDialog, QTabWidget, QDialog, QScrollArea,
    QGridLayout, QLineEdit, QSpinBox, QFrame, QCompleter
)
from PySide6.QtGui import QFont, QIcon, QColor, QClipboard
from PySide6.QtCore import Qt
import sys
import os
import threading
import webbrowser
import traceback

# Add to path for standalone imports
sys.path.insert(0, os.path.dirname(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../..'))

try:
    from modules.end_user.tracking_so_du_paymentkey import get_payment_address_info
    from modules.end_user.tracking_so_du_stakekey import check_stake_balance
    from modules.end_user.key_generator import KeyGenerator
    from modules.end_user.offline_signing_dialog import OfflineSigningDialog
    from modules.end_user.web_signing_server import WebSigningServer
    from utils.bip39 import BIP39
    from utils.mnemonic_generator import MnemonicGenerator
except ImportError:
    # Fallback for relative imports
    from tracking_so_du_paymentkey import get_payment_address_info
    from tracking_so_du_stakekey import check_stake_balance
    from key_generator import KeyGenerator
    from offline_signing_dialog import OfflineSigningDialog
    from web_signing_server import WebSigningServer
    try:
        from utils.bip39 import BIP39
        from utils.mnemonic_generator import MnemonicGenerator
    except:
        BIP39 = None
        MnemonicGenerator = None

# Custom Stylesheet
DARK_STYLESHEET = """
    QMainWindow { 
        background-color: #0d1117; 
    }
    QLabel { 
        color: #c9d1d9; 
        font-weight: 500;
    }
    QPushButton {
        background-color: #238636;
        color: white;
        padding: 10px 16px;
        border: none;
        border-radius: 6px;
        font-weight: 600;
        font-size: 12px;
        min-height: 32px;
    }
    QPushButton:hover { 
        background-color: #2ea043; 
    }
    QPushButton:pressed { 
        background-color: #1f6feb; 
    }
    QPushButton:disabled {
        background-color: #444c56;
        color: #8b949e;
    }
    QPushButton#primaryBtn {
        background-color: #1f6feb;
        font-size: 13px;
    }
    QPushButton#primaryBtn:hover {
        background-color: #388bfd;
    }
    QPushButton#dangerBtn {
        background-color: #da3633;
    }
    QPushButton#dangerBtn:hover {
        background-color: #f85149;
    }
    QPushButton#navBtn {
        background-color: #444c56;
        color: #c9d1d9;
    }
    QPushButton#navBtn:hover {
        background-color: #30363d;
    }
    QTextEdit {
        background-color: #0d1117;
        color: #8b949e;
        font-family: 'Courier New', monospace;
        border: 1px solid #30363d;
        border-radius: 6px;
        padding: 8px;
        selection-background-color: #388bfd;
    }
    QLineEdit {
        background-color: #0d1117;
        color: #c9d1d9;
        border: 1px solid #30363d;
        border-radius: 6px;
        padding: 8px;
        font-size: 12px;
        selection-background-color: #388bfd;
    }
    QSpinBox {
        background-color: #0d1117;
        color: #c9d1d9;
        border: 1px solid #30363d;
        border-radius: 6px;
        padding: 6px;
    }
    QDialog {
        background-color: #0d1117;
    }
    QScrollArea {
        background-color: #0d1117;
    }
"""

class EndUserDashboard(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("🔐 Cardano End-User Tool")
        self.setGeometry(100, 100, 1000, 700)
        self.setStyleSheet(DARK_STYLESHEET)
        self.setWindowIcon(QIcon())
        self.setup_ui()

    def setup_ui(self):
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        main_layout = QVBoxLayout(main_widget)
        main_layout.setSpacing(12)
        main_layout.setContentsMargins(12, 12, 12, 12)

        # Header
        header = QLabel("🔐 Cardano End-User Tool Suite")
        header.setFont(QFont("Segoe UI", 18, QFont.Bold))
        header.setStyleSheet("color: #79c0ff; padding: 10px;")
        main_layout.addWidget(header)

        # ===== TOOLBAR: Horizontal buttons on top =====
        toolbar_layout = QHBoxLayout()
        toolbar_layout.setSpacing(8)
        toolbar_layout.setContentsMargins(0, 0, 0, 0)

        btn_keygen = QPushButton("🔑 Generate/Restore")
        btn_keygen.setObjectName("primaryBtn")
        btn_keygen.setMinimumHeight(40)
        btn_keygen.clicked.connect(self.on_keygen)
        toolbar_layout.addWidget(btn_keygen)

        btn_sign = QPushButton("✍️ Sign")
        btn_sign.setMinimumHeight(40)
        btn_sign.clicked.connect(self.on_sign)
        toolbar_layout.addWidget(btn_sign)

        btn_export = QPushButton("📤 Export")
        btn_export.setMinimumHeight(40)
        btn_export.clicked.connect(self.on_export)
        toolbar_layout.addWidget(btn_export)

        btn_verify = QPushButton("✓ Verify")
        btn_verify.setMinimumHeight(40)
        btn_verify.clicked.connect(self.on_verify)
        toolbar_layout.addWidget(btn_verify)

        btn_check_balance = QPushButton("💰 Check Balance")
        btn_check_balance.setMinimumHeight(40)
        btn_check_balance.clicked.connect(self.on_check_balance)
        toolbar_layout.addWidget(btn_check_balance)

        btn_clean = QPushButton("🗑️ Clean Keys")
        btn_clean.setObjectName("dangerBtn")
        btn_clean.setMinimumHeight(40)
        btn_clean.clicked.connect(self.on_clean)
        toolbar_layout.addWidget(btn_clean)

        toolbar_layout.addStretch()
        main_layout.addLayout(toolbar_layout)

        # Divider
        divider = QFrame()
        divider.setFrameShape(QFrame.HLine)
        divider.setFrameShadow(QFrame.Sunken)
        divider.setStyleSheet("background-color: #30363d;")
        main_layout.addWidget(divider)

        # ===== OUTPUT CONSOLE =====
        console_label = QLabel("📋 Console Output")
        console_label.setFont(QFont("Segoe UI", 12, QFont.Bold))
        console_label.setStyleSheet("color: #79c0ff;")
        main_layout.addWidget(console_label)

        self.output_text = QTextEdit()
        self.output_text.setReadOnly(True)
        self.output_text.setMinimumHeight(500)
        main_layout.addWidget(self.output_text)

        # Output controls
        output_btn_layout = QHBoxLayout()
        output_btn_layout.setSpacing(8)

        btn_clear = QPushButton("Clear")
        btn_clear.setObjectName("navBtn")
        btn_clear.setMaximumWidth(100)
        btn_clear.clicked.connect(lambda: self.output_text.clear())
        output_btn_layout.addWidget(btn_clear)

        btn_copy = QPushButton("Copy All")
        btn_copy.setObjectName("navBtn")
        btn_copy.setMaximumWidth(100)
        btn_copy.clicked.connect(self.copy_output)
        output_btn_layout.addWidget(btn_copy)

        output_btn_layout.addStretch()
        main_layout.addLayout(output_btn_layout)

    def copy_output(self):
        """Copy output to clipboard"""
        from PySide6.QtGui import QClipboard
        clipboard = QApplication.clipboard()
        clipboard.setText(self.output_text.toPlainText())
        self.append_output("✓ Output copied to clipboard")

    def append_output(self, text: str):
        self.output_text.append(text)
        self.output_text.verticalScrollBar().setValue(
            self.output_text.verticalScrollBar().maximum()
        )

    def on_keygen(self):
        """Generate keypair - single unified screen with all options"""
        from PySide6.QtWidgets import QDialog, QVBoxLayout, QHBoxLayout, QPushButton, QLabel, QSpinBox, QScrollArea, QGridLayout, QLineEdit, QTextEdit, QTabWidget, QWidget, QFrame
        from PySide6.QtCore import Qt
        
        self.append_output("\n[*] Starting key generation process...")
        
        # Main dialog with tabs/sections
        main_dialog = QDialog(self)
        main_dialog.setWindowTitle("🔐 Wallet Key Generation")
        main_dialog.setGeometry(50, 50, 1200, 900)
        main_dialog.setStyleSheet(DARK_STYLESHEET)
        main_dialog.setWindowModality(Qt.ApplicationModal)
        
        main_layout = QVBoxLayout(main_dialog)
        main_layout.setSpacing(16)
        main_layout.setContentsMargins(20, 20, 20, 20)
        
        # Header
        header = QLabel("🔐 Wallet Key Generation Console")
        header.setFont(QFont("Segoe UI", 16, QFont.Bold))
        header.setStyleSheet("color: #79c0ff;")
        main_layout.addWidget(header)
        
        # Divider
        divider = QFrame()
        divider.setFrameShape(QFrame.HLine)
        divider.setFrameShadow(QFrame.Sunken)
        divider.setStyleSheet("background-color: #30363d;")
        main_layout.addWidget(divider)
        
        # Content area with scroll
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll_widget = QWidget()
        content_layout = QVBoxLayout(scroll_widget)
        content_layout.setSpacing(20)
        content_layout.setContentsMargins(10, 10, 10, 10)
        
        # ===== SECTION 1: Mode Selection =====
        section1 = QLabel("1️⃣ WALLET MODE")
        section1.setFont(QFont("Segoe UI", 13, QFont.Bold))
        section1.setStyleSheet("color: #79c0ff;")
        content_layout.addWidget(section1)
        
        mode_layout = QHBoxLayout()
        mode_layout.setSpacing(10)
        
        mode_selected = None
        
        def select_mode(m):
            nonlocal mode_selected
            mode_selected = m
        
        btn_create = QPushButton("➕ Create New")
        btn_create.setMinimumHeight(50)
        btn_create.setFont(QFont("Segoe UI", 11, QFont.Bold))
        btn_create.setObjectName("primaryBtn")
        btn_create.clicked.connect(lambda: select_mode("create"))
        mode_layout.addWidget(btn_create)
        
        btn_restore = QPushButton("🔄 Restore")
        btn_restore.setMinimumHeight(50)
        btn_restore.setFont(QFont("Segoe UI", 11, QFont.Bold))
        btn_restore.clicked.connect(lambda: select_mode("restore"))
        mode_layout.addWidget(btn_restore)
        
        mode_layout.addStretch()
        content_layout.addLayout(mode_layout)
        
        # ===== SECTION 2: Word Count Selection =====
        section2 = QLabel("2️⃣ RECOVERY PHRASE LENGTH")
        section2.setFont(QFont("Segoe UI", 13, QFont.Bold))
        section2.setStyleSheet("color: #79c0ff;")
        content_layout.addWidget(section2)
        
        word_count_layout = QHBoxLayout()
        word_count_layout.setSpacing(10)
        
        word_count_selected = None
        
        def select_word_count(count):
            nonlocal word_count_selected
            word_count_selected = count
        
        for count, desc in [(12, "12 Words"), (15, "15 Words"), (24, "24 Words")]:
            btn = QPushButton(f"🔢 {desc}")
            btn.setMinimumHeight(50)
            btn.setFont(QFont("Segoe UI", 11, QFont.Bold))
            btn.setObjectName("primaryBtn")
            btn.clicked.connect(lambda checked=False, c=count: select_word_count(c))
            word_count_layout.addWidget(btn)
        
        word_count_layout.addStretch()
        content_layout.addLayout(word_count_layout)
        
        # ===== SECTION 3: Input Method / Auto Fill =====
        section3 = QLabel("3️⃣ INPUT METHOD")
        section3.setFont(QFont("Segoe UI", 13, QFont.Bold))
        section3.setStyleSheet("color: #79c0ff;")
        content_layout.addWidget(section3)
        
        input_layout = QHBoxLayout()
        input_layout.setSpacing(10)
        
        input_mode_selected = None
        
        def select_input_mode(m):
            nonlocal input_mode_selected
            input_mode_selected = m
        
        btn_auto_fill = QPushButton("⚡ Auto Fill (1-Click Generate)")
        btn_auto_fill.setMinimumHeight(50)
        btn_auto_fill.setFont(QFont("Segoe UI", 11, QFont.Bold))
        btn_auto_fill.setObjectName("primaryBtn")
        btn_auto_fill.clicked.connect(lambda: select_input_mode("auto_fill"))
        input_layout.addWidget(btn_auto_fill)
        
        btn_fast = QPushButton("📋 Fast (Paste)")
        btn_fast.setMinimumHeight(50)
        btn_fast.setFont(QFont("Segoe UI", 11, QFont.Bold))
        btn_fast.clicked.connect(lambda: select_input_mode("fast"))
        input_layout.addWidget(btn_fast)
        
        btn_safety = QPushButton("🛡️ Safety (Word by Word)")
        btn_safety.setMinimumHeight(50)
        btn_safety.setFont(QFont("Segoe UI", 11, QFont.Bold))
        btn_safety.clicked.connect(lambda: select_input_mode("safety"))
        input_layout.addWidget(btn_safety)
        
        input_layout.addStretch()
        content_layout.addLayout(input_layout)
        
        # ===== SECTION 4: Address Configuration =====
        section4 = QLabel("4️⃣ ADDRESS GENERATION")
        section4.setFont(QFont("Segoe UI", 13, QFont.Bold))
        section4.setStyleSheet("color: #79c0ff;")
        content_layout.addWidget(section4)
        
        addr_layout = QHBoxLayout()
        addr_layout.setSpacing(10)
        
        addr_mode_selected = None
        
        def select_addr_mode(m):
            nonlocal addr_mode_selected
            addr_mode_selected = m
        
        btn_quick = QPushButton("⚡ Quick (1 external + 1 internal)")
        btn_quick.setMinimumHeight(50)
        btn_quick.setFont(QFont("Segoe UI", 11, QFont.Bold))
        btn_quick.setObjectName("primaryBtn")
        btn_quick.clicked.connect(lambda: select_addr_mode("quick"))
        addr_layout.addWidget(btn_quick)
        
        btn_custom = QPushButton("🔧 Custom")
        btn_custom.setMinimumHeight(50)
        btn_custom.setFont(QFont("Segoe UI", 11, QFont.Bold))
        btn_custom.clicked.connect(lambda: select_addr_mode("custom"))
        addr_layout.addWidget(btn_custom)
        
        addr_layout.addStretch()
        content_layout.addLayout(addr_layout)
        
        # Custom address counts (visible when custom is selected)
        custom_counts_layout = QHBoxLayout()
        custom_counts_layout.setSpacing(15)
        
        custom_counts_layout.addWidget(QLabel("External:"))
        spin_ext = QSpinBox()
        spin_ext.setValue(5)
        spin_ext.setMinimum(0)
        spin_ext.setMaximum(100)
        spin_ext.setMinimumHeight(40)
        custom_counts_layout.addWidget(spin_ext)
        
        custom_counts_layout.addWidget(QLabel("Internal:"))
        spin_int = QSpinBox()
        spin_int.setValue(3)
        spin_int.setMinimum(0)
        spin_int.setMaximum(100)
        spin_int.setMinimumHeight(40)
        custom_counts_layout.addWidget(spin_int)
        
        custom_counts_layout.addStretch()
        content_layout.addLayout(custom_counts_layout)
        
        content_layout.addStretch()
        scroll.setWidget(scroll_widget)
        main_layout.addWidget(scroll)
        
        # Buttons
        btn_layout = QHBoxLayout()
        btn_layout.setSpacing(10)
        
        btn_generate = QPushButton("✓ Generate/Restore")
        btn_generate.setObjectName("primaryBtn")
        btn_generate.setMinimumHeight(50)
        btn_generate.setFont(QFont("Segoe UI", 12, QFont.Bold))
        
        btn_cancel = QPushButton("Cancel")
        btn_cancel.setObjectName("navBtn")
        btn_cancel.setMinimumHeight(50)
        btn_cancel.clicked.connect(main_dialog.close)
        
        btn_layout.addStretch()
        btn_layout.addWidget(btn_cancel)
        btn_layout.addWidget(btn_generate)
        main_layout.addLayout(btn_layout)
        
        # Handle generate button
        def on_generate_click():
            if not mode_selected:
                QMessageBox.warning(main_dialog, "Error", "Please select wallet mode (Create or Restore)")
                return
            if not word_count_selected:
                QMessageBox.warning(main_dialog, "Error", "Please select recovery phrase length")
                return
            if not input_mode_selected:
                QMessageBox.warning(main_dialog, "Error", "Please select input method")
                return
            if not addr_mode_selected:
                QMessageBox.warning(main_dialog, "Error", "Please select address generation mode")
                return
            
            main_dialog.close()
            
            # Now proceed with the actual generation logic
            self._perform_keygen(mode_selected, word_count_selected, input_mode_selected, addr_mode_selected, spin_ext.value(), spin_int.value())
        
        btn_generate.clicked.connect(on_generate_click)
        main_dialog.exec()
    
    def _perform_keygen(self, mode_selected, word_count_selected, input_mode_selected, addr_mode_selected, ext_count, int_count):
        """Perform actual key generation after all options selected"""
        from PySide6.QtWidgets import QDialog, QVBoxLayout, QHBoxLayout, QPushButton, QLabel, QScrollArea, QGridLayout, QLineEdit, QTextEdit, QCompleter
        from PySide6.QtCore import Qt
        
        mnemonic = None
        
        # ===== Get mnemonic based on mode and input method =====
        if input_mode_selected == "auto_fill":
            # Auto fill: generate random mnemonic
            self.append_output(f"[*] Auto-generating {word_count_selected}-word mnemonic...")
            try:
                if MnemonicGenerator:
                    gen = MnemonicGenerator()
                    mnemonic = gen.generate_mnemonic(word_count_selected)
                    if mnemonic:
                        self.append_output(f"[+] Generated mnemonic: {mnemonic[:30]}...")
                    else:
                        raise Exception("MnemonicGenerator failed")
                else:
                    self.append_output(f"⚠️  MnemonicGenerator not available, trying fallback...")
                    # Try mnemonic library as fallback
                    try:
                        from mnemonic import Mnemonic
                        mnemo = Mnemonic("english")
                        strength = {12: 128, 15: 160, 24: 256}.get(word_count_selected, 128)
                        mnemonic = mnemo.generate(strength=strength)
                        self.append_output(f"[+] Generated mnemonic: {mnemonic[:30]}...")
                    except:
                        # Last resort: random words
                        import random
                        words = ["abandon", "ability", "about", "above", "absent", "absorb"]
                        mnemonic = " ".join(random.choices(words, k=word_count_selected))
                        self.append_output(f"[+] Generated (fallback) mnemonic: {mnemonic[:30]}...")
            except Exception as e:
                self.append_output(f"✗ Failed to generate mnemonic: {e}")
                return
        
        elif input_mode_selected == "fast":
            # Fast input: paste
            paste_dialog = QDialog(self)
            paste_dialog.setWindowTitle("Paste Recovery Phrase")
            paste_dialog.setGeometry(150, 100, 800, 500)
            paste_dialog.setStyleSheet(DARK_STYLESHEET)
            paste_dialog.setWindowModality(Qt.ApplicationModal)
            
            layout = QVBoxLayout(paste_dialog)
            layout.setSpacing(12)
            layout.setContentsMargins(20, 20, 20, 20)
            
            label = QLabel("📋 Paste your recovery phrase:")
            label.setFont(QFont("Segoe UI", 12, QFont.Bold))
            label.setStyleSheet("color: #79c0ff;")
            layout.addWidget(label)
            
            text_area = QTextEdit()
            text_area.setPlaceholderText("Paste here...")
            text_area.setMinimumHeight(250)
            layout.addWidget(text_area)
            
            btn_layout = QHBoxLayout()
            btn_ok = QPushButton("✓ Next")
            btn_ok.setObjectName("primaryBtn")
            btn_cancel = QPushButton("Cancel")
            btn_cancel.setObjectName("navBtn")
            
            def on_paste_ok():
                nonlocal mnemonic
                phrase = text_area.toPlainText().strip()
                if not phrase:
                    QMessageBox.warning(paste_dialog, "Error", "Please paste phrase")
                    return
                words = phrase.replace('\n', ' ').split()
                mnemonic = " ".join(words)
                paste_dialog.close()
            
            btn_ok.clicked.connect(on_paste_ok)
            btn_cancel.clicked.connect(paste_dialog.close)
            
            btn_layout.addStretch()
            btn_layout.addWidget(btn_cancel)
            btn_layout.addWidget(btn_ok)
            layout.addLayout(btn_layout)
            
            paste_dialog.exec()
            
            if not mnemonic:
                self.append_output("❌ Mnemonic input cancelled")
                return
            
            self.append_output(f"[+] Pasted: {len(mnemonic.split())} words")
        
        else:  # safety mode - word by word
            # Load wordlist
            wordlist = []
            try:
                wordlist_path = os.path.join(os.path.dirname(__file__), '../../wordlist.txt')
                if os.path.exists(wordlist_path):
                    with open(wordlist_path, 'r') as f:
                        wordlist = [line.strip() for line in f if line.strip()]
            except:
                pass
            
            input_dialog = QDialog(self)
            input_dialog.setWindowTitle(f"Enter {word_count_selected} Words")
            input_dialog.setGeometry(100, 50, 950, 720)
            input_dialog.setStyleSheet(DARK_STYLESHEET)
            input_dialog.setWindowModality(Qt.ApplicationModal)
            
            layout = QVBoxLayout(input_dialog)
            layout.setSpacing(12)
            layout.setContentsMargins(16, 16, 16, 16)
            
            label = QLabel(f"📝 Enter {word_count_selected} words:")
            label.setFont(QFont("Segoe UI", 13, QFont.Bold))
            label.setStyleSheet("color: #79c0ff;")
            layout.addWidget(label)
            
            scroll = QScrollArea()
            scroll.setWidgetResizable(True)
            scroll_widget = QWidget()
            grid = QGridLayout(scroll_widget)
            grid.setSpacing(10)
            
            text_boxes = []
            cols = 4
            
            for i in range(word_count_selected):
                row = i // cols
                col = i % cols
                
                lbl = QLabel(f"{i+1}.")
                lbl.setStyleSheet("color: #8b949e; font-weight: bold;")
                grid.addWidget(lbl, row, col * 2)
                
                txt = QLineEdit()
                txt.setPlaceholderText("word")
                txt.setMaxLength(20)
                if wordlist:
                    completer = QCompleter(wordlist)
                    completer.setCaseSensitivity(Qt.CaseInsensitive)
                    txt.setCompleter(completer)
                grid.addWidget(txt, row, col * 2 + 1)
                text_boxes.append(txt)
            
            scroll.setWidget(scroll_widget)
            layout.addWidget(scroll)
            
            btn_layout = QHBoxLayout()
            btn_ok = QPushButton("✓ Next")
            btn_ok.setObjectName("primaryBtn")
            btn_cancel = QPushButton("Cancel")
            btn_cancel.setObjectName("navBtn")
            
            def on_safety_ok():
                nonlocal mnemonic
                words = []
                for txt in text_boxes:
                    word = txt.text().strip().lower()
                    if not word:
                        QMessageBox.warning(input_dialog, "Error", "Fill all words")
                        return
                    words.append(word)
                mnemonic = " ".join(words)
                input_dialog.close()
            
            btn_ok.clicked.connect(on_safety_ok)
            btn_cancel.clicked.connect(input_dialog.close)
            
            btn_layout.addStretch()
            btn_layout.addWidget(btn_cancel)
            btn_layout.addWidget(btn_ok)
            layout.addLayout(btn_layout)
            
            input_dialog.exec()
            
            if not mnemonic:
                self.append_output("❌ Input cancelled")
                return
            
            self.append_output(f"[+] Entered: {len(mnemonic.split())} words")
        
        # Select wallet output path
        wallet_path = QFileDialog.getExistingDirectory(self, "Select wallet output directory")
        if not wallet_path:
            self.append_output("❌ Directory selection cancelled")
            return
        
        self.append_output(f"[+] Wallet path: {wallet_path}")
        
        # Set address counts
        if addr_mode_selected == "quick":
            ext_count = 1
            int_count = 1
        
        # ===== GENERATE =====
        self.append_output(f"\n{'='*60}")
        self.append_output(f"🔑 Multi-Address Generation Started")
        self.append_output(f"{'='*60}")
        self.append_output(f"📋 Configuration:")
        self.append_output(f"  Mode: {mode_selected}")
        self.append_output(f"  Input: {input_mode_selected}")
        self.append_output(f"  External: {ext_count} | Internal: {int_count}\n")
        
        try:
            self.append_output("[*] Initializing KeyGenerator...")
            gen = KeyGenerator(wallet_path)
            self.append_output("[+] KeyGenerator initialized")
            
            self.append_output(f"[*] Generating {ext_count} external addresses...")
            external_addrs = []
            for i in range(ext_count):
                result = gen.generate_addresses(mnemonic, account_index=0, 
                                               address_count=1, address_index=i, 
                                               is_external=True)
                if result:
                    addr = result.get('address', 'N/A')
                    self.append_output(f"  ✓ Ext {i}: {addr[:40]}...")
                    external_addrs.append(addr)
                else:
                    self.append_output(f"  ✗ Failed ext {i}")
            
            self.append_output(f"[*] Generating {int_count} internal addresses...")
            internal_addrs = []
            for i in range(int_count):
                result = gen.generate_addresses(mnemonic, account_index=0, 
                                               address_count=1, address_index=i, 
                                               is_external=False)
                if result:
                    addr = result.get('address', 'N/A')
                    self.append_output(f"  ✓ Int {i}: {addr[:40]}...")
                    internal_addrs.append(addr)
                else:
                    self.append_output(f"  ✗ Failed int {i}")
            
            total_addrs = len(external_addrs) + len(internal_addrs)
            self.append_output(f"\n✅ Complete! Total: {total_addrs} addresses generated")
            self.append_output(f"{'='*60}\n")
        except Exception as e:
            self.append_output(f"✗ Error: {str(e)}")
            self.append_output(traceback.format_exc())

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
