# SpoilAlert - Skincare Expiry Tracker

## Executive Summary

**SpoilAlert** is an iOS app that tracks skincare product expiration after opening using PAO (Period After Opening) symbol photo recognition, smart countdown timers, and daily check-in habits. The killer feature is **PAO symbol OCR recognition** — no competitor offers this. Users simply photograph the jar symbol on their product packaging, and the app automatically detects the PAO period (e.g., "12M"), calculates the expiration date, and sets up multi-level reminders.

**Product Vision**: Become the de facto skincare safety net for American women — every product tracked, every expiration known, no expired skincare ever applied.

**Core Differentiators**:
1. PAO symbol photo recognition (Vision OCR) — unique in market
2. Daily skincare check-in mechanism — drives daily active usage
3. Skin journal correlation — link product usage to skin condition
4. Pure offline, zero-server architecture — privacy-first, zero maintenance cost

**Target Market**: 25-45 year old North American women who use 5+ skincare products daily. Market size: ~60 million US women.

---

## Competitive Analysis

| Feature | SpoilAlert | CosmeTick | CosmeticsMoa | BeautiStics | Best By |
|---------|:-:|:-:|:-:|:-:|:-:|
| **PAO Photo Recognition** | YES | NO | NO | NO | NO |
| **Barcode Scanner** | YES | YES | NO | NO | NO |
| **Expiry Countdown** | YES | YES | YES | YES | YES |
| **Daily Check-in** | YES | NO | NO | NO | NO |
| **Skin Journal** | YES | NO | NO | NO | NO |
| **Widget** | YES | NO | NO | NO | NO |
| **iCloud Sync** | YES(Pro) | NO | NO | YES | NO |
| **Family Sharing** | YES(Pro) | NO | NO | NO | NO |
| **Dark Mode** | YES | NO | NO | YES | NO |
| **Offline** | YES | YES | YES | NO | YES |
| **App Store Rating** | — | 5.0(1) | NEW | 5.0(1) | NEW |
| **Pricing** | Free+$2.99/$4.99 | Free+$4.99+ | Free | Free+IAP | Free |
| **Min iOS** | 17.0 | 15+ | 18.0 | 16.0 | 15.1 |

**Key Competitive Advantages**:
- PAO photo recognition is a unique feature no competitor offers
- Daily check-in creates habit loop driving DAU
- Offline-first architecture ensures reliability
- Focused on skincare (not broad cosmetics/food) for vertical depth

---

## Apple Design Guidelines Compliance

- **HIG Layout**: Use standard NavigationStack, TabView, and SwiftUI components
- **Typography**: SF Pro system fonts with Dynamic Type support
- **Colors**: Support both light and dark mode with semantic colors
- **Accessibility**: VoiceOver labels, minimum 44pt touch targets, high contrast support
- **Privacy**: No data leaves the device (except Pro iCloud sync with user consent)
- **Notifications**: Request permission with clear explanation of value
- **Camera**: Request permission only when user initiates scan action
- **IAP**: Follow Apple's subscription guidelines — no dark patterns, dynamic pricing, restore purchases

---

## Technical Architecture

```
Frontend:    SwiftUI + SwiftData + WidgetKit
AI/OCR:      Vision Framework (VNRecognizeTextRequest, VNDetectBarcodesRequest)
Camera:      AVFoundation (real-time preview for barcode scanning)
Notifications: UserNotifications + Background Tasks
Storage:     SwiftData (primary) + UserDefaults (settings) + Keychain (subscription)
IAP:         StoreKit 2
Cloud:       CloudKit (Pro tier only)
```

**Architecture Pattern**: MVVM (Model-View-ViewModel)
- Models: SwiftData @Model classes
- Views: SwiftUI views
- ViewModels: @Observable classes managing business logic
- Services: Singleton services for OCR, notifications, purchases

**No third-party dependencies** — all Apple native frameworks.

---

## Module Structure & File Organization

