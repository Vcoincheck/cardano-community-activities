"""
Main Application - PySide6 GUI Launcher
Switch between admin and end-user modes
"""
import sys
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QPushButton, QLabel, QDialog, QMessageBox, QComboBox
)
from PySide6.QtGui import QFont, QIcon
from PySide6.QtCore import Qt


class MainLauncher(QMainWindow):
    """Main launcher to choose between admin and end-user modes"""
    
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Cardano Community Activities")
        self.setGeometry(100, 100, 600, 400)
        self.setStyleSheet("""
            QMainWindow { background-color: #1e1e1e; }
            QLabel { color: #00ffff; }
            QPushButton { 
                background-color: #3d7ba4; 
                color: white; 
                padding: 12px; 
                border-radius: 6px; 
                font-weight: bold;
                font-size: 13pt;
            }
            QPushButton:hover { background-color: #4d8bb4; }
            QPushButton:pressed { background-color: #2d6b94; }
        """)
        
        self.setup_ui()
    
    def setup_ui(self):
        """Create launcher UI"""
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        
        layout = QVBoxLayout(main_widget)
        layout.setSpacing(20)
        layout.setContentsMargins(40, 40, 40, 40)
        
        # Header
        header = QLabel("🔐 Cardano Community Activities")
        header.setFont(QFont("Arial", 20, QFont.Bold))
        header.setAlignment(Qt.AlignCenter)
        layout.addWidget(header)
        
        # Subtitle
        subtitle = QLabel("Select your role:")
        subtitle.setFont(QFont("Arial", 12))
        subtitle.setAlignment(Qt.AlignCenter)
        layout.addWidget(subtitle)
        
        layout.addSpacing(30)
        
        # Admin button
        btn_admin = QPushButton("👥 Admin Mode")
        btn_admin.setMinimumHeight(60)
        btn_admin.setFont(QFont("Arial", 13, QFont.Bold))
        btn_admin.setStyleSheet("""
            background-color: #2d7b3a;
            color: white;
            padding: 15px;
            border-radius: 8px;
            font-weight: bold;
            font-size: 14pt;
        """)
        btn_admin.clicked.connect(self.launch_admin)
        layout.addWidget(btn_admin)
        
        # End-user button
        btn_user = QPushButton("👤 End-User Mode")
        btn_user.setMinimumHeight(60)
        btn_user.setFont(QFont("Arial", 13, QFont.Bold))
        btn_user.setStyleSheet("""
            background-color: #3d6b9a;
            color: white;
            padding: 15px;
            border-radius: 8px;
            font-weight: bold;
            font-size: 14pt;
        """)
        btn_user.clicked.connect(self.launch_user)
        layout.addWidget(btn_user)
        
        layout.addSpacing(20)
        
        # Exit button
        btn_exit = QPushButton("Exit")
        btn_exit.clicked.connect(self.close)
        layout.addWidget(btn_exit)
        
        layout.addStretch()
    
    def launch_admin(self):
        """Launch admin dashboard"""
        try:
            from .modules.admin.admin_dashboard import AdminDashboard
            self.admin_window = AdminDashboard()
            self.admin_window.show()
            self.hide()
        except ImportError as e:
            QMessageBox.critical(self, "Error", f"Failed to load admin module: {e}")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")
    
    def launch_user(self):
        """Launch end-user dashboard"""
        try:
            from .modules.end_user.end_user_dashboard import EndUserDashboard
            self.user_window = EndUserDashboard()
            self.user_window.show()
            self.hide()
        except ImportError as e:
            QMessageBox.critical(self, "Error", f"Failed to load user module: {e}")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error: {e}")


def main():
    """Main entry point"""
    app = QApplication(sys.argv)
    
    launcher = MainLauncher()
    launcher.show()
    
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
