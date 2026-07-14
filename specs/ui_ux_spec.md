# Shiftak (`شِفْتَك`) — UI/UX Specification & Design System
> **Status:** `APPROVED` | **Version:** `1.0.0` | **Last Updated:** 2026-07-14  
> **Platform:** Flutter 3.22+ | **Theme:** Minimalist Light | **Primary Font:** Cairo (RTL Default)

---

## 1. Design Philosophy

ShiftSync's visual language is built on three principles:

1. **Clarity over decoration**: Every visual element earns its presence by communicating information.
2. **State at a glance**: Color and badge shapes are the primary carriers of shift state — a nurse should understand their schedule without reading a word.
3. **Calm confidence**: Soft shadows, generous whitespace, and rounded corners create a premium feel without feeling playful or clinical.

---

## 2. Design Tokens

All tokens are defined as Dart constants in `lib/core/theme/app_tokens.dart`.
No raw hex colors or hardcoded values are permitted anywhere outside this file.

### 2.1 Color Palette

```dart
// lib/core/theme/app_tokens.dart

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary       = Color(0xFF2563EB); // Blue 600   — actions, links, active state
  static const Color primaryLight  = Color(0xFFEFF6FF); // Blue 50    — primary surface tint
  static const Color primaryDark   = Color(0xFF1D4ED8); // Blue 700   — pressed states

  static const Color secondary     = Color(0xFF0F172A); // Slate 900  — headings, high-emphasis text
  static const Color secondaryMid  = Color(0xFF475569); // Slate 600  — body text, labels
  static const Color secondaryLow  = Color(0xFF94A3B8); // Slate 400  — captions, placeholder text

  // ── Surface & Background ───────────────────────────────────────────────────
  static const Color background    = Color(0xFFF8FAFC); // Slate 50   — app background
  static const Color surface       = Color(0xFFFFFFFF); // White      — card surfaces
  static const Color surfaceAlt    = Color(0xFFF1F5F9); // Slate 100  — secondary surfaces, dividers

  // ── Shift State Colors ─────────────────────────────────────────────────────
  static const Color shiftLong     = Color(0xFF3B82F6); // Blue 500   — Long Day shift
  static const Color shiftLongBg   = Color(0xFFEFF6FF); // Blue 50    — Long Day badge bg
  static const Color shiftNight    = Color(0xFF6366F1); // Indigo 500 — Sahr/Night shift
  static const Color shiftNightBg  = Color(0xFFEEF2FF); // Indigo 50  — Night badge bg
  static const Color shiftOff      = Color(0xFF64748B); // Slate 500  — Day Off
  static const Color shiftOffBg    = Color(0xFFF1F5F9); // Slate 100  — Day Off badge bg

  // ── Financial State Colors ─────────────────────────────────────────────────
  static const Color debtRed       = Color(0xFFEF4444); // Red 500    — "I owe" / عليا فلوس
  static const Color debtRedBg     = Color(0xFFFEF2F2); // Red 50     — Debt card background
  static const Color debtRedBorder = Color(0xFFFECACA); // Red 200    — Debt card border
  static const Color claimGreen    = Color(0xFF22C55E); // Green 500  — "Owed to me" / ليا فلوس
  static const Color claimGreenBg  = Color(0xFFF0FDF4); // Green 50   — Claim card background
  static const Color claimBorder   = Color(0xFFBBF7D0); // Green 200  — Claim card border
  static const Color settledGray   = Color(0xFF94A3B8); // Slate 400  — Settled transactions

  // ── Status & Feedback ──────────────────────────────────────────────────────
  static const Color success       = Color(0xFF16A34A); // Green 600
  static const Color warning       = Color(0xFFF59E0B); // Amber 500
  static const Color error         = Color(0xFFDC2626); // Red 600
  static const Color info          = Color(0xFF0284C7); // Sky 600

  // ── Swap State Colors ──────────────────────────────────────────────────────
  static const Color swapPending   = Color(0xFFF59E0B); // Amber 500
  static const Color swapAccepted  = Color(0xFF3B82F6); // Blue 500
  static const Color swapCompleted = Color(0xFF22C55E); // Green 500
  static const Color swapRejected  = Color(0xFFEF4444); // Red 500
  static const Color swapExpired   = Color(0xFF94A3B8); // Slate 400
}
```

### 2.2 Typography Scale

