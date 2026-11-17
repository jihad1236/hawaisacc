# Frontend API Guidance: Subscription & Payment Integration

This document provides complete, production-ready frontend integration specifications for the **Hawiisaac Subscription & Stripe Payment System**.

---

## 1. Quick API Reference Table

| Action | HTTP Method | Endpoint URL | Request Body | Auth Header |
| :--- | :--- | :--- | :--- | :--- |
| **Get Available Plans** | `GET` | `/api/subscriptions/plans/` | None | Optional / Public |
| **Check Current Subscription**| `GET` | `/api/subscriptions/my-subscription/` | None | `Bearer <access_token>` |
| **Initiate Checkout / Sheet** | `POST` | `/api/subscriptions/checkout/` | Plan ID, billing cycle, options | `Bearer <access_token>` |
| **Direct Card Subscription** | `POST` | `/api/subscriptions/subscribe/` | Plan ID, cycle, `payment_method_id` | `Bearer <access_token>` |
| **Cancel Subscription** | `POST` | `/api/subscriptions/cancel/` | `{}` (Empty) | `Bearer <access_token>` |

---

## 2. Subscription Data Models & Fields

### A. Subscription Plan Object (`Subscription`)

Each plan represents a subscription tier (e.g. Free, Pro Monthly, Pro Yearly):

| Field Name | Type | Description | Example |
| :--- | :--- | :--- | :--- |
| `id` | `number` | Unique ID of the subscription plan | `1` |
| `title` | `string` | Display name of the plan | `"Pro Athlete"` |
| `tier_badge` | `string` | Badge text shown on card | `"POPULAR"` or `"MOST POPULAR"` |
| `cta_label` | `string` | Button text | `"Start 7-Day Free Trial"` |
| `subtitle` | `string` | Short description | `"Unlock AI workout plans & scan history"` |
| `benefits` | `string[]` | List of features included in plan | `["Unlimited AI Scans", "Custom Plans"]` |
| `monthly_price` | `string` | Monthly price amount | `"9.99"` |
| `monthly_billing_note`| `string` | Note under monthly price | `"Billed monthly, cancel anytime"` |
| `yearly_price` | `string` | Yearly price amount | `"79.99"` |
| `yearly_billing_note` | `string` | Note under yearly price | `"Billed annually at €79.99"` |
| `yearly_save_badge` | `string` | Discount badge | `"SAVE 33%"` |
| `currency` | `string` | Currency code | `"eur"` |
| `currency_symbol` | `string` | Currency symbol | `"€"` |
| `is_active` | `boolean` | Plan visibility | `true` |

---

### B. User Subscription Object (`UserSubscription`)

Returned by `GET /api/subscriptions/my-subscription/`:

| Field Name | Type | Description |
| :--- | :--- | :--- |
| `has_subscription` | `boolean` | `true` if user has an active or trialing subscription |
| `status` | `string` | `'active'`, `'trialing'`, `'past_due'`, `'canceled'`, or `'none'` |
| `is_valid` | `boolean` | `true` if current period has not expired |
| `subscription.plan_title` | `string` | Title of the active plan (e.g. `"Pro Athlete"`) |
| `subscription.billing_cycle`| `string` | `'monthly'` or `'yearly'` |
| `subscription.current_period_end` | `string` | ISO timestamp of expiration / renewal date |
| `subscription.cancel_at_period_end`| `boolean` | `true` if user has cancelled and will expire at period end |

---

## 3. Endpoints & Request / Response Specifications

### A. Get Available Subscription Plans
Public endpoint to display the Paywall / Pricing screen.

- **Method:** `GET`
- **URL:** `/api/subscriptions/plans/`
- **Headers:** `Authorization: Bearer <token>` (Optional)

