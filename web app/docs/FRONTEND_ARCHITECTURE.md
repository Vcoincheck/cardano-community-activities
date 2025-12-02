# Frontend Architecture & UI/UX Design Guide

## 📐 Overall Architecture

```
frontend/
├── src/
│   ├── main.jsx                    # Root component
│   ├── pages/                      # Page-level components
│   │   ├── LandingPage.jsx         # Home/role selection
│   │   ├── EndUserDashboard.jsx    # User tools dashboard
│   │   ├── AdminDashboard.jsx      # Admin dashboard
│   │   └── NotFound.jsx            # 404 page
│   ├── components/                 # Reusable components
│   │   ├── layout/
│   │   │   ├── Header.jsx
│   │   │   ├── Sidebar.jsx
│   │   │   ├── Footer.jsx
│   │   │   └── MainLayout.jsx
│   │   ├── tools/                  # Feature tools
│   │   │   ├── KeyGenerator.jsx
│   │   │   ├── MessageSigner.jsx
│   │   │   ├── SignatureVerifier.jsx
│   │   │   ├── WalletExporter.jsx
│   │   │   ├── EventGenerator.jsx
│   │   │   ├── SignatureVerifyAdmin.jsx
│   │   │   ├── RegistryManager.jsx
│   │   │   └── ReportGenerator.jsx
│   │   ├── common/
│   │   │   ├── Button.jsx
│   │   │   ├── Card.jsx
│   │   │   ├── Modal.jsx
│   │   │   ├── Input.jsx
│   │   │   ├── TextArea.jsx
│   │   │   ├── Badge.jsx
│   │   │   ├── Spinner.jsx
│   │   │   ├── Alert.jsx
│   │   │   └── Table.jsx
│   │   └── forms/
│   │       ├── WalletForm.jsx
│   │       ├── MessageForm.jsx
│   │       ├── EventForm.jsx
│   │       └── RegistryForm.jsx
│   ├── hooks/                      # Custom React hooks
│   │   ├── useApi.js               # API calls wrapper
│   │   ├── useAuth.js              # Authentication state
│   │   ├── useLocalStorage.js      # Local storage handler
│   │   └── useCopy.js              # Copy to clipboard
│   ├── services/                   # API/service layer
│   │   ├── api.js                  # Axios instance
│   │   ├── eventService.js         # Event API calls
│   │   ├── signatureService.js     # Signature API calls
│   │   ├── registryService.js      # Registry API calls
│   │   ├── walletService.js        # Wallet API calls
│   │   └── reportService.js        # Report API calls
│   ├── styles/                     # Global styles
│   │   ├── globals.css             # Base styles
│   │   ├── variables.css           # CSS variables
│   │   ├── animations.css          # Animations
│   │   └── responsive.css          # Media queries
│   ├── utils/                      # Utility functions
│   │   ├── formatters.js           # Data formatting
│   │   ├── validators.js           # Input validation
│   │   ├── crypto.js               # Crypto helpers
│   │   └── constants.js            # App constants
│   └── context/                    # React Context
│       ├── AppContext.js           # Global app state
│       └── UserContext.js          # User state
├── public/
│   └── index.html                  # HTML entry point
├── vite.config.js                  # Vite configuration
├── package.json
└── .env.example
```

---

## 🎨 Design System

### Color Palette

```css
/* Primary Colors */
--primary-blue: #00d4ff        /* Cyan/Electric Blue */
--primary-dark: #0a0e27        /* Dark Navy */
--primary-darker: #1a1f3a      /* Dark Blue-Gray */

/* Background Colors */
--bg-primary: #0a0e27          /* Main background */
--bg-secondary: #1a1f3a        /* Secondary background */
--bg-tertiary: #2a3050         /* Tertiary background */
--bg-card: rgba(30, 40, 70, 0.9)  /* Card background */
--bg-overlay: rgba(10, 14, 39, 0.95)  /* Modal overlay */

/* Text Colors */
--text-primary: #e0e0e0        /* Primary text */
--text-secondary: #a0a0a0      /* Secondary text */
--text-tertiary: #808080        /* Tertiary text */
--text-hover: #00d4ff           /* Hover text */

/* Status Colors */
--success: #4ade80             /* Green */
--warning: #facc15             /* Amber/Yellow */
--danger: #ef4444              /* Red */
--info: #0ea5e9                /* Sky Blue */

/* Border Colors */
--border-primary: #00d4ff      /* Primary border */
--border-secondary: #1e4d5a    /* Secondary border */
```

### Typography

```css
/* Font Family */
font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;

/* Font Sizes */
--font-xs: 12px
--font-sm: 14px
--font-base: 16px
--font-lg: 18px
--font-xl: 20px
--font-2xl: 24px
--font-3xl: 28px
--font-4xl: 32px

/* Font Weights */
--font-normal: 400
--font-medium: 500
--font-semibold: 600
--font-bold: 700
```

### Spacing

