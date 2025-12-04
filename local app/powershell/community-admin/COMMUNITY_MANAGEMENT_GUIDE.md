# Community Management Features - User Guide

## Overview
The Community Admin Dashboard now includes powerful features for managing communities and events with Excel/CSV export capabilities.

## New Features

### 1. Create Community
**Purpose:** Create a new community in the system

**Steps:**
1. Click the **"Create Community"** button (purple button)
2. Fill in the following fields:
   - **Community ID**: Unique identifier for the community (e.g., `vcc-community`)
   - **Community Name**: Display name (e.g., `VCC Community`)
   - **Description**: Brief description of the community
3. Click **OK** to create
4. Success message will appear in the output panel

**Output:**
- Community is added to the system
- Fields initialized: created date, active members (0), total events (0), status (Active)

---

### 2. Create Event
**Purpose:** Create and associate an event with a community

**Steps:**
1. Click the **"Create Event"** button (light blue button)
2. Fill in the following fields:
   - **Event ID**: Unique identifier (e.g., `event-001`)
   - **Event Name**: Display name (e.g., `Cardano Workshop`)
   - **Event Date**: Date of the event (format: YYYY-MM-DD)
   - **Location**: Event location (e.g., `Manila, Philippines`)
   - **Status**: Choose from:
     - Planned
     - In Progress
     - Completed
     - Cancelled
   - **Description**: Event details
3. Click **OK** to add
4. The event will be associated with the default community and count updated

**Output:**
- Event is added to the system
- Community's event count automatically increments
- Success message confirms addition

---

### 3. Export to Excel/CSV
**Purpose:** Generate Excel files for community and event management

**Output Files:**

#### Master Communities File
- **Filename:** `Communities_Master_[timestamp].xlsx`
- **Sheets:** 
  - "Communities" sheet containing:
    - Community ID
    - Name
    - Description
    - Created Date
    - Active Members
    - Total Events
    - Status

#### Individual Community Files
- **Filename:** `[CommunityName]_Detail_[timestamp].xlsx`
- **Sheets:**
  - "Events" sheet with all events for that community
  - "Members" sheet with community members

**Features:**
- ✓ Auto-sizing columns
- ✓ Frozen header rows
- ✓ Professional table formatting
- ✓ Automatic handling of special characters in filenames
- ✓ Fallback to CSV if ImportExcel module not available

---

## Requirements

### For Excel Export
**ImportExcel Module** (Optional but recommended)
```powershell
# Install ImportExcel for better formatting
Install-Module -Name ImportExcel -Force -Scope CurrentUser
```

**Fallback:**
- If ImportExcel is not installed, files will be exported as CSV format instead
- CSV format is fully compatible with Excel, Google Sheets, etc.

---

## Data Storage

### In-Memory Storage
Currently, communities and events are stored in memory:
- `$script:CommunitiesData` - Array of community objects
- `$script:EventsData` - Array of event objects

### For Production Use
Consider implementing persistent storage:
- JSON files (recommended for local use)
- Database (SQL Server, PostgreSQL)
- Cloud storage (Azure, AWS)

**Example:** Update `CommunityManagement.ps1` functions to add database integration

---

## File Locations

- **Exports Directory:** `.\community-admin\exports\`
- **Module Files:**
  - `CommunityManagement.ps1` - Core community/event management
  - `ExcelExport.ps1` - Excel/CSV export functions
  - `AdminGUI.ps1` - Main dashboard interface

---

## Troubleshooting

### "ImportExcel module not found" Warning
- **Solution:** The system will automatically use CSV export format
- **Recommendation:** Run `Install-Module -Name ImportExcel -Force` for better formatting

### Export Directory Not Found
- **Solution:** Automatically created if it doesn't exist
- **Check:** Ensure you have write permissions in the `community-admin` folder

### Special Characters in Community Names
- **Handled Automatically:** Special characters are removed from filenames
- **Example:** "VCC Community!" becomes "VCC_Community" in filename

---

## Example Workflow

1. **Create Community**
   - Community ID: `vcc-ph`
   - Name: `VCC Philippines`
   - Description: `Cardano Verification Community Philippines`

2. **Create Events** (repeat for each event)
   - Event: `Meetup January 2025`
   - Location: `Manila`
   - Status: `Planned`

3. **Export to Excel**
   - Click "Export to Excel" button
   - Files generated:
     - `Communities_Master_20250104_143022.xlsx`
     - `VCC_Philippines_Detail_20250104_143022.xlsx`

4. **Share with Team**
   - Distribute Excel files
   - Open in Excel, Google Sheets, or any spreadsheet application

---

## Features Coming Soon

- [ ] CSV import (bulk add communities/events)
- [ ] Edit existing communities/events
- [ ] Member management
- [ ] Event attendance tracking
- [ ] Persistent database storage
- [ ] Email notifications
- [ ] Calendar integration

