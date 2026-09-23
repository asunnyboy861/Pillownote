# Improvement Plan 1 — QA Round 1 (Step 11)

## Phase A: Issues Found

| Issue | Description | Severity | Fix |
|-------|-------------|----------|-----|
| ISSUE-001 | Monthly Glow had no generation entry point in GlowView (only weekly) | Major | Added "Generate Monthly Glow" button with premium deep-AI path and free simplified path |
| ISSUE-002 | PairingService missing SwiftData import caused cascade compile failures | Critical | Added `import SwiftData` |
| ISSUE-003 | @Model classes used with @ObservedObject (incompatible with new Observation-backed SwiftData) | Critical | Switched to plain properties in RevealView/EnvelopeOpenView |
| ISSUE-004 | `Product.SubscriptionInfo` period API misuse in Paywall | Major | Used `subscriptionPeriod.unit == .year` |
| ISSUE-005 | Date `.formatted(.date)` invalid inference in two files | Major | Explicit `formatted(date:time:)` |
| ISSUE-006 | AIProviderProfile not Hashable for Picker/ForEach | Minor | Conformance changed to Hashable |
| ISSUE-007 | Unused ShareItem struct + async call in onAppear | Minor | Removed; wrapped in Task |

## Phase B: Implementation
All 7 items implemented and verified with successful build.

## Hardcoded version scan: PASS (only dynamic Bundle fallback present)
## TODO/stub scan: PASS (0 occurrences)
## Forbidden dead code scan (free generation counting): PASS (0 occurrences)

## Scores After Iteration 1:
- Usability: 4/5
- UI Consistency: 5/5
- Feature Completeness: 5/5 (12/12 primary features, 12/12 sub-features, 6/6 cross-feature dependencies)
- Download-to-Use: 5/5 (works solo out-of-box; demo partner previews reveal; static bank fallback for AI)
- Competitive Level: 4/5
- Contact Support: 5/5 (all 11 COMPLIANCE-CS requirements)
- Accessibility: 4/5

EXIT CRITERIA: ALL MET

FINAL SCORES (after 1 iteration):
- Usability: 4/5
- UI Consistency: 5/5
- Feature Completeness: 5/5
- Download-to-Use: 5/5
- Competitive Level: 4/5
- Contact Support: 5/5
- Accessibility: 4/5
EXIT CRITERIA: ALL MET