```css
--spacing-xs: 4px
--spacing-sm: 8px
--spacing-md: 16px
--spacing-lg: 24px
--spacing-xl: 32px
--spacing-2xl: 48px
--spacing-3xl: 64px
```

### Border Radius

```css
--radius-sm: 4px
--radius-md: 8px
--radius-lg: 12px
--radius-xl: 16px
--radius-full: 9999px
```

---

## 📄 Page-Level Components

### 1. Landing Page (LandingPage.jsx)

**Purpose:** Home page with role selection

**Layout:**
```
┌─────────────────────────────────────┐
│         CARDANO COMMUNITY SUITE      │
│    Choose your role to continue      │
└─────────────────────────────────────┘

┌──────────────────┐   ┌──────────────────┐
│      👤          │   │    👨‍💼           │
│   END-USER       │   │    ADMIN         │
│ Manage wallets   │   │ Verify users     │
│   [Enter]        │   │   [Enter]        │
└──────────────────┘   └──────────────────┘

┌──────────────────────────────────────┐
│          ✨ FEATURES                 │
├──────────────────────────────────────┤
│ 🔐 End-User Tools                   │
│ 👨‍💼 Admin Features                 │
│ 🔐 Security                         │
│ 📊 Analytics                        │
└──────────────────────────────────────┘
```

**Components:**
- Header with logo
- Hero section with tagline
- Two role cards (clickable, hoverable)
- Features section (4-column grid)
- Footer with version info

**State:**
```javascript
{
  role: null | 'user' | 'admin',
  stats: {
    total_users: number,
    total_verified: number,
    total_communities: number
  }
}
```

---

### 2. End-User Dashboard (EndUserDashboard.jsx)

**Purpose:** User tools interface

**Layout:**
```
┌─────────────────────────────────────┐
│ [← Back]  👤 END-USER TOOLS        │
└─────────────────────────────────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   🔑 GEN     │  │  ✍️ SIGN     │  │  ✓ VERIFY    │  │  💾 EXPORT   │
│ KEYPAIR     │  │  MESSAGE     │  │  SIGNATURE   │  │  WALLET      │
│ [Access]    │  │  [Access]    │  │  [Access]    │  │  [Access]    │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
```

**Sub-Components (4 tools):**

#### Tool 1: KeyGenerator
- Generate Ed25519 keypairs
- Display public/private keys (with copy buttons)
- Export key pair as JSON
- Download functionality

#### Tool 2: MessageSigner
- Input text message
- Paste private key (client-side only)
- Sign message button
- Display signature (copyable)
- QR code for signature (optional)

#### Tool 3: SignatureVerifier
- Input original message
- Input public key
- Input signature
- Verify button
- Show verification result with badge

#### Tool 4: WalletExporter
- Generate wallet data structure
- Include all derived keys
- Display JSON format
- Download as file

---

### 3. Admin Dashboard (AdminDashboard.jsx)

**Purpose:** Community administration interface

**Layout:**
```
┌──────────────────────────────────────┐
│ [← Back]  👨‍💼 ADMIN DASHBOARD         │
└──────────────────────────────────────┘

┌─────────┐  ┌─────────┐  ┌─────────┐
│ 3,420   │  │ 2,890   │  │   15    │
│ USERS   │  │VERIFIED │  │COMMUNTY │
└─────────┘  └─────────┘  └─────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  ➕ CREATE   │  │  ✅ VERIFY   │  │  📊 VIEW     │  │  📈 EXPORT   │
│  EVENT       │  │  SIGNATURE   │  │  REGISTRY    │  │  REPORT      │
│  [Access]    │  │  [Access]    │  │  [Access]    │  │  [Access]    │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
```

**Stat Cards:**
- Total Users: 3,420
- Total Verified: 2,890
- Total Communities: 15

**Sub-Components (4 tools):**

#### Tool 1: EventGenerator
- Input community ID
- Input custom message (optional)
- Generate event button
- Display: event_id, nonce, expiry
- Copy event details button
- Share/QR code functionality

#### Tool 2: SignatureVerifyAdmin
- Input event_id
- Input wallet address
- Input public key
- Input signature
- Verify button
- Result: Valid/Invalid with details

#### Tool 3: RegistryManager
- Table: User ID | Wallet | Community | Status | Actions
- Filters: By community, By status
- Search box
- Pagination (10/25/50 per page)
- Actions: View, Edit, Delete
- Inline editing capability

#### Tool 4: ReportGenerator
- Select report type (JSON/CSV)
- Select date range
- Select community filter
- Generate report button
- Display preview
- Download button

---

## 🧩 Reusable Components

### Layout Components

#### MainLayout.jsx
```javascript
<MainLayout role="user|admin">
  {children}
</MainLayout>
```
Wraps pages with header, sidebar (optional), and footer

#### Header.jsx
```javascript
<Header 
  title="Page Title"
  showBackButton={true}
  onBack={() => setRole(null)}
/>
```

