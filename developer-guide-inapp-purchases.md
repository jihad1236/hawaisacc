# HYKX In-App Purchase & Subscription Integration Guide
**Version:** 2.0  
**Target Platforms:** Android (Google Play Billing) & iOS (Apple App Store / StoreKit 2)  
**Base URL (Production):** `https://api.hykxapp.com`  
**Base URL (Local/Staging):** `http://187.77.182.87:9003`

---

## 1. Overview & Architecture

HYKX features server-side verification and subscription lifecycle management for both Google Play and Apple In-App Purchases.

### Security Principles:
1. **Authoritative Backend Verification:** Premium access is never granted based on client flags. The backend verifies the store receipt/token against store APIs before updating entitlements.
2. **Anti-Account Hijacking (Cross-Account Conflict Prevention):** A single purchase token or Apple `original_transaction_id` cannot be claimed by or transferred to multiple HYKX accounts. Attempting to reuse an active token on another account returns `400 Bad Request`.
3. **Automatic Lifecycle Synchronization:** Real-time developer webhooks handle renewals, cancellations, billing retries, refunds, and expiries automatically.
4. **Graceful Sandbox Fallback:** In sandbox/development environments or when external store API keys are being provisioned, the backend seamlessly supports testing with deterministic validation.

---

## 2. In-App Purchase Products & Mapping

| Plan Name | Billing Interval | Google Play Product ID | Apple App Store Product ID | Fallback Monthly Equiv |
|:---|:---|:---|:---|:---|
| **HYKX Pro Monthly** | Monthly | `hykx_pro_monthly` | `hykx_pro_monthly` | $14.99/mo |
| **HYKX Pro Yearly** | Yearly | `hykx_pro_yearly` | `hykx_pro_yearly` | $119.99/yr |

### Fetch Available Plans
```http
GET /api/subscriptions/plans/
Accept: application/json
```
**Response (200 OK):**
```json
[
  {
    "id": 1,
    "title": "HYKX Pro",
    "tier_badge": "PRO",
    "monthly_price": "14.99",
    "yearly_price": "119.99",
    "google_monthly_product_id": "hykx_pro_monthly",
    "google_yearly_product_id": "hykx_pro_yearly",
    "apple_monthly_product_id": "hykx_pro_monthly",
    "apple_yearly_product_id": "hykx_pro_yearly",
    "benefits": [
      "Bespoke 4-day workout splits",
      "AI Equipment Recognition Scanner",
      "Advanced Progress Analytics & Daily Stats",
      "Unlimited workout session history"
    ]
  }
]
```

---

## 3. Verify Purchase Endpoints

### 3.1 Android — Google Play Verification
When a purchase completes in the Android Google Play Billing client:

```http
POST /api/subscriptions/google-play/verify/
Authorization: Bearer <user_jwt_access_token>
Content-Type: application/json
```

**Request Payload:**
```json
{
  "product_id": "hykx_pro_monthly",
  "purchase_token": "inapp_purchase_token_from_google_billing",
  "order_id": "GPA.3344-5566-7788-99001",
  "package_name": "com.hykx.app"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "is_premium": true,
  "status": "active",
  "payment_source": "google_play",
  "message": "Google Play subscription verified and activated successfully!",
  "subscription": {
    "id": 5,
    "status": "active",
    "billing_cycle": "monthly",
    "payment_source": "google_play",
    "plan_title": "HYKX Pro",
    "is_valid": true,
    "current_period_end": "2026-12-02T11:20:00Z",
    "auto_renew_status": true,
    "environment": "sandbox",
    "entitlements": [
      "bespoke_workout_plans",
      "ai_equipment_scanner",
      "advanced_progress_analytics",
      "unlimited_workout_sessions",
      "custom_workout_routines",
      "priority_support"
    ]
  },
  "transaction": {
    "id": 12,
    "store": "google_play",
    "product_id": "hykx_pro_monthly",
    "transaction_id": "GPA.3344-5566-7788-99001",
    "status": "verified"
  }
}
```

---

### 3.2 iOS — Apple App Store Verification
When a purchase completes with StoreKit / StoreKit 2:

```http
POST /api/subscriptions/apple/verify/
Authorization: Bearer <user_jwt_access_token>
Content-Type: application/json
```

**Request Payload:**
```json
{
  "product_id": "hykx_pro_yearly",
  "original_transaction_id": "1000000987654321",
  "transaction_id": "2000000123456789",
  "signed_transaction_info": "<StoreKit_2_JWS_representation_optional>"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "is_premium": true,
  "status": "active",
  "payment_source": "apple_app_store",
  "message": "Apple App Store subscription verified and activated successfully!",
  "subscription": {
    "id": 6,
    "status": "active",
    "billing_cycle": "yearly",
    "payment_source": "apple_app_store",
    "plan_title": "HYKX Pro",
    "is_valid": true,
    "current_period_end": "2027-11-02T11:20:00Z",
    "auto_renew_status": true,
    "environment": "sandbox",
    "entitlements": [
      "bespoke_workout_plans",
      "ai_equipment_scanner",
      "advanced_progress_analytics",
      "unlimited_workout_sessions",
      "custom_workout_routines",
      "priority_support"
    ]
  },
  "transaction": {
    "id": 13,
    "store": "apple_app_store",
    "product_id": "hykx_pro_yearly",
    "original_transaction_id": "1000000987654321",
    "status": "verified"
  }
}
```

---

## 4. Restore Purchases Endpoint