```
SpoilAlert/
├── SpoilAlertApp.swift                    # App entry point + SwiftData container
├── Models/
│   ├── SkincareProduct.swift              # Product data model (SwiftData)
│   ├── SkinLog.swift                      # Skin journal entry model
│   ├── ProductCategory.swift              # Category enum + defaults
│   └── ExpiryStatus.swift                 # Expiry status enum
├── ViewModels/
│   ├── DashboardViewModel.swift           # Dashboard business logic
│   ├── AddProductViewModel.swift          # Add product flow logic
│   ├── ProductListViewModel.swift         # Product list filtering/sorting
│   └── SettingsViewModel.swift            # Settings management
├── Views/
│   ├── ContentView.swift                  # Main TabView navigation
│   ├── Dashboard/
│   │   ├── DashboardView.swift            # Main dashboard with overview
│   │   ├── ExpiryRingView.swift           # Circular expiry chart
│   │   └── StatCardView.swift             # Stat card component
│   ├── Products/
│   │   ├── ProductListView.swift          # Product list with filters
│   │   ├── ProductRowView.swift           # Product row component
│   │   └── ProductDetailView.swift        # Product detail + edit
│   ├── AddProduct/
│   │   ├── AddProductView.swift           # Add product form
│   │   ├── PAOScanView.swift              # PAO symbol camera scan
│   │   └── BarcodeScanView.swift          # Barcode scanner
│   ├── CheckIn/
│   │   ├── DailyCheckInView.swift         # Daily check-in view
│   │   └── CheckInButton.swift            # Check-in button component
│   ├── SkinJournal/
│   │   ├── SkinJournalView.swift          # Skin journal list
│   │   └── AddSkinLogView.swift           # Add skin log entry
│   ├── Settings/
│   │   ├── SettingsView.swift             # Settings main view
│   │   ├── PaywallView.swift              # Subscription paywall
│   │   └── ContactSupportView.swift       # Contact support form
│   └── Onboarding/
│       └── OnboardingView.swift           # First-launch onboarding
├── Services/
│   ├── PAORecognitionService.swift        # Vision OCR for PAO symbols
│   ├── BarcodeScannerService.swift        # Barcode detection
│   ├── NotificationService.swift          # Expiry reminder scheduling
│   └── PurchaseManager.swift              # StoreKit 2 subscription manager
├── Utilities/
│   ├── Constants.swift                    # App-wide constants
│   └── Extensions.swift                   # Swift extensions
└── Widget/
    ├── SpoilAlertWidget.swift             # Widget entry point
    └── SpoilAlertWidgetBundle.swift       # Widget bundle
```

---

## Implementation Flow

### Step 1: Data Models (SwiftData)
- Create SkincareProduct @Model with all attributes
- Create SkinLog @Model with relationship to product
- Create ProductCategory enum with default PAO values
- Create ExpiryStatus enum for UI color coding
- Configure SwiftData container in App entry

### Step 2: Core Services
- Implement PAORecognitionService with Vision OCR
- Implement BarcodeScannerService with Vision barcode detection
- Implement NotificationService with 4-level reminders
- Implement PurchaseManager with StoreKit 2

### Step 3: Dashboard & Navigation
- Create ContentView with TabView (Dashboard, Products, Check-in, Skin Journal, Settings)
- Create DashboardView with overview cards, expiry ring, expiring soon list
- Create StatCardView and ExpiryRingView components

### Step 4: Product Management
- Create AddProductView with manual entry + PAO scan + barcode scan
- Create PAOScanView with camera and OCR
- Create BarcodeScanView with camera and barcode detection
- Create ProductListView with filtering and sorting
- Create ProductDetailView with edit and delete

### Step 5: Daily Check-in
- Create DailyCheckInView with product check-in buttons
- Create CheckInButton component with toggle state

### Step 6: Skin Journal
- Create SkinJournalView with log list and trend
- Create AddSkinLogView with condition rating and notes

### Step 7: Settings & IAP
- Create SettingsView with preferences and links
- Create PaywallView with subscription tiers
- Create ContactSupportView with feedback form
- Integrate PurchaseManager throughout app

### Step 8: Widget & Onboarding
- Create Widget for home screen
- Create OnboardingView for first launch
- Request notification and camera permissions

---

## UI/UX Design Specifications

