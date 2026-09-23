# Pillownote - iOS Development Guide

> Source: TR-20260916-枕边信Pillownote情侣App操作指南.MD (translated & restructured)
> Date: 2026-09-23 ｜ Category: Lifestyle ｜ Target Market: US ｜ Age Rating: 12+

## Executive Summary

**Pillownote** is a couples app built around one emotional ritual: leaving a note on your partner's pillow — from anywhere. It clones the proven core loop of Flamme (daily couple questions + AI relationship coach, $3K→$10K MRR in 8 months, 250K downloads) and crushes its verified pain points:

- **Never-repeating questions** via on-device Apple Foundation Models + sanitized cloud AI (competitors repeat content within 3 days)
- **Blind-answer mechanic**: both partners answer before either can see the other's response
- **Pillow Note ritual**: async text/voice/photo notes that unlock at the partner's local 7:00 AM with a tear-open envelope animation (zero-effort intimacy for LDR couples)
- **AI with long-term memory**: on-device MemoryDigest accumulates tags/valence/highlights, powering Monthly Glow reports no competitor offers
- **All widgets free** (Flamme charges for widgets)
- **Transparent pricing**: $34.99/year undercuts Flamme ($39.99), Evergreen ($49.99), Paired (~$99)

**Target audience**: US couples, especially the ~14M long-distance relationships. Designed to be opened 2×/day for 30–60 seconds, then closed ("an app designed to be closed" — no infinite feeds).

## Competitive Analysis (verified 2026-09, from guide's field research)

| App | Pricing | Strengths | Weaknesses (verified complaints) | Our Advantage |
|-----|---------|-----------|----------------------------------|---------------|
| Flamme (clone target) | Free + $11.99/mo, $39.99/yr | Daily question, 1000+ quizzes, AI coach | AI had no long-term memory until 2025; question repetition; widgets paywalled; no memory export | AI memory digest + Monthly Glow + free widgets + cheaper |
| Paired | Free + ~$69.99–99/yr | 8M downloads, expert content | "Overly focused on physical intimacy"; high content wall | Warm intimacy without paywall cliffs |
| Evergreen | Free + $9.99/mo, $49.99/yr | Beautiful UI, courses | Content repeats ~day 3; paywall from day 3 | Free tier is genuinely usable forever |
| Couply | Free + $15/mo, $69.99/yr | Quizzes/games/courses | Priciest tier | $34.99/yr |
| Gottman Card Decks | Free | 14 decks, 1000+ researched questions | No interaction loop (static flashcards) | We monetize the interaction + memory around questions |
| Between / Agapé | Free + IAP | LDR private space/timeline | Feature bloat, zero AI | AI-first, focused 5-screen IA |
| CoupleBee | Free + sub | Blind answers + shared timeline | Single-point feature, weak ecosystem | Blind answer is one layer of a full stack |
| SumOne | Free + IAP | Daily question game | Repetitive/generic questions, crashes, expensive IAP | AI-generated, dedup-enforced questions |

## App Identity

| Item | Value |
|---|---|
| App Name | **Pillownote** |
| Subtitle | Daily Questions for Couples |
| Marketing line | "Leave a note on their pillow, from anywhere." |
| Keywords | couple,daily question,relationship,love note,long distance,anniversary,partner,quiz,us,together |
| Category | Lifestyle ｜ Age: 12+ |
| Backup names (if taken) | Heartpost → Amorly |

## Apple Design Guidelines Compliance

- **Cozy Intimacy design language**: Warm Coral `#FF7A6B` primary, Cream `#FFF8F2` background, Ink `#2B2320` text, Sage `#A8C3A0` accent; full warm-dark mode support
- **Typography**: SF Pro Rounded (numbers/large titles) + SF Pro (body); full Dynamic Type support
- **Shape**: 24pt-corner cards, envelope paper texture
- **Animations**: 300–500ms only (envelope tear-open, answer reveal flip, heartbeat haptics via CoreHaptics); fade-in fallback when Reduce Motion is on
- **Layout**: single-column card flow, NO infinite scrolling feeds; one primary button per screen; voice button ≥44pt pinned bottom-right
- **Human Interface Guidelines**: SF Symbols throughout, system materials, respect Dark Mode/Dynamic Type/Reduce Motion/Always-on display constraints