#### Sidebar.jsx (Admin only)
Navigation menu with sections:
- Dashboard
- Tools (Event, Verify, Registry, Reports)
- Settings
- Logout

---

### Common UI Components

#### Button.jsx
```javascript
<Button 
  variant="primary|secondary|danger"
  size="sm|md|lg"
  disabled={false}
  loading={false}
  onClick={handleClick}
>
  Button Text
</Button>
```

#### Card.jsx
```javascript
<Card title="Card Title" icon="🔐">
  {children}
</Card>
```

#### Input.jsx
```javascript
<Input
  label="Field Label"
  type="text|email|password|number"
  placeholder="Enter value..."
  value={value}
  onChange={handleChange}
  error={errorMessage}
  required={true}
/>
```

#### TextArea.jsx
```javascript
<TextArea
  label="Message"
  placeholder="Enter message..."
  value={value}
  onChange={handleChange}
  rows={4}
  maxLength={500}
/>
```

#### Modal.jsx
```javascript
<Modal 
  isOpen={true}
  title="Modal Title"
  onClose={handleClose}
>
  {children}
</Modal>
```

#### Table.jsx
```javascript
<Table
  columns={[
    { key: 'id', label: 'ID', width: '20%' },
    { key: 'name', label: 'Name', width: '40%' },
    { key: 'status', label: 'Status', width: '20%', render: (val) => <Badge>{val}</Badge> },
    { key: 'actions', label: 'Actions', width: '20%' }
  ]}
  data={tableData}
  onRowClick={handleRowClick}
  pagination={true}
  itemsPerPage={10}
/>
```

#### Badge.jsx
```javascript
<Badge variant="success|warning|danger|info">
  Label
</Badge>
```

#### Alert.jsx
```javascript
<Alert 
  type="success|error|warning|info"
  title="Alert Title"
  message="Alert message content"
  onClose={handleClose}
/>
```

---

## 🎯 Key Workflows

### Workflow 1: Generate Keypair (End-User)
```
KeyGenerator Component
├── [Generate Keys Button]
├── On Click:
│   ├── Generate Ed25519 keys
│   ├── Display public key (copyable)
│   ├── Display private key (hidden by default)
│   └── Show/Hide toggle for private key
├── [Export as JSON Button]
└── [Download Button]
```

### Workflow 2: Sign Message (End-User)
```
MessageSigner Component
├── Input: Message (TextArea)
├── Input: Private Key (TextArea, masked)
├── [Sign Button]
├── On Sign:
│   ├── Validate inputs
│   ├── Sign locally (crypto-js)
│   └── Display signature
├── [Copy Signature Button]
└── [QR Code Button] (optional)
```

### Workflow 3: Create Event (Admin)
```
EventGenerator Component
├── Input: Community ID (Input)
├── Input: Custom Message (TextArea, optional)
├── [Generate Event Button]
├── On Generate:
│   ├── POST /api/events/generate
│   ├── Display: event_id, nonce, timestamp, expiry
│   └── Show success message
├── [Copy Event Details Button]
└── [Share/QR Button]
```

### Workflow 4: Verify Event Signature (Admin)
```
SignatureVerifyAdmin Component
├── Input: Event ID (Input)
├── Input: Wallet Address (Input)
├── Input: Public Key (TextArea)
├── Input: Signature (TextArea)
├── [Verify Button]
├── On Verify:
│   ├── POST /api/signatures/verify
│   ├── Display: Valid/Invalid badge
│   └── Show details (verified at, method, etc.)
└── [Register User Button] (if valid)
```

---

## 🔄 State Management

### Global Context Structure

#### AppContext.js
```javascript
{
  theme: 'dark' | 'light',
  notifications: [],
  loading: false,
  error: null,
  
  actions: {
    addNotification(message, type),
    removeNotification(id),
    setLoading(bool),
    setError(error)
  }
}
```

#### UserContext.js
```javascript
{
  role: null | 'user' | 'admin',
  userId: string | null,
  communityId: string | null,
  stats: {
    total_users: number,
    total_verified: number,
    total_communities: number
  },
  
  actions: {
    setRole(role),
    setUserId(id),
    logout()
  }
}
```

---

## 🎨 Responsive Design

### Breakpoints
```css
Mobile:     < 640px
Tablet:     640px - 1024px
Desktop:    > 1024px
Large:      > 1280px
```

### Grid System

**Landing Page:**
```css
grid-template-columns: 1fr 1fr     /* Desktop */
grid-template-columns: 1fr         /* Tablet/Mobile */
```

**Tool Cards:**
```css
grid-template-columns: repeat(4, 1fr)  /* Desktop (1200px+) */
grid-template-columns: repeat(2, 1fr)  /* Tablet (768px - 1024px) */
grid-template-columns: 1fr             /* Mobile (< 768px) */
```

