# Architecture Diagram

## Module Dependency Graph

```
                        ┌─────────────────────┐
                        │   Application       │
                        │   Entry Point       │
                        └──────────┬──────────┘
                                   │
                  ┌────────────────┼────────────────┐
                  │                │                │
                  ▼                ▼                ▼
            ┌──────────┐     ┌──────────┐    ┌──────────┐
            │  Core    │     │  GUI     │    │  Data    │
            │ (API,    │     │ (Forms,  │    │ (File    │
            │ Crypto)  │     │ Panels)  │    │ Loader)  │
            └──────────┘     └──────────┘    └──────────┘
                  ▲                ▲                ▲
                  │                │                │
         ┌────────┴────────┐  ┌────┴──────┐   ┌────┴────┐
         │                 │  │            │   │          │
         ▼                 ▼  ▼            ▼   ▼          ▼
    ┌───────────────────────────┐   ┌──────────────────────┐
    │  Address Management       │   │  Recovery/Key Mgmt   │
    │  (Panel UI Logic)         │   │  (MidnightSigner     │
    │                           │   │   Integration)       │
    └───────────────────────────┘   └──────────────────────┘
         ▲                                    ▲
         │                                    │
         └────────────┬──────────────────────┘
                      │
                      ▼
         ┌───────────────────────────┐
         │  Execution Engine         │
         │  (Business Logic Layer)   │
         └───────────────────────────┘
```

## Function Call Flow

### On Startup
```
Main.ps1
  ├─ Load Core.ps1
  ├─ Load DataLoader.ps1
  ├─ Load AddressManagement.ps1
  ├─ Load ExecutionEngine.ps1
  ├─ Load MidnightSignerIntegration.ps1
  ├─ Load GUIBuilder.ps1
  ├─ Build-MainForm()
  ├─ Add-AddressPanel()
  ├─ Start-DelegatedSummaryWatchers()
  ├─ Show-WelcomeMessage()
  └─ form.ShowDialog() [BLOCKING]
```

### On "Auto-fill" Button Click
```
GUIBuilder.ps1 (btnAutoFill click)
  └─ MidnightSignerIntegration.ps1
     └─ Load-FromMidnightSigner()
        ├─ Scan phrase folders
        ├─ Find delegated.addr files
        └─ AddressManagement.ps1
           └─ Add-AddressPanel() [repeated]
              └─ Fill with addresses
```

### On "Check" Button Click (per panel)
```
AddressManagement.ps1 (btnCheck click)
  └─ Core.ps1
     └─ Get-Statistics()
        └─ API call to mine.defensio.io
           └─ Update label "Solutions: X"
```

### On "Execute" Button Click (single)
```
AddressManagement.ps1 (btnExecute click)
  └─ ExecutionEngine.ps1
     └─ Execute-SingleAddress()
        ├─ Core.ps1
        │  ├─ Get-Statistics()
        │  ├─ Create-Signature()
        │  ├─ Execute-Donation()
        │  └─ Process-Response()
        │
        └─ Core.ps1
           └─ Save-FullLog()
```

### On "Execute All" Button Click (batch)
```
GUIBuilder.ps1 (btnBatchExecute click)
  └─ ExecutionEngine.ps1
     └─ Execute-BatchAddresses()
        ├─ Loop through panels
        │  └─ For each: Create-Signature() + Execute-Donation()
        │
        └─ Save-FullLog()
           └─ Show-ContinueDialog()
```

## Data Flow

### Address Loading Pipeline

```
File System
    │
    ├─ phrase1/generated_keys/wallet_external_0/delegated.addr
    ├─ phrase1/generated_keys/wallet_external_1/delegated.addr
    └─ phrase1/generated_keys/wallet_internal_0/delegated.addr
        │
        ▼ (Scan-DelegatedFilesFast)
    DataLoader.ps1
        │
        ▼ (Show-AddressSelectionDialog)
    User selects addresses
        │
        ▼ (Populate-PanelsFromSelected)
    AddressManagement.ps1
        │
        ▼
    [Panel 1] [Panel 2] [Panel 3]
        ║          ║          ║
        ▼          ▼          ▼
    txtOriginal txtOriginal txtOriginal
    txtSkey     txtSkey     txtSkey
```

### Execution Pipeline

```
User Input:
  - Original Address
  - Private Key (.skey)
  - Destination Address
        │
        ▼
ExecutionEngine.ps1 (Execute-SingleAddress)
        │
        ├─ Get-Statistics()
        │  └─ Display solution count
        │
        ├─ Create-Signature()
        │  └─ Call cardano-signer executable
        │
        ├─ Execute-Donation()
        │  └─ POST to https://mine.defensio.io/api/donate_to/...
        │
        └─ Process-Response()
           └─ Parse and log result
           │
           ├─ SUCCESS ─┐
           ├─ CONFLICT ├─ Write-Log()
           ├─ ERROR    │  └─ Colored output to logBox
           └─ OTHER  ──┘
                │
                ▼
           Save-FullLog()
           └─ Export to CSV file
```

## Global State Management

