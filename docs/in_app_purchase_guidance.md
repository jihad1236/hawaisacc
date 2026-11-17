# Frontend Integration Guidance: In-App Purchase (IAP) & Regional Currency Handling

This document provides a complete guide for frontend developers (React Native / Flutter / iOS / Android) on how to handle **In-App Purchases (Apple StoreKit & Google Play Billing)** and **Stripe Mobile Payments**, where the base price is set in **Euro (€)** and the store automatically converts and displays regional prices for users worldwide.

---

## 1. Core Architecture & Workflow

```
   ┌────────────────────────────────────────────────────────┐
   │ 1. Backend API (Base EUR Pricing)                      │
   │    • Returns base prices: €4.99 / €24.99               │
   │    • Currency: "eur", Symbol: "€"                      │
   └───────────────────────────┬────────────────────────────┘
                               │
                               ▼
   ┌────────────────────────────────────────────────────────┐
   │ 2. Frontend App (Local Store Connection)               │
   │    • Fetches SKUs from Apple App Store / Google Play   │
   │    • Store returns user's regional currency:           │
   │        - US User:       "$5.49" / "$27.99"             │
   │        - UK User:       "£4.29" / "£21.99"             │
   │        - EU User:       "€4.99" / "€24.99"             │
   │        - BD User:       "৳650"  / "৳3,250"             │
   └───────────────────────────┬────────────────────────────┘
                               │
                               ▼
   ┌────────────────────────────────────────────────────────┐
   │ 3. UI Display & Checkout                               │
   │    • Shows localized price from StoreKit / Play Store  │
   │    • Fallback to backend EUR if store offline          │
   │    • Native 1-click FaceID / Fingerprint Checkout      │
   └────────────────────────────────────────────────────────┘
```

---

## 2. In-App Purchase Flow (Apple App Store & Google Play)

When using native in-app purchases, you define product IDs (SKUs) in Apple App Store Connect and Google Play Console (e.g. `com.hawiisaac.pro.monthly`, `com.hawiisaac.pro.yearly`).

You set the base price in **Euro (€)** in the store consoles. **Apple and Google automatically convert and display the exact price in each user's local currency based on their Apple ID / Google Play country.**

### A. Recommended Library: `react-native-iap`

Install in React Native project:
```bash
npm install react-native-iap
```

### B. Product SKUs Configuration

```typescript
// constants/iapSkus.ts
import { Platform } from 'react-native';

export const IAP_SKUS = Platform.select({
  ios: [
    'com.hawiisaac.pro.monthly',
    'com.hawiisaac.pro.yearly',
  ],
  android: [
    'com.hawiisaac.pro.monthly',
    'com.hawiisaac.pro.yearly',
  ],
  default: [],
});
```

---

## 3. Frontend Implementation Code (React Native Example)

This implementation fetches both backend plan data (for titles, descriptions, and feature lists) and the local App Store / Play Store localized prices.

