# Quick Start Guide - Python Edition

## 5 Phút Để Chạy Ứng Dụng

### Step 1: Chuẩn Bị (1 phút)

```bash
# Vào folder python
cd python

# Kiểm tra Python version (phải >= 3.8)
python --version
```

### Step 2: Setup (2 phút)

**Trên Linux/macOS:**
```bash
chmod +x setup.sh
./setup.sh
```

**Trên Windows:**
```bash
setup.bat
```

**Manual Setup:**
```bash
# Tạo virtual environment
python -m venv venv

# Activate
# Linux/macOS
source venv/bin/activate
# Windows
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### Step 3: Chạy (30 giây)

```bash
python main.py
```

✅ Ứng dụng sẽ mở cửa sổ launcher!

## 🎯 Hai Apps

### 1. Admin Dashboard 👨‍💼

**Công dụng:**
- Quản lý communities
- Tạo events
- Xuất Excel
- Xác minh on-chain

**Bắt đầu:**
1. Click "Admin Dashboard" từ launcher
2. Click "Create Community"
   - ID: `vcc-ph`
   - Name: `VCC Philippines`
   - Description: `Cardano Community`
   - Click OK ✓
3. Click "Create Event"
   - ID: `event-001`
   - Name: `Meetup January`
   - Date: `2025-01-15`
   - Location: `Manila`
   - Status: `Planned`
   - Click OK ✓
4. Click "Export to Excel"
   - Files sinh ra tại `./exports/`

### 2. End-User Tools 🔐

**Công dụng:**
- Sinh keypair
- Ký tin nhắn
- Xác minh chữ ký

**Bắt đầu:**
1. Click "End-User Tools" từ launcher
2. Click "1. Generate Keypair"
   - Keys lưu tại `./keys/`
   - ✓ Success
3. Click "2. Sign Message"
   - Nhập: `Hello World`
   - Click "Sign"
   - Signature sinh ra
4. Click "4. Verify Local"
   - Paste message, signature, public key
   - Click "Verify"
   - Kết quả: Valid/Invalid

## 📁 Output Files

Sau khi chạy:

```
python/
├── keys/                          # Generated keypairs
│   ├── private_key_20250104_143022.pem
│   └── public_key_20250104_143022.pem
├── exports/                       # Excel exports
│   ├── Communities_Master_20250104_143022.xlsx
│   └── VCC_Philippines_Detail_20250104_143022.xlsx
└── venv/                          # Virtual environment
```

## 🐛 Troubleshooting

### Error: "No module named 'PySide6'"
```bash
pip install PySide6
```

### Error: "openpyxl not found"
```bash
pip install openpyxl
```

### PySide6 GUI không hiển thị
```bash
# Reinstall PySide6
pip uninstall PySide6
pip install PySide6
```

### API không kết nối
- Kiểm tra internet
- Xác minh stake address format

## 📊 Example Data

### Community
```json
{
  "community_id": "vcc-ph",
  "name": "VCC Philippines",
  "description": "Cardano Verification Community",
  "created_date": "2025-01-04",
  "active_members": 0,
  "total_events": 1,
  "status": "Active"
}
```

### Event
```json
{
  "event_id": "event-001",
  "event_name": "Meetup January",
  "event_date": "2025-01-15",
  "location": "Manila",
  "status": "Planned",
  "attendees": 0,
  "description": "Monthly meetup"
}
```

### Challenge
```json
{
  "challenge_id": "a1b2c3d4e5f6...",
  "community_id": "vcc-ph",
  "nonce": "base64_encoded_nonce",
  "timestamp": 1735996800,
  "action": "verify_membership",
  "message": "I hereby verify...",
  "expiry": 1736000400
}
```

## 🔑 Keys Example

### Private Key (PEM)
```
-----BEGIN PRIVATE KEY-----
MC4CAQAwBQYDK2VwBCIEIPhTLu7nBrN7xP9sVhP1Ls7VDqOZ2KqQ...
-----END PRIVATE KEY-----
```

### Public Key (PEM)
```
-----BEGIN PUBLIC KEY-----
MCowBQYDK2VwAyEA8nTd+8xq4Q/tqO+2bX7C8E7v2H7xqV3P...
-----END PUBLIC KEY-----
```

## 🔗 Useful Links

- **PySide6 Docs**: https://doc.qt.io/qtforpython/
- **Koios API**: https://koios.rest/
- **Cardano**: https://cardano.org/

## 📞 Next Steps

1. **Explore GUI**: Click all buttons, try different scenarios
2. **Generate Data**: Create multiple communities and events
3. **Export Files**: Download Excel files và open trong Excel
4. **Test Keys**: Generate keys và ký tin nhắn
5. **Read Docs**: Xem `README.md` để chi tiết hơn

## ✅ Checklist

- [ ] Python 3.8+ installed
- [ ] Setup ran successfully
- [ ] main.py runs without errors
- [ ] Admin Dashboard opens
- [ ] End-User Tools opens
- [ ] Can create community
- [ ] Can create event
- [ ] Can export to Excel
- [ ] Can generate keypair
- [ ] Can sign message
- [ ] Can verify signature

## 🎉 Success!

Nếu mọi thứ hoạt động, bạn sẵn sàng sử dụng ứng dụng!

---

**Estimated Time**: 5 minutes  
**Difficulty**: Easy  
**Status**: ✓ Ready to go!