**Admin Stats:**
```css
grid-template-columns: repeat(3, 1fr)  /* Desktop */
grid-template-columns: repeat(2, 1fr)  /* Tablet */
grid-template-columns: 1fr             /* Mobile */
```

---

## 🚀 Performance Optimization

### Code Splitting
```javascript
// pages/ - lazy loaded
const EndUserDashboard = lazy(() => import('./pages/EndUserDashboard'));
const AdminDashboard = lazy(() => import('./pages/AdminDashboard'));

// Suspense fallback
<Suspense fallback={<Spinner />}>
  {children}
</Suspense>
```

### API Caching
```javascript
// useApi hook with caching
const { data, loading, error } = useApi(
  '/api/registry/stats/summary',
  { cache: 300 } // 5 minutes
);
```

### Image Optimization
- SVG icons for all buttons
- Optimized PNGs for screenshots
- WebP format with PNG fallback

---

## ♿ Accessibility

### ARIA Labels
```jsx
<button aria-label="Generate new keypair">
  🔑 Generate
</button>
```

### Keyboard Navigation
- Tab through all interactive elements
- Enter/Space to activate buttons
- Escape to close modals

### Color Contrast
- All text meets WCAG AA standards
- Primary text: #e0e0e0 on #0a0e27 (contrast 13.1:1)
- Blue: #00d4ff on #0a0e27 (contrast 8.2:1)

---

## 📦 Dependencies

```json
{
  "react": "^18.2.0",
  "react-dom": "^18.2.0",
  "react-router-dom": "^6.14.0",
  "axios": "^1.4.0",
  "crypto-js": "^4.1.1",
  "qrcode.react": "^1.0.1",
  "date-fns": "^2.30.0",
  "zustand": "^4.4.0"
}
```

---

## 🔐 Security Considerations

### Client-Side Crypto
- All key generation done in browser
- Private keys NEVER sent to server
- No server-side storage of private keys
- Use crypto-js for Ed25519 operations

### Input Validation
- Validate all form inputs before submission
- Sanitize clipboard paste content
- Max length constraints

### XSS Prevention
- Escape all user-generated content
- Use textContent instead of innerHTML
- React's built-in escaping

---

## 📱 Mobile Responsiveness

### Touch-Friendly
- Buttons: min 44x44px
- Spacing: touch-friendly gaps
- Swipe gestures for navigation (optional)

### Mobile Layout
```
Landing:
- Single column role cards
- Stacked stats
- Full-width features

Dashboard:
- Card grid → Single column
- Collapsible sidebar
- Bottom navigation tabs
```

---

## 🎭 Animation & Transitions

### Entrance Animations
```css
@keyframes slideInUp {
  from { transform: translateY(20px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

animation: slideInUp 0.3s ease-out;
```

### Hover Effects
```css
button:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(0, 212, 255, 0.2);
}
```

### Loading States
- Spinner animation on API calls
- Skeleton loading for tables/lists
- Disabled state during submission

---

## 🛠️ Development Workflow

### Component Creation Checklist
- [ ] Create component file
- [ ] Import required dependencies
- [ ] Define component props (PropTypes or TypeScript)
- [ ] Create JSX markup
- [ ] Style with CSS/inline styles
- [ ] Add error handling
- [ ] Add accessibility (aria labels)
- [ ] Export component

### Testing
```bash
# Run tests
npm test

# Test coverage
npm test -- --coverage
```

---

## 📝 File Naming Conventions

- Components: PascalCase (e.g., KeyGenerator.jsx)
- Hooks: camelCase starting with 'use' (e.g., useApi.js)
- Utils: camelCase (e.g., formatters.js)
- Styles: descriptive names (e.g., card.css)
- Images: kebab-case (e.g., hero-image.png)

---

## 🚀 Deployment Checklist

- [ ] Build production bundle
- [ ] Test all features
- [ ] Verify API endpoints
- [ ] Check responsive design
- [ ] Test on mobile devices
- [ ] Lighthouse audit
- [ ] Optimize bundle size
- [ ] Deploy to hosting

---

---

# 🔀 App Routes & Navigation Structure

## 📍 Route Map

```
/                               Landing Page (Role Selection)
├── /user                       End-User Dashboard (Main)
│   ├── /user/keygen            Keypair Generator Tool
│   ├── /user/signer            Message Signer Tool
│   ├── /user/verifier          Signature Verifier Tool
│   └── /user/exporter          Wallet Exporter Tool
│
├── /admin                       Admin Dashboard (Main)
│   ├── /admin/events           Event Generator Tool
│   ├── /admin/verify           Signature Verifier Tool
│   ├── /admin/registry         User Registry Manager
│   └── /admin/reports          Report Generator Tool
│
└── /404                         Not Found Page
```

---

## 🏠 Route Details

### 1. Landing Page
**Path:** `/`  
**Component:** `LandingPage.jsx`  
**Purpose:** Home page with role selection

**Features:**
- Hero section with project title
- Two role cards (End-User, Admin)
- Features showcase
- Statistics preview

