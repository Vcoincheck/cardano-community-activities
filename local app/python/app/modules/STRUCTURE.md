# Python App Modules Structure

## Overview
Các modules được tổ chức thành 3 thư mục chính: `admin`, `end_user`, và `shared`.

## Directory Structure

```
app/modules/
├── __init__.py                 # Main package init
├── admin/                      # Community Admin modules
│   ├── __init__.py
│   ├── community_manager.py   # Manage communities and events
│   └── excel_exporter.py      # Export to Excel/CSV
├── end_user/                  # End-User App modules
│   ├── __init__.py
│   ├── key_generator.py       # Generate cryptographic keypairs
│   └── message_signer.py      # Sign and verify messages
└── shared/                    # Shared modules for both apps
    ├── __init__.py
    ├── challenge_generator.py # Generate signing challenges
    └── onchain_verifier.py    # Verify on-chain stake
```

## Module Descriptions

### Admin Modules (`app.modules.admin`)

#### CommunityManager
Quản lý communities và events:
```python
from app.modules.admin import CommunityManager

manager = CommunityManager()
manager.add_community("vcc-ph", "VCC Philippines", "Community description")
manager.add_event("vcc-ph", "event-001", "Event Name", "2025-01-15", "Manila")
communities = manager.get_all_communities()
```

#### ExcelExporter
Xuất dữ liệu ra Excel/CSV:
```python
from app.modules.admin import ExcelExporter

exporter = ExcelExporter(output_path="./exports")
exporter.export_communities_excel(communities, format_type="xlsx")
exporter.export_community_detail_excel(community_id, community_name, events)
```

---

### End-User Modules (`app.modules.end_user`)

#### KeyGenerator
Tạo cặp khóa mã hóa:
```python
from app.modules.end_user import KeyGenerator

keys = KeyGenerator.generate_keypair(save_path="./keys")
# Returns: private_key, public_key, private_path, public_path
```

#### MessageSigner
Ký và xác minh tin nhắn:
```python
from app.modules.end_user import MessageSigner

# Ký tin nhắn
result = MessageSigner.sign_message("Hello World", private_key_pem)

# Xác minh chữ ký
is_valid = MessageSigner.verify_signature(message, signature, public_key_pem)
```

---

### Shared Modules (`app.modules.shared`)

#### ChallengeGenerator
Tạo thử thách mã hóa:
```python
from app.modules.shared import ChallengeGenerator

challenge = ChallengeGenerator.generate_signing_challenge(
    community_id="vcc-ph",
    action="verify_membership"
)
```

#### OnChainVerifier
Xác minh stake trên blockchain:
```python
from app.modules.shared import OnChainVerifier

result = OnChainVerifier.verify_stake(
    stake_address="stake1...",
    api_provider="koios"
)
```

---

## Import Examples

### Import from admin
```python
from app.modules.admin import CommunityManager, ExcelExporter
```

### Import from end_user
```python
from app.modules.end_user import KeyGenerator, MessageSigner
```

### Import from shared
```python
from app.modules.shared import ChallengeGenerator, OnChainVerifier
```

### Import from main modules package
```python
from app.modules import (
    CommunityManager, ExcelExporter,  # Admin
    KeyGenerator, MessageSigner,      # End-user
    ChallengeGenerator, OnChainVerifier  # Shared
)
```

---

## File Organization

### Admin-only files
- `community_manager.py` - Quản lý community/events (admin chỉ)
- `excel_exporter.py` - Export Excel/CSV (admin chỉ)

### End-user-only files
- `key_generator.py` - Tạo khóa (end-user chỉ)
- `message_signer.py` - Ký tin nhắn (end-user chỉ)

### Shared files
- `challenge_generator.py` - Thử thách (cả admin và end-user)
- `onchain_verifier.py` - Xác minh blockchain (cả admin và end-user)

---

## Usage in GUIs

### Admin Dashboard
```python
from app.modules.admin import CommunityManager, ExcelExporter

class AdminDashboard:
    def __init__(self):
        self.community_manager = CommunityManager()
        self.excel_exporter = ExcelExporter()
```

### End-User Dashboard
```python
from app.modules.end_user import KeyGenerator, MessageSigner
from app.modules.shared import ChallengeGenerator, OnChainVerifier

class EndUserDashboard:
    def __init__(self):
        self.key_generator = KeyGenerator
        self.message_signer = MessageSigner
        self.challenge_gen = ChallengeGenerator
```

---

## Benefits of This Structure

✅ **Separation of Concerns**
- Admin modules không ảnh hưởng end-user code
- End-user modules độc lập

✅ **Easy Maintenance**
- Tìm kiếm code dễ dàng
- Thay đổi không ảnh hưởng phần khác

✅ **Clear Dependencies**
- Biết rõ ai dùng gì
- Shared modules rõ ràng

✅ **Scalability**
- Thêm modules mới dễ dàng
- Không cần thay đổi cấu trúc

✅ **Import Flexibility**
- Import từ subfolder cụ thể
- Hoặc import từ parent package