```dart
class AppTextStyles {
  AppTextStyles._();
  // Font: 'Inter' — imported via google_fonts package

  static const TextStyle displayLg  = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2);
  static const TextStyle displayMd  = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3);
  static const TextStyle headingLg  = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle headingMd  = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle headingSm  = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.5);
  static const TextStyle bodyLg     = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6);
  static const TextStyle bodyMd     = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.6);
  static const TextStyle bodySm     = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle label      = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4, letterSpacing: 0.5);
  static const TextStyle caption    = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, height: 1.4);
  static const TextStyle buttonText = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.3);
  static const TextStyle monoMd     = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'monospace');
}
```

### 2.3 Spacing & Radius Tokens

```dart
class AppSpacing {
  AppSpacing._();
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;
}

class AppRadius {
  AppRadius._();
  static const double sm   = 8.0;   // Tags, chips
  static const double md   = 12.0;  // Input fields, small cards
  static const double lg   = 16.0;  // Main cards (standard)
  static const double xl   = 20.0;  // Bottom sheets, modals
  static const double full = 999.0; // Pills, badges
}
```

### 2.4 Shadow System

```dart
class AppShadows {
  AppShadows._();

  // Subtle elevation for cards
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x08000000), blurRadius: 4,  offset: Offset(0, 1)),
  ];

  // Stronger for modals, bottom sheets
  static const List<BoxShadow> modalShadow = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  // Invisible — used to reserve space without visual shadow
  static const List<BoxShadow> none = [];
}
```

---

## 3. Component Library

### 3.1 `ShiftBadge` — Shift Type Indicator

A pill-shaped tag showing the shift type. Used on calendar cells and schedule cards.

```
Properties:
  shiftType: ShiftType (LONG | NIGHT | OFF)
  size: BadgeSize (small | medium)  — default: medium

Visual:
  - LONG:  background=#EFF6FF, text=#2563EB, label="Long"
  - NIGHT: background=#EEF2FF, text=#6366F1, label="Night"
  - OFF:   background=#F1F5F9, text=#64748B, label="Off"
  - Border radius: AppRadius.full
  - Padding: 4x10 (sm) | 6x14 (md)
```

### 3.2 `StatusChip` — Swap/Sale Status

```
Properties:
  status: String (PENDING | ACCEPTED | COMPLETED | REJECTED | EXPIRED | LISTED | PURCHASED | SETTLED)

Visual:
  - PENDING:   bg=Amber50, text=Amber700, dot=Amber500
  - ACCEPTED:  bg=Blue50, text=Blue700, dot=Blue500
  - COMPLETED: bg=Green50, text=Green700, dot=Green500
  - REJECTED:  bg=Red50, text=Red700, dot=Red500
  - EXPIRED:   bg=Slate100, text=Slate500, dot=Slate400
  - LISTED:    bg=Blue50, text=Blue700 (pulsing dot animation)
  - PURCHASED: bg=Indigo50, text=Indigo700
  - SETTLED:   bg=Slate100, text=Slate500
```

### 3.3 `LedgerCard` — Financial Record Display

```
Properties:
  entryType: LedgerEntryType (DEBIT | CREDIT)
  amount: double
  counterpartyName: String
  shiftDate: DateTime
  status: LedgerStatus
  onSettle: VoidCallback? (only for CREDIT + UNSETTLED)

Visual (DEBIT — I OWE):
  - Background: AppColors.debtRedBg
  - Left border accent: 3px solid AppColors.debtRed
  - Header label: "عليا فلوس" in AppColors.debtRed, AppTextStyles.headingSm
  - Amount: AppTextStyles.displayMd in AppColors.debtRed
  - Person label: "لـ [name]" in AppColors.secondaryMid

Visual (CREDIT — OWED TO ME):
  - Background: AppColors.claimGreenBg
  - Left border accent: 3px solid AppColors.claimGreen
  - Header label: "ليا فلوس" in AppColors.claimGreen, AppTextStyles.headingSm
  - Amount: AppTextStyles.displayMd in AppColors.claimGreen
  - Person label: "من [name]" in AppColors.secondaryMid
  - Action button: "Confirm Settlement" — filled, AppColors.claimGreen
    - Shows confirmation bottom sheet before firing onSettle
```

### 3.4 `AppCard` — Base Card Container

```
Properties:
  child: Widget
  padding: EdgeInsets (default: all(AppSpacing.lg))
  onTap: VoidCallback?

Visual:
  - Background: AppColors.surface
  - Border radius: AppRadius.lg (16dp)
  - Box shadow: AppShadows.cardShadow
  - Ink ripple on tap with radius clipped to BorderRadius.circular(AppRadius.lg)
```

---

## 4. Screen Specifications