### Design Philosophy
**Keywords**: Fresh, Clean, Calm, Empowering

Inspired by 2025-2026 "Quiet Luxury" aesthetic — soft tones, generous whitespace, rounded corners, lightweight typography. Avoid stereotypical "cute pink" — pursue "intelligent elegance."

### Color System
| Role | Light Mode | Dark Mode |
|------|-----------|-----------|
| Primary | Sage Green #8B9D83 | Sage Green #8B9D83 |
| Accent | Soft Lavender #B8A9C9 | Soft Lavender #B8A9C9 |
| Background | Warm Cream #FFF8F0 | Deep Indigo #0F0F1A |
| Card Surface | White #FFFFFF | Indigo Gray #1A1A2E |
| Text Primary | Deep Indigo #1A1A2E | Light Indigo White #E8E8F0 |
| Text Secondary | Gray #6B7280 | Gray #9CA3AF |
| Safe (>30d) | Green #4CAF50 | Green #66BB6A |
| Warning (8-30d) | Amber #FFB74D | Amber #FFB74D |
| Critical (1-7d) | Orange #FF7043 | Orange #FF7043 |
| Expired | Red #EF5350 | Red #EF5350 |

### Typography
| Usage | Font | Size | Weight |
|-------|------|------|--------|
| Large Title | SF Pro Rounded | 34pt | Bold |
| Page Title | SF Pro Rounded | 28pt | Semibold |
| Card Title | SF Pro Rounded | 20pt | Medium |
| Body | SF Pro Text | 16pt | Regular |
| Caption | SF Pro Text | 14pt | Regular |
| Countdown | SF Pro Rounded | 48pt | Bold |

### Navigation
- TabView with 5 tabs: Dashboard, Products, Check-in, Journal, Settings
- Each tab uses NavigationStack for hierarchical navigation
- Add Product button in top-right of Dashboard and Product List

### iPad Layout Rules
- Main content in ScrollView: `.frame(maxWidth: 720).frame(maxWidth: .infinity)`
- Never use `.tabViewStyle(.sidebarAdaptable)`

---

## Code Generation Rules

1. **Architecture**: MVVM with SwiftData @Model
2. **UI**: Pure SwiftUI, no UIKit except AVFoundation camera
3. **Storage**: SwiftData primary, UserDefaults settings only, Keychain subscriptions
4. **Async**: async/await + Actor, no Combine or DispatchQueue (except Vision callbacks)
5. **Error Handling**: Swift native Error protocol with user-friendly descriptions
6. **Naming**: English naming, Service suffix for services, View suffix for views
7. **Min Deploy**: iOS 17.0 (SwiftData stable requirement)
8. **No Third-Party**: All Apple native frameworks
9. **Accessibility**: VoiceOver, Dynamic Type, high contrast, reduced motion
10. **No Comments**: Do not add comments unless explicitly asked
11. **iPad**: Always add `.frame(maxWidth: 720).frame(maxWidth: .infinity)` to main content ScrollView
12. **ObservableObject**: Do NOT use ObservableObject conformance on views already marked with @Observable
13. **iOS 17+**: Do NOT use iOS 18+ only APIs
14. **Accent Color**: Use `Color.accentColor` instead of `ShapeStyle.accent`

---

## Testing & Validation Standards

- Build must succeed on both iPhone and iPad simulators
- All TabView tabs must be navigable
- Add product flow must work (manual entry at minimum)
- Dashboard must display correct stats
- Check-in must toggle correctly
- Dark mode must render properly
- No crashes on launch or navigation

---

## Build & Deployment Checklist

- [ ] Xcode project configured with correct Bundle ID (com.zzoutuo.SpoilAlert)
- [ ] iOS Deployment Target set to 17.0
- [ ] SwiftData container configured
- [ ] Camera usage description in Info.plist
- [ ] Notification usage description in Info.plist
- [ ] Photo library usage description in Info.plist
- [ ] StoreKit configuration file added
- [ ] Widget target configured
- [ ] App icon configured
- [ ] Privacy Policy page deployed
- [ ] Terms of Use page deployed
- [ ] Support page deployed
- [ ] App Store metadata prepared