## ⚠️ Feature Inventory (MANDATORY)

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | **Onboarding & Pairing** | 1. Launch → 2 Tinder-style cards (relationship status: same-city/LDR/newlywed; desired ritual) → 2. App generates 6-digit pairing code / AirDrop-SMS invite → 3. Partner enters code → 4. Avatar merge animation + heartbeat haptic → 5. First question forced (30s answer) → 6. Prompt first Pillow Note → 7. Auto-set daily reminder + widget guide | Status selection, pairing code entry | CloudKit CKShare creation; code↔share mapping; skip allowed (solo play) | Paired couple space; first question delivered | SwiftData `CoupleProfile` + CloudKit shared DB | Two devices paired via code see each other's activity; solo user can answer/write before partner joins |
| 2 | **Daily Spark (daily question, AI-generated, blind answer)** | 1. Evening → today's question delivered (AI-personalized) → 2. Blind answer (type or 60s voice) → 3. Answer locks into envelope → 4. If partner answered: side-by-side reveal animation + AI resonance line → 5. Else: "Their answer is on its way" heartbeat animation | Answer text/voice | Apple FM generates question (iOS 26+); dedup via history hash; fallback static bank (dedup rotation); valence/tags extracted on-device; unlock = both fields non-nil (CloudKit field-level) | Question card, reveal pair, AI resonance note | SwiftData `Question` + CloudKit shared `answerA`/`answerB` | Same question never repeats; neither side sees other's answer before both submitted; works offline (local-first) |
| 3 | **Pillow Note (async love notes)** | 1. 30s compose: text / hold-to-talk voice / photo → 2. Send → 3. Partner gets local notification at THEIR 7:00 AM → 4. Envelope floats on Today screen → 5. Swipe up to tear open (paper sound + haptic) → 6. Read text/listen voice/view photo → 7. Tap reaction emoji | Text, voice recording, photo, reaction | End-side encryption of body; unlockAt = partner local 7:00 AM stored as UTC; Free tier: 1/day; Plus: unlimited | Envelope with sealed/opened state, reaction badge | SwiftData `PillowNote` + CloudKit sync | Note invisible before unlockAt; offline sends queue and deliver when online; voice+transcript both preserved |
| 4 | **Coach (AI relationship coach, long memory)** | 1. Open Coach tab → 2. Chat "Ask anything about us" → 3. AI answers using MemoryDigest (weeks/months of tags+valence) | Chat messages | Router: on-device Apple FM for 90% calls; cloud GLM (via Cloudflare Worker proxy, sanitized payload only) for deep reasoning; Plus: unlimited; Free: limited | Conversation with context-aware replies | SwiftData `CoachMessage` + `MemoryDigest` (never leaves device unless consent) | AI references past themes ("you two started talking more about the future"); works on iOS 26+ without any key |
| 5 | **Weekly Glow (Sunday report card)** | 1. Sunday evening → card appears → 2. Resonance count / new discoveries / sweetest quote → 3. One-tap share image (IG Story/TikTok native asset) | Aggregated week digests | On-device aggregation from MemoryDigest; renderer draws shareable card | Weekly card + share image | SwiftData `GlowReport` | Card auto-appears Sundays; share image exports to Photos/share sheet |
| 6 | **Monthly Glow (monthly relationship report)** | 1. 1st of month → 2. Radar chart of communication patterns → 3. AI insight ("You started talking more about the future") → 4. Each insight traceable: tap to see source themes → 5. Unlock next month's ritual skin | Sanitized digests (tags+valence+topic words ONLY, never raw text) | Cloud GLM deep report if consent given + Plus; on-device simplified report otherwise; 12s timeout → simplified fallback | Monthly report with radar chart + insights + skin unlock | SwiftData `GlowReport` | Report generation degrades gracefully (never blank); raw conversations never uploaded; insight tap shows source |
| 7 | **Anniversary Book** | 1. Anniversary/N-days → auto-preassembled book → 2. Year's Q&A highlights + photos + AI preface → 3. Export polished PDF → 4. (Future: physical print order) | Collected Questions, PillowNotes, photos | PDFKit/UIGPDFRenderer layout engine; Plus: 3 exports/month | PDF document in Files/Share sheet | Generated PDF file | One-tap PDF matches preview; respects consent (only own-space content) |
| 8 | **Widgets (all FREE)** | Home/lock screen: Days Together (big number + "days of us"), LDR countdown ("N days to see you"), Today's Question, Partner's Mood | App Group shared data from SwiftData | WidgetKit timeline refresh; UTC→local recalculation | 4 widget families | App Group UserDefaults/SwiftData snapshot | Widgets show correct data without opening app; Flamme-charged features here are free |
| 9 | **Us (relationship dashboard)** | Tab 2: days-together counter, anniversary list, reunion countdown, partner's mood timeline | CoupleProfile dates, mood reactions | Date math across time zones | Timeline view | SwiftData | All counts correct across DST/time zones |
| 10 | **Settings** | Tab 5: binding status, privacy statement ("Your raw words never leave your devices & your iCloud — AI can't see them"), subscription manage, consent toggle for anonymized digest upload, export all data (JSON+photos zip), restore purchases, version (read from Bundle) | Toggles, export action | Zip+JSON serializer; StoreKit restore | Export file in share sheet | FileSystem | Export contains complete user data; version string matches Xcode MARKETING_VERSION |
| 11 | **Monetization (Paywall)** | 1. Triggered by limit/upsell → 2. Transparent pricing page: title, length, price, auto-renewal text, Privacy Policy + Terms links → 3. Purchase/restore | StoreKit 2 transactions | Entitlements: free / plus (auto-renew sub) / byo (lifetime non-consumable) / theme packs (consumable) | Unlocked features | StoreKit 2 + RevenueCat | Free: unlimited daily questions + 1 note/day + all widgets; Plus $5.99/mo $34.99/yr 7-day trial; BYO $29.99 lifetime (user pastes own GLM key, unlimited); no buyback of GLM-tier (consumable cost) |
| 12 | **Local Notifications** | Daily reminder (set at onboarding day 3+), note-arrival, trial-ending reminder 3 days before | Schedule times in partner's local tz | Pre-schedule 7 days of local notifications; resync recalculates across tz | System notifications | UNUserNotificationCenter | Notifications arrive at correct local time after travel/time-zone change |