### Screen 1: Dashboard

**Route:** `/dashboard`  
**Bottom Nav Index:** 0

**Layout:**
```
┌─────────────────────────────────┐
│  [Avatar] Good morning, [Name]  │  ← Greeting header, current date
│  Dept: [Department Name]        │
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │  THIS WEEK SNAPSHOT       │  │  ← AppCard
│  │  Mon  Tue  Wed  Thu  Fri  │  │
│  │  [L]  [N]  [O]  [L]  [N] │  │  ← ShiftBadge per day (mini)
│  └───────────────────────────┘  │
│                                 │
│  ┌──────────┐  ┌──────────┐    │
│  │ HOURS    │  │ ALERTS   │    │  ← 2-column widget row
│  │ 112/160h │  │ 2 active │    │
│  │ ▓▓▓▓░░░░ │  │ swaps    │    │
│  └──────────┘  └──────────┘    │
│                                 │
│  ┌───────────────────────────┐  │
│  │  ACTIVE ALERTS            │  │  ← Alert feed (max 3 visible)
│  │  • Swap request from Ali  │  │
│  │  • New listing in dept    │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

**Key Elements:**
- **Greeting header**: Contextual — "Good Morning / Afternoon / Evening" based on time.
- **This Week Snapshot**: Horizontal row of 7 mini `ShiftBadge` widgets (Mon–Sun). Current day highlighted with primary color ring.
- **Hours Widget**: Circular progress indicator (custom painter) showing `worked / target` hours. Color: primary when < 90%, warning at 90-100%, success at 100%+.
- **Alert Feed**: Real-time list from notification stream (Riverpod StreamProvider). Tapping navigates to relevant screen.

---

### Screen 2: Shift Calendar

**Route:** `/calendar`  
**Bottom Nav Index:** 1

**Layout:**
```
┌─────────────────────────────────┐
│  < July 2026 >      [Batch]    │  ← Month navigator + batch-mode toggle
├─────────────────────────────────┤
│  Mon  Tue  Wed  Thu  Fri  Sat  Sun  │
│  ─────────────────────────────  │
│   1    2    3    4    5    6    7   │  ← Each cell:
│  [L]  [N]  [O]  [L]  [ ]  [ ] [ ]  │    colored chip if assigned
│   8    9   10   11   12   13   14  │    empty tap area if not
│  [N]  [ ]  [L]  [L]  [N]  [O] [O] │
│   ... (full month) ...              │
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │  ← Summary strip (sticky bottom)
│  │ Long: 12  Night: 8  Off: 5│  │
│  │ Total: 244h / 160h target │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

**Interaction States:**

| Tap State | Cell Appearance | Behavior |
|---|---|---|
| Empty cell | Dashed border, ghost | Opens ShiftType bottom sheet |
| Assigned cell | Filled chip color | Cycles type OR opens edit sheet (long-press) |
| Batch mode ON | Cells show checkboxes | Multi-select then assign from bottom sheet |
| Shift in active swap | Amber dashed border | Tap shows "Locked — active swap" toast |

**ShiftType Selection Bottom Sheet:**
- Presents 3 option tiles: Long (Blue), Night (Indigo), Off (Slate)
- Each tile: Icon + label + time range + tap to assign
- "Remove shift" destructive option at bottom (red text)

---

### Screen 3: Marketplace & Swap Board

**Route:** `/marketplace`  
**Bottom Nav Index:** 2

**Tab Structure:**
```
[Marketplace]  |  [Swap Requests]
```

#### Tab A: Marketplace (Shift Sales)

```
┌─────────────────────────────────┐
│  [🏪 Marketplace]  [+ Post]     │  ← Header + Post listing FAB
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │  ← ShiftSaleCard
│  │ [L] July 18 · Long Shift  │  │
│  │ Posted by: Sara Ahmed      │  │
│  │ Asking: 25,000 IQD         │  │
│  │ Expires in: 3 days         │  │
│  │            [Purchase Shift]│  │  ← Primary CTA button
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ [N] July 22 · Night Shift  │  │
│  │ Posted by: Noor Hassan     │  │
│  │ Asking: 30,000 IQD         │  │
│  │            [Purchase Shift]│  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

**ShiftSaleCard spec:**
- AppCard container
- Left-edge accent bar colored by `shiftType`
- Shift date in `AppTextStyles.headingMd`
- Poster name + asking amount below
- Expiry countdown in `AppColors.warning` when < 24h
- Purchase button: disabled if current user is the seller

#### Tab B: Swap Requests

```
┌─────────────────────────────────┐
│  INCOMING (2)                   │  ← Section header
│  ┌───────────────────────────┐  │
│  │ [PENDING] From: Ahmed M.   │  │  ← SwapCard
│  │ They offer: July 10 [L]    │  │
│  │ Want your:  July 14 [N]    │  │
│  │  [Reject]       [Accept]  │  │
│  └───────────────────────────┘  │
│                                 │
│  OUTGOING (1)                   │
│  ┌───────────────────────────┐  │
│  │ [ACCEPTED] To: Sara A.    │  │
│  │ You offered: July 10 [L]  │  │
│  │ Requesting:  July 14 [N]  │  │
│  │             [Confirm Now] │  │  ← Both parties must confirm
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