**Navigation:**
```
├── Click "End-User" → navigate to /user
├── Click "Admin" → navigate to /admin
└── Footer links → external resources
```

**Component Structure:**
```jsx
<LandingPage />
├── Header
│   └── Logo + Title
├── Hero Section
│   ├── Welcome Message
│   └── Tagline
├── Role Selection
│   ├── UserCard → onClick → navigate('/user')
│   └── AdminCard → onClick → navigate('/admin')
├── Features Grid
│   ├── Feature 1
│   ├── Feature 2
│   ├── Feature 3
│   └── Feature 4
└── Footer
    ├── Version Info
    └── Links
```

---

## 👤 End-User Routes

### 2. End-User Dashboard
**Path:** `/user`  
**Component:** `EndUserDashboard.jsx`  
**Purpose:** Main hub for end-user tools

**Features:**
- 4 tool cards (Keygen, Signer, Verifier, Exporter)
- Quick access buttons
- Navigation header with back button
- Tool switching via route or UI

**Layout:**
```
┌─────────────────────────────────────┐
│ [← Back]  👤 END-USER TOOLS        │
└─────────────────────────────────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   🔑 KEYGEN  │  │  ✍️ SIGNER   │  │  ✓ VERIFIER  │  │  💾 EXPORT   │
│   [Access]   │  │   [Access]   │  │   [Access]   │  │   [Access]   │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
```

**Navigation:**
```javascript
// From card click
<Card onClick={() => navigate('/user/keygen')}>
  🔑 Keypair Generator
</Card>

// Or from direct URL
/user/keygen → Show KeyGenerator tool
/user/signer → Show MessageSigner tool
/user/verifier → Show SignatureVerifier tool
/user/exporter → Show WalletExporter tool
```

**Component Structure:**
```jsx
<EndUserDashboard initialTool="keygen">
├── Header
│   ├── Back Button
│   └── Title
├── ToolGrid
│   ├── ToolCard (keygen)
│   ├── ToolCard (signer)
│   ├── ToolCard (verifier)
│   └── ToolCard (exporter)
└── ActiveTool (conditional render)
    ├── KeyGenerator (when route = /user/keygen)
    ├── MessageSigner (when route = /user/signer)
    ├── SignatureVerifier (when route = /user/verifier)
    └── WalletExporter (when route = /user/exporter)
```

---

### 2.1 Keypair Generator
**Path:** `/user/keygen`  
**Component:** `KeyGenerator.jsx`  
**Purpose:** Generate Ed25519 keypairs

**Features:**
- Generate button
- Display public key
- Display/hide private key
- Copy to clipboard
- Download as JSON
- Clear all

**Props from parent:**
```javascript
{
  isActive: true,
  onBack: () => navigate('/user')
}
```

**State:**
```javascript
{
  publicKey: string | null,
  privateKey: string | null,
  showPrivateKey: boolean,
  copied: boolean,
  loading: boolean
}
```

**API Calls:**
```javascript
// Client-side only - no API calls
// Uses TweetNaCl.js or similar for key generation
```

---

### 2.2 Message Signer
**Path:** `/user/signer`  
**Component:** `MessageSigner.jsx`  
**Purpose:** Sign messages with private key

**Features:**
- Input message textarea
- Input private key textarea
- Sign button
- Display signature
- Copy signature
- QR code (optional)
- Clear form

**Form Inputs:**
```javascript
{
  message: string,
  privateKey: string
}
```

**State:**
```javascript
{
  message: string,
  privateKey: string,
  signature: string | null,
  copied: boolean,
  loading: boolean,
  error: string | null
}
```

**Workflow:**
```
1. User enters message
2. User pastes private key
3. Clicks "Sign Message"
4. Validate inputs
5. Sign locally (Ed25519)
6. Display signature
7. User can copy or download
```

---

### 2.3 Signature Verifier
**Path:** `/user/verifier`  
**Component:** `SignatureVerifier.jsx`  
**Purpose:** Verify signatures locally

**Features:**
- Input original message
- Input public key
- Input signature
- Verify button
- Display result (Valid/Invalid)
- Show verification details

**Form Inputs:**
```javascript
{
  message: string,
  publicKey: string,
  signature: string
}
```

**State:**
```javascript
{
  message: string,
  publicKey: string,
  signature: string,
  verified: boolean | null,
  loading: boolean,
  error: string | null
}
```

**Workflow:**
```
1. User enters message, public key, signature
2. Clicks "Verify"
3. Verify locally (Ed25519)
4. Show: ✓ Valid or ✗ Invalid
5. Display verification time
```

---

### 2.4 Wallet Exporter
**Path:** `/user/exporter`  
**Component:** `WalletExporter.jsx`  
**Purpose:** Export wallet data structure

**Features:**
- Generate wallet structure
- Display JSON format
- Copy to clipboard
- Download as file
- Show wallet summary