### Sub-Features & Detail Interactions

| # | Parent | Sub-Feature | Detail | Interaction |
|---|--------|-------------|--------|-------------|
| 1.1 | Onboarding | Solo play | User can answer Q1 / write first note before partner joins | Auto-unlocks reading when partner pairs |
| 1.2 | Onboarding | Pairing code | 6-digit code + AirDrop/SMS deep link | Paste or tap link |
| 2.1 | Daily Spark | Voice answer | Hold-to-talk 60s, speech-to-text + keep original audio | Long-press mic button |
| 2.2 | Daily Spark | Heartbeat waiting | "Their answer is on its way" pulse animation | Auto-updates when partner submits |
| 3.1 | Pillow Note | Tear-open animation | Swipe-up rip + paper sound + haptic; fade fallback (Reduce Motion) | Swipe gesture |
| 3.2 | Pillow Note | Reaction | Emoji mood reaction on opened note | Tap emoji row |
| 3.3 | Pillow Note | Envelope skins | Paper textures; seasonal packs; Plus themes | Settings/shop |
| 4.1 | Coach | Memory transparency | AI answers cite digest themes | Info chip per message |
| 6.1 | Monthly Glow | Consent gate | Explicit opt-in before any anonymized upload | Toggle in Settings |
| 10.1 | Settings | Delete account | Wipe local + CloudKit zone | Destructive confirm |
| 11.1 | Paywall | Transparent page | Price, length, cancel-via-App Store note, legal links | Static content |
| 11.2 | Paywall | BYO key setup | Paste GLM key (z.ai/BigModel) in Settings | Secure text field |

### Cross-Feature Dependencies

| Dependency | Source | Target | Data Passed | Trigger |
|------------|--------|--------|-------------|---------|
| Daily answers → memory | Daily Spark | Coach/Monthly Glow | tags, valence, highlight | Each answer completion |
| Mood reaction → Us timeline | Pillow Note reaction | Us tab | reaction + timestamp | Reaction tapped |
| Pairing → widgets | Onboarding | Widgets | daysTogether, countdown | Pairing complete |
| Entitlement → limits | StoreKit | Notes/Coach/Book/Report | Entitlement enum | Transaction updates |
| Digest consent → cloud AI | Settings consent | Monthly Glow | uploadConsent flag | Report generation |
| Question history → dedup | Answered questions | SparkGenerator | history hashes | Question generation |

**VERIFICATION**: 12 primary features vs guide sections 三 (L1–L6) + 五 (flows) + 八 (pricing) + 6.3 reliability items — ✅ all covered.

## ⚠️ App Store Compliance — AI Features

### Apple Intelligence (Default Free AI Backend)
- iOS 26+: on-device Foundation Models is the default AI backend — zero config, free, private.
- iOS < 26 or simulator: `SystemLanguageModel.default.availability != .available` → fall back to static question bank (500+ questions, dedup rotation) and on-device heuristic reports. **AI is never the only path.**
- `canGenerate = true` always for core question generation (free tier included); no generation counting for on-device AI.