#### Response (`200 OK`):
```json
[
  {
    "id": 1,
    "title": "Pro Monthly",
    "tier_badge": "POPULAR",
    "cta_label": "Subscribe Monthly",
    "subtitle": "Full access to all AI scanning and workout tracking",
    "benefits": [
      "Unlimited AI Equipment Scans",
      "Custom Workout Plans",
      "Full Exercise Library",
      "Detailed 1RM & Analytics"
    ],
    "monthly_price": "9.99",
    "monthly_billing_note": "Billed every month",
    "monthly_save_badge": "",
    "yearly_price": "79.99",
    "yearly_billing_note": "Billed annually",
    "yearly_save_badge": "SAVE 33%",
    "currency": "eur",
    "currency_symbol": "€",
    "is_active": true
  }
]
```

---

### B. Check User's Active Subscription Status
Call on app launch or before accessing premium features.

- **Method:** `GET`
- **URL:** `/api/subscriptions/my-subscription/`
- **Headers:** `Authorization: Bearer <user_access_token>`

#### Response Scenario 1: User has NO active subscription (`200 OK`)
```json
{
  "has_subscription": false,
  "status": "none",
  "is_valid": false,
  "message": "No active subscription found.",
  "subscription": null
}
```

#### Response Scenario 2: User HAS an active subscription (`200 OK`)
```json
{
  "has_subscription": true,
  "status": "active",
  "is_valid": true,
  "message": "Active subscription found.",
  "subscription": {
    "id": 14,
    "status": "active",
    "billing_cycle": "yearly",
    "plan": 1,
    "plan_title": "Pro Monthly",
    "plan_tier": "POPULAR",
    "plan_benefits": [
      "Unlimited AI Equipment Scans",
      "Custom Workout Plans",
      "Full Exercise Library"
    ],
    "is_valid": true,
    "started_at": "2026-04-01T10:00:00Z",
    "current_period_end": "2027-04-01T10:00:00Z",
    "cancel_at_period_end": false,
    "canceled_at": null,
    "created_at": "2026-04-01T10:00:00Z"
  }
}
```

---

### C. Purchase Subscription: Option 1 — Mobile Payment Sheet (Recommended for React Native / Flutter)

Opens Stripe's native Mobile Payment Sheet bottom-sheet inside the app (Apple Pay, Google Pay, Cards).

- **Method:** `POST`
- **URL:** `/api/subscriptions/checkout/`
- **Headers:**
  ```http
  Authorization: Bearer <user_access_token>
  Content-Type: application/json
  ```
- **Request Body:**
  ```json
  {
    "plan_id": 1,
    "billing_cycle": "yearly",
    "payment_sheet": true
  }
  ```

#### Response (`200 OK`):
```json
{
  "paymentIntent": "pi_3NxABC_secret_xyz...",
  "ephemeralKey": "ek_test_123...",
  "customer": "cus_ABC123",
  "publishableKey": "pk_test_51Nx..."
}
```
*The frontend feeds these 4 keys directly to `@stripe/stripe-react-native` (`initPaymentSheet()` & `presentPaymentSheet()`).*

---

### D. Purchase Subscription: Option 2 — Web Checkout URL

For Web apps or WebViews where the user is redirected to Stripe Hosted Checkout.

- **Method:** `POST`
- **URL:** `/api/subscriptions/checkout/`
- **Headers:**
  ```http
  Authorization: Bearer <user_access_token>
  Content-Type: application/json
  ```
- **Request Body:**
  ```json
  {
    "plan_id": 1,
    "billing_cycle": "monthly",
    "payment_sheet": false,
    "success_url": "https://yourapp.com/subscription/success?session_id={CHECKOUT_SESSION_ID}",
    "cancel_url": "https://yourapp.com/subscription/cancel"
  }
  ```

#### Response (`200 OK`):
```json
{
  "checkout_url": "https://checkout.stripe.com/c/pay/cs_test_a1b2c3...",
  "session_id": "cs_test_a1b2c3...",
  "publishable_key": "pk_test_51Nx..."
}
```
*Frontend redirects browser window or WebView to `checkout_url`.*

---

### E. Purchase Subscription: Option 3 — Direct In-App Card Subscription

When designing a custom in-app Card Form (Card Number, Exp, CVC). The frontend creates a `paymentMethod` using Stripe SDK, then sends the `payment_method_id` to the backend.

- **Method:** `POST`
- **URL:** `/api/subscriptions/subscribe/`  
  *(Alternative alias: `/api/subscriptions/card-payment/`)*
