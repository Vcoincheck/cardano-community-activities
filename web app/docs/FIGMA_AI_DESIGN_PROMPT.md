# Figma AI Design Prompt - Cardano Community Suite Web App

## 🎨 Complete Design Prompt for Figma

Copy and paste this entire prompt into Figma's AI design tool to auto-generate the complete UI/UX design:

---

### MASTER DESIGN PROMPT

```
Create a complete web application UI/UX design system for "Cardano Community Suite" 
following these specifications:

## PROJECT OVERVIEW
- Name: Cardano Community Suite Web App
- Purpose: Multi-purpose web platform for wallet management and community verification
- Target Users: Cryptocurrency community members (end-users) and community admins
- Color Theme: Dark mode with electric blue accents
- Style: Modern, professional, tech-forward

## DESIGN SYSTEM

### Color Palette
- Primary Dark: #0a0e27 (main background)
- Primary Darker: #1a1f3a (secondary background)
- Card Background: rgba(30, 40, 70, 0.9)
- Primary Blue: #00d4ff (electric blue for accents, buttons, borders)
- Text Primary: #e0e0e0 (main text)
- Text Secondary: #a0a0a0 (secondary text)
- Success: #4ade80 (green)
- Warning: #facc15 (yellow)
- Danger: #ef4444 (red)
- Info: #0ea5e9 (sky blue)

### Typography
- Font: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif
- Headings: Bold, 28-32px
- Body: Regular, 14-16px
- Buttons: Semi-bold, 14px

### Spacing & Radius
- Use 8px, 16px, 24px, 32px for consistent spacing
- Border radius: 8px for cards, 6px for buttons, 12px for larger elements

## PAGE DESIGNS

### PAGE 1: LANDING PAGE (Hero & Role Selection)

**Layout Structure:**
- Full screen dark gradient background (top to bottom: #0a0e27 to #1a1f3a)
- Centered container, max-width 1200px

**Header Section:**
- Logo: "🔗 Cardano Community Suite" (cyan/electric blue text)
- Subtitle: "Choose your role to continue" (secondary text, smaller)
- Padding: 40px top

**Role Selection Cards (2 columns on desktop, 1 on mobile):**
1. "End-User" Card:
   - Icon: 👤
   - Title: "END-USER"
   - Description: "Manage wallets & sign messages"
   - Button: "Enter" (cyan background, dark text)
   - Hover effect: slight upward lift, cyan glow shadow
   - Card background: rgba(30, 40, 70, 0.9)
   - Border: 2px solid #00d4ff

2. "Admin" Card:
   - Icon: 👨‍💼
   - Title: "ADMIN"
   - Description: "Manage community & verify users"
   - Button: "Enter" (cyan background, dark text)
   - Same hover/styling as End-User card

**Features Grid (below role cards):**
- 4 equal-width cards in a row (2x2 on tablet, 1 column on mobile)
- Feature 1: "🔐 End-User Tools" - List: Generate keypairs, Sign messages, Export wallet, Verify signatures
- Feature 2: "👨‍💼 Admin Features" - List: Create events, Verify signatures, Check on-chain, Manage registry
- Feature 3: "🔐 Security" - List: Offline signing, Ed25519 crypto, Event-response auth, Replay protection
- Feature 4: "📊 Analytics" - List: Generate reports, Track stats, Verify trends, Community analytics

Each feature card:
- Background: rgba(30, 40, 70, 0.6)
- Left border: 4px solid #00d4ff
- Padding: 20px
- Border radius: 8px

**Footer:**
- Version: "Cardano Community Suite v1.0.0"
- Tagline: "Built with ❤️ for Cardano Community"
- Centered, light gray text

---

### PAGE 2: END-USER DASHBOARD

**Layout Structure:**
- Dark gradient background (same as landing)
- Header bar at top with: [← Back Button] + "👤 END-USER TOOLS" (title)
- Main content area with grid layout

**Header Section:**
- Back button: arrow icon, clickable, leads to landing
- Title: "👤 END-USER TOOLS" (cyan text)
- Padding: 20px

**Tool Grid (4 tools, 4 columns on desktop, 2 on tablet, 1 on mobile):**

1. Tool Card: "Keypair Generator" (🔑)
   - Title: "🔑 GENERATE KEYPAIR"
   - Description: "Create a new Ed25519 keypair for signing"
   - Button: "Generate Keys" (cyan, full width)
   - Background: rgba(30, 40, 70, 0.9)
   - Border: 1px solid #00d4ff
   - Padding: 20px
   - Border radius: 8px

2. Tool Card: "Message Signer" (✍️)
   - Title: "✍️ SIGN MESSAGE"
   - Description: "Sign a message with your private key"
   - Button: "Sign Now"
   - Same styling as above

3. Tool Card: "Signature Verifier" (✓)
   - Title: "✓ VERIFY SIGNATURE"
   - Description: "Verify a signature locally before submitting"
   - Button: "Verify"
   - Same styling

4. Tool Card: "Wallet Exporter" (💾)
   - Title: "💾 EXPORT WALLET"
   - Description: "Backup your wallet data"
   - Button: "Export"
   - Same styling

**Tool Details Panels (when tool is selected):**
- Should appear below the tool grid or in a modal
- Display form fields with proper styling:
  - Input fields: dark background (rgba background), cyan border on focus, white text
  - Text areas: larger, similar styling
  - Buttons: cyan background, hover effect (slight brightness increase)
  - Buttons have rounded corners (6px)
  - Success/error messages: use green/red badges

---

### PAGE 3: ADMIN DASHBOARD

**Layout Structure:**
- Same as End-User Dashboard (dark gradient background)
- Header bar with back button and title

**Header Section:**
- [← Back Button] + "👨‍💼 ADMIN DASHBOARD"
- Padding: 20px

**Statistics Cards (3 cards in a row, 2 on tablet, 1 on mobile):**

1. Stat Card: "Total Users"
   - Large number: "3,420" (cyan text, 32px bold)
   - Label: "TOTAL USERS" (secondary text)
   - Background: rgba(0, 212, 255, 0.1)
   - Border: 2px solid #00d4ff
   - Padding: 20px
   - Border radius: 8px
   - Text align: center

2. Stat Card: "Verified"
   - Large number: "2,890" (cyan text, 32px bold)
   - Label: "VERIFIED" (secondary text)
   - Same styling

3. Stat Card: "Communities"
   - Large number: "15" (cyan text, 32px bold)
   - Label: "COMMUNITIES" (secondary text)
   - Same styling

**Admin Tool Grid (4 tools, same layout as End-User):**

1. Tool Card: "Event Generator" (➕)
   - Title: "➕ GENERATE EVENT"
   - Description: "Create a new verification event"
   - Button: "Generate"
   - Same styling as End-User cards

2. Tool Card: "Signature Verifier" (✅)
   - Title: "✅ VERIFY SIGNATURE"
   - Description: "Verify user signatures"
   - Button: "Verify"
   - Same styling

3. Tool Card: "Registry Manager" (📊)
   - Title: "📊 VIEW REGISTRY"
   - Description: "Manage community members"
   - Button: "View"
   - Same styling

4. Tool Card: "Report Generator" (📈)
   - Title: "📈 EXPORT REPORT"
   - Description: "Generate community reports"
   - Button: "Export"
   - Same styling

---

### PAGE 4: KEYPAIR GENERATOR TOOL

**Panel Layout:**
- Title: "🔑 Keypair Generator"
- Subtitle: "Generate a new Ed25519 keypair for signing messages"

**Form Section:**
- [Generate Keys] button (cyan, large)
- Text below: "Click the button above to generate a new keypair"

**Results Section (appears after generation):**
- Success message: Green badge "✓ Keys generated successfully"
- Public Key display:
  - Label: "Public Key"
  - Text area (disabled, read-only, monospace font)
  - Value: truncated hex string with copy button
  - Copy button: "📋 Copy"
- Private Key display:
  - Label: "Private Key (Keep Secret!)"
  - Toggle button: "👁️ Show / Hide"
  - Text area (disabled, monospace font, hidden by default)
  - When visible, red warning: "⚠️ Never share this key!"
  - Copy button: "📋 Copy"
- Action buttons below:
  - [Download as JSON] button (secondary style)
  - [Clear All] button (danger style)

---

### PAGE 5: MESSAGE SIGNER TOOL

**Panel Layout:**
- Title: "✍️ Message Signer"
- Subtitle: "Sign a message with your private key (offline, client-side only)"

**Form Section (3 fields):**

1. Input: "Message to Sign"
   - Label: "Message"
   - Text area, placeholder: "Enter the message to sign..."
   - Max height: 120px
   - Style: dark input, cyan border on focus

2. Input: "Private Key"
   - Label: "Private Key (Client-side, never sent)"
   - Text area, placeholder: "Paste your private key here..."
   - Height: 100px
   - Style: dark input, red/warning border

3. Button: "Sign Message"
   - Full width, cyan background
   - Loading state: spinner animation

**Results Section (after signing):**
- Success message: Green badge "✓ Message signed successfully"
- Signature display:
  - Label: "Signature"
  - Text area (disabled, monospace font)
  - Value: long hex string
  - Copy button: "📋 Copy"
- Metadata:
  - "Signed at: [timestamp]"
  - "Algorithm: Ed25519"
- Action buttons:
  - [Download Signature] button
  - [Download as JSON] button
  - [Sign Another Message] button (clears form)

---

### PAGE 6: SIGNATURE VERIFIER TOOL

**Panel Layout:**
- Title: "✓ Verify Signature"
- Subtitle: "Verify a signature locally (no server needed)"

**Form Section (4 fields):**

1. Input: "Original Message"
   - Text area, placeholder: "Paste the original message..."
   - Height: 100px

2. Input: "Public Key"
   - Text area, placeholder: "Paste the public key..."
   - Height: 80px

3. Input: "Signature"
   - Text area, placeholder: "Paste the signature..."
   - Height: 80px

4. Button: "Verify Signature"
   - Full width, cyan background

**Results Section:**
- Verification Result badge (conditional):
  - If valid: Green badge "✓ VALID SIGNATURE"
  - If invalid: Red badge "✗ INVALID SIGNATURE"
- Metadata (if verified):
  - "Verified at: [timestamp]"
  - "Algorithm: Ed25519"
  - "Signer: [truncated public key]"
- Action button:
  - [Verify Another] button (clears form)

---

### PAGE 7: ADMIN - EVENT GENERATOR

**Panel Layout:**
- Title: "➕ Event Generator"
- Subtitle: "Create a new verification event for your community"

**Form Section (2 fields):**

1. Input: "Community ID"
   - Label: "Community ID"
   - Input field, placeholder: "e.g., cardano-devs-ph"
   - Required field (red asterisk)

2. Input: "Custom Message (Optional)"
   - Label: "Custom Message"
   - Text area, placeholder: "Enter custom message (optional)..."
   - Height: 100px
   - Hint text: "If blank, default message will be used"

3. Button: "Generate Event"
   - Full width, cyan background
   - Loading state: spinner

**Results Section (after generation):**
- Success message: Green badge "✓ Event generated successfully"
- Event Details display:
  - Event ID: "UUID-here" + copy button
  - Nonce: "base64-here" + copy button
  - Timestamp: "1701274800"
  - Expiry: "1701278400 (in 1 hour)"
  - Message: "[Generated message text]"
- Action buttons:
  - [Copy All Details] button
  - [Generate QR Code] button (optional)
  - [Share Event] button (optional)
  - [Generate Another] button

---

### PAGE 8: ADMIN - SIGNATURE VERIFIER

**Panel Layout:**
- Title: "✅ Verify Signature (Admin)"
- Subtitle: "Verify user signature and optionally register them"

**Form Section (4 fields):**

1. Input: "Event ID"
   - Input field, placeholder: "Paste event ID..."

2. Input: "Wallet Address"
   - Input field, placeholder: "Paste wallet address..."

3. Input: "Public Key"
   - Text area, placeholder: "Paste public key..."
   - Height: 80px

4. Input: "Signature"
   - Text area, placeholder: "Paste signature..."
   - Height: 80px

5. Button: "Verify Signature"
   - Full width, cyan background
   - Loading state

**Results Section:**
- Verification Result badge:
  - If valid: Green badge "✓ VALID SIGNATURE"
  - If invalid: Red badge "✗ INVALID SIGNATURE"
- Verification Details:
  - "Verified at: [timestamp]"
  - "Signature ID: [UUID]"
- Conditional Button (only if valid):
  - [Register User] button (green background)
  - Shows confirmation modal before registering

---

### PAGE 9: ADMIN - REGISTRY MANAGER

**Panel Layout:**
- Title: "📊 User Registry"
- Subtitle: "Manage and view all registered community members"

**Filter & Search Section (sticky top):**
- Search box: "Search by wallet or user ID..." (cyan border on focus)
- Filter 1: Dropdown "Filter by Community" (default: "All")
- Filter 2: Dropdown "Filter by Status" (options: All, Verified, Pending)
- [Clear Filters] button (secondary style)
- Results count: "Showing X-Y of Z total users"

**Data Table:**
- Columns: User ID | Wallet Address | Community | Status | Actions
- Column widths: 15% | 35% | 20% | 15% | 15%
- Row styling:
  - Alternating row colors (slight opacity difference)
  - Hover effect: row highlight with slightly lighter background
  - Rows: 30px height

- Cell 1 (User ID): Truncated UUID, monospace font
- Cell 2 (Wallet Address): Truncated (addr1q...), clickable tooltip on hover
- Cell 3 (Community): Community name
- Cell 4 (Status): Badge
  - "verified" = Green badge
  - "pending" = Yellow badge
- Cell 5 (Actions): 
  - [View] icon button
  - [Edit] icon button
  - [Delete] icon button (with confirmation)

**Pagination (bottom):**
- Items per page selector: 10 | 25 | 50
- Page numbers: « 1 2 3 4 ... »
- Navigation arrows

---

### PAGE 10: ADMIN - REPORT GENERATOR

**Panel Layout:**
- Title: "📈 Report Generator"
- Subtitle: "Generate community reports in JSON or CSV format"

**Form Section (4 fields):**

1. Select: "Report Format"
   - Options: JSON | CSV
   - Default: JSON

2. Input: "From Date"
   - Date picker, format: YYYY-MM-DD
   - Placeholder: "Select start date..."

3. Input: "To Date"
   - Date picker, format: YYYY-MM-DD
   - Placeholder: "Select end date..."

4. Select: "Community (Optional)"
   - Dropdown with options (or "All Communities")
   - Searchable

5. Button: "Generate Report"
   - Full width, cyan background
   - Loading state: spinner with "Generating report..."

**Results Section (after generation):**
- Success message: Green badge "✓ Report generated successfully"
- Report Preview:
  - Shows JSON/CSV formatted text in monospace
  - Max height: 300px with scroll
  - Code block styling with dark background
- Report Summary:
  - "Generated at: [timestamp]"
  - "Total users: 3,420"
  - "Verified: 2,890"
  - "Pending: 530"
- Action buttons:
  - [Copy Report] button
  - [Download as JSON] or [Download as CSV] button (depending on format)
  - [Generate Another] button

---

## COMPONENT STYLES

### Buttons
- Default: Cyan background (#00d4ff), dark text (#0a0e27), 6px radius
- Secondary: Dark background with cyan border, cyan text, 6px radius
- Danger: Red background (#ef4444), white text, 6px radius
- Hover: All buttons lift slightly (transform: translateY(-2px)), shadow increases
- Disabled: Grayed out, no hover effect
- Loading: Show spinner animation inside button
- Size: Padding 10px 25px, min-height 44px

### Input Fields
- Background: rgba(30, 40, 70, 0.6)
- Border: 1px solid #1e4d5a
- Border radius: 6px
- Padding: 12px 16px
- Text color: #e0e0e0
- Focus: Border color changes to #00d4ff, shadow: 0 0 10px rgba(0, 212, 255, 0.3)
- Placeholder: #808080
- Error: Border color #ef4444

### Cards
- Background: rgba(30, 40, 70, 0.9)
- Border: 1px solid rgba(0, 212, 255, 0.3)
- Padding: 20px
- Border radius: 8px
- Shadow: 0 4px 12px rgba(0, 0, 0, 0.3)

### Badges
- Success: Background #4ade80, text #0a0e27, padding 4px 12px, radius 4px
- Warning: Background #facc15, text #0a0e27, padding 4px 12px, radius 4px
- Danger: Background #ef4444, text white, padding 4px 12px, radius 4px
- Info: Background #0ea5e9, text white, padding 4px 12px, radius 4px

### Tables
- Header row: Background rgba(0, 212, 255, 0.1), border-bottom 2px solid #00d4ff
- Body rows: Background transparent, border-bottom 1px solid rgba(0, 212, 255, 0.2)
- Hover rows: Background rgba(0, 212, 255, 0.05)
- Text: #e0e0e0 for primary, #a0a0a0 for secondary

### Modals/Overlays
- Backdrop: rgba(10, 14, 39, 0.95)
- Modal background: rgba(26, 31, 58, 0.95)
- Border: 2px solid #00d4ff
- Close button: Top right corner
- Padding: 32px
- Border radius: 12px

### Loading Spinner
- Show rotating circle animation, cyan color (#00d4ff)
- Size: 40px
- Animation: 1s rotation

---

## RESPONSIVE DESIGN

### Desktop (1200px+)
- 4-column grid for tool cards
- 3-column grid for stats
- Full-width tables

### Tablet (768px - 1199px)
- 2-column grid for tool cards
- 2-column grid for stats
- Adjusted table columns with scroll on smaller tables

### Mobile (< 768px)
- 1-column grid for all cards
- 1-column grid for stats
- Stack all sections vertically
- Touch-friendly: buttons min 44px height
- Reduced padding on mobile

---

## ANIMATIONS & INTERACTIONS

### Entrance Animations
- Pages: Fade in + slight slide up (200ms ease-out)
- Cards: Stagger entrance (100ms delay between each)
- Forms: Fade in when section becomes active

### Hover Effects
- Buttons: Lift up 2px, shadow increases
- Cards (clickable): Lift up 5px, shadow increases, border becomes more vibrant
- Links: Text color becomes brighter (#00d4ff)
- Table rows (hoverable): Background highlight

### Loading States
- Show spinner in button during API calls
- Disable form inputs during submission
- Show loading skeleton for tables

### Success/Error States
- Success: Green badge appears, auto-dismiss after 3 seconds (optional)
- Error: Red badge appears, stays until dismissed
- Validation errors appear below field in red text

### Copy to Clipboard
- On copy: Show temporary "✓ Copied!" message or toast notification
- Toast appears top-right, auto-dismiss after 2 seconds

---

## GLOBAL LAYOUT

### Grid System
- Max width: 1200px
- Padding: 20px on desktop, 16px on tablet, 12px on mobile
- Column gap: 24px
- Row gap: 24px

### Spacing
- Page top padding: 40px
- Section spacing: 32px
- Card padding: 20px
- Label spacing: 12px
- Input spacing: 16px between inputs

---

## ADDITIONAL ELEMENTS

### Breadcrumb Navigation (optional)
- Format: "Home / Admin / Events"
- Location: Below header
- Style: Secondary text color

### Notifications/Toasts
- Position: Top-right corner
- Size: 350px width, auto height
- Duration: 3-5 seconds auto-dismiss
- Colors: Green (success), Red (error), Yellow (warning), Blue (info)
- Include close button

### Help Text/Hints
- Color: #a0a0a0
- Font size: 12px
- Margin top: 4px below input
- Italic or light font weight

### Tooltips
- Background: #1a1f3a
- Border: 1px solid #00d4ff
- Text: #e0e0e0
- Padding: 8px 12px
- Border radius: 6px
- Arrow pointing to target element

---

## EXPORT REQUIREMENTS

Create wireframes and high-fidelity mockups for:
1. ✓ Landing Page
2. ✓ End-User Dashboard
3. ✓ All 4 End-User Tools (Keygen, Signer, Verifier, Exporter)
4. ✓ Admin Dashboard
5. ✓ All 4 Admin Tools (Event, Verify, Registry, Report)

Include:
- Desktop (1200px)
- Tablet (768px)
- Mobile (375px)

Create component library with:
- Buttons (all variants)
- Input fields
- Text areas
- Badges
- Cards
- Tables
- Modals
- Spinners
- Icons (use system icons or emoji)

Export as:
- Figma design file (.fig)
- SVG/PNG assets for components
- CSS variables file matching color system
```