### BYO API Key (Pillownote BYO lifetime tier, $29.99)
- Users paste their own GLM key (z.ai/BigModel) in Settings → app calls the endpoint directly; unlimited deep features.
- Never hardcode any cloud AI key in the app. Cloud GLM (non-BYO) goes ONLY through the Cloudflare Worker proxy; app never holds the key.
- **Dead code prohibition**: no `freeGenerationsUsed`, `maxFreeGenerations`, `canGenerateFree`, `incrementGenerationCount()`.
- Paywall value framing: "Unlock premium features" — features first, not "AI generations".

## ⚠️ App Store Compliance — Subscriptions

- Paywall MUST show: subscription title, length, price, auto-renewal disclosure, working Privacy Policy link, working Terms of Use (Apple standard EULA) link.
- Free tier is genuinely usable forever (daily question + blind answer + 1 note/day + all widgets) — paywall must not block core loop.
- Trial: 7-day full-featured trial on annual plan; local reminder 3 days before trial end (cancellable).
- Lapsed subscribers keep read-only access to all history + 1 note/week ("downgrade without losing the love").
- Privacy label target: Data Not Collected (or "not linked to identity" if sanitized digests used with consent).

## Technical Architecture

- **Language**: Swift 5.9+, SwiftUI-first
- **Min iOS**: 17.0 (Foundation Models gated behind `if #available(iOS 26, *)` with static-bank fallback)
- **Data**: SwiftData (local-first; offline full functionality) + CloudKit CKSyncEngine (Private DB + Shared DB via CKShare)
- **AI**: Apple Foundation Models (`@Generable`/`GenerationSchema` structured output) + optional GLM-5.3-Flash via Cloudflare Worker proxy (sanitized payloads only, 12s timeout)
- **IAP**: StoreKit 2 (+ RevenueCat SDK if network permits; otherwise pure StoreKit 2 entitlements)
- **Widgets**: WidgetKit + App Groups
- **Voice**: Speech framework (SFSpeechRecognizer) for transcription; audio kept
- **PDF**: PDFKit + UIGraphicsPDFRenderer
- **Notifications**: UNUserNotificationCenter local scheduling
- **Encryption**: CryptoKit for note body end-side encryption

### Data Models (SwiftData)

```swift
@Model final class Question {
    var id: UUID
    var text: String                 // AI-generated or bank
    var category: String             // intimacy/future/fun/deep/gratitude
    var sourceRaw: String            // onDeviceAI / cloudAI / staticBank
    var myAnswerText: String?
    var myAnswerAudioPath: String?
    var partnerAnswerEncrypted: Data?
    var assignedUTC: Date
    var myTZ: String
    var partnerTZ: String
    var revealedAt: Date?
}
@Model final class PillowNote {
    var id: UUID
    var kindRaw: String              // text/voice/photo
    var bodyEncrypted: Data
    var transcript: String?
    var voiceDuration: TimeInterval?
    var createdInTZ: String
    var unlockAtUTC: Date            // partner local 07:00
    var openedAt: Date?
    var reaction: String?
}
@Model final class MemoryDigest {
    var day: Date
    var tags: [String]
    var valence: Double              // -1…1
    var highlight: String
    var uploadedConsent: Bool
}
@Model final class CoupleProfile {
    var pairedCode: String?
    var anniversaryDate: Date?
    var reunionDate: Date?
    var partnerTZ: String
    var isPartnerA: Bool
}
```

## Module Structure

```
Pillownote/
├── App/
│   ├── PillownoteApp.swift          // @main, SwiftData container, deep links
│   └── RootTabView.swift            // Today / Us / Coach / Glow / Settings
├── Models/                          // SwiftData entities above
├── Views/
│   ├── Today/ (EnvelopeView, DailySparkView, BlindAnswerView, RevealView)
│   ├── Us/ (DaysCounterView, AnniversaryListView, MoodTimelineView)
│   ├── Coach/ (CoachChatView)
│   ├── Glow/ (WeeklyGlowView, MonthlyGlowView, RadarChartView, ShareCardView)
│   ├── Book/ (AnniversaryBookView, PDFExportView)
│   ├── Onboarding/ (CardOnboardingView, PairingView)
│   ├── Settings/ (SettingsView, BYOKeyView, ExportView)
│   └── Paywall/ (PaywallView, ThemeShopView)
├── Services/
│   ├── AIService (AppleIntelligenceService, GLMProxyService, SparkGenerator, AIRouter)
│   ├── CloudKitService (CKSyncEngine, CKShare pairing, blind-answer fields)
│   ├── StoreService (StoreKit2 entitlements)
│   ├── NotificationService
│   ├── SpeechService
│   ├── CryptoService
│   ├── ExportService (JSON+zip, PDF)
│   └── HapticService
├── PillownoteWidgets/               // WidgetKit extension target
└── Resources/ (Assets, Localizable)
```

