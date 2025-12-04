# Cardano Community Activities - Python Edition

Phiên bản Python của ứng dụng Cardano Community Activities với giao diện PySide6.

## 📋 Tổng Quan

Dự án này chuyển đổi toàn bộ mã PowerShell thành Python với các tính năng:

- **Admin Dashboard**: Quản lý communities, events, sinh challenge, xác minh on-chain
- **End-User Tools**: Sinh khóa, ký tin nhắn, xác minh chữ ký
- **Excel Export**: Xuất dữ liệu thành file Excel/CSV
- **Giao diện PySide6**: GUI hiện đại với theme tối

## 🚀 Cài Đặt

### Yêu Cầu
- Python 3.8+
- pip hoặc conda

### Bước 1: Tạo Virtual Environment

```bash
cd /path/to/python
python -m venv venv

# Trên Linux/macOS
source venv/bin/activate

# Trên Windows
venv\Scripts\activate
```

### Bước 2: Cài Đặt Dependencies

```bash
pip install -r requirements.txt
```

### Bước 3: Chạy Ứng Dụng

```bash
python main.py
```

## 📁 Cấu Trúc Dự Án

```
python/
├── main.py                  # Main launcher
├── requirements.txt         # Dependencies
├── README.md               # This file
└── app/
    ├── __init__.py
    ├── admin_dashboard.py   # Admin GUI
    ├── end_user_dashboard.py # End-User GUI
    ├── modules/            # Business logic
    │   ├── __init__.py
    │   ├── challenge_generator.py
    │   ├── onchain_verifier.py
    │   ├── community_manager.py
    │   ├── excel_exporter.py
    │   ├── key_generator.py
    │   └── message_signer.py
    └── utils/              # Utilities
        ├── __init__.py
        └── crypto.py
```

## 🎯 Tính Năng

### Admin Dashboard

#### 1. Generate Challenge
- Sinh challenge mã hóa với nonce và community ID
- Thêm timestamp và expiry time
- Export dưới dạng JSON

#### 2. Create Community
- Dialog để tạo community mới
- Nhập Community ID, Name, Description
- Auto-gen Created Date, Status, Event Count

#### 3. Create Event
- Dialog để tạo event trong community
- Nhập Event ID, Name, Date, Location, Status
- Tự động cập nhật community event count

#### 4. Check On-Chain Stake
- Xác minh stake address trên-chain qua Koios API
- Lấy balance, status
- Hiển thị balance ADA và Lovelace

#### 5. Export to Excel
- Xuất master file: `Communities_Master_[timestamp].xlsx`
- Xuất chi tiết: `[CommunityName]_Detail_[timestamp].xlsx`
- Tự động formatting: frozen headers, auto-size columns, table styling
- Fallback to CSV nếu openpyxl không cài

### End-User Tools

#### 1. Generate Keypair
- Sinh Ed25519 keypair
- Lưu private key và public key thành file PEM
- Hiển thị keys trong output panel

#### 2. Sign Message (Offline)
- Ký tin nhắn với private key
- Xuất signature dưới dạng base64
- Không cần kết nối mạng

#### 3. Verify Signature
- Xác minh chữ ký bằng public key
- Hỗ trợ Ed25519
- Local verification (không cần mạng)

#### 4. Load Keys from File
- Load private key từ file PEM
- Sử dụng cho signing

#### 5. Export Wallet
- Placeholder cho tính năng tương lai

## 🔧 Module Chi Tiết

### challenge_generator.py
```python
from app.modules import ChallengeGenerator

# Generate challenge
challenge = ChallengeGenerator.generate_signing_challenge(
    community_id="vcc-ph",
    action="verify_membership"
)
```

### onchain_verifier.py
```python
from app.modules import OnChainVerifier

# Verify on-chain stake
result = OnChainVerifier.verify_stake(
    stake_address="stake1u...",
    api_provider="koios"
)
```

### community_manager.py
```python
from app.modules import CommunityManager

manager = CommunityManager()

# Add community
manager.add_community("vcc-ph", "VCC Philippines", "Community description")

# Add event
manager.add_event("vcc-ph", "event-001", "Meetup", "2025-01-15", "Manila", "Planned")

# Get data
communities = manager.get_all_communities()
events = manager.get_community_events("vcc-ph")
```