---

## 📋 HOW TO USE THIS PROMPT

### Step 1: Copy the Prompt
Select and copy the entire "MASTER DESIGN PROMPT" section above (from "Create a complete web application..." to the end of the prompt).

### Step 2: Open Figma
- Go to figma.com
- Create or open a project
- Access Figma's AI design tool (Figjam or Figma's AI plugin)

### Step 3: Paste the Prompt
- Open the AI design tool
- Paste the copied prompt
- Click "Generate Design" or similar button

### Step 4: Review & Customize
- Review the generated designs
- Make any adjustments needed
- Export components and assets

### Step 5: Extract Assets
- Download all component SVGs
- Export color variables
- Export typography settings
- Generate CSS for styling

---

## 🎯 EXPECTED OUTCOMES

Figma AI should generate:

✅ **10 Complete Pages:**
- Landing page with role selection
- End-User dashboard + 4 tool pages
- Admin dashboard + 4 tool pages

✅ **Component Library:**
- 15+ reusable UI components
- All variants (default, hover, active, disabled, loading)
- Proper spacing and alignment

✅ **Design System:**
- Color palette with all defined colors
- Typography styles
- Spacing/grid system
- Shadow and effects system

✅ **Responsive Breakpoints:**
- Desktop, Tablet, Mobile versions
- Proper responsive behavior
- Touch-friendly sizing