Used when the user taps "Restore Purchases" on either iOS or Android, or logs in on a new device.

```http
POST /api/subscriptions/restore/
Authorization: Bearer <user_jwt_access_token>
Content-Type: application/json
```

**Request Payload:**
```json
{
  "purchases": [
    {
      "store": "google_play",
      "product_id": "hykx_pro_monthly",
      "purchase_token": "token_from_google_billing",
      "transaction_id": "GPA.3344-5566-7788-99001"
    },
    {
      "store": "apple_app_store",
      "product_id": "hykx_pro_yearly",
      "original_transaction_id": "1000000987654321",
      "signed_transaction_info": "<optional_jws>"
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "is_premium": true,
  "restored_count": 1,
  "message": "Restored 1 active subscription(s).",
  "subscription": {
    "id": 6,
    "status": "active",
    "billing_cycle": "yearly",
    "payment_source": "apple_app_store",
    "is_valid": true,
    "entitlements": [
      "bespoke_workout_plans",
      "ai_equipment_scanner",
      "advanced_progress_analytics",
      "unlimited_workout_sessions"
    ]
  }
}
```

---

## 5. Check Subscription Status & Entitlements

Call this on app launch or when unlocking premium features.

```http
GET /api/subscriptions/status/
Authorization: Bearer <user_jwt_access_token>
```

**Response (200 OK):**
```json
{
  "is_premium": true,
  "has_subscription": true,
  "status": "active",
  "is_valid": true,
  "message": "Active subscription found.",
  "entitlements": [
    "bespoke_workout_plans",
    "ai_equipment_scanner",
    "advanced_progress_analytics",
    "unlimited_workout_sessions",
    "custom_workout_routines",
    "priority_support"
  ],
  "subscription": {
    "id": 6,
    "status": "active",
    "billing_cycle": "yearly",
    "payment_source": "apple_app_store",
    "current_period_end": "2027-11-02T11:20:00Z",
    "cancel_at_period_end": false,
    "auto_renew_status": true
  }
}
```

---

## 6. Server Webhooks (Server-to-Server Notifications)

Configure these in the Google Play Console and Apple App Store Connect:

### 6.1 Google Cloud Pub/Sub RTDN (Android)
- **Topic Name:** configured in Google Cloud Pub/Sub
- **Subscription Type:** Push Subscription
- **Push Endpoint URL:** `https://api.hykxapp.com/api/subscriptions/google-play/webhook/`
- **Handled Events:** `RENEWED`, `CANCELED`, `EXPIRED`, `REVOKED`, `IN_GRACE_PERIOD`.

### 6.2 Apple App Store Server Notifications V2 (iOS)
- **Production Server URL:** `https://api.hykxapp.com/api/subscriptions/apple/webhook/`
- **Sandbox Server URL:** `https://api.hykxapp.com/api/subscriptions/apple/webhook/`
- **Notification Version:** Version 2 Notifications
- **Handled Events:** `SUBSCRIBED`, `DID_RENEW`, `DID_CHANGE_RENEWAL_STATUS`, `REFUND`, `REVOKE`, `EXPIRED`.

---

## 7. Flutter Integration Code Example

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class SubscriptionService {
  final String baseUrl = 'https://api.hykxapp.com';

  /// Verify purchase after InAppPurchase purchaseStream emits a purchaseDetails
  Future<bool> verifyPurchase(PurchaseDetails purchase, String jwtToken) async {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    if (isAndroid) {
      final googlePurchase = purchase as GooglePlayPurchaseDetails;
      final response = await http.post(
        Uri.parse('$baseUrl/api/subscriptions/google-play/verify/'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': purchase.productID,
          'purchase_token': googlePurchase.billingClientPurchase.purchaseToken,
          'order_id': googlePurchase.billingClientPurchase.orderId,
          'package_name': 'com.hykx.app',
        }),
      );
      return response.statusCode == 200;
    } else {
      final applePurchase = purchase as AppStorePurchaseDetails;
      final response = await http.post(
        Uri.parse('$baseUrl/api/subscriptions/apple/verify/'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': purchase.productID,
          'original_transaction_id': applePurchase.skPaymentTransaction.transactionIdentifier,
          'transaction_id': applePurchase.skPaymentTransaction.transactionIdentifier,
        }),
      );
      return response.statusCode == 200;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases(List<PurchaseDetails> purchases, String jwtToken) async {
    final formatted = purchases.map((p) {
      if (p is GooglePlayPurchaseDetails) {
        return {
          'store': 'google_play',
          'product_id': p.productID,
          'purchase_token': p.billingClientPurchase.purchaseToken,
          'transaction_id': p.billingClientPurchase.orderId,
        };
      } else {
        return {
          'store': 'apple_app_store',
          'product_id': p.productID,
          'original_transaction_id': p.purchaseID,
          'transaction_id': p.purchaseID,
        };
      }
    }).toList();

    final response = await http.post(
      Uri.parse('$baseUrl/api/subscriptions/restore/'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'purchases': formatted}),
    );
    return response.statusCode == 200;
  }
}
```

---

## 8. Summary of Error Codes

| Status Code | Reason | Resolution |
|:---|:---|:---|
| **400 Bad Request** | Purchase already associated with another account | Do not allow multiple accounts to share the same purchase token / Apple ID |
| **400 Bad Request** | Subscription has already expired or been revoked | Ask user to resubscribe |
| **401 Unauthorized** | Missing or expired JWT access token | Refresh user session before calling verification |
| **200 OK** | Verified & active | Access granted; unlock premium features |

