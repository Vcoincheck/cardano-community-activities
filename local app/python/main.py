#!/usr/bin/env python3
"""
Main Launcher - Choose between Admin Dashboard or End-User Dashboard
"""
import sys
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QPushButton, QLabel
)
from PySide6.QtGui import QFont
from PySide6.QtCore import Qt


class LauncherWindow(QMainWindow):
    """Application launcher window"""
    
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Cardano Community Activities - Launcher")
        self.setGeometry(200, 200, 600, 400)
        self._setup_ui()
    
    def _setup_ui(self):
        """Setup UI"""
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        
        layout = QVBoxLayout(main_widget)
        layout.setSpacing(30)
        layout.setContentsMargins(40, 40, 40, 40)
        
        # Title
        title = QLabel("🔗 Cardano Community Activities")
        title_font = QFont("Arial", 24, QFont.Bold)
        title.setFont(title_font)
        title.setStyleSheet("color: #FFD700; text-align: center;")
        layout.addWidget(title)
        
        subtitle = QLabel("Choose Application")
        subtitle_font = QFont("Arial", 16)
        subtitle.setFont(subtitle_font)
        subtitle.setStyleSheet("color: #87CEEB; text-align: center;")
        layout.addWidget(subtitle)
        
        layout.addSpacing(30)
        
        # Admin button
        admin_btn = QPushButton("👨‍💼 Admin Dashboard")
        admin_btn.setMinimumHeight(80)
        admin_btn.setFont(QFont("Arial", 14, QFont.Bold))
        admin_btn.setStyleSheet("""
            background-color: #2E7D32;
            color: white;
            border-radius: 8px;
            padding: 15px;
            font-weight: bold;
        """)
        admin_btn.clicked.connect(self._launch_admin)
        layout.addWidget(admin_btn)
        
        # End-user button
        user_btn = QPushButton("🔐 End-User Tools")
        user_btn.setMinimumHeight(80)
        user_btn.setFont(QFont("Arial", 14, QFont.Bold))
        user_btn.setStyleSheet("""
            background-color: #1976D2;
            color: white;
            border-radius: 8px;
            padding: 15px;
            font-weight: bold;
        """)
        user_btn.clicked.connect(self._launch_enduser)
        layout.addWidget(user_btn)
        
        layout.addStretch()
        
        # Styling
        main_widget.setStyleSheet("background-color: #1e1e1e;")
    
    def _launch_admin(self):
        """Launch admin dashboard"""
        self.hide()
        from app.admin_dashboard import AdminDashboard
        self.admin_window = AdminDashboard()
        self.admin_window.show()
        self.admin_window.destroyed.connect(self.show)
    
    def _launch_enduser(self):
        """Launch end-user dashboard"""
        self.hide()
        from app.end_user_dashboard import EndUserDashboard
        self.user_window = EndUserDashboard()
        self.user_window.show()
        self.user_window.destroyed.connect(self.show)


def main():
    """Main entry point"""
    app = QApplication(sys.argv)
    app.setStyle('Fusion')
    
    launcher = LauncherWindow()
    launcher.show()
    
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
