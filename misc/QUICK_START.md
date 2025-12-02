# Quick Start Guide - Modular Architecture

## 📦 What Changed

Your 2000+ line GUI script has been split into **6 independent modules** for easier maintenance:

```
Original:  solution_transfer_manual_gui_v3.ps1 (2000 lines)
              ↓
New:       Main.ps1 + lib/6 modules (1900 lines, better organized)
```

## ⚡ How to Run

```powershell
# Old way (still works):
.\solution_transfer_manual_gui_v3.ps1

# New way (recommended):
.\Main.ps1
```

## 📁 New File Structure

```
Guitool/
├── Main.ps1                             ← NEW: Start here
├── lib/                                 ← NEW: Module folder
│   ├── Core.ps1                         ← API, logging, signatures
│   ├── DataLoader.ps1                   ← File scanning, dialogs
│   ├── AddressManagement.ps1            ← Address panels
│   ├── ExecutionEngine.ps1              ← Donation logic
│   ├── MidnightSignerIntegration.ps1    ← Recovery phrases
│   └── GUIBuilder.ps1                   ← GUI construction
├── README_ARCHITECTURE.md               ← NEW: Full documentation
├── REFACTORING_GUIDE.md                 ← NEW: Maintainer guide
└── solution_transfer_manual_gui_v3.ps1  ← OLD: Still available
```

## 🎯 Module Responsibilities

| Module | What it does | When to modify |
|--------|------------|---|
| **Core.ps1** | API calls, signatures, logging | Adding new API features or changing endpoints |
| **DataLoader.ps1** | File scanning, parsing, dialogs | Changing how addresses are loaded |
| **AddressManagement.ps1** | Address panels UI | Modifying panel layout or buttons |
| **ExecutionEngine.ps1** | Execute donations | Changing execution workflow |
| **MidnightSignerIntegration.ps1** | Recovery phrases, key generation | Modifying signer integration |
| **GUIBuilder.ps1** | Main form construction | Changing main window layout |

## 🔧 Common Tasks

### ✏️ Change API Endpoint
**File:** `lib/Core.ps1`, line 7
```powershell
$script:apiBase = "https://new-api.com/endpoint"
```

### ✨ Add New Button to Address Panel
**File:** `lib/AddressManagement.ps1`, function `Add-AddressPanel`
```powershell
$btnMyFeature = New-Object System.Windows.Forms.Button
$btnMyFeature.Location = New-Object System.Drawing.Point(650, 5)
$btnMyFeature.Text = "My Feature"
$addrPanel.Controls.Add($btnMyFeature)
```

### 📝 Modify Log Colors
**File:** `lib/Core.ps1`, function `Write-Log`
```powershell
'mycolor' { $col = [System.Drawing.Color]::FromArgb(R,G,B) }
```

### 🔍 Debug a Module
```powershell
# Test just one module without GUI
. .\lib\Core.ps1
$result = Get-Statistics -Address "addr1xyz..."
Write-Host $result
```

## 🧪 Testing

### Run full application
```powershell
.\Main.ps1
```

### Test individual module
```powershell
# Load module and test a function
. .\lib\DataLoader.ps1
$files = Scan-DelegatedFilesFast -PhraseFolder ".\phrase1"
$files | ForEach-Object { Write-Host $_.File }
```

## 📚 Documentation

- **README_ARCHITECTURE.md** - Complete module documentation
- **REFACTORING_GUIDE.md** - Detailed maintainer guide with examples

## ✅ Quick Checklist for Adding Features

1. **Identify module** - Which module should contain the new code?
2. **Add function** - Create the function in that module
3. **Add dependencies** - What does it need from other modules?
4. **Test** - Load module and test the function
5. **Integrate** - Call from appropriate place (Main.ps1, other functions)
6. **Document** - Update comments and README if needed

## 🚀 Performance Notes

- ✓ Fast file scanning (uses .NET, not Get-ChildItem)
- ✓ Thread-safe queue for async operations
- ✓ Lazy panel creation (only when needed)
- ✓ All original functionality maintained

## ⚠️ If Something Breaks

1. **Check load order** - Modules must load in order (see Main.ps1)
2. **Verify scopes** - UI elements must be `$global:`, internal state `$script:`
3. **Test isolation** - Load just the failing module to narrow down the issue
4. **Use original** - The original script still works as a fallback

## 💡 Tips for Maintainers

- Each module should be **independent and reusable**
- Keep functions **pure** (no side effects) in Core.ps1
- Use `Write-Log` for important operations
- Always include error handling (try-catch)
- Add comments for non-obvious logic

## 🎓 Learning Resources

1. Start with **README_ARCHITECTURE.md** for full overview
2. Read **REFACTORING_GUIDE.md** for detailed explanations
3. Check individual module comments for function details
4. Review **Main.ps1** to understand module loading

---

**Questions?** See README_ARCHITECTURE.md or REFACTORING_GUIDE.md for detailed answers.