### excel_exporter.py
```python
from app.modules import ExcelExporter

exporter = ExcelExporter("./exports")

# Export communities
exporter.export_communities_excel(communities, format_type="xlsx")

# Export community details
exporter.export_community_detail_excel(
    "vcc-ph", "VCC Philippines", events, members
)
```

### key_generator.py
```python
from app.modules import KeyGenerator

# Generate keypair
result = KeyGenerator.generate_keypair("./keys")
# Returns: {
#   'private_key': PEM string,
#   'public_key': PEM string,
#   'private_path': file path,
#   'public_path': file path
# }
```

### message_signer.py
```python
from app.modules import MessageSigner

# Sign message
result = MessageSigner.sign_message("Hello World", private_key_pem)

# Verify signature
is_valid = MessageSigner.verify_signature(message, signature_b64, public_key_pem)
```

## 📊 Data Persistence

Hiện tại, dữ liệu được lưu trong memory. Để sử dụng production:

### Option 1: JSON Files
```python
import json

def save_communities(communities, filepath):
    with open(filepath, 'w') as f:
        json.dump(communities, f, indent=2)

def load_communities(filepath):
    with open(filepath, 'r') as f:
        return json.load(f)
```

### Option 2: Database (SQLite)
```python
import sqlite3

# Create connection
conn = sqlite3.connect('cardano.db')
cursor = conn.cursor()

# Create tables
cursor.execute('''
    CREATE TABLE communities (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        created_date TEXT,
        status TEXT
    )
''')
```

### Option 3: PostgreSQL/MySQL
Sử dụng SQLAlchemy hoặc psycopg2

## 📦 Dependencies

- **PySide6**: GUI framework
- **openpyxl**: Excel file handling
- **pandas**: Data manipulation
- **requests**: HTTP requests (Koios API)
- **cryptography**: Cryptographic operations
- **pydantic**: Data validation
- **python-dotenv**: Environment variables

## 🔐 Bảo Mật

### Best Practices

1. **Private Keys**: Luôn lưu riêng tư, không commit vào Git
2. **Environment Variables**: Sử dụng `.env` cho API keys
3. **Signatures**: Xác minh trước khi sử dụng
4. **HTTPS**: Luôn dùng HTTPS cho API calls

### File .gitignore
```
venv/
__pycache__/
*.pyc
.env
keys/
exports/
*.xlsx
*.csv
```

## 🐛 Troubleshooting

### PySide6 không cài được
```bash
pip install --upgrade PySide6
# Hoặc dùng conda
conda install PySide6
```

### openpyxl không tìm thấy
```bash
pip install openpyxl
```

### API Koios không kết nối
- Kiểm tra internet connection
- Xác minh stake address format
- Fallback to CSV export nếu cần

## 📝 Hướng Dẫn Sử Dụng

### Workflow Admin

1. Chạy `python main.py`
2. Click "Admin Dashboard"
3. Click "Create Community"
   - Nhập ID, Name, Description
   - Click OK
4. Click "Create Event"
   - Nhập thông tin event
   - Click OK
5. Click "Export to Excel"
   - Files được sinh ra tại `./exports/`

### Workflow End-User

1. Chạy `python main.py`
2. Click "End-User Tools"
3. Click "1. Generate Keypair"
   - Keys được lưu tại `./keys/`
4. Click "2. Sign Message (Offline)"
   - Nhập message
   - Signature sinh ra
5. Click "4. Verify Local"
   - Nhập message, signature, public key
   - Kiểm tra valid/invalid

## 🚧 Future Enhancements

- [ ] Database integration (SQLite/PostgreSQL)
- [ ] CSV import for bulk operations
- [ ] Email notifications
- [ ] Calendar integration
- [ ] Web-based signing (Midnight Signer)
- [ ] Multi-language support
- [ ] Dark/Light theme toggle
- [ ] Custom reports
- [ ] Member management
- [ ] Event attendance tracking

## 📄 License

Theo dõi file LICENSE trong root repository

## 👥 Contributors

Cardano Community

## 📞 Support

Cho câu hỏi hoặc issue, vui lòng tạo issue mới trong repository

---

**Version**: 1.0.0  
**Last Updated**: December 4, 2025