**Generated Wallet Structure:**
```javascript
{
  walletId: "uuid",
  createdAt: "2025-11-29T...",
  keys: {
    publicKey: string,
    privateKey: string
  },
  metadata: {
    algorithm: "Ed25519",
    format: "JSON"
  }
}
```

**State:**
```javascript
{
  walletData: object | null,
  copied: boolean,
  loading: boolean
}
```

---

## 👨‍💼 Admin Routes

### 3. Admin Dashboard
**Path:** `/admin`  
**Component:** `AdminDashboard.jsx`  
**Purpose:** Main hub for admin tools + statistics

**Features:**
- 3 stat cards (Total Users, Verified, Communities)
- 4 tool cards (Events, Verify, Registry, Reports)
- Navigation header with back button
- Real-time stats loading

**Layout:**
```
┌──────────────────────────────────────┐
│ [← Back]  👨‍💼 ADMIN DASHBOARD        │
└──────────────────────────────────────┘

┌─────────┐  ┌─────────┐  ┌─────────┐
│ 3,420   │  │ 2,890   │  │   15    │
│ USERS   │  │VERIFIED │  │COMMUNTY │
└─────────┘  └─────────┘  └─────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ ➕ EVENTS    │  │ ✅ VERIFY    │  │ 📊 REGISTRY  │  │ 📈 REPORTS   │
│ [Access]    │  │ [Access]     │  │ [Access]     │  │ [Access]     │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
```

**Navigation:**
```javascript
// From card click
<Card onClick={() => navigate('/admin/events')}>
  ➕ Event Generator
</Card>

// Or from direct URL
/admin/events → Show EventGenerator tool
/admin/verify → Show SignatureVerifier tool
/admin/registry → Show RegistryManager tool
/admin/reports → Show ReportGenerator tool
```

**Component Structure:**
```jsx
<AdminDashboard initialTool="events">
├── Header
│   ├── Back Button
│   └── Title
├── StatCards
│   ├── Stat Card (Total Users)
│   ├── Stat Card (Verified)
│   └── Stat Card (Communities)
├── ToolGrid
│   ├── ToolCard (events)
│   ├── ToolCard (verify)
│   ├── ToolCard (registry)
│   └── ToolCard (reports)
└── ActiveTool (conditional render)
    ├── EventGenerator (when route = /admin/events)
    ├── SignatureVerifyAdmin (when route = /admin/verify)
    ├── RegistryManager (when route = /admin/registry)
    └── ReportGenerator (when route = /admin/reports)
```

**State:**
```javascript
{
  stats: {
    total_users: number,
    total_verified: number,
    total_communities: number
  },
  loading: boolean,
  error: string | null
}
```

**API Calls:**
```javascript
// On mount, fetch dashboard stats
GET /api/reports/dashboard/stats

// Response
{
  total_users: 3420,
  total_verified: 2890,
  total_communities: 15
}
```

---

### 3.1 Event Generator
**Path:** `/admin/events`  
**Component:** `EventGenerator.jsx`  
**Purpose:** Generate verification events

**Features:**
- Input community ID
- Input custom message (optional)
- Generate button
- Display event details (event_id, nonce, expiry)
- Copy event details
- Share/QR functionality

**Form Inputs:**
```javascript
{
  communityId: string,
  customMessage: string (optional)
}
```

**State:**
```javascript
{
  communityId: string,
  customMessage: string,
  generatedEvent: {
    event_id: string,
    nonce: string,
    timestamp: number,
    expiry: number,
    message: string
  } | null,
  loading: boolean,
  error: string | null,
  copied: boolean
}
```

**Workflow:**
```
1. Admin enters community ID
2. (Optional) enters custom message
3. Clicks "Generate Event"
4. POST /api/events/generate
5. Display event details
6. Admin can copy/share
```

**API Call:**
```javascript
POST /api/events/generate
Content-Type: application/json

{
  "communityId": "cardano-devs-ph",
  "customMessage": "Please verify your membership"
}

// Response
{
  "event_id": "uuid",
  "community_id": "cardano-devs-ph",
  "nonce": "base64...",
  "timestamp": 1701274800,
  "action": "verify_membership",
  "message": "Please verify your membership",
  "expiry": 1701278400,
  "created_at": "2025-11-29T15:00:00Z"
}
```

---

### 3.2 Signature Verifier (Admin)
**Path:** `/admin/verify`  
**Component:** `SignatureVerifyAdmin.jsx`  
**Purpose:** Verify user signatures and register users

**Features:**
- Input event ID
- Input wallet address
- Input public key
- Input signature
- Verify button
- Display result (Valid/Invalid)
- Register user button (if valid)

**Form Inputs:**
```javascript
{
  eventId: string,
  walletAddress: string,
  publicKey: string,
  signature: string
}
```

**State:**
```javascript
{
  eventId: string,
  walletAddress: string,
  publicKey: string,
  signature: string,
  verificationResult: {
    valid: boolean,
    signature_id: string,
    verified_at: timestamp
  } | null,
  loading: boolean,
  error: string | null
}
```

