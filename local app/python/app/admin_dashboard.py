"""
Community Admin Dashboard - PySide6 GUI
Giao diện quản lý community và event
"""
import sys
import json
from typing import Optional
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QPushButton, QLabel, QTextEdit, QDialog, QLineEdit, QComboBox,
    QMessageBox, QFileDialog
)
from PySide6.QtGui import QFont, QColor
from PySide6.QtCore import Qt, QSize

from app.modules import (
    ChallengeGenerator, OnChainVerifier, CommunityManager, ExcelExporter
)
from app.utils.crypto import Logger


class CommunityDialog(QDialog):
    """Dialog for creating a new community"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Create New Community")
        self.setGeometry(100, 100, 500, 400)
        self.result_data = None
        self._setup_ui()
    
    def _setup_ui(self):
        """Setup dialog UI"""
        layout = QVBoxLayout()
        
        # Title
        title = QLabel("Create New Community")
        title_font = QFont("Arial", 14, QFont.Bold)
        title.setFont(title_font)
        title.setStyleSheet("color: cyan;")
        layout.addWidget(title)
        
        # Community ID
        layout.addWidget(QLabel("Community ID:"))
        self.community_id_input = QLineEdit()
        self.community_id_input.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        layout.addWidget(self.community_id_input)
        
        # Community Name
        layout.addWidget(QLabel("Community Name:"))
        self.name_input = QLineEdit()
        self.name_input.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        layout.addWidget(self.name_input)
        
        # Description
        layout.addWidget(QLabel("Description:"))
        self.desc_input = QTextEdit()
        self.desc_input.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        self.desc_input.setMaximumHeight(120)
        layout.addWidget(self.desc_input)
        
        # Buttons
        btn_layout = QHBoxLayout()
        
        ok_btn = QPushButton("OK")
        ok_btn.setStyleSheet("background-color: #649632; color: white; padding: 8px;")
        ok_btn.clicked.connect(self._on_ok)
        btn_layout.addWidget(ok_btn)
        
        cancel_btn = QPushButton("Cancel")
        cancel_btn.setStyleSheet("background-color: #963232; color: white; padding: 8px;")
        cancel_btn.clicked.connect(self.reject)
        btn_layout.addWidget(cancel_btn)
        
        layout.addLayout(btn_layout)
        
        # Styling
        self.setStyleSheet("background-color: #1e1e1e; color: white;")
        self.setLayout(layout)
    
    def _on_ok(self):
        """Handle OK button click"""
        if not self.community_id_input.text():
            QMessageBox.warning(self, "Error", "Community ID is required")
            return
        
        if not self.name_input.text():
            QMessageBox.warning(self, "Error", "Community Name is required")
            return
        
        self.result_data = {
            'community_id': self.community_id_input.text(),
            'name': self.name_input.text(),
            'description': self.desc_input.toPlainText()
        }
        self.accept()


class EventDialog(QDialog):
    """Dialog for creating a new event"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Create New Event")
        self.setGeometry(100, 100, 500, 500)
        self.result_data = None
        self._setup_ui()
    
    def _setup_ui(self):
        """Setup dialog UI"""
        layout = QVBoxLayout()
        
        # Title
        title = QLabel("Create New Event")
        title_font = QFont("Arial", 14, QFont.Bold)
        title.setFont(title_font)
        title.setStyleSheet("color: cyan;")
        layout.addWidget(title)
        
        # Event ID
        layout.addWidget(QLabel("Event ID:"))
        self.event_id_input = QLineEdit()
        self.event_id_input.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        layout.addWidget(self.event_id_input)
        
        # Event Name
        layout.addWidget(QLabel("Event Name:"))
        self.event_name_input = QLineEdit()
        self.event_name_input.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        layout.addWidget(self.event_name_input)
        
        # Event Date
        layout.addWidget(QLabel("Event Date (YYYY-MM-DD):"))
        self.event_date_input = QLineEdit()
        self.event_date_input.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        from datetime import datetime
        self.event_date_input.setText(datetime.now().strftime('%Y-%m-%d'))
        layout.addWidget(self.event_date_input)
        
        # Location
        layout.addWidget(QLabel("Location:"))
        self.location_input = QLineEdit()
        self.location_input.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        layout.addWidget(self.location_input)
        
        # Status
        layout.addWidget(QLabel("Status:"))
        self.status_combo = QComboBox()
        self.status_combo.addItems(["Planned", "In Progress", "Completed", "Cancelled"])
        self.status_combo.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        layout.addWidget(self.status_combo)
        
        # Description
        layout.addWidget(QLabel("Description:"))
        self.desc_input = QTextEdit()
        self.desc_input.setStyleSheet("background-color: #323232; color: white; padding: 5px;")
        self.desc_input.setMaximumHeight(80)
        layout.addWidget(self.desc_input)
        
        # Buttons
        btn_layout = QHBoxLayout()
        
        ok_btn = QPushButton("OK")
        ok_btn.setStyleSheet("background-color: #649632; color: white; padding: 8px;")
        ok_btn.clicked.connect(self._on_ok)
        btn_layout.addWidget(ok_btn)
        
        cancel_btn = QPushButton("Cancel")
        cancel_btn.setStyleSheet("background-color: #963232; color: white; padding: 8px;")
        cancel_btn.clicked.connect(self.reject)
        btn_layout.addWidget(cancel_btn)
        
        layout.addLayout(btn_layout)
        
        # Styling
        self.setStyleSheet("background-color: #1e1e1e; color: white;")
        self.setLayout(layout)
    
    def _on_ok(self):
        """Handle OK button click"""
        if not self.event_id_input.text():
            QMessageBox.warning(self, "Error", "Event ID is required")
            return
        
        if not self.event_name_input.text():
            QMessageBox.warning(self, "Error", "Event Name is required")
            return
        
        self.result_data = {
            'event_id': self.event_id_input.text(),
            'event_name': self.event_name_input.text(),
            'event_date': self.event_date_input.text(),
            'location': self.location_input.text(),
            'status': self.status_combo.currentText(),
            'description': self.desc_input.toPlainText()
        }
        self.accept()


