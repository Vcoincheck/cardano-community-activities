# Refactoring Guide - From Monolith to Modular

## Executive Summary

The 2000+ line monolithic script has been split into **6 focused modules**, each with a single responsibility:

| Module | Lines | Purpose |
|--------|-------|---------|
| Core.ps1 | ~180 | API calls, logging, response handling |
| DataLoader.ps1 | ~450 | File scanning, dialog UI, data parsing |
| AddressManagement.ps1 | ~280 | Address panel creation and lifecycle |
| ExecutionEngine.ps1 | ~260 | Single/batch execution logic |
| MidnightSignerIntegration.ps1 | ~380 | Recovery phrase handling, file watchers |
| GUIBuilder.ps1 | ~280 | Main form construction |
| Main.ps1 | ~60 | Module loading and orchestration |

**Total: ~1890 lines** (slightly smaller, better organized)

---

## Key Refactoring Decisions

### 1. **Why Modules Instead of Classes?**
PowerShell has limited class support and doesn't require it for this use case. Modules (script files sourced into the global scope) are:
- ✓ Simpler to debug
- ✓ Easier to test individually
- ✓ Better for legacy PowerShell versions
- ✓ Clearer scope management

### 2. **Global Scope Strategy**
All UI elements and shared state stored in `$script:` and `$global:` scopes:
- `$script:` (private to script) for internal state
- `$global:` (accessible everywhere) for UI elements that buttons reference

**Why?** PowerShell UI callbacks need access to form elements, which forces use of global scope.

### 3. **Dependency Injection via Closures**
Recovery phrase handlers use `.GetNewClosure()`:
```powershell
$btnClick.Add_Click({
    Invoke-RecoveryPhraseAuto -TxtRecovery $txtRecovery -BtnEnterRecovery $btnEnterRecovery
}.GetNewClosure())
```

This captures the button/textbox references without polluting global scope.

### 4. **Function Organization**
- **Pure functions** (no side effects) → Core.ps1
- **I/O operations** → DataLoader.ps1
- **UI operations** → AddressManagement.ps1 / GUIBuilder.ps1
- **Business logic** → ExecutionEngine.ps1
- **Integrations** → MidnightSignerIntegration.ps1

---

## Module Load Order

```
Main.ps1 loads in this order:
  1. Core.ps1              (no dependencies)
  2. DataLoader.ps1        (depends on Core, AddressManagement)
  3. AddressManagement.ps1 (depends on Core, ExecutionEngine, MidnightSigner)
  4. ExecutionEngine.ps1   (depends on Core)
  5. MidnightSigner*.ps1   (depends on Core, DataLoader, AddressManagement)
  6. GUIBuilder.ps1        (depends on all others)
```

**Critical:** This order prevents "function not found" errors.

---

## Breaking Changes

### ❌ Old Way (Monolith)
```powershell
.\solution_transfer_manual_gui_v3.ps1
# Everything runs as one giant script
```

### ✅ New Way (Modular)
```powershell
.\Main.ps1
# Loads all modules and orchestrates
```

**Migration:** Old script still works. New development uses Main.ps1.

---

## Adding Features

### Example: Add Email Notification

**Step 1**: Add function to Core.ps1
```powershell
function Send-EmailNotification {
    param([string]$Message)
    # Implementation here
}
```

**Step 2**: Call from ExecutionEngine.ps1
```powershell
function Execute-SingleAddress {
    # ... existing code ...
    if ($response.status -eq "success") {
        Send-EmailNotification -Message "Donation successful!"
    }
}
```

**Step 3**: Load the modified Main.ps1
```powershell
.\Main.ps1
```

---

## Debugging Guide

### Finding Issues

| Problem | Where to Look |
|---------|---------------|
| "Function not found" error | Check load order in Main.ps1 |
| API failures | Core.ps1 (Execute-Donation, Process-Response) |
| File not found errors | DataLoader.ps1 (Show-RescanDialog, Scan-*) |
| UI not responding | GUIBuilder.ps1 or AddressManagement.ps1 |
| Recovery phrase issues | MidnightSignerIntegration.ps1 |

### Debug Technique: Load Individual Module

```powershell
# Test just the Core functions
. .\lib\Core.ps1
$stats = Get-Statistics -Address "addr1..."
Write-Host $stats
```

### Enable Verbose Logging

```powershell
# Modify Main.ps1 to add:
$DebugPreference = "Continue"
$VerbosePreference = "Continue"
```

---

## Performance Optimizations

### Current Optimizations

1. **Fast File Scanning** (DataLoader.ps1)
   ```powershell
   [System.IO.Directory]::EnumerateFiles($genRoot, '*.addr', [System.IO.SearchOption]::AllDirectories)
   # Uses .NET directly, not Get-ChildItem (slower)
   ```

