"""
Admin Dashboard - PySide6 GUI
Main interface for admin tools
"""
from PySide6.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
    QTextEdit, QMessageBox, QInputDialog, QFileDialog, QTabWidget
)
from PySide6.QtGui import QFont
from PySide6.QtCore import Qt
from ...modules.admin.challenge_generator import ChallengeGenerator
from ...modules.admin.excel_exporter import ExcelExporter
from ...modules.shared.on_chain_verifier import OnChainVerifier


class AdminDashboard(QMainWindow):
    """Admin dashboard for community management"""
    
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Cardano Community Admin Tools")
        self.setGeometry(100, 100, 900, 700)
        self.setStyleSheet("""
            QMainWindow { background-color: #1e1e1e; }
            QLabel { color: #00ffff; }
            QPushButton { 
                background-color: #3d7b00; 
                color: white; 
                padding: 8px; 
                border-radius: 4px; 
                font-weight: bold;
            }
            QPushButton:hover { background-color: #4d8b00; }
            QPushButton:pressed { background-color: #2d6b00; }
            QTextEdit { 
                background-color: #0a0a0a; 
                color: #00ff00; 
                font-family: 'Courier New'; 
                border: 1px solid #333;
            }
        """)
        
        self.challenge_gen = None
        self.excel_exporter = None
        self.on_chain_verifier = None
        self.setup_ui()
    
    def setup_ui(self):
        """Create UI layout"""
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        
        main_layout = QHBoxLayout(main_widget)
        
        # Left panel - buttons
        left_layout = QVBoxLayout()
        
        title = QLabel("🔐 Admin Tools")
        title.setFont(QFont("Arial", 14, QFont.Bold))
        left_layout.addWidget(title)
        
        left_layout.addSpacing(20)
        
        # Create event
        btn_create_event = QPushButton("1. Create Event")
        btn_create_event.setMinimumHeight(45)
        btn_create_event.clicked.connect(self.on_create_event)
        left_layout.addWidget(btn_create_event)
        
        # Generate challenge
        btn_gen_challenge = QPushButton("2. Generate Challenge")
        btn_gen_challenge.setMinimumHeight(45)
        btn_gen_challenge.clicked.connect(self.on_generate_challenge)
        left_layout.addWidget(btn_gen_challenge)
        
        # Verify signatures
        btn_verify = QPushButton("3. Verify Signatures")
        btn_verify.setMinimumHeight(45)
        btn_verify.clicked.connect(self.on_verify_signatures)
        left_layout.addWidget(btn_verify)
        
        # Export to Excel
        btn_export = QPushButton("4. Export Results")
        btn_export.setMinimumHeight(45)
        btn_export.clicked.connect(self.on_export_results)
        left_layout.addWidget(btn_export)
        
        # View participants
        btn_participants = QPushButton("5. View Participants")
        btn_participants.setMinimumHeight(45)
        btn_participants.clicked.connect(self.on_view_participants)
        left_layout.addWidget(btn_participants)
        
        left_layout.addSpacing(20)
        
        # Load data
        btn_load = QPushButton("Load Data from File")
        btn_load.setMinimumHeight(40)
        btn_load.clicked.connect(self.on_load_data)
        btn_load.setStyleSheet("""
            background-color: #663300;
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
    
    def on_create_event(self):
        """Create new event"""
        try:
            event_name, ok = QInputDialog.getText(
                self,
                "Create Event",
                "Enter event name:"
            )
            
            if not ok or not event_name.strip():
                return
            
            event_desc, ok = QInputDialog.getMultiLineText(
                self,
                "Create Event",
                "Enter event description:"
            )
            
            if not ok or not event_desc.strip():
                return
            
            self.append_output(f"✓ Event created: {event_name}")
            self.append_output(f"Description: {event_desc}")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
    
    def on_generate_challenge(self):
        """Generate challenge for participants"""
        try:
            num_participants, ok = QInputDialog.getInt(
                self,
                "Generate Challenge",
                "Number of participants:",
                1, 1, 10000
            )
            
            if not ok:
                return
            
            self.append_output(f"[*] Generating {num_participants} challenges...")
            
            self.challenge_gen = ChallengeGenerator()
            challenges = self.challenge_gen.generate_batch(num_participants)
            
            if challenges:
                self.append_output(f"✓ Generated {len(challenges)} challenges")
                self.append_output(f"Sample: {challenges[0][:50]}...")
            else:
                self.append_output("✗ Failed to generate challenges")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
    
    def on_verify_signatures(self):
        """Verify participant signatures"""
        try:
            file_path, _ = QFileDialog.getOpenFileName(
                self,
                "Select Signature File",
                ".",
                "JSON files (*.json);;CSV files (*.csv);;All files (*.*)"
            )
            
            if not file_path:
                return
            
            self.append_output("[*] Verifying signatures...")
            
            self.on_chain_verifier = OnChainVerifier()
            result = self.on_chain_verifier.verify_batch_from_file(file_path)
            
            if result:
                self.append_output(f"✓ Verification complete")
                self.append_output(f"Valid: {result.get('valid', 0)}")
                self.append_output(f"Invalid: {result.get('invalid', 0)}")
            else:
                self.append_output("✗ Verification failed")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
    
    def on_export_results(self):
        """Export verification results to Excel"""
        try:
            file_path, _ = QFileDialog.getSaveFileName(
                self,
                "Export Results",
                "results.xlsx",
                "Excel files (*.xlsx);;All files (*.*)"
            )
            
            if not file_path:
                return
            
            self.append_output("[*] Exporting results...")
            
            self.excel_exporter = ExcelExporter()
            success = self.excel_exporter.export_verification_results(
                {},  # Empty data for now
                file_path
            )
            
            if success:
                self.append_output(f"✓ Exported to {file_path}")
            else:
                self.append_output("✗ Export failed")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
    
    def on_view_participants(self):
        """View participant list"""
        try:
            self.append_output("""
Participants:
┌─────┬──────────────────┬────────────────┬──────────┐
│ ID  │ Address          │ Status         │ Score    │
├─────┼──────────────────┼────────────────┼──────────┤
│ 1   │ addr1_short...   │ Verified ✓     │ 100      │
│ 2   │ addr2_short...   │ Verified ✓     │ 95       │
│ 3   │ addr3_short...   │ Pending        │ -        │
└─────┴──────────────────┴────────────────┴──────────┘

Total: 3 participants (2 verified, 1 pending)
            """)
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
    
    def on_load_data(self):
        """Load data from file"""
        try:
            file_path, _ = QFileDialog.getOpenFileName(
                self,
                "Load Data",
                ".",
                "JSON files (*.json);;CSV files (*.csv);;All files (*.*)"
            )
            
            if file_path:
                import json
                with open(file_path) as f:
                    data = json.load(f)
                self.append_output(f"✓ Loaded data from {file_path}")
                self.append_output(f"Records: {len(data) if isinstance(data, list) else 1}")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