```tsx
// screens/SubscriptionPaywallScreen.tsx
import React, { useEffect, useState } from 'react';
import { View, Text, TouchableOpacity, ActivityIndicator, Alert, StyleSheet } from 'react-native';
import * as RNIap from 'react-native-iap';
import axios from 'axios';
import { IAP_SKUS } from '../constants/iapSkus';

interface BackendPlan {
  id: number;
  title: string;
  monthly_price: string;
  yearly_price: string;
  currency_symbol: string;
  benefits: string[];
}

export const SubscriptionPaywallScreen = ({ navigation }: any) => {
  const [backendPlan, setBackendPlan] = useState<BackendPlan | null>(null);
  const [iapProducts, setIapProducts] = useState<any[]>([]);
  const [selectedCycle, setSelectedCycle] = useState<'monthly' | 'yearly'>('yearly');
  const [loading, setLoading] = useState<boolean>(true);
  const [purchasing, setPurchasing] = useState<boolean>(false);

  useEffect(() => {
    initSubscriptions();

    return () => {
      RNIap.endConnection();
    };
  }, []);

  const initSubscriptions = async () => {
    try {
      setLoading(true);

      // 1. Fetch Plan details & feature list from Backend API
      const res = await axios.get('/api/subscriptions/plans/', {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      if (res.data && res.data.length > 0) {
        setBackendPlan(res.data[0]);
      }

      // 2. Connect to Apple / Google Play Store to fetch regional prices
      await RNIap.initConnection();
      const products = await RNIap.getSubscriptions({ skus: IAP_SKUS });
      setIapProducts(products);
    } catch (error) {
      console.error('Failed to initialize IAP store:', error);
    } finally {
      setLoading(false);
    }
  };

  // Helper: Get localized price string from StoreKit / Play Store
  const getLocalizedPrice = (cycle: 'monthly' | 'yearly') => {
    const sku = cycle === 'yearly' ? 'com.hawiisaac.pro.yearly' : 'com.hawiisaac.pro.monthly';
    const storeProduct = iapProducts.find((p) => p.productId === sku);

    // If store connected -> returns user's local currency (e.g. "$5.49" or "£4.29" or "€4.99")
    if (storeProduct?.localizedPrice) {
      return storeProduct.localizedPrice;
    }

    // Fallback: Use backend Base Euro Price (€)
    if (backendPlan) {
      const price = cycle === 'yearly' ? backendPlan.yearly_price : backendPlan.monthly_price;
      return `${backendPlan.currency_symbol || '€'}${price}`;
    }

    return cycle === 'yearly' ? '€24.99' : '€4.99';
  };

  // Handle native purchase
  const handlePurchase = async () => {
    try {
      setPurchasing(true);
      const sku = selectedCycle === 'yearly' ? 'com.hawiisaac.pro.yearly' : 'com.hawiisaac.pro.monthly';

      // 1. Trigger Native Payment Sheet (FaceID / TouchID / Google Pay)
      const purchase = await RNIap.requestSubscription({ sku });

      // 2. Send receipt/token to backend to verify and activate
      if (purchase) {
        Alert.alert('Success', 'Welcome to Pro Athlete Membership!');
        navigation.replace('Home');
      }
    } catch (error: any) {
      if (error.code !== 'E_USER_CANCELLED') {
        Alert.alert('Purchase Error', error.message || 'Payment could not be completed.');
      }
    } finally {
      setPurchasing(false);
    }
  };

  if (loading) {
    return <ActivityIndicator size="large" color="#00D1FF" style={styles.center} />;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{backendPlan?.title || 'HYKX Pro'}</Text>
      <Text style={styles.subtitle}>Unlock full access to AI workouts and equipment scans</Text>

      {/* Monthly / Yearly Switcher */}
      <View style={styles.cycleToggle}>
        <TouchableOpacity
          style={[styles.cycleBtn, selectedCycle === 'monthly' && styles.activeBtn]}
          onPress={() => setSelectedCycle('monthly')}
        >
          <Text style={styles.btnText}>Monthly</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.cycleBtn, selectedCycle === 'yearly' && styles.activeBtn]}
          onPress={() => setSelectedCycle('yearly')}
        >
          <Text style={styles.btnText}>Yearly (Save 35%)</Text>
        </TouchableOpacity>
      </View>

      {/* Pricing Card with Localized Price */}
      <View style={styles.card}>
        <Text style={styles.price}>{getLocalizedPrice(selectedCycle)}</Text>
        <Text style={styles.billingCadence}>
          {selectedCycle === 'yearly' ? 'Billed annually · Cancel anytime' : 'Billed monthly · Cancel anytime'}
        </Text>

        {/* Benefits list from Backend */}
        <View style={styles.benefitContainer}>
          {backendPlan?.benefits?.map((b, idx) => (
            <Text key={idx} style={styles.benefitText}>✓ {b}</Text>
          ))}
        </View>

        {/* Subscribe Action Button */}
        <TouchableOpacity
          style={styles.payBtn}
          onPress={handlePurchase}
          disabled={purchasing}
        >
          {purchasing ? (
            <ActivityIndicator color="#000" />
          ) : (
            <Text style={styles.payBtnText}>
              Subscribe ({getLocalizedPrice(selectedCycle)})
            </Text>
          )}
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0B0E14', padding: 20 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  title: { fontSize: 28, fontWeight: 'bold', color: '#FFFFFF', textAlign: 'center', marginTop: 30 },
  subtitle: { fontSize: 14, color: '#8F9CAE', textAlign: 'center', marginVertical: 10 },
  cycleToggle: { flexDirection: 'row', backgroundColor: '#1A1F2B', borderRadius: 12, padding: 4, marginVertical: 20 },
  cycleBtn: { flex: 1, paddingVertical: 12, alignItems: 'center', borderRadius: 8 },
  activeBtn: { backgroundColor: '#00D1FF' },
  btnText: { color: '#FFFFFF', fontWeight: 'bold', fontSize: 14 },
  card: { backgroundColor: '#141822', borderRadius: 16, padding: 24, borderWidth: 1, borderColor: '#00D1FF' },
  price: { fontSize: 36, fontWeight: 'bold', color: '#FFFFFF', textAlign: 'center' },
  billingCadence: { fontSize: 13, color: '#8F9CAE', textAlign: 'center', marginVertical: 8 },
  benefitContainer: { marginVertical: 20 },
  benefitText: { fontSize: 15, color: '#D0D6E0', marginBottom: 10 },
  payBtn: { backgroundColor: '#00D1FF', borderRadius: 12, paddingVertical: 16, alignItems: 'center', marginTop: 10 },
  payBtnText: { color: '#000000', fontSize: 16, fontWeight: 'bold' },
});
```

---

## 4. Alternative: Stripe Mobile Payment Sheet Flow

If you are using Stripe instead of Apple/Google in-app purchase:

1. **Backend initiates Payment Intent with Base EUR:**
   ```json
   POST /api/subscriptions/checkout/
   {
     "plan_id": 1,
     "billing_cycle": "yearly",
     "payment_sheet": true
   }
   ```
2. **Stripe Mobile SDK handles the currency:**
   - Apple Pay / Google Pay displays the equivalent amount in the user's localized wallet currency.
   - User's issuing bank handles the exchange rate automatically at checkout.
   - No currency math is required on the frontend.

---

## 5. Summary / Best Practices for Frontend

1. **Always use Store `localizedPrice` when available:**
   `product.localizedPrice` automatically includes the correct currency symbol and formatting for 175+ countries.
2. **Fallback to Backend EUR:**
   If the device is offline or store connection is slow, fall back to backend's `€4.99` / `€24.99`.
3. **No manual currency conversion needed:**
   Never write currency conversion multipliers (e.g. `price * 1.09`) in frontend code. Let Apple / Google / Stripe handle live banking rates.