- **Headers:**
  ```http
  Authorization: Bearer <user_access_token>
  Content-Type: application/json
  ```
- **Request Body:**
  ```json
  {
    "plan_id": 1,
    "billing_cycle": "yearly",
    "payment_method_id": "pm_1NxABC123XYZ",
    "save_card": true
  }
  ```

#### Response (`200 OK`):
```json
{
  "success": true,
  "status": "active",
  "requires_action": false,
  "client_secret": null,
  "message": "Subscription activated successfully!",
  "subscription": {
    "id": 15,
    "status": "active",
    "billing_cycle": "yearly",
    "plan_title": "Pro Monthly",
    "is_valid": true,
    "current_period_end": "2027-04-01T10:00:00Z"
  }
}
```

---

### F. Cancel Active Subscription

Cancels the user's recurring subscription. The user keeps access until `current_period_end`.

- **Method:** `POST`
- **URL:** `/api/subscriptions/cancel/`
- **Headers:**
  ```http
  Authorization: Bearer <user_access_token>
  Content-Type: application/json
  ```
- **Request Body:** `{}` (Empty)

#### Response (`200 OK`):
```json
{
  "detail": "Subscription scheduled to cancel at end of billing period.",
  "status": "active",
  "cancel_at_period_end": true,
  "current_period_end": "2027-04-01T10:00:00Z"
}
```

---

## 4. Frontend Integration Code Examples

### A. TypeScript API Client (`services/subscriptionApi.ts`)

```typescript
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.EXPO_PUBLIC_API_URL || 'http://localhost:8000',
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export interface SubscriptionPlan {
  id: number;
  title: string;
  tier_badge: string;
  cta_label: string;
  subtitle: string;
  benefits: string[];
  monthly_price: string;
  monthly_billing_note: string;
  yearly_price: string;
  yearly_billing_note: string;
  yearly_save_badge: string;
  currency: string;
  currency_symbol: string;
  is_active: boolean;
}

export interface MySubscriptionResponse {
  has_subscription: boolean;
  status: 'active' | 'trialing' | 'past_due' | 'canceled' | 'none';
  is_valid: boolean;
  message: string;
  subscription: {
    id: number;
    status: string;
    billing_cycle: 'monthly' | 'yearly';
    plan_title: string;
    plan_tier: string;
    plan_benefits: string[];
    is_valid: boolean;
    current_period_end: string;
    cancel_at_period_end: boolean;
  } | null;
}

export const subscriptionApi = {
  // 1. Get all pricing plans
  getPlans: () => api.get<SubscriptionPlan[]>('/api/subscriptions/plans/').then((res) => res.data),

  // 2. Check my subscription status
  getMySubscription: () => api.get<MySubscriptionResponse>('/api/subscriptions/my-subscription/').then((res) => res.data),

  // 3. Initiate Mobile Payment Sheet
  getMobilePaymentSheet: (planId: number, billingCycle: 'monthly' | 'yearly') =>
    api.post('/api/subscriptions/checkout/', {
      plan_id: planId,
      billing_cycle: billingCycle,
      payment_sheet: true,
    }).then((res) => res.data),

  // 4. Cancel recurring subscription
  cancel: () => api.post('/api/subscriptions/cancel/', {}).then((res) => res.data),
};
```

---

### B. React Native Stripe Payment Sheet Flow (`screens/SubscriptionPaywall.tsx`)

