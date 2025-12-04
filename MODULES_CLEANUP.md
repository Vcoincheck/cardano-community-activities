# Cleanup Instructions - Old Module Files

Các file cũ này cần được xóa vì đã được di chuyển vào các thư mục con (admin, end_user, shared):

## Files to Remove

```
python/app/modules/challenge_generator.py
python/app/modules/community_manager.py
python/app/modules/excel_exporter.py
python/app/modules/key_generator.py
python/app/modules/message_signer.py
python/app/modules/onchain_verifier.py
```

## How to Remove

### Option 1: Using Linux commands
```bash
cd /workspaces/cardano-community-activities
rm python/app/modules/challenge_generator.py
rm python/app/modules/community_manager.py
rm python/app/modules/excel_exporter.py
rm python/app/modules/key_generator.py
rm python/app/modules/message_signer.py
rm python/app/modules/onchain_verifier.py
```

### Option 2: Using Python
```python
import os
files = [
    "python/app/modules/challenge_generator.py",
    "python/app/modules/community_manager.py",
    "python/app/modules/excel_exporter.py",
    "python/app/modules/key_generator.py",
    "python/app/modules/message_signer.py",
    "python/app/modules/onchain_verifier.py"
]
for f in files:
    if os.path.exists(f):
        os.remove(f)
```

### Option 3: Using VS Code File Explorer
1. Open VS Code Explorer
2. Navigate to `python/app/modules/`
3. Right-click on each file and select "Delete"

## After Cleanup

The structure should look like:

```
python/app/modules/
├── __init__.py
├── STRUCTURE.md
├── admin/
│   ├── __init__.py
│   ├── community_manager.py
│   └── excel_exporter.py
├── end_user/
│   ├── __init__.py
│   ├── key_generator.py
│   └── message_signer.py
└── shared/
    ├── __init__.py
    ├── challenge_generator.py
    └── onchain_verifier.py
```

---

## Why These Changes?

✅ **Better Organization**: Modules grouped by function (admin vs end-user)
✅ **No Duplication**: Old files removed, only new organized structure remains
✅ **Clear Import Paths**: `from app.modules.admin import CommunityManager`
✅ **Easier Maintenance**: Know exactly where to find each module