✅ **Interactive Elements:**
- Button hover states
- Input focus states
- Form validation states
- Modal overlays

✅ **Assets & Exports:**
- SVG icons
- Component library
- CSS variables
- Figma components

---

## 💡 TIPS FOR BEST RESULTS

1. **If Figma AI generates incomplete designs:**
   - Add more specific prompts for missing sections
   - Request "Create detailed wireframes for the Registry Manager page"
   - Ask for "Create a component library with all button variants"

2. **For refinement:**
   - Request "Make the design more modern with gradient accents"
   - Ask for "Add micro-interactions and animations to all buttons"
   - Request "Create dark mode variations"

3. **For exports:**
   - Ask Figma AI to "Export all components as individual SVGs"
   - Request "Generate CSS variables matching the design system"
   - Ask for "Create a component documentation page"

4. **For consistency:**
   - Request "Apply consistent spacing throughout all pages"
   - Ask for "Ensure all buttons have consistent styling"
   - Request "Standardize all form inputs and text areas"

---

## 📞 ADDITIONAL CUSTOMIZATION PROMPTS

### To add more detail:
```
"Add detailed form validation states showing error messages in red below each field. 
Show success states with green checkmarks. Create loading states with spinners."
```

### To add animations:
```
"Add smooth transition animations between pages. 
Create button hover animations with 2px lift and shadow increase. 
Add staggered entrance animations for card grids."
```

### To add interactions:
```
"Create interactive mockups showing: 
1. Clicking role card opens dashboard
2. Clicking tool card opens tool panel
3. Form submission shows success notification
4. Error states show red validation messages"
```

### For mobile optimization:
```
"Create mobile-optimized versions where:
- All tool cards stack vertically (1 column)
- Tables become card-based layouts
- Buttons become full-width and touch-friendly (48px min height)
- Modals cover full screen on mobile"
```

---

## 🚀 QUICK START CHECKLIST

- [ ] Copy the Master Design Prompt
- [ ] Open Figma
- [ ] Access AI design tool
- [ ] Paste prompt
- [ ] Click Generate
- [ ] Review generated designs
- [ ] Make customizations
- [ ] Export components and assets
- [ ] Convert to CSS/code
- [ ] Integrate with React frontend

**Next Step:** Use generated designs as reference for building React components!