**Workflow:**
```
1. Admin enters event details and signature
2. Clicks "Verify Signature"
3. POST /api/signatures/verify
4. Show: ✓ Valid or ✗ Invalid
5. If valid, show "Register User" button
6. Click to register in registry
```

**API Calls:**
```javascript
// Step 1: Verify signature
POST /api/signatures/verify
{
  "event_id": "uuid",
  "wallet_address": "addr1q...",
  "public_key": "hex...",
  "signature": "hex...",
  "signing_method": "cip30"
}

// Step 2 (if valid): Register user
POST /api/registry/register
{
  "wallet_address": "addr1q...",
  "event_id": "uuid",
  "community_id": "cardano-devs-ph",
  "public_key": "hex..."
}
```

---

### 3.3 Registry Manager
**Path:** `/admin/registry`  
**Component:** `RegistryManager.jsx`  
**Purpose:** Manage community members

**Features:**
- User table with columns (ID, Wallet, Community, Status)
- Search box
- Filters (by community, by status)
- Pagination (10/25/50 per page)
- Actions (View, Edit, Delete)
- Sort by column
- Bulk actions (optional)

**Table Columns:**
```javascript
[
  { key: 'id', label: 'User ID', width: '15%', sortable: true },
  { key: 'wallet_address', label: 'Wallet Address', width: '35%', truncate: true },
  { key: 'community_id', label: 'Community', width: '20%', sortable: true },
  { key: 'status', label: 'Status', width: '15%', render: renderStatusBadge },
  { key: 'actions', label: 'Actions', width: '15%', render: renderActions }
]
```

**State:**
```javascript
{
  users: array,
  filteredUsers: array,
  searchQuery: string,
  filterCommunity: string,
  filterStatus: string,
  currentPage: number,
  itemsPerPage: 10,
  totalUsers: number,
  loading: boolean,
  error: string | null,
  sortBy: string,
  sortOrder: 'asc' | 'desc'
}
```

**Workflow:**
```
1. Load users from API
2. Display table with filters
3. User can:
   - Search by wallet/user ID
   - Filter by community
   - Filter by status
   - Sort by columns
   - View user details
   - Edit status
   - Delete user
4. Pagination for large datasets
```

**API Calls:**
```javascript
// Fetch all users (with filters)
GET /api/registry?community_id=xxx&status=verified&page=1&limit=10

// Get single user
GET /api/registry/:userId

// Update user status
PATCH /api/registry/:userId/status
{ "status": "verified" | "pending" }

// Delete user
DELETE /api/registry/:userId
```

---

### 3.4 Report Generator
**Path:** `/admin/reports`  
**Component:** `ReportGenerator.jsx`  
**Purpose:** Generate community reports

**Features:**
- Report type selector (JSON, CSV)
- Date range picker
- Community filter
- Generate button
- Preview report
- Download button

**Form Inputs:**
```javascript
{
  reportType: 'json' | 'csv',
  dateFrom: date,
  dateTo: date,
  communityId: string (optional)
}
```

**State:**
```javascript
{
  reportType: 'json' | 'csv',
  dateFrom: date,
  dateTo: date,
  communityId: string,
  reportData: object | null,
  preview: string | null,
  loading: boolean,
  error: string | null,
  downloading: boolean
}
```

**Workflow:**
```
1. Admin selects report type
2. Selects date range
3. (Optional) filters by community
4. Clicks "Generate Report"
5. POST /api/reports/community
6. Show preview of report
7. Download button available
```

**API Calls:**
```javascript
// Generate report
POST /api/reports/community
{
  "format": "json" | "csv",
  "date_from": "2025-11-01",
  "date_to": "2025-11-29",
  "community_id": "cardano-devs-ph" (optional)
}

// Response (JSON)
{
  "generated_at": "2025-11-29T15:00:00Z",
  "total_users": 3420,
  "verified": 2890,
  "pending": 530,
  "users": [...]
}
```

---

## 🚫 Error Pages

### 4. Not Found Page
**Path:** `/404` (or any undefined route)  
**Component:** `NotFound.jsx`  
**Purpose:** Handle 404 errors

**Features:**
- 404 error message
- Back to home button
- Suggested navigation links

**Layout:**
```
┌──────────────────────────────┐
│      404 - Page Not Found    │
│    The page you're looking   │
│   for doesn't exist or has   │
│    been moved elsewhere       │
└──────────────────────────────┘

[← Go Home]  [Browse Tools]
```

---

## 🔀 Navigation Helper Functions

