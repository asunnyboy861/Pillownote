# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | Pillownote |
| **Git URL** | git@github.com:asunnyboy861/Pillownote.git |
| **Repo URL** | https://github.com/asunnyboy861/Pillownote |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/Pillownote/ | ✅ Active |
| Support | https://asunnyboy861.github.io/Pillownote/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/Pillownote/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/Pillownote/terms.html | ✅ Active |

## Repository Structure

```
Pillownote/
├── Pillownote.xcodeproj/          # Xcode Project (xcodegen-generated)
├── Pillownote/                    # iOS App Source Code
│   ├── App/                       # Entry + root tabs
│   ├── Models/                    # SwiftData entities
│   ├── Views/                     # Today/Us/Coach/Glow/Book/Onboarding/Settings/Paywall
│   ├── Services/                  # AI, StoreKit, CloudKit, Speech, Crypto, Export, Glow
│   ├── Theme/                     # Cozy Intimacy design system
│   └── Assets.xcassets/           # App icon + accent color
├── PillownoteWidgets/             # WidgetKit extension (4 free widgets)
├── Shared/                        # App Group shared widget snapshot
├── Pillownote.storekit            # Local StoreKit testing configuration
├── project.yml                    # xcodegen project definition
├── us.md                          # English development guide
├── capabilities.md                # Capabilities configuration
├── icon.md                        # App icon documentation
├── price.md                       # Pricing configuration
├── app_review_info.md             # App Review information
├── nowgit.md                      # This file
├── keytext.md                     # ⚠️ EXCLUDED from repo (.gitignore — confidential ASO strategy)
└── COMPETITOR_REPORT.md           # ⚠️ EXCLUDED from repo (.gitignore — confidential)
```

## Verified Build Status

| Check | Result |
|-------|--------|
| iPhone 16 build + run | ✅ Launched, onboarding rendered |
| iPad Pro 13-inch (M5) build + run | ✅ Launched, layout centered correctly |
| Security scan (secrets) | ✅ CLEAN |
| Local commit | ac06162 |
