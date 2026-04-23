# Price Configuration

## Monetization Model
Auto-renewable Subscription (IAP Required)

## Subscription Group
Group Name: SpoilAlert Pro

### Tier 0: Free (Always Available)
- **Type**: Free (limited features)
- **Features**: 3 products max, manual add, basic expiry countdown, single reminder, dark mode, daily check-in, basic widget
- **Purpose**: User acquisition, trial experience

### Tier 1: Plus Monthly Subscription
- **Reference Name**: SpoilAlert Plus Monthly
- **Product ID**: com.zzoutuo.SpoilAlert.plus.monthly
- **Price**: $2.99 (USD)
- **Subscription Period**: 1 Month
- **Localization (English US)**:
  - Display Name: SpoilAlert Plus Monthly (max 35 chars)
  - Description: Unlock PAO scan and skin journal (max 55 chars)

### Tier 2: Plus Yearly Subscription
- **Reference Name**: SpoilAlert Plus Yearly
- **Product ID**: com.zzoutuo.SpoilAlert.plus.yearly
- **Price**: $19.99 (USD)
- **Subscription Period**: 1 Year
- **Localization (English US)**:
  - Display Name: SpoilAlert Plus Yearly (max 35 chars)
  - Description: Save 44% with annual plan (max 55 chars)

### Tier 3: Pro Monthly Subscription
- **Reference Name**: SpoilAlert Pro Monthly
- **Product ID**: com.zzoutuo.SpoilAlert.pro.monthly
- **Price**: $4.99 (USD)
- **Subscription Period**: 1 Month
- **Localization (English US)**:
  - Display Name: SpoilAlert Pro Monthly (max 35 chars)
  - Description: Full features with iCloud sync (max 55 chars)

### Tier 4: Pro Yearly Subscription
- **Reference Name**: SpoilAlert Pro Yearly
- **Product ID**: com.zzoutuo.SpoilAlert.pro.yearly
- **Price**: $34.99 (USD)
- **Subscription Period**: 1 Year
- **Localization (English US)**:
  - Display Name: SpoilAlert Pro Yearly (max 35 chars)
  - Description: Save 42% with annual Pro plan (max 55 chars)

### Tier 5: Lifetime (Non-consumable)
- **Include**: YES (App has NO API costs or usage-based costs — all Vision/SwiftData is local)
- **Reference Name**: SpoilAlert Pro Lifetime
- **Product ID**: com.zzoutuo.SpoilAlert.pro.lifetime
- **Price**: $49.99 (USD)
- **Type**: Non-consumable (One-time, no renewal)
- **Localization (English US)**:
  - Display Name: SpoilAlert Pro Lifetime (max 35 chars)
  - Description: One-time purchase, forever access (max 55 chars)

## Feature Matrix by Tier

| Feature | Free | Plus | Pro |
|---------|------|------|-----|
| Product count | 3 | Unlimited | Unlimited |
| Manual add | YES | YES | YES |
| Expiry countdown | YES | YES | YES |
| Basic reminder (1x) | YES | YES | YES |
| Dark mode | YES | YES | YES |
| Daily check-in | YES | YES | YES |
| Basic widget | YES | YES | YES |
| PAO photo recognition | NO | YES | YES |
| Barcode scanner | NO | YES | YES |
| Multi-level reminders (4x) | NO | YES | YES |
| Usage tracking | NO | YES | YES |
| Skin journal | NO | YES | YES |
| Product photos | NO | YES | YES |
| Custom categories | NO | YES | YES |
| Enhanced widget | NO | YES | YES |
| iCloud sync | NO | NO | YES |
| Family sharing (5) | NO | NO | YES |
| Data export PDF | NO | NO | YES |
| Batch scanning | NO | NO | YES |
| Repurchase reminder | NO | NO | YES |
| Priority support | NO | NO | YES |
| Ads | Non-intrusive | None | None |

## App Store Connect Setup Instructions
1. Go to App Store Connect → Your App → Subscriptions
2. Create Subscription Group: "SpoilAlert Pro"
3. Add subscriptions with above Product IDs
4. Configure localizations for each
5. Submit for review

## IAP Compliance Checklist (REQUIRED for Subscription Apps)
- [ ] Paywall displays subscription names
- [ ] Paywall displays subscription durations
- [ ] Dynamic pricing from StoreKit (no hardcoded prices)
- [ ] Renewal terms displayed
- [ ] Cancellation instructions displayed
- [ ] Free trial clause displayed (if applicable)
- [ ] Restore Purchases button implemented
- [ ] Privacy Policy link on paywall
- [ ] Terms of Use link on paywall
- [ ] NO dark patterns (no auto-selecting expensive options)
- [ ] Lifetime tier included (app has NO API/usage costs)
