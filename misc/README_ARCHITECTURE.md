# Scavenger Donation Manager - Modular Architecture

## Overview

The original monolithic GUI script (`solution_transfer_manual_gui_v3.ps1`) has been refactored into a modular architecture for better maintainability and extensibility.

## File Structure

```
Guitool/
├── Main.ps1                          # Entry point (imports all modules)
├── lib/
│   ├── Core.ps1                      # Core functions (logging, API calls)
│   ├── DataLoader.ps1                # Data loading (file scanning, dialogs)
│   ├── AddressManagement.ps1         # Address panel management
│   ├── ExecutionEngine.ps1           # Donation execution logic
│   ├── MidnightSignerIntegration.ps1 # Recovery phrase handling
│   └── GUIBuilder.ps1                # GUI construction
├── solution_transfer_manual_gui_v3.ps1  # Original monolithic file (legacy)
└── README_ARCHITECTURE.md             # This file
```

## Module Description

### 1. **Core.ps1** - API & Logging Layer
**Responsibility:** Low-level utilities and external API communication

**Key Functions:**
- `Write-Log` - Colored logging to rich text box
- `Get-Statistics` - Fetch wallet solutions from API
- `Create-Signature` - Generate CIP-30 signatures using cardano-signer
- `Execute-Donation` - Make API call to transfer solutions
- `Process-Response` - Parse and log API responses
- `Save-FullLog` - Export donation logs to CSV

**Dependencies:** None (standalone)

---

### 2. **DataLoader.ps1** - File I/O & Data Parsing
**Responsibility:** Scanning file systems, parsing logs, handling dialogs

**Key Functions:**
- `Show-AddressSelectionDialog` - UI dialog for address selection
- `Scan-DelegatedFilesFast` - Fast enumeration of delegated.addr files
- `Parse-GenerationLog` - Extract wallet entries from generation.log
- `Show-LogScanDialog` - Dialog to scan and load from generation.log
- `Show-RescanDialog` - Dialog to rescan delegated.addr files
- `Populate-PanelsFromSelected` - Fill address panels from loaded data

**Dependencies:** 
- Calls `Write-Log` from Core.ps1
- Calls `Add-AddressPanel` from AddressManagement.ps1

---

### 3. **AddressManagement.ps1** - UI Panel Management
**Responsibility:** Creating and managing address input panels

**Key Functions:**
- `Add-AddressPanel` - Create new address panel with buttons
- `Remove-AddressPanel` - Delete an address panel
- `Update-AddButtonPosition` - Reposition "Add" button
- `Reset-AllAddresses` - Clear all panels

**Global Variables:**
- `$script:addressPanels` - Array of panel objects

**Dependencies:**
- Calls `Write-Log` from Core.ps1
- Calls `Execute-SingleAddress` from ExecutionEngine.ps1
- Calls `Invoke-RecoveryPhrase*` from MidnightSignerIntegration.ps1
- Calls `Get-Statistics` from Core.ps1

---

### 4. **ExecutionEngine.ps1** - Donation Processing
**Responsibility:** Single and batch donation execution

**Key Functions:**
- `Execute-SingleAddress` - Execute donation for one address
- `Execute-BatchAddresses` - Execute batch donations
- `Show-ContinueDialog` - Post-execution prompt

**Dependencies:**
- Calls `Get-Statistics`, `Create-Signature`, `Execute-Donation`, `Process-Response`, `Save-FullLog` from Core.ps1
- Accesses UI elements: `$txtDestination`, `$btnBatchExecute`
- Accesses address panels: `$script:addressPanels`

---

### 5. **MidnightSignerIntegration.ps1** - Recovery Phrases
**Responsibility:** Handling recovery phrases and key generation integration

**Key Functions:**
- `Load-FromMidnightSigner` - Auto-load from latest phrase folder
- `Invoke-RecoveryPhraseAuto` - Run auto key generation
- `Invoke-RecoveryPhraseManual` - Launch manual GUI and load keys
- `Process-DelegatedSummaryAppend` - Watch file changes
- `Start-DelegatedSummaryWatchers` - Setup file watchers
- Queue processing timer (in Main.ps1)

