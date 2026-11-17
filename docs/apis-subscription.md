# HYKX Subscription & Payment API Documentation

Complete specification for subscription management, Stripe card payments, mobile payment sheets, and Google Play Android In-App Purchases (IAP).

---

## 1. Overview & Pricing Architecture

HYKX offers two subscription options delivering full access to the platform:

| Option | Billing Cadence | Price | Benefits Included |
|---|---|---|---|
| **Pro Monthly** | Monthly | **$4.99 / mo** | Unlimited routines, 100+ machines, Details instruction, tips, Advanced progress tracking, Advanced analytics |
| **Pro Yearly** | Yearly | **$24.99 / yr** | Unlimited routines, 100+ machines, Details instruction, tips, Advanced progress tracking, Advanced analytics |

- **Currency**: `USD` (`$`)
- **Payment Providers Supported**:
  1. **Google Play Billing (Android In-App Purchase)**: Native Android purchase flow via `purchaseToken` verification.
  2. **Stripe Direct In-App Card**: Native mobile card entry via `payment_method_id` (`/api/subscriptions/subscribe/`).
  3. **Stripe Mobile Payment Sheet**: Pre-built native mobile bottom sheet (`/api/subscriptions/checkout/` with `payment_sheet: true`).
  4. **Stripe Web Checkout**: Hosted Stripe checkout session (`/api/subscriptions/checkout/`).

---

## 2. Android In-App Purchase (Google Play Billing) Guide

### How Android In-App Purchases Work
1. The Android app displays available plans fetched from `GET /api/subscriptions/plans/`.
2. The user selects **Pro Monthly** (`hykx_pro_monthly`) or **Pro Yearly** (`hykx_pro_yearly`).
3. The Android app initiates Google Play Billing using Google Play Billing Library:
   ```kotlin
   val billingFlowParams = BillingFlowParams.newBuilder()
       .setProductDetailsParamsList(...)
       .build()
   billingClient.launchBillingFlow(activity, billingFlowParams)
   ```
4. When Google Play finishes the payment, Google returns a `Purchase` object containing `purchaseToken`, `orderId`, and `productId`.
5. The Android app sends this purchase receipt to your backend:
   ```
   POST /api/subscriptions/google-play/verify/
   ```
6. The backend verifies the token, records the subscription with `payment_source: "google_play"`, sets `current_period_end` (30 days for monthly, 365 days for yearly), and activates the user.

### Android Google Play Setup Requirements (.env)
Add to your `.env`:
```env
GOOGLE_PLAY_PACKAGE_NAME=com.hykxapp.hykx
# Optional for server-to-server Real-Time Developer Notifications (RTDN):
# GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=/path/to/service-account.json
```

---



## 4. API Endpoints Reference

### 4.1 List Available Subscription Plans
Fetch all active subscription plans.

- **Method**: `GET`
- **URL**: `{{baseurl}}/api/subscriptions/plans/`
- **Headers**:
  ```http
  Authorization: Bearer <access_token>   # (Optional - public endpoint)
  ```
- **Response `200 OK`**:
```json
[
  {
    "id": 1,
    "title": "HYKX",
    "tier_badge": "Pro",
    "cta_label": "Subscribe to Yearly plan",
    "subtitle": "Get full access to HYKX",
    "benefits": [
      "Unlimited routines",
      "100+ machines",
      "Details instruction, tips",
      "Advanced progress tracking",
      "Advanced analytics"
    ],
    "monthly_price": "4.99",
    "monthly_billing_note": "$4.99 billed monthly",
    "monthly_save_badge": "",
    "yearly_price": "24.99",
    "yearly_cadence_label": "Yearly",
    "yearly_billing_note": "$24.99 billed yearly",
    "yearly_save_badge": "Save 58%",
    "currency": "usd",
    "currency_symbol": "$",
    "google_monthly_product_id": "hykx_pro_monthly",
    "google_yearly_product_id": "hykx_pro_yearly",
    "is_active": true,
    "created_at": "2026-09-29T09:29:20.460515Z"
  }
]
```

---

### 4.2 Check Current User Subscription Status
Check whether the authenticated user has an active membership and when it expires.

- **Method**: `GET`
- **URL**: `{{baseurl}}/api/subscriptions/my-subscription/`
- **Headers**:
  ```http
  Authorization: Bearer <access_token>
  ```
- **Response `200 OK` (Active Subscriber)**:
```json
{
  "has_subscription": true,
  "status": "active",
  "is_valid": true,
  "message": "Active subscription found.",
  "subscription": {
    "id": 1,
    "status": "active",
    "billing_cycle": "monthly",
    "payment_source": "google_play",
    "plan": 1,
    "plan_title": "HYKX",
    "plan_tier": "Pro",
    "plan_benefits": [
      "Unlimited routines",
      "100+ machines",
      "Details instruction, tips",
      "Advanced progress tracking",
      "Advanced analytics"
    ],
    "is_valid": true,
    "started_at": "2026-10-13T10:00:00Z",
    "current_period_end": "2026-11-12T10:00:00Z",
    "cancel_at_period_end": false,
    "canceled_at": null,
    "created_at": "2026-10-13T10:00:00Z"
  }
}
```

- **Response `200 OK` (Free / Unsubscribed)**:
```json
{
  "has_subscription": false,
  "status": "none",
  "is_valid": false,
  "message": "No active subscription found.",
  "subscription": null
}
```

---

### 4.3 Android Google Play In-App Purchase Verification
Verify purchase token received by the Android app from Google Play Billing and activate subscription.

- **Method**: `POST`
- **URL**: `{{baseurl}}/api/subscriptions/google-play/verify/`
- **Headers**:
  ```http
  Authorization: Bearer <access_token>
  Content-Type: application/json
  ```
