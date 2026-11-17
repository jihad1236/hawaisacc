# HYKX In-App Purchase Complete Integration & Developer Guide

**Document Version:** 2.0  
**Target Environment:** Local, Staging (`http://187.77.182.87:9003`) & Production (`https://api.hykxapp.com`)  
**Package:** `in_app_purchase: ^3.3.1`  
**Platform Extensions:** `in_app_purchase_android: ^0.5.5`, `in_app_purchase_storekit: ^0.4.17`  
**Platforms Supported:** Android (Google Play Billing 6+) & iOS (Apple App Store / StoreKit 2)

---

## Table of Contents
1. [Overview & Architectural Flow](#1-overview--architectural-flow)
2. [Product IDs & Store Mapping](#2-product-ids--store-mapping)
3. [Client-Side Implementation Breakdown](#3-client-side-implementation-breakdown)
4. [Backend Verification API Contracts](#4-backend-verification-api-contracts)
5. [Google Play Console Setup Guide](#5-google-play-console-setup-guide)
6. [Apple App Store Connect Setup Guide](#6-apple-app-store-connect-setup-guide)
7. [Store Review & Legal Compliance Checklist](#7-store-review--legal-compliance-checklist)
8. [Troubleshooting Common Issues](#8-troubleshooting-common-issues)

---

## 1. Overview & Architectural Flow

Apple App Store (Guideline 3.1.1) and Google Play Developer Policies require all in-app digital subscriptions to use native platform billing. All payments for HYKX Pro are executed via native platform sheets and verified authoritatively by the HYKX backend server.

### Complete Purchase Lifecycle

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Purchase Lifecycle Flow                         │
└────────────────────────────────────────────────────────────────────────┘
          │
          ▼
   [ User Taps Subscribe ]
          │
          ▼
   InAppPurchaseService.instance.buyProduct(productDetails)
          │
          ▼
   _iap.buyNonConsumable(purchaseParam: purchaseParam)
          │
          ▼
   Stream<List<PurchaseDetails>> emits PurchaseStatus
          ├────────────────────────────────────────┬─────────────────────┐
          ▼                                        ▼                     ▼
   [ PurchaseStatus.pending ]            [ PurchaseStatus.error ]   [ PurchaseStatus.purchased / restored ]
   Show loading indicator                Dismiss loading & toast           │
                                                                           ▼
                                                                  Backend Server Verification:
                                                                  - Android: /api/subscriptions/google-play/verify/
                                                                  - iOS:     /api/subscriptions/apple/verify/
                                                                           │
                                                                           ▼
                                                                  Is Backend Verified?
                                                                  ├── YES:
                                                                  │   1. _iap.completePurchase(purchaseDetails)  <-- CRITICAL!
                                                                  │   2. UserSubscriptionController.refreshStatus()
                                                                  │   3. Show success dialog & unlock features
                                                                  └── NO:
                                                                      1. _iap.completePurchase(purchaseDetails)
                                                                      2. Show verification failed error
```

> [!IMPORTANT]
> Always call `_iap.completePurchase(purchaseDetails)`. On Android, if a purchase is not acknowledged within 3 days, Google Play will **automatically refund the user and revoke the subscription**.

---

## 2. Product IDs & Store Mapping

The backend and native stores share the exact same subscription identifiers:

| Plan Name | Billing Cycle | Product ID (Android & iOS) | Default Fallback Price |
|:---|:---|:---|:---|
| **HYKX Pro Monthly** | Monthly | `hykx_pro_monthly` | $14.99 / month |
| **HYKX Pro Yearly** | Yearly | `hykx_pro_yearly` | $119.99 / year (Save 33%) |

---

## 3. Client-Side Implementation Breakdown

### 3.1 Service: `InAppPurchaseService`
**File:** `lib/core/services/in_app_purchase_service.dart`

- **Singleton Pattern:** Initialized once in `main.dart` via `InAppPurchaseService.instance.initialize()`.
- **Persistent Stream:** Subscribes to `_iap.purchaseStream` to catch purchases even if the app was suspended or killed during checkout.
- **Dynamic Product Querying:** `loadProducts()` queries Google Play / App Store for prices and availability in local currencies.
- **Purchase Launch:** `buyProduct(ProductDetails product)` triggers the OS purchase sheet via `buyNonConsumable`.
- **Platform-Specific Token Extraction:**
  - **Android:** Casts `purchaseDetails` to `GooglePlayPurchaseDetails` to read `billingClientPurchase.purchaseToken` and `billingClientPurchase.orderId`.
  - **iOS:** Casts to `AppStorePurchaseDetails` to read `skPaymentTransaction.originalTransaction.transactionIdentifier` or `transactionIdentifier`.
- **Backend Verification:** Dispatches tokens to the backend and awaits server confirmation before acknowledging the purchase.

### 3.2 UI & State: `PremiumController` & `PremiumView`
**Files:**
- `lib/features/profile/controller/premium_controller.dart`
- `lib/features/profile/screens/premium_view.dart`

- Displays localized prices dynamically formatted from the store (e.g. `storeMonthly?.price`).
- Triggers `InAppPurchaseService.instance.buyProduct(...)` when the user taps "Subscribe".
- Prominent **Restore Purchases** button in both the header AppBar and bottom footer.
- Compliant EULA, Terms of Service, and Privacy Policy links.

### 3.3 Entitlement State: `UserSubscriptionController`
**File:** `lib/features/profile/controller/user_subscription_controller.dart`

- Global controller registered via GetX.
- Exposes `isPremium.value` and `hasEntitlement('bespoke_workout_plans')`.
- Calls `refreshStatus()` whenever a purchase or restore succeeds.

### 3.4 Android Manifest Permissions
**File:** `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

---

## 4. Backend Verification API Contracts

### 4.1 Android — Google Play Verification
- **Endpoint:** `POST /api/subscriptions/google-play/verify/`
- **Header:** `Authorization: Bearer <user_access_token>`
- **Request Body:**
```json
{
  "product_id": "hykx_pro_monthly",
  "purchase_token": "in-app-purchase-token-from-google-play",
  "order_id": "GPA.3344-5566-7788-99001",
  "package_name": "com.hykx.app",
  "billing_cycle": "monthly"
}
```
- **Response (200 OK):**
```json
{
  "success": true,
  "message": "Google Play purchase verified successfully.",
  "is_premium": true,
  "subscription": {
    "status": "active",
    "billing_cycle": "monthly",
    "current_period_end": "2026-12-17T12:00:00Z"
  }
}
```

### 4.2 iOS — Apple App Store Verification
- **Endpoint:** `POST /api/subscriptions/apple/verify/`
- **Header:** `Authorization: Bearer <user_access_token>`
- **Request Body:**
```json
{
  "product_id": "hykx_pro_yearly",
  "original_transaction_id": "1000000987654321",
  "transaction_id": "2000000123456789",
  "billing_cycle": "yearly"
}
```

### 4.3 Restore Purchases
- **Endpoint:** `POST /api/subscriptions/restore/`
- **Header:** `Authorization: Bearer <user_access_token>`
- **Request Body:**
```json
{
  "purchases": [
    {
      "store": "google_play",
      "product_id": "hykx_pro_monthly",
      "purchase_token": "token-xyz",
      "transaction_id": "GPA.1234-5678"
    }
  ]
}
```

---

## 5. Google Play Console Setup Guide

Follow these steps to ensure Google Play serves in-app products to test devices:

### Step 1: Create the Subscriptions and Base Plans
1. Open [Google Play Console](https://play.google.com/console).
2. Select your app (`com.hykx.app`).
3. In the left menu, navigate to **Monetize > Products > Subscriptions**.
4. Create two subscriptions:
   - **Product ID:** `hykx_pro_monthly`
     - Click **Add base plan** -> Type: **Auto-renewing** -> Billing period: **Monthly** -> Set Price -> Click **Activate**.
   - **Product ID:** `hykx_pro_yearly`
     - Click **Add base plan** -> Type: **Auto-renewing** -> Billing period: **Yearly** -> Set Price -> Click **Activate**.
5. Ensure the base plans are marked as **Active** (not Draft).

### Step 2: Upload a Build to Internal Testing
Google Play requires at least one build in an active testing track before enabling billing APIs:
1. Build an app bundle:
   ```bash
   flutter build appbundle
   ```
2. In Play Console, go to **Testing > Internal testing**.
3. Create a new release, upload the `.aab`, and click **Next > Save > Start rollout to Internal testing**.

### Step 3: Configure License Testing (Free Test Purchases)
1. Go to **Setup > License testing** (in the Play Console left sidebar).
2. In the "License testers" field, add the Google email address of the developer/tester.
3. Set **License response** to `RESPOND_NORMALLY`.
4. Click **Save changes**.

### Step 4: Accept the Testing Invite on the Device/Simulator
> [!IMPORTANT]
> Google Play blocks products until the test account accepts the testing invitation link.
1. In **Testing > Internal testing**, switch to the **Testers** tab.
2. Under "How testers join your test", copy the link (**"Join on Android"** or **"Join on the web"**).
3. Open Chrome on your Android test device or emulator (logged in with that tester email).
4. Paste the link and click **"Accept Invite" / "Become a tester"**.

---

## 6. Apple App Store Connect Setup Guide

### Step 1: Create the Subscription Group
1. Open [App Store Connect](https://appstoreconnect.apple.com).
2. Go to **Apps > HYKX > Subscriptions** (under Monetization).
3. Click **Create Subscription Group** (e.g. `HYKX Pro Access`).
4. Add two subscriptions:
   - Reference Name: `HYKX Pro Monthly` | Product ID: `hykx_pro_monthly` | Duration: 1 Month
   - Reference Name: `HYKX Pro Yearly` | Product ID: `hykx_pro_yearly` | Duration: 1 Year
5. Set prices and localized descriptions.

### Step 2: Create Sandbox Test Users
1. In App Store Connect, go to **Users and Access > Sandbox Testers**.
2. Click `+` to add a sandbox tester account.
3. On an iOS test device, go to **Settings > App Store > Sandbox Account** and sign in with this test account.

---

## 7. Store Review & Legal Compliance Checklist

Both Apple and Google will reject paywalls that fail to meet subscription disclosure guidelines. The HYKX app includes:

- [x] **Clear Billing Frequency & Pricing:** Full price and recurring period clearly stated.
- [x] **Prominent Restore Button:** Visible in both header AppBar and footer.
- [x] **Terms of Use (EULA) Link:** Direct link in the footer.
- [x] **Privacy Policy Link:** Direct link in the footer.
- [x] **Auto-Renewal Disclosure:** Explicit text stating subscriptions renew automatically unless canceled at least 24 hours before renewal.
- [x] **Cancellation Instructions:** Text informing users that management is handled via App Store / Google Play account settings.

---

## 8. Troubleshooting Common Issues

### Issue 1: `InAppPurchase store unavailable on this device`
- **Cause:** `InAppPurchase.instance.isAvailable()` returned `false`. The device has no connection to Google Play Services.
- **Solution:**
  1. If using an Android Emulator, make sure it has the **Google Play Store** pre-installed (look for the Play Store badge in Android Studio's Device Manager).
  2. Open the Play Store app on the device/emulator and log in to a Google account.

### Issue 2: `Products not found in store: [hykx_pro_monthly, hykx_pro_yearly]`
- **Cause:** The store connection is working, but Google Play cannot find the product IDs.
- **Solution:**
  1. Verify the product IDs match character-for-character with Google Play Console.
  2. Check that the subscription's **Base Plan** is set to **Active**.
  3. Ensure you have accepted the Internal Testing invite link inside the emulator's browser.
  4. Allow up to 2–12 hours for Google Play's CDN servers to propagate new subscriptions.

### Issue 3: Purchases automatically refunded after 3 days
- **Cause:** The app failed to acknowledge the purchase with the store.
- **Solution:** Ensure `await _iap.completePurchase(purchaseDetails)` is called after successful backend verification. This is already implemented in `_listenToPurchaseUpdated`.