**Global Variables:**
- `$script:summaryQueue` - Thread-safe queue for pending addresses
- `$script:queueLock` - Synchronization lock
- `$script:summaryOffsets` - File offset tracking

**Dependencies:**
- Calls `Write-Log` from Core.ps1
- Calls `Show-AddressSelectionDialog` from DataLoader.ps1
- Calls `Populate-PanelsFromSelected` from DataLoader.ps1
- Calls `Add-AddressPanel` from AddressManagement.ps1

---

### 6. **GUIBuilder.ps1** - UI Construction
**Responsibility:** Building the main GUI form and controls

**Key Functions:**
- `Build-MainForm` - Creates and returns the main form
- `Show-WelcomeMessage` - Display welcome banner

**Global Elements Created:**
- `$form` - Main window
- `$global:addressContainer` - Scrollable address panel container
- `$global:txtDestination` - Destination address textbox
- `$global:btnBatchExecute` - Batch execute button
- `$global:btnAddAddress` - Add address button
- `$script:logBox` - Rich text log display

**Dependencies:**
- Calls `Add-AddressPanel` from AddressManagement.ps1
- Calls `Execute-BatchAddresses` from ExecutionEngine.ps1
- Calls all dialog functions from DataLoader.ps1
- Calls `Write-Log` from Core.ps1

---

## Execution Flow

```
Main.ps1
  ├─ Load all modules in order
  ├─ Initialize global variables ($script:isExecuting, etc.)
  ├─ Build GUI form
  ├─ Create first address panel
  ├─ Start file watchers for delegated_summary
  ├─ Show welcome message
  └─ Launch form (blocking call until form closes)
```

## Usage

### Run the Application
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Main.ps1
```

### Add Custom Features

1. **New logging feature?** → Add function to `Core.ps1`
2. **New file loading method?** → Add function to `DataLoader.ps1`
3. **New execution workflow?** → Add function to `ExecutionEngine.ps1`
4. **New UI panel type?** → Modify `AddressManagement.ps1`
5. **New signer integration?** → Add to `MidnightSignerIntegration.ps1`
6. **GUI layout changes?** → Modify `GUIBuilder.ps1`

## Global Scope Considerations

### Shared Global Variables (Must be declared)
- `$script:addressPanels` - Address panel tracking
- `$script:isExecuting` - Execution lock flag
- `$script:logBox` - Log output control
- `$script:apiBase` - API endpoint URL
- `$script:summaryQueue` - Async queue
- `$script:queueLock` - Thread synchronization

### Shared UI Elements (Must be global)
- `$global:addressContainer` - Address list container
- `$global:txtDestination` - Destination address input
- `$global:btnBatchExecute` - Batch execute button
- `$global:btnAddAddress` - Add address button

## Dependency Chain

```
Core.ps1 (no dependencies)
    ↑
    ├─ DataLoader.ps1
    ├─ AddressManagement.ps1
    ├─ ExecutionEngine.ps1
    └─ MidnightSignerIntegration.ps1
    
    (All feed into)
    
GUIBuilder.ps1

(All orchestrated by)

Main.ps1
```

## Migration Notes

- The original file can still be used (not deleted)
- New development should use the modular architecture
- Gradual refactoring is possible if needed
- All functions maintain backward compatibility

## Performance Considerations

1. **File Scanning**: Uses .NET `EnumerateFiles` for speed (Scan-DelegatedFilesFast)
2. **Thread Safety**: Summary queue uses Monitor locks for thread safety
3. **Async Loading**: File watchers run in background, UI updates via timer
4. **Lazy Loading**: Address panels created only when needed

## Testing Recommendations

Test each module independently:
```powershell
# Test Core functions
. .\lib\Core.ps1
$response = Get-Statistics -Address "addr1xyz..."

# Test DataLoader
. .\lib\Core.ps1
. .\lib\AddressManagement.ps1
. .\lib\DataLoader.ps1
$results = Scan-DelegatedFilesFast -PhraseFolder ".\phrase1"

# Test full application
.\Main.ps1
```

## Future Improvements

- [ ] Convert to PS modules (.psm1) for better isolation
- [ ] Add configuration file support
- [ ] Extract hardcoded strings to resources file
- [ ] Add unit tests
- [ ] Create plugin system for extensibility
- [ ] Add REST API option instead of CLI