2. **Thread-Safe Queue** (MidnightSignerIntegration.ps1)
   ```powershell
   [System.Threading.Monitor]::Enter($script:queueLock)
   # Prevents race conditions in file watchers
   ```

3. **Lazy Panel Creation** (AddressManagement.ps1)
   ```powershell
   while ($panelIndex -ge $script:addressPanels.Count) {
       Add-AddressPanel  # Only create when needed
   }
   ```

### Possible Future Optimizations

- [ ] Cache API statistics results
- [ ] Parallel batch execution (with throttling)
- [ ] Async file I/O for large file sets
- [ ] UI virtualization for 100+ addresses

---

## Testing Strategy

### Unit Tests (Recommended)

```powershell
# test-core.ps1
. .\lib\Core.ps1

function Test-CreateSignature {
    # Mock cardano-signer
    # Verify signature format
}

function Test-ProcessResponse {
    $response = @{
        status = "success"
        message = "Test"
        Solutions_consolidated = 100
    }
    $result = Process-Response -Response $response -OriginalAddr "test" -DestAddr "test"
    Assert-Contains $result "SUCCESS"
}
```

### Integration Tests

```powershell
# test-integration.ps1
# Load all modules
. .\Main.ps1

# Test end-to-end workflow
# - Load address
# - Execute donation
# - Verify response
```

---

## Common Maintenance Tasks

### 1. Update API Endpoint
**File:** Core.ps1, Line 7
```powershell
$script:apiBase = "https://NEW_ENDPOINT/api"  # Change here
```

### 2. Modify Log Colors
**File:** Core.ps1, Write-Log function
```powershell
'softred' { $col = [System.Drawing.Color]::FromArgb(255,107,107) }  # Adjust RGB
```

### 3. Add New Address Panel Button
**File:** AddressManagement.ps1, in Add-AddressPanel function
```powershell
$btnNewFeature = New-Object System.Windows.Forms.Button
# ... configure button ...
$addrPanel.Controls.Add($btnNewFeature)
```

### 4. Change File Watcher Behavior
**File:** MidnightSignerIntegration.ps1, Start-DelegatedSummaryWatchers function
```powershell
$fsw.NotifyFilter = [System.IO.NotifyFilters]'LastWrite,FileName'  # Adjust filters
```

### 5. Modify Dialog Appearance
**File:** DataLoader.ps1, Show-*Dialog functions
```powershell
$form.Width = 900  # Adjust dimensions
$list.Font = New-Object System.Drawing.Font('Courier New', 10)  # Change font
```

---

## Rollback Plan

If issues arise:

1. **Keep backup of original file:**
   ```powershell
   cp solution_transfer_manual_gui_v3.ps1 solution_transfer_manual_gui_v3.ps1.bak
   ```

2. **Test old version:**
   ```powershell
   .\solution_transfer_manual_gui_v3.ps1.bak
   ```

3. **Identify module causing issue:**
   - Disable by commenting in Main.ps1
   - Test step-by-step

4. **Merge fixes back if needed**

---

## Checklist for Code Review

When reviewing changes to modules:

- [ ] Function dependencies documented?
- [ ] No new global variables without justification?
- [ ] Error handling includes try-catch?
- [ ] Write-Log called for important operations?
- [ ] Module load order maintained?
- [ ] No circular dependencies?
- [ ] UI elements properly scoped?
- [ ] Comments explain non-obvious logic?

---

## Future Architecture Improvements

### Phase 2: Convert to .PSM1 Modules
```powershell
# lib/Guitool.Core.psm1
function Write-Log { ... }
Export-ModuleMember -Function Write-Log
```

Benefits:
- Better encapsulation
- Private/Public function separation
- Native PowerShell module system

### Phase 3: Configuration Management
```powershell
# config.json
{
    "apiBase": "https://mine.defensio.io/api",
    "logColors": { "success": "#00FF00" },
    "uiSettings": { "formWidth": 1200 }
}
```

### Phase 4: Plugin System
Allow users to add custom processors:
```powershell
# Load all .plugin.ps1 files from plugins/ folder
Get-ChildItem .\plugins\*.plugin.ps1 | ForEach-Object { . $_ }
```

---

## Quick Reference

| Action | Command |
|--------|---------|
| Run app | `.\Main.ps1` |
| Test Core | `. .\lib\Core.ps1; Get-Statistics -Address "..."` |
| View architecture | `code README_ARCHITECTURE.md` |
| Debug module load | Add `-Verbose` flag in Main.ps1 |
| Add feature | Create function in appropriate module |
| Test individual module | `. .\lib\ModuleName.ps1` |

---

## Contact & Support

- **Issues found?** Check README_ARCHITECTURE.md dependency chain
- **New feature?** Follow "Adding Features" section above
- **Performance issue?** Check "Performance Optimizations" section
- **Testing needed?** See "Testing Strategy" section

Happy maintaining! 🚀
