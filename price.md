# Pricing Configuration

## Monetization Model: Subscription (IAP)

Free-to-download couples app with a genuinely usable forever free tier. One auto-renewable subscription group (Pillownote Plus monthly/annual, 7-day annual trial) plus two non-consumable one-time purchases (BYO Lifetime, Seasonal Envelope Themes). On-device AI (Apple Foundation Models) is free for everyone — subscriptions unlock app features and cloud-depth, never gate the core loop.

## Subscription Group
- **Group Name**: Pillownote Plus
- **Reference Name**: Pillownote Plus
- **Products in group**: Plus Monthly, Plus Annual

## Subscription Tiers (Auto-Renewable)

### 1. Monthly Subscription
- **Reference Name**: Pillownote Plus Monthly
- **Product ID**: `com.zzoutuo.pillownote.plus.monthly`
- **Type**: Auto-renewable subscription
- **Price**: $5.99 USD per month
- **Display Name**: `Pillownote Plus` (15 chars, ≤35 ✅)
- **Description**: `Unlimited notes, coach and glow reports` (39 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: Pillownote Plus
- **Restore Purchases**: ✅ Required

### 2. Yearly Subscription
- **Reference Name**: Pillownote Plus Annual
- **Product ID**: `com.zzoutuo.pillownote.plus.yearly`
- **Type**: Auto-renewable subscription
- **Price**: $34.99 USD per year (51% savings vs monthly)
- **Display Name**: `Pillownote Plus Annual` (22 chars, ≤35 ✅)
- **Description**: `All Plus features with a 7-day free trial` (41 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: Pillownote Plus (same group as monthly)
- **Introductory Offer**: 7-day free trial (auto-renews at $34.99/yr unless cancelled)
- **Restore Purchases**: ✅ Required

## One-Time Purchases (Non-Consumable)

### 1. BYO Lifetime
- **Reference Name**: Pillownote BYO Lifetime
- **Product ID**: `com.zzoutuo.pillownote.byo.lifetime`
- **Type**: Non-consumable (one-time purchase, permanently unlocked)
- **Price**: $29.99 USD (one-time)
- **Display Name**: `Pillownote BYO Lifetime` (23 chars, ≤35 ✅)
- **Description**: `All Plus features using your own API key` (40 chars, ≤55 ✅)
- **Localization**: English (US)
- **Restore Purchases**: ✅ Required
- **Differentiation Note**: BYO Lifetime unlocks the SAME feature set as Plus Annual but as a one-time purchase — cloud deep-AI calls run through the user's own API key (configured in Settings), so there is zero marginal cost to us. Users who already have a key and hate subscriptions pick this; everyone else picks Plus.
- **BYO Key note**: purchase unlocks feature UI only; deep AI calls use the user's own key; unlimited usage; no free-generation counting (`freeGenerationsUsed` / `maxFreeGenerations` forbidden)

### 2. Seasonal Envelope Themes
- **Reference Name**: Pillownote Seasonal Themes
- **Product ID**: `com.zzoutuo.pillownote.themes.seasons`
- **Type**: Non-consumable (one-time purchase, permanently unlocked)
- **Price**: $2.99 USD (one-time)
- **Display Name**: `Seasonal Envelope Themes` (24 chars, ≤35 ✅)
- **Description**: `Valentine, holiday and pride envelope skins` (43 chars, ≤55 ✅)
- **Localization**: English (US)
- **Restore Purchases**: ✅ Required
- **Differentiation Note**: Purely visual — unlocks all current and future seasonal envelope paper skins. Does NOT unlock any Plus feature; Plus does NOT include seasonal skins.

## Free Tier (Default)

- **Price**: Free, forever
- **Features**:
  - Daily Spark daily question with blind answer — unlimited, forever (AI-generated on iOS 26+, static bank otherwise)
  - 1 Pillow Note per day (text)
  - All widgets (Days Together, Reunion Countdown, Today's Question, Partner's Mood)
  - Together days, anniversaries, mood timeline
  - On-device AI capabilities (question generation, mood classification) — unlimited
  - Weekly Glow simplified card
- **Conversion hooks**:
  - "Send as many notes as you feel — text, voice, photos"
  - "Your monthly relationship report, with insights you can trace"
  - "Turn your year of questions into a keepsake PDF book"
  - "7 days free, then less than any other couples app"

## Pro Features Unlocked (All Paid Tiers)

| Feature | Free | Plus (Monthly/Annual) | BYO Lifetime |
|---------|:----:|:---------------------:|:------------:|
| Daily Spark question + blind answer | ✅ Unlimited | ✅ Unlimited | ✅ Unlimited |
| Pillow Notes (text) | 1/day | ✅ Unlimited | ✅ Unlimited |
| Pillow Notes voice + photo | ❌ | ✅ | ✅ |
| Voice-to-text transcription | ❌ | ✅ | ✅ |
| AI Coach chat | ✅ On-device only | ✅ + cloud deep reasoning | ✅ Deep reasoning via own key |
| Monthly Glow (deep cloud report) | Simplified on-device version | ✅ 2 deep reports/month (GLM) | ✅ Unlimited via own key |
| Weekly Glow share cards | ✅ Simplified | ✅ Full | ✅ Full |
| Anniversary Book PDF export | ❌ | ✅ 3 exports/month | ✅ 3 exports/month |
| Couple theme skins + paper textures | ❌ | ✅ | ✅ |
| Seasonal envelope skins | ❌ Not included — separate $2.99 add-on | ❌ Not included — separate $2.99 add-on | ❌ Not included — separate $2.99 add-on |
| All widgets | ✅ Free forever | ✅ | ✅ |
| Local data export (JSON+zip) | ✅ | ✅ | ✅ |

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to $34.99/year paid subscription)
- **Available for**: Plus Annual only

## Policy Pages Required
- Support Page: ✅ (must include subscription management + cancellation instructions)
- Privacy Policy: ✅
- Terms of Use (EULA): ✅ (REQUIRED — subscription apps must have Terms)
- **Total policy pages**: 3

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms will be included in Terms of Use
- [x] Cancellation instructions will be included in Support Page
- [x] Pricing clearly stated in PaywallView
- [x] Free trial terms included (7-day, annual tier)
- [x] Restore purchases functionality implemented
- [x] No external payment links (Guideline 3.1.1)
- [x] No price references to outside-App-Store options
- [x] All IAP descriptions ≤ 55 characters
- [x] All IAP display names ≤ 35 characters
- [x] BYO Key model: gated only by one-time unlock + user's own key — no generation counting
- [x] Free tier never blocks the core loop (Guideline 3.1.2 safe)