### useNavigate Hook
```javascript
import { useNavigate } from 'react-router-dom';

export function useNavigation() {
  const navigate = useNavigate();

  return {
    toHome: () => navigate('/'),
    toUserDashboard: () => navigate('/user'),
    toUserKeygen: () => navigate('/user/keygen'),
    toUserSigner: () => navigate('/user/signer'),
    toUserVerifier: () => navigate('/user/verifier'),
    toUserExporter: () => navigate('/user/exporter'),
    toAdminDashboard: () => navigate('/admin'),
    toAdminEvents: () => navigate('/admin/events'),
    toAdminVerify: () => navigate('/admin/verify'),
    toAdminRegistry: () => navigate('/admin/registry'),
    toAdminReports: () => navigate('/admin/reports'),
    goBack: () => navigate(-1)
  };
}
```

### Usage Example
```javascript
import { useNavigation } from './hooks/useNavigation';

export function MyComponent() {
  const nav = useNavigation();

  return (
    <button onClick={nav.toUserDashboard}>
      Go to User Dashboard
    </button>
  );
}
```

---

## 🔗 Link Components

### NavLink Example
```javascript
import { Link } from 'react-router-dom';

<Link to="/user/keygen">Generate Keypair</Link>
<Link to="/admin/events">Create Event</Link>
<Link to="/">Back to Home</Link>
```

### Dynamic Navigation
```javascript
import { useLocation } from 'react-router-dom';

export function BreadCrumb() {
  const location = useLocation();
  const path = location.pathname;

  return (
    <div>
      {path === '/user/keygen' && 'Home / User / Keygen'}
      {path === '/admin/events' && 'Home / Admin / Events'}
    </div>
  );
}
```

---

## 🎯 Route Protection (Future Enhancement)

### Private Route Component
```javascript
import { Navigate } from 'react-router-dom';

function PrivateRoute({ element, requiredRole }) {
  const { role } = useContext(UserContext);

  if (!role) {
    return <Navigate to="/" replace />;
  }

  if (requiredRole && role !== requiredRole) {
    return <Navigate to="/404" replace />;
  }

  return element;
}

// Usage
<Route 
  path="/admin" 
  element={<PrivateRoute element={<AdminDashboard />} requiredRole="admin" />} 
/>
```

---

## 📊 Route State Management

### Using URL State
```javascript
// Store data in URL parameters
navigate(`/admin/registry?search=addr1q&status=verified`);

// Read from URL
const searchParams = new URLSearchParams(location.search);
const search = searchParams.get('search');
const status = searchParams.get('status');
```

### Using Context
```javascript
// Store in global context for cross-route access
const { user, setUser } = useContext(UserContext);
```

---

## ⚡ Performance Optimization

### Route-Based Code Splitting
```javascript
const EndUserDashboard = lazy(() => 
  import('./pages/EndUserDashboard')
);
const AdminDashboard = lazy(() => 
  import('./pages/AdminDashboard')
);

// Wrapped with Suspense
<Suspense fallback={<LoadingFallback />}>
  <Routes>
    <Route path="/user" element={<EndUserDashboard />} />
    <Route path="/admin" element={<AdminDashboard />} />
  </Routes>
</Suspense>
```

### Prefetch Routes
```javascript
export function usePrefetch() {
  const navigate = useNavigate();

  const prefetch = (path) => {
    // Optional: Preload route component
    import(`./${path}`);
  };

  return { prefetch };
}
```

---

## 📝 Route Naming Convention

- **Public routes:** Lowercase, dash-separated (e.g., `/user-guide`)
- **Dynamic routes:** With params in brackets (e.g., `/user/:id`)
- **Grouped routes:** Share common prefix (e.g., `/admin/*`)
- **Nested routes:** Clear hierarchy (e.g., `/admin/registry/edit/:id`)

---

## 🧪 Testing Routes

### Route Testing Example
```javascript
import { render, screen } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import App from './App';

test('navigates to user dashboard', () => {
  render(
    <BrowserRouter>
      <App />
    </BrowserRouter>
  );
  
  const userButton = screen.getByText('End-User');
  userButton.click();
  
  expect(screen.getByText('END-USER TOOLS')).toBeInTheDocument();
});
```

---

## 📋 Quick Reference

| Route | Component | Purpose |
|-------|-----------|---------|
| `/` | LandingPage | Home page |
| `/user` | EndUserDashboard | User dashboard |
| `/user/keygen` | KeyGenerator | Generate keys |
| `/user/signer` | MessageSigner | Sign messages |
| `/user/verifier` | SignatureVerifier | Verify signatures |
| `/user/exporter` | WalletExporter | Export wallet |
| `/admin` | AdminDashboard | Admin dashboard |
| `/admin/events` | EventGenerator | Generate events |
| `/admin/verify` | SignatureVerifyAdmin | Verify signatures |
| `/admin/registry` | RegistryManager | Manage users |
| `/admin/reports` | ReportGenerator | Generate reports |
| `/404` | NotFound | Not found page |

---

## 📞 Support & Documentation

For questions or issues with frontend implementation:
1. Check component documentation sections above
2. Review API_SPEC.md for backend endpoints
3. Check SETUP.md for development environment
