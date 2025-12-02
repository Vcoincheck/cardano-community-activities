# 📑 File Index & Navigation Guide

## 🎯 Start Here!

### **00_START_HERE.md** ← READ THIS FIRST
- Executive summary of refactoring
- What was done and why
- Quick overview of new structure
- Next steps and getting started
- Quality metrics and benefits

**Time to read: 5-10 minutes**

---

## 📚 Documentation Files

### **QUICK_START.md** 
For developers who want to jump in immediately.

**Contents:**
- What changed (before/after)
- How to run the application
- Module responsibilities table
- Common modification tasks
- Quick reference table

**When to read:** Before touching any code

**Time: 5-10 minutes**

---

### **README_ARCHITECTURE.md**
Complete technical documentation of the modular architecture.

**Contents:**
- File structure overview
- Detailed module descriptions
- Function reference for each module
- Global variables documentation
- Execution flow
- Dependency chain diagram
- Migration notes
- Performance considerations
- Testing recommendations

**When to read:** When you need to understand how things work

**Time: 15-20 minutes**

---

### **REFACTORING_GUIDE.md**
Detailed guide for maintainers explaining design decisions and techniques.

**Contents:**
- Refactoring rationale
- Key design decisions explained
- Module load order analysis
- Adding features (with examples)
- Debugging guide
- Performance optimizations
- Common maintenance tasks
- Rollback plan
- Code review checklist
- Future improvements
- Quick reference table

**When to read:** When adding features or debugging issues

**Time: 20-30 minutes**

---

### **ARCHITECTURE_DIAGRAM.md**
Visual representation of system architecture using ASCII diagrams.

**Contents:**
- Module dependency graph
- Function call flow (various scenarios)
- Data flow pipelines
- Execution state machine
- File organization tree
- Global state management visualization
- Error handling flow
- Threading model

**When to read:** When you need to visualize how components interact

**Time: 10-15 minutes**

---

### **VALIDATION_CHECKLIST.md**
Quality assurance and verification checklist.

**Contents:**
- File structure verification
- Module load order verification
- Function availability checklist
- Global variables listing
- Code quality checks
- Integration point verification
- Feature completeness
- Documentation quality
- Testing recommendations
- Backward compatibility check
- Performance considerations
- Security review
- Maintainability scoring
- Sign-off checklist

**When to read:** Before deployment or after major changes

**Time: Reference document (as needed)**

---

## 🔧 Application Files

### **Main.ps1** (Root directory)
The application entry point that orchestrates all modules.

**What it does:**
- Loads all 6 modules in correct order
- Initializes global variables
- Builds the main GUI form
- Creates first address panel
- Starts file watchers
- Launches the application

**Lines:** ~60

**When to modify:** When changing module load order or app initialization