```
Shared Globals:
├─ $script:addressPanels[]
│  └─ Array of {TextBoxOriginal, TextBoxSkey, LabelSolutions, ...}
│
├─ $script:isExecuting
│  └─ Flag to prevent concurrent execution
│
├─ $script:logBox
│  └─ Reference to RichTextBox control
│
├─ $script:apiBase
│  └─ API endpoint URL
│
├─ $script:summaryQueue
│  └─ Thread-safe ArrayList for async address updates
│
├─ $script:queueLock
│  └─ Monitor lock for queue synchronization
│
└─ $global:txtDestination, $global:btnBatchExecute, etc.
   └─ Form controls referenced by multiple modules
```

## Execution State Machine

```
                    ┌──────────────┐
                    │   IDLE       │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼ (Execute clicked)       ▼ (Recovery phrase entered)
        ┌─────────────┐          ┌──────────────────┐
        │ EXECUTING   │          │ GENERATING KEYS  │
        │ (lock=true) │          │ (external proc)  │
        └──────┬──────┘          └────────┬─────────┘
               │                         │
               │ (done)                  │ (done)
               │                         │
               └─────────────┬───────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ READY TO EXECUTE │
                    │ (lock=false)     │
                    └──────────────────┘
```

## GUI Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                 Scavenger Donation Manager v4.1                 │
├──────────────────────────────────────┬──────────────────────────┤
│                                      │                          │
│  LEFT PANEL (Address Management)     │   RIGHT PANEL            │
│  ─────────────────────────────────   │   (Log Display)          │
│                                      │                          │
│  [ORIGINAL ADDRESSES MANAGEMENT]     │   [EXECUTION LOG]        │
│  ┌──────────────────────────────┐   │                          │
│  │ + Add Original Address       │   │  ┌────────────────────┐  │
│  └──────────────────────────────┘   │  │                    │  │
│                                      │  │   Console Output   │  │
│  ┌──────────────────────────────┐   │  │   (Colored Text)   │  │
│  │ ADDRESS PANEL #1             │   │  │                    │  │
│  ├──────────────────────────────┤   │  │                    │  │
│  │ Original Address: [____] [Check][Execute][X]  │  │                    │  │
│  │ Private Key (.skey): [____] [...] │  │                    │  │
│  │ Recovery: [____] [Auto][Manual]   │  │                    │  │
│  │ Message: [Assign accumulated...] │  │                    │  │
│  │ Solutions: Not checked           │  │  │                    │  │
│  └──────────────────────────────┘   │  │                    │  │
│                                      │  │                    │  │
│  [More panels if added]              │  │                    │  │
│                                      │  └────────────────────┘  │
│  ┌──────────────────────────────┐   │                          │
│  │ DESTINATION & BATCH           │   │  [Clear Log] [Reset]    │
│  ├──────────────────────────────┤   │                          │
│  │ Destination Address: [______] │   │                          │
│  │                              │   │                          │
│  │ [Execute All (Batch Mode)]   │   │                          │
│  │          (ORANGE BIG BUTTON) │   │                          │
│  └──────────────────────────────┘   │                          │
│                                      │                          │
└──────────────────────────────────────┴──────────────────────────┘
```

## Address Panel Component

```
┌─────────────────────────────────────────────────────┐
│ #1  Original Address: [_________________] [Check]  │
│                                      [Execute][X]   │
│                                                     │
│ Private Key (.skey): [___________] [...]          │
│                                                     │
│ Recovery: [_______________] [Auto] [Manual]       │
│                                                     │
│ Message: [Assign accumulated Scavenger rights to: ]│
│                                                     │
│ Solutions: Not checked                             │
└─────────────────────────────────────────────────────┘

Components:
- #N: Panel number identifier
- Original Address TextBox: Cardano address input
- Check Button: Fetch solution count from API
- Execute Button: Execute single address donation
- X Button: Remove panel
- Private Key TextBox: Path to .skey file (read-only)
- Browse Button: File picker for private key
- Recovery TextBox: Recovery phrase input
- Auto Button: Auto-populate recovery phrase
- Manual Button: Manual recovery phrase entry
- Message TextBox: Custom message for donation
- Solutions Label: Display current solution count
```

## Error Handling Flow

```
User Action
    │
    ▼
Try: Execute function
    │
    ├─ Success ──────── Write-Log "✓ Success" (Green)
    │
    └─ Exception
        │
        ├─ Catch: Log error
        │  │
        │  ├─ API error ── Write-Log "✗ API Error" (SoftRed)
        │  ├─ File error ─ Write-Log "✗ File not found" (SoftRed)
        │  └─ Other error  Write-Log "✗ Error: ..." (SoftRed)
        │
        └─ Finally: Cleanup
           ├─ Re-enable buttons
           ├─ Reset "Wait..." text
           └─ Release execution lock
```

## Threading Model

```
UI Thread (Main)
    │
    ├─ Event handlers (button clicks)
    │  └─ Must not block (use background processes)
    │
    ├─ UI updates
    │  └─ Must happen on UI thread
    │
    └─ Timer (summaryTimer)
       └─ Runs on UI thread every 500ms
          └─ Processes queued addresses

Background Process (File Watcher)
    │
    └─ Monitors delegated_summary.txt
       ├─ Detects changes
       ├─ Adds to summaryQueue (thread-safe)
       └─ UI timer picks up and adds to panels
```

---

This diagram shows how all 6 modules work together to create a maintainable, modular application!