```tsx
import React, { useEffect, useState } from 'react';
import { View, Text, TouchableOpacity, Alert, ActivityIndicator, StyleSheet } from 'react-native';
import { useStripe } from '@stripe/stripe-react-native';
import { subscriptionApi, SubscriptionPlan } from '../services/subscriptionApi';

export const SubscriptionPaywall = ({ navigation }: any) => {
  const { initPaymentSheet, presentPaymentSheet } = useStripe();
  const [plans, setPlans] = useState<SubscriptionPlan[]>([]);
  const [selectedCycle, setSelectedCycle] = useState<'monthly' | 'yearly'>('yearly');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    subscriptionApi.getPlans().then(setPlans).catch(console.error);
  }, []);

  const handleSubscribe = async (plan: SubscriptionPlan) => {
    try {
      setLoading(true);

      // 1. Fetch keys from backend
      const sheetData = await subscriptionApi.getMobilePaymentSheet(plan.id, selectedCycle);

      // 2. Initialize Stripe Payment Sheet
      const { error: initError } = await initPaymentSheet({
        paymentIntentClientSecret: sheetData.paymentIntent,
        customerEphemeralKeySecret: sheetData.ephemeralKey,
        customerId: sheetData.customer,
        merchantDisplayName: 'Hawiisaac Fitness',
      });

      if (initError) {
        Alert.alert('Payment Error', initError.message);
        return;
      }

      // 3. Present Payment Sheet to user
      const { error: presentError } = await presentPaymentSheet();

      if (presentError) {
        Alert.alert('Payment Cancelled', presentError.message);
      } else {
        Alert.alert('Success', 'Welcome to Pro Athlete Membership!');
        navigation.replace('Home');
      }
    } catch (err: any) {
      Alert.alert('Error', err.response?.data?.detail || 'Failed to process payment');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.header}>Upgrade to Pro</Text>
      
      {/* Billing Cycle Switcher */}
      <View style={styles.cycleToggle}>
        <TouchableOpacity
          style={[styles.cycleBtn, selectedCycle === 'monthly' && styles.activeCycle]}
          onPress={() => setSelectedCycle('monthly')}
        >
          <Text style={styles.btnText}>Monthly</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.cycleBtn, selectedCycle === 'yearly' && styles.activeCycle]}
          onPress={() => setSelectedCycle('yearly')}
        >
          <Text style={styles.btnText}>Yearly (Save 33%)</Text>
        </TouchableOpacity>
      </View>

      {/* Plan Card */}
      {plans.map((plan) => (
        <View key={plan.id} style={styles.card}>
          <Text style={styles.planTitle}>{plan.title}</Text>
          <Text style={styles.price}>
            {plan.currency_symbol}
            {selectedCycle === 'yearly' ? plan.yearly_price : plan.monthly_price}
          </Text>
          <Text style={styles.billingNote}>
            {selectedCycle === 'yearly' ? plan.yearly_billing_note : plan.monthly_billing_note}
          </Text>

          {plan.benefits.map((b, idx) => (
            <Text key={idx} style={styles.benefitItem}>✓ {b}</Text>
          ))}

          <TouchableOpacity
            style={styles.payBtn}
            disabled={loading}
            onPress={() => handleSubscribe(plan)}
          >
            {loading ? <ActivityIndicator color="#fff" /> : <Text style={styles.payBtnText}>{plan.cta_label}</Text>}
          </TouchableOpacity>
        </View>
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, backgroundColor: '#0B0E14' },
  header: { fontSize: 26, color: '#fff', fontWeight: 'bold', marginBottom: 20 },
  cycleToggle: { flexDirection: 'row', backgroundColor: '#1E232F', borderRadius: 10, padding: 4, marginBottom: 20 },
  cycleBtn: { flex: 1, paddingVertical: 10, alignItems: 'center', borderRadius: 8 },
  activeCycle: { backgroundColor: '#00D1FF' },
  btnText: { color: '#fff', fontWeight: 'bold' },
  card: { backgroundColor: '#151922', padding: 20, borderRadius: 16, borderColor: '#00D1FF', borderWidth: 1 },
  planTitle: { color: '#00D1FF', fontSize: 18, fontWeight: 'bold' },
  price: { color: '#fff', fontSize: 32, fontWeight: 'bold', marginVertical: 8 },
  billingNote: { color: '#8F9CAE', fontSize: 14, marginBottom: 16 },
  benefitItem: { color: '#DCE1E8', fontSize: 14, marginBottom: 6 },
  payBtn: { backgroundColor: '#00D1FF', padding: 16, borderRadius: 12, alignItems: 'center', marginTop: 16 },
  payBtnText: { color: '#000', fontSize: 16, fontWeight: 'bold' },
});
```