**Dependencies:** Loads all lib/*.ps1 files

---

## 📦 Module Files (lib/ directory)

### **lib/Core.ps1**
API communication, logging, and utility layer.

**Key Functions:**
- `Write-Log` - Colored logging to UI
- `Get-Statistics` - Fetch wallet info from API
- `Create-Signature` - Generate CIP-30 signatures
- `Execute-Donation` - API call to transfer solutions
- `Process-Response` - Parse and log API responses
- `Save-FullLog` - Export logs to CSV

**Lines:** ~180

**Dependencies:** None (standalone)

**When to modify:**
- Changing API endpoint
- Modifying log colors
- Adding new API features
- Changing signature logic

---

### **lib/DataLoader.ps1**
File system operations and data loading dialogs.

**Key Functions:**
- `Show-AddressSelectionDialog` - UI dialog for address selection
- `Scan-DelegatedFilesFast` - Fast .NET file enumeration
- `Parse-GenerationLog` - Extract wallet data from logs
- `Show-LogScanDialog` - Dialog to load from generation.log
- `Show-RescanDialog` - Dialog to rescan files
- `Populate-PanelsFromSelected` - Fill address panels

**Lines:** ~450

**Dependencies:** Core.ps1, AddressManagement.ps1

**When to modify:**
- Changing file loading methods
- Modifying dialog appearance
- Adjusting parsing logic
- Adding new data sources

---

### **lib/AddressManagement.ps1**
Address panel UI creation and lifecycle management.

**Key Functions:**
- `Add-AddressPanel` - Create new address input panel
- `Remove-AddressPanel` - Delete a panel
- `Update-AddButtonPosition` - Reposition "Add" button
- `Reset-AllAddresses` - Clear all data

**Lines:** ~280

**Dependencies:** Core.ps1, ExecutionEngine.ps1, MidnightSignerIntegration.ps1

**Global Variables:** $script:addressPanels

**When to modify:**
- Adding new controls to panel
- Changing panel layout
- Adding new buttons
- Modifying panel styling

---

### **lib/ExecutionEngine.ps1**
Donation execution logic for single and batch operations.

**Key Functions:**
- `Execute-SingleAddress` - Execute one donation
- `Execute-BatchAddresses` - Execute batch of donations
- `Show-ContinueDialog` - Post-execution prompt

**Lines:** ~260

**Dependencies:** Core.ps1

**When to modify:**
- Changing execution workflow
- Adding pre/post execution hooks
- Modifying validation logic
- Adding new execution modes

---

### **lib/MidnightSignerIntegration.ps1**
Recovery phrase handling and file watcher integration.

**Key Functions:**
- `Load-FromMidnightSigner` - Auto-load from phrase folders
- `Invoke-RecoveryPhraseAuto` - Auto key generation
- `Invoke-RecoveryPhraseManual` - Manual GUI launch
- `Process-DelegatedSummaryAppend` - File change processing
- `Start-DelegatedSummaryWatchers` - Setup watchers

**Lines:** ~380

**Dependencies:** Core.ps1, DataLoader.ps1, AddressManagement.ps1

**Global Variables:** $script:summaryQueue, $script:queueLock, $script:summaryOffsets

**When to modify:**
- Changing signer integration
- Modifying recovery phrase handling
- Adjusting file watcher behavior
- Adding new key generation modes

---

### **lib/GUIBuilder.ps1**
Main GUI form construction and initial setup.

**Key Functions:**
- `Build-MainForm` - Create and return main form
- `Show-WelcomeMessage` - Display welcome banner

**Lines:** ~280

**Dependencies:** All other modules (indirectly through button handlers)

**Global Variables Set:** 
- $global:addressContainer
- $global:txtDestination
- $global:btnBatchExecute
- $global:btnAddAddress
- $script:logBox

**When to modify:**
- Changing window size
- Modifying button layouts
- Adding new controls
- Changing colors/fonts
- Adjusting panel positioning

---

## 📋 File Size Summary

| File | Lines | Size | Purpose |
|------|-------|------|---------|
| Main.ps1 | ~60 | 2KB | Orchestrator |
| Core.ps1 | ~180 | 6KB | API layer |
| DataLoader.ps1 | ~450 | 15KB | File I/O |
| AddressManagement.ps1 | ~280 | 10KB | UI panels |
| ExecutionEngine.ps1 | ~260 | 9KB | Business logic |
| MidnightSignerIntegration.ps1 | ~380 | 13KB | Integration |
| GUIBuilder.ps1 | ~280 | 10KB | GUI builder |
| **Total** | **~1890** | **~65KB** | **Application** |

---

## 📖 Documentation Size Summary

| File | Lines | Size | Purpose |
|------|-------|------|---------|
| 00_START_HERE.md | ~200 | 8KB | Executive summary |
| QUICK_START.md | ~150 | 6KB | Quick reference |
| README_ARCHITECTURE.md | ~350 | 12KB | Full docs |
| REFACTORING_GUIDE.md | ~500 | 18KB | Maintainer guide |
| ARCHITECTURE_DIAGRAM.md | ~350 | 12KB | Visual docs |
| VALIDATION_CHECKLIST.md | ~300 | 10KB | QA checklist |
| FILE_INDEX.md (this file) | ~400 | 14KB | Navigation |
| **Total** | **~2250** | **~80KB** | **Documentation** |

---

## 🗺️ Navigation Guide

### "I want to..."

#### ...run the application
→ **Main.ps1** or read **QUICK_START.md**

#### ...understand the architecture
→ **README_ARCHITECTURE.md** or **ARCHITECTURE_DIAGRAM.md**

#### ...add a new feature
→ **REFACTORING_GUIDE.md** (section: "Adding Features")

#### ...debug an issue
→ **REFACTORING_GUIDE.md** (section: "Debugging Guide")

#### ...modify API endpoint
→ **lib/Core.ps1** (line 7) or **REFACTORING_GUIDE.md**

#### ...change GUI layout
→ **lib/GUIBuilder.ps1** or **QUICK_START.md**

#### ...verify code quality
→ **VALIDATION_CHECKLIST.md**

#### ...understand module load order
→ **README_ARCHITECTURE.md** or **ARCHITECTURE_DIAGRAM.md**

#### ...test a module
→ **REFACTORING_GUIDE.md** (section: "Testing Strategy")

#### ...contribute code
→ **REFACTORING_GUIDE.md** (section: "Code Review Checklist")

---

## 🎯 Reading Path by Role

### For Project Managers
1. 00_START_HERE.md (5 min)
2. QUICK_START.md (5 min)
3. VALIDATION_CHECKLIST.md (10 min)

**Total: 20 minutes**

---

### For Developers (First Time)
1. 00_START_HERE.md (5 min)
2. QUICK_START.md (10 min)
3. README_ARCHITECTURE.md (20 min)
4. ARCHITECTURE_DIAGRAM.md (15 min)

**Total: 50 minutes**

---

### For Developers (Adding Features)
1. REFACTORING_GUIDE.md (30 min)
2. Relevant module comments (5 min)
3. Reference appropriate module (10 min)

**Total: 45 minutes**

---

### For Maintainers
1. All documentation files (1-2 hours)
2. Review all module files (1 hour)
3. VALIDATION_CHECKLIST.md (30 min)

**Total: 2.5-3 hours for full understanding**

---

### For QA / Testing
1. QUICK_START.md (10 min)
2. VALIDATION_CHECKLIST.md (30 min)
3. REFACTORING_GUIDE.md - Testing section (15 min)

**Total: 55 minutes**

---

## 📊 Cross-Reference Index

### Find information about...

**API Endpoint**: Core.ps1 line 7, README_ARCHITECTURE.md, REFACTORING_GUIDE.md

**Logging System**: Core.ps1 Write-Log(), README_ARCHITECTURE.md, QUICK_START.md

**File Scanning**: DataLoader.ps1 Scan-DelegatedFilesFast(), ARCHITECTURE_DIAGRAM.md

**Address Panels**: AddressManagement.ps1, QUICK_START.md, README_ARCHITECTURE.md

**Execution Logic**: ExecutionEngine.ps1, ARCHITECTURE_DIAGRAM.md

**Recovery Phrases**: MidnightSignerIntegration.ps1, REFACTORING_GUIDE.md

**GUI Layout**: GUIBuilder.ps1, QUICK_START.md

**Dependencies**: README_ARCHITECTURE.md, ARCHITECTURE_DIAGRAM.md

**Testing**: REFACTORING_GUIDE.md, VALIDATION_CHECKLIST.md

**Debugging**: REFACTORING_GUIDE.md, ARCHITECTURE_DIAGRAM.md

**Performance**: README_ARCHITECTURE.md, REFACTORING_GUIDE.md

**Security**: README_ARCHITECTURE.md, VALIDATION_CHECKLIST.md

---

## 🚀 Quick Links

- **Get Started**: `00_START_HERE.md`
- **Run App**: `Main.ps1`
- **Change API**: `lib/Core.ps1` line 7
- **Add Feature**: `REFACTORING_GUIDE.md`
- **Fix Bug**: `REFACTORING_GUIDE.md` → Debugging section
- **Verify Quality**: `VALIDATION_CHECKLIST.md`
- **Understand Arch**: `ARCHITECTURE_DIAGRAM.md`
- **Learn Details**: `README_ARCHITECTURE.md`

---

## ✅ File Checklist

- [x] 00_START_HERE.md - Executive summary
- [x] QUICK_START.md - Quick reference  
- [x] README_ARCHITECTURE.md - Full documentation
- [x] REFACTORING_GUIDE.md - Maintainer guide
- [x] ARCHITECTURE_DIAGRAM.md - Visual docs
- [x] VALIDATION_CHECKLIST.md - QA checklist
- [x] FILE_INDEX.md - This file (navigation)
- [x] Main.ps1 - Entry point
- [x] lib/Core.ps1 - API layer
- [x] lib/DataLoader.ps1 - File I/O
- [x] lib/AddressManagement.ps1 - UI panels
- [x] lib/ExecutionEngine.ps1 - Business logic
- [x] lib/MidnightSignerIntegration.ps1 - Integration
- [x] lib/GUIBuilder.ps1 - GUI builder

**All files present: ✅**

---

## 🎓 Learning Resources

All necessary learning materials are included:

- ✅ Architecture documentation
- ✅ Code examples and patterns  
- ✅ Debugging techniques
- ✅ Testing strategies
- ✅ Maintenance guidelines
- ✅ Visual diagrams
- ✅ Quick references
- ✅ Checklists

---

**Total Time to Master:** 2-3 hours for complete understanding

**Total Time to Run:** 30 seconds

**Total Time to Modify:** 15-30 minutes (depending on complexity)

---

**Navigation Status: ✅ COMPLETE**

**Last Updated:** November 29, 2025

**Questions?** See `00_START_HERE.md` → "Getting Help" section