---

### Screen 4: Ledger Wallet

**Route:** `/ledger`  
**Bottom Nav Index:** 3

**Layout:**
```
┌─────────────────────────────────┐
│  My Wallet                      │
│  [I OWE]  |  [OWED TO ME]  |  [History]  ← 3 tabs
├─────────────────────────────────┤
│                                 │
│  Tab: I OWE (عليا فلوس)        │
│  ┌───────────────────────────┐  │  ← LedgerCard (DEBIT)
│  │ 🔴 عليا فلوس             │  │
│  │    25,000 IQD             │  │
│  │    لـ Sara Ahmed           │  │
│  │    July 18 Night Shift    │  │
│  │    [UNSETTLED]            │  │
│  └───────────────────────────┘  │
│                                 │
│  Tab: OWED TO ME (ليا فلوس)    │
│  ┌───────────────────────────┐  │  ← LedgerCard (CREDIT)
│  │ 🟢 ليا فلوس              │  │
│  │    30,000 IQD             │  │
│  │    من Ahmed Ali            │  │
│  │    July 22 Long Shift     │  │
│  │   [Confirm Settlement]    │  │  ← Action button — ONLY for to_user
│  └───────────────────────────┘  │
│                                 │
│  Tab: History                   │
│  ← Muted/grayscale version of settled records
└─────────────────────────────────┘
```

**Settlement Confirmation Flow:**

1. User taps "Confirm Settlement" on a CREDIT card.
2. Modal bottom sheet appears with:
   - Summary: counterparty name, amount, shift date
   - Warning text: "This confirms [Name] has paid you. This action cannot be undone."
   - Two buttons: "Cancel" (outlined) and "Yes, Settled" (filled green)
3. On confirm: API call → PATCH `/api/v1/ledger/{uuid}/settle`
4. Optimistic UI update: card animates out (slide + fade), success snackbar shown.

---

### Screen 5: Navigation Shell

**Bottom Navigation Bar** (4 items):

| Index | Label | Icon | Route |
|---|---|---|---|
| 0 | Home | `home_rounded` | `/dashboard` |
| 1 | Calendar | `calendar_month_rounded` | `/calendar` |
| 2 | Market | `storefront_rounded` | `/marketplace` |
| 3 | Wallet | `account_balance_wallet_rounded` | `/ledger` |

**Style:**
- Background: `AppColors.surface`
- Top border: 1px `AppColors.surfaceAlt`
- Selected item: `AppColors.primary` icon + label
- Unselected: `AppColors.secondaryLow`
- No background indicator pill (flat style)
- Badge on "Market" tab: shows count of new listings (red dot, `< 99`)

---

## 5. Motion & Animation Guidelines

| Interaction | Animation | Duration | Curve |
|---|---|---|---|
| Screen transition | Slide right (push) | 280ms | `Curves.easeInOut` |
| Bottom sheet appear | Slide up + fade | 240ms | `Curves.easeOut` |
| Card tap | Scale 0.98 → 1.0 | 120ms | `Curves.easeOut` |
| Ledger card dismiss (settled) | Slide left + fade out | 360ms | `Curves.easeIn` |
| Shift badge assignment | Scale 0 → 1.0 with bounce | 300ms | `Curves.elasticOut` |
| Loading state | Shimmer sweep | Continuous | Linear |
| Active listing dot | Pulse opacity 1.0 → 0.4 | 800ms loop | `Curves.easeInOut` |

---

## 6. Accessibility Notes

- All interactive elements have a minimum touch target of 44x44dp.
- Color is never the sole indicator of meaning — always paired with text label or icon.
- Financial amounts use `Semantics(label: "25000 Iraqi Dinars, owed")` for screen readers.
- Calendar cells use `Semantics(label: "July 14, Long shift, tap to edit")`.