## ⚠️ Data Flow Diagram (per primary feature)

```
Feature: Daily Spark
User answers (text/voice)
  └→ TodayViewModel.submitAnswer()
       └→ SwiftData Question.myAnswerText (local commit, status local-only)
            └→ on-device FM: extract tags/valence/highlight → MemoryDigest (never leaves phone)
            └→ CloudKitService writes answerA|answerB (encrypted) to shared record
                 └→ partner device push → both-non-nil check → reveal state flips
                      └→ RevealView side-by-side animation + AI resonance line (on-device FM)
Fallback: FM unavailable → StaticBank.nextUnasked(excluding: history)

Feature: Pillow Note
Compose (text/voice/photo) → CryptoService.encrypt(body)
  └→ SwiftData PillowNote (unlockAtUTC = partner 07:00 local)
       └→ CloudKit sync → partner device
            └→ NotificationService schedules arrival at partner local tz
                 └→ EnvelopeView sealed until unlockAt → swipe tear-open → decrypt → display
                      └→ reaction written back → partner Us timeline

Feature: Monthly Glow
MemoryDigest[] (local) → consent? yes:
  └→ sanitize (tags+valence+topic words ONLY) → Cloudflare Worker → GLM → report JSON → local render (tap-to-source)
     no / timeout: on-device simplified report (no feature loss, less depth)
```

## Implementation Flow

1. xcodegen project scaffold: app target + widget extension target, App Group, bundle `com.zzoutuo.Pillownote`, iOS 17.0, SwiftUI lifecycle
2. SwiftData models + in-memory demo data for previews
3. Core loop UI: Today (envelope + daily spark + blind answer + reveal), animations 300–500ms
4. Static question bank (500+ curated English questions, categories, dedup engine)
5. AI layer: AIRouter → AppleIntelligenceService (iOS 26 gated) → GLMProxyService (BYO key direct / worker proxy)
6. Coach chat with MemoryDigest context
7. Glow reports (weekly on-device; monthly with radar chart + share card)
8. Pillow Note voice/photo + Speech transcription + CryptoKit
9. Pairing: pairing-code model + CKShare service (graceful degradation when CloudKit entitlement unavailable at dev time: local "demo partner" mode)
10. StoreKit 2 products + Paywall + BYO key settings
11. Widgets extension (4 widgets, App Group)
12. PDF export (Anniversary Book)
13. Notifications, Settings, data export
14. Build & run on iPhone + iPad simulators via XcodeBuildMCP; fix until green

## UI/UX Design Specifications

- Colors: `#FF7A6B` coral primary / `#FFF8F2` cream bg / `#2B2320` ink / `#A8C3A0` sage; warm-dark variants
- Fonts: SF Pro Rounded display numbers; SF Pro body; Dynamic Type everywhere
- Cards: 24pt radius; envelope paper textures
- Animations: envelope tear (spring 300–450ms), reveal flip-open, heartbeat haptic (CoreHaptics); Reduce Motion → fade
- Navigation: 5 tabs max (Today, Us, Coach, Glow, Settings); single-column; one primary CTA per screen; voice button ≥44pt bottom-right on compose screens

## Code Generation Rules

- Local-first: every write hits SwiftData first; UI never waits on network; sync is a side effect
- Never `JSON.parse` AI output — use `@Generable` + `GenerationSchema`
- All timestamps stored UTC; displayed in each user's local tz; unlock = partner 7:00 AM
- Entitlement-driven feature flags; changing prices never changes code
- No hardcoded version strings — read `Bundle.main.infoDictionary`
- No dead AI-limit code (see compliance section)
- Graceful degradation everywhere: FM→static bank; GLM→on-device; CloudKit→local demo partner; never a blank screen

## Build & Deployment Checklist

1. xcodegen generates project → open in Xcode via XcodeBuildMCP
2. Configure signing automatically (simulator builds don't need team)
3. Build iPhone simulator (iPhone 16, iOS 18.4) + iPad (iPad Air 11-inch M3)
4. Verify: onboarding → pair → answer → reveal → note → widget → paywall flows
5. Cleanup simulator data after testing (`cleanup_simulators.sh after_test <UDID>`)
6. GitHub push (single repo, code + /docs policy pages)
7. App Store Connect: name availability check (Pillownote→Heartpost→Amorly), privacy label, subscription products, EULA reference
