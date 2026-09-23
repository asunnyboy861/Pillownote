# App Review Information

## Demo Account for Apple Review

### AI Configuration
The app uses Apple Intelligence (on-device Foundation Models) as the default AI backend — AI features work immediately on iPhone 15 Pro+ with iOS 26+, with no API key and no configuration. On the simulator or older devices, the app automatically falls back to a built-in curated question bank and on-device heuristic summaries, so every AI-driven feature remains fully testable without any key.

Optional "Bring Your Own API Key" mode (Settings → AI Configuration):
1. Open Settings → AI Configuration
2. Paste any OpenAI-compatible API key (e.g., from z.ai) and pick a provider
3. Deep reasoning features then call that endpoint

There is no free-generation counting; the core daily question is free and unlimited for all users by design.

### Subscription Testing
- Product IDs (StoreKit configuration file included in the repo for local testing):
  - `com.zzoutuo.pillownote.plus.monthly` — $5.99/month
  - `com.zzoutuo.pillownote.plus.yearly` — $34.99/year with 7-day free trial
  - `com.zzoutuo.pillownote.byo.lifetime` — $29.99 one-time (BYO lifetime)
  - `com.zzoutuo.pillownote.themes.seasons` — $2.99 one-time (seasonal envelope themes)
- The free tier (daily question + blind answer, 1 note/day, all widgets) never blocks the core loop.

### Required Links (In-App)
- Privacy Policy: https://asunnyboy861.github.io/Pillownote/privacy.html
- Terms of Use: https://asunnyboy861.github.io/Pillownote/terms.html
- Support Page: https://asunnyboy861.github.io/Pillownote/support.html

These links are accessible from:
1. Settings → Legal & Support section
2. Paywall (below the Subscribe button)

## Review Notes

### AI Features
- Default AI backend is Apple Intelligence (on-device, iOS 26+); no third-party AI is required for core functionality.
- Optional BYO API key mode: users provide their own key, stored in the iOS Keychain. The app never bundles or sells API keys and does not promote any specific AI provider in user-facing UI.
- No free-generation limits exist for on-device AI.

### Demo Partner Mode
- During onboarding, users may enable "Try with a demo partner" to preview the blind-answer reveal flow before pairing. This is clearly labeled as a demo for previewing the interaction.

### China App Store Compliance
This app does NOT include ChatGPT functionality or reference ChatGPT/OpenAI in any user-facing UI or metadata for the China storefront. The AI features use a generic "Bring Your Own API Key" model where users configure their own API endpoint. No specific AI provider is promoted or bundled.

### Privacy
- All user content is stored locally (SwiftData) with optional iCloud sync. Raw conversation text never leaves the device unless the user explicitly enables anonymized theme sharing (tags/mood scores only).
- Contact Support sends feedback (name, email, subject, message) to our support backend only when the user submits it.