class AdminDashboard(QMainWindow):
    """Main Admin Dashboard Window"""
    
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Cardano Community Admin Dashboard")
        self.setGeometry(100, 100, 900, 750)
        
        # Initialize modules
        self.community_manager = CommunityManager()
        self.excel_exporter = ExcelExporter("./exports")
        self.challenge_generator = ChallengeGenerator()
        self.onchain_verifier = OnChainVerifier()
        
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
        header = QLabel("👨‍💼 Community Admin Dashboard")
        header_font = QFont("Arial", 16, QFont.Bold)
        header.setFont(header_font)
        header.setStyleSheet("color: yellow;")
        left_panel.addWidget(header)
        
        left_panel.addSpacing(20)
        
        # Buttons
        btn_gen_challenge = self._create_button(
            "Generate Challenge",
            "#649632",
            self._on_generate_challenge
        )
        left_panel.addWidget(btn_gen_challenge)
        
        btn_verify = self._create_button(
            "Verify Signature",
            "#649632",
            self._on_verify_signature
        )
        left_panel.addWidget(btn_verify)
        
        btn_onchain = self._create_button(
            "Check On-Chain Stake",
            "#649632",
            self._on_check_onchain
        )
        left_panel.addWidget(btn_onchain)
        
        btn_registry = self._create_button(
            "View Registry",
            "#649632",
            self._on_view_registry
        )
        left_panel.addWidget(btn_registry)
        
        btn_export = self._create_button(
            "Export Report",
            "#649632",
            self._on_export_report
        )
        left_panel.addWidget(btn_export)
        
        left_panel.addSpacing(20)
        
        # New features
        btn_create_community = self._create_button(
            "Create Community",
            "#9664B4",
            self._on_create_community
        )
        left_panel.addWidget(btn_create_community)
        
        btn_create_event = self._create_button(
            "Create Event",
            "#64B4C8",
            self._on_create_event
        )
        left_panel.addWidget(btn_create_event)
        
        btn_export_excel = self._create_button(
            "Export to Excel",
            "#C89664",
            self._on_export_excel
        )
        left_panel.addWidget(btn_export_excel)
        
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
    
    def _on_generate_challenge(self):
        """Generate challenge"""
        challenge = self.challenge_generator.generate_signing_challenge(
            community_id="cardano-devs-ph",
            action="verify_membership"
        )
        self._append_output(json.dumps(challenge, indent=2))
    
    def _on_verify_signature(self):
        """Verify signature - placeholder"""
        self._append_output("Verify Signature: Not yet implemented")
    
    def _on_check_onchain(self):
        """Check on-chain stake"""
        stake_addr = "stake1uypj8d4dn2ygt8nzrymdnrmx0d0aepz5pjx5z7ncjg5dmqwv8kvu"
        result = self.onchain_verifier.verify_stake(stake_addr)
        self._append_output(json.dumps(result, indent=2))
    
    def _on_view_registry(self):
        """View registry - placeholder"""
        self._append_output("View Registry: Not yet implemented")
    
    def _on_export_report(self):
        """Export report - placeholder"""
        self._append_output("Export Report: Not yet implemented")
    
    def _on_create_community(self):
        """Create community dialog"""
        dialog = CommunityDialog(self)
        if dialog.exec() == QDialog.Accepted:
            if dialog.result_data:
                success = self.community_manager.add_community(
                    dialog.result_data['community_id'],
                    dialog.result_data['name'],
                    dialog.result_data['description']
                )
                if success:
                    self._append_output(f"✓ Community created:\n{json.dumps(dialog.result_data, indent=2)}")
    
    def _on_create_event(self):
        """Create event dialog"""
        dialog = EventDialog(self)
        if dialog.exec() == QDialog.Accepted:
            if dialog.result_data:
                success = self.community_manager.add_event(
                    'default-community',
                    dialog.result_data['event_id'],
                    dialog.result_data['event_name'],
                    dialog.result_data['event_date'],
                    dialog.result_data['location'],
                    dialog.result_data['status'],
                    dialog.result_data['description']
                )
                if success:
                    self._append_output(f"✓ Event created:\n{json.dumps(dialog.result_data, indent=2)}")
    
    def _on_export_excel(self):
        """Export to Excel"""
        communities = self.community_manager.get_all_communities()
        events = self.community_manager.get_all_events()
        
        if not communities:
            self._append_output("✗ No communities to export. Create a community first.")
            return
        
        try:
            # Export master file
            export_file = self.excel_exporter.export_communities_excel(communities, format_type="xlsx")
            self._append_output(f"✓ Master export: {export_file}")
            
            # Export individual communities
            for community in communities:
                comm_events = self.community_manager.get_community_events(community['community_id'])
                if comm_events:
                    export_file = self.excel_exporter.export_community_detail_excel(
                        community['community_id'],
                        community['name'],
                        comm_events,
                        [],
                        format_type="xlsx"
                    )
                    self._append_output(f"✓ Community export: {export_file}")
            
            self._append_output(f"\n✓ Export completed!\nCommunities: {len(communities)}\nEvents: {len(events)}")
        
        except Exception as e:
            self._append_output(f"✗ Export error: {str(e)}")


def main():
    """Main entry point"""
    app = QApplication(sys.argv)
    
    # Set dark theme
    app.setStyle('Fusion')
    
    dashboard = AdminDashboard()
    dashboard.show()
    
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
