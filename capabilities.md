# Capabilities Configuration

## Analysis
Based on guide + us.md analysis:
- CloudKit sync + CKShare pairing → iCloud (CloudKit) — "同步/CKSyncEngine/双人共享库"
- Local notifications for note arrival → Push Notifications — "通知/提醒"
- WidgetKit extension → App Groups + widget target — "组件全家桶"
- StoreKit subscriptions/IAP → In-App Purchase capability (auto-enabled with StoreKit code)
- Photo notes → NSPhotoLibrary usage descriptions
- Voice notes + speech-to-text → NSMicrophone + NSSpeechRecognition usage descriptions
- No HealthKit / Location / Watch / Siri needed

## Project Scaffold (auto-created via xcodegen — user-authorized)
- Pillownote.xcodeproj generated with 2 targets:
  - Pillownote (iOS app, SwiftUI lifecycle, bundle `com.zzoutuo.Pillownote`, iPhone+iPad)
  - PillownoteWidgets (widget extension, bundle `com.zzoutuo.Pillownote.Widgets`)
- App Group: `group.com.zzoutuo.Pillownote` (both targets)
- Deployment target: iOS 17.0

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| App Groups | ✅ Configured | .entitlements (both targets) |
| iCloud (CloudKit, container `iCloud.com.zzoutuo.Pillownote`) | ✅ Entitlement set | .entitlements |
| Push Notifications (aps-environment) | ✅ Entitlement set | .entitlements |
| Widget Extension target | ✅ Configured | xcodegen project.yml |
| Camera/Photo Library usage | ✅ To be added in code-gen phase Info.plist keys | GENERATE_INFOPLIST_FILE |
| Microphone / Speech usage | ✅ To be added in code-gen phase Info.plist keys | GENERATE_INFOPLIST_FILE |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| CloudKit container in Apple Developer portal | ⏳ Pending (needs paid team signing) | Xcode → Signing & Capabilities → select Team → CloudKit dashboard: create container `iCloud.com.zzoutuo.Pillownote` + enable APNs. **App works without it**: local-first SwiftData with demo-partner mode is the default; CloudKit sync is an enhancement |
| APNs key for real push | ⏳ Pending | Apple Developer portal → Keys → Apple Push Notifications service. **App works without it**: local notifications cover the daily loop |
| IAP products in App Store Connect | ⏳ Pending | Created at submission time (see price.md) |

## No Configuration Needed
- HealthKit, Location, Apple Watch, Siri, Sign in with Apple — not in scope
- No third-party SDK forced: StoreKit 2 native (RevenueCat optional, not required)

## Verification
- Build succeeded after configuration: ✅ (iPhone 16 simulator, 9.8s)
- All entitlements correct: ✅
- App icon set + no alpha: ✅