- **Request Body (Monthly)**:
```json
{
  "product_id": "hykx_pro_monthly",
  "purchase_token": "in_app_purchase_token_from_google_play_client",
  "order_id": "GPA.1234-5678-9012-34567",
  "billing_cycle": "monthly"
}
```
- **Request Body (Yearly)**:
```json
{
  "product_id": "hykx_pro_yearly",
  "purchase_token": "in_app_purchase_token_from_google_play_client",
  "order_id": "GPA.9876-5432-1098-76543",
  "billing_cycle": "yearly"
}
```
- **Response `200 OK`**:
```json
{
  "success": true,
  "status": "active",
  "payment_source": "google_play",
  "message": "Google Play subscription activated successfully!",
  "subscription": {
    "id": 1,
    "status": "active",
    "billing_cycle": "monthly",
    "payment_source": "google_play",
    "plan": 1,
    "plan_title": "HYKX",
    "plan_tier": "Pro",
    "plan_benefits": [
      "Unlimited routines",
      "100+ machines",
      "Details instruction, tips",
      "Advanced progress tracking",
      "Advanced analytics"
    ],
    "is_valid": true,
    "started_at": "2026-10-13T10:20:00Z",
    "current_period_end": "2026-11-12T10:20:00Z",
    "cancel_at_period_end": false,
    "canceled_at": null,
    "created_at": "2026-10-13T10:20:00Z"
  }
}
```

---

### 4.4 Direct In-App Card Subscription (Stripe Native Card)
Submit a `payment_method_id` generated on device via Stripe Android SDK to start recurring billing.

- **Method**: `POST`
- **URL**: `{{baseurl}}/api/subscriptions/subscribe/` *(or `{{baseurl}}/api/subscriptions/card-payment/`)*
- **Headers**:
  ```http
  Authorization: Bearer <access_token>
  Content-Type: application/json
  ```
- **Request Body**:
```json
{
  "plan_id": 1,
  "billing_cycle": "monthly",
  "payment_method_id": "pm_card_visa",
  "save_card": true
}
```
- **Response `200 OK`**:
```json
{
  "success": true,
  "status": "active",
  "requires_action": false,
  "client_secret": null,
  "message": "Subscription activated successfully!",
  "subscription": {
    "id": 1,
    "status": "active",
    "billing_cycle": "monthly",
    "payment_source": "stripe",
    "plan": 1,
    "plan_title": "HYKX",
    "plan_tier": "Pro",
    "is_valid": true
  }
}
```

---

### 4.5 Stripe Mobile Payment Sheet Initiation
Generate parameters for Stripe's prebuilt Android bottom-sheet UI.

- **Method**: `POST`
- **URL**: `{{baseurl}}/api/subscriptions/checkout/`
- **Headers**:
  ```http
  Authorization: Bearer <access_token>
  Content-Type: application/json
  ```
- **Request Body**:
```json
{
  "plan_id": 1,
  "billing_cycle": "monthly",
  "payment_sheet": true
}
```
- **Response `200 OK`**:
```json
{
  "paymentIntent": "pi_3MtwLwLkdIwHu7ix28a3tqPa_secret_YrKJ...",
  "ephemeralKey": "ek_test_YWNjdF8x...",
  "customer": "cus_NffrFeUknnRRCH",
  "publishableKey": "pk_test_51SJZg4AH6r5jNzNwuFyHUFFE0NJEcV17D2FZXEAYApasqgrIaPi44n1gT2sBKDq3RNPbP63gCRdvpSCUgJt5VsWW00x7PIkSx6"
}
```

---

### 4.6 Cancel Active Subscription
Schedules cancellation at the end of the current billing cycle so the user retains access until their paid period concludes.

- **Method**: `POST`
- **URL**: `{{baseurl}}/api/subscriptions/cancel/`
- **Headers**:
  ```http
  Authorization: Bearer <access_token>
  ```
- **Response `200 OK`**:
```json
{
  "detail": "Subscription scheduled to cancel at end of billing period.",
  "status": "active",
  "cancel_at_period_end": true,
  "current_period_end": "2026-11-12T10:20:00Z"
}
```

---

### 4.7 Stripe Webhook Listener
Automated Stripe backend webhook receiver for recurring lifecycle events.

- **Method**: `POST`
- **URL**: `{{baseurl}}/api/subscriptions/webhook/`
- **Headers**:
  ```http
  Stripe-Signature: <stripe_signature>
  Content-Type: application/json
  ```
- **Events Handled**:
  - `checkout.session.completed`
  - `payment_intent.succeeded`
  - `invoice.payment_succeeded`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`

---

## 5. Postman Collection Testing Checklist

```markdown
1. [GET]  {{baseurl}}/api/subscriptions/plans/
   -> Expect 200 OK with HYKX plan, monthly_price: 4.99, yearly_price: 24.99, currency: usd.

2. [GET]  {{baseurl}}/api/subscriptions/my-subscription/
   -> Expect 200 OK with has_subscription: false (if new user).

3. [POST] {{baseurl}}/api/subscriptions/google-play/verify/
   -> Body: { "product_id": "hykx_pro_monthly", "purchase_token": "test_token_123", "billing_cycle": "monthly" }
   -> Expect 200 OK with success: true, status: "active", payment_source: "google_play".

4. [GET]  {{baseurl}}/api/subscriptions/my-subscription/
   -> Expect 200 OK with has_subscription: true, is_valid: true.

5. [POST] {{baseurl}}/api/subscriptions/cancel/
   -> Expect 200 OK with cancel_at_period_end: true.
```

