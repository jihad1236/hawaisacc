# Frontend API Guidance: User Notifications Integration

This document provides complete, production-ready frontend integration specifications for the **User In-App Notifications Screen** in the Hawiisaac mobile app (matching the Notifications Inbox design).

---

## 1. Quick API Reference Table

| Action | HTTP Method | Endpoint URL | Request Body | Auth Header | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Get Notifications** | `GET` | `/api/notifications/` | None | `Bearer <token>` | Fetches user's notification list |
| **Get Unread Count** | `GET` | `/api/notifications/unread-count/` | None | `Bearer <token>` | Badge counter for bell icon (e.g. `3`) |
| **Mark Single as Read** | `PATCH` | `/api/notifications/<id>/mark-read/` | None | `Bearer <token>` | Marks specific notification read |
| **Mark All as Read** | `POST` | `/api/notifications/mark-all-read/` | None | `Bearer <token>` | Marks all notifications read |

---

## 2. Screen UI Mapping from API Response

Matching your mobile screen design:

```
[Screen Header]
  • Title: "Notifications"
  • Back Button: < (Navigate back)

[Notification Item Card]
  • Title: item.title                   ───> "20% off" / "MoneyBack" / "Offer! Offer!"
  • Timestamp: item.time_display        ───> "TUE, 7:30 PM"
  • Body / Subtitle: item.message       ───> "You will get flat 20% off next 3 months."
  • Read / Unread Indicator: item.is_read ──> Light background or dot if unread
```

---

## 3. Endpoints & Request / Response Specifications

### A. Fetch Notification List
- **Method:** `GET`
- **URL:** `/api/notifications/`
- **Headers:** `Authorization: Bearer <user_access_token>`

#### Response Payload (`200 OK`):
```json
[
  {
    "id": 1,
    "notification_type": "offer",
    "type_display": "Offer & Promotion",
    "title": "20% off",
    "message": "You will get flat 20% off next 3 months.",
    "time_display": "TUE, 7:30 PM",
    "link": "/subscriptions/",
    "metadata": {
      "discount_percent": 20,
      "duration_months": 3
    },
    "is_read": false,
    "read_at": null,
    "created_at": "2026-10-06T19:30:00Z"
  },
  {
    "id": 2,
    "notification_type": "offer",
    "type_display": "Offer & Promotion",
    "title": "MoneyBack",
    "message": "You will get flat 20% off next 3 months.",
    "time_display": "TUE, 7:30 PM",
    "link": "/subscriptions/",
    "metadata": {
      "guarantee": "30_days"
    },
    "is_read": false,
    "read_at": null,
    "created_at": "2026-10-06T19:30:00Z"
  },
  {
    "id": 3,
    "notification_type": "offer",
    "type_display": "Offer & Promotion",
    "title": "Offer! Offer!",
    "message": "You will get flat 20% off next 3 months.",
    "time_display": "TUE, 7:30 PM",
    "link": "/subscriptions/",
    "metadata": {
      "promo_code": "PROMO20"
    },
    "is_read": true,
    "read_at": "2026-10-06T20:00:00Z",
    "created_at": "2026-10-06T19:30:00Z"
  }
]
```

> **Note on `time_display`:** The backend automatically formats the timestamp as `"TUE, 7:30 PM"` (matching the screenshot) so no custom date parsing is required in frontend.

---

### B. Get Unread Count (Bell Icon Badge)
Use this on the home screen / navigation bar to display an unread badge on the Notification Bell icon.

- **Method:** `GET`
- **URL:** `/api/notifications/unread-count/`
- **Headers:** `Authorization: Bearer <user_access_token>`

#### Response Payload (`200 OK`):
```json
{
  "unread_count": 2
}
```

---

### C. Mark Single Notification as Read
Triggered when the user taps on a notification card.

- **Method:** `PATCH` (or `POST`)
- **URL:** `/api/notifications/{notification_id}/mark-read/`
- **Headers:** `Authorization: Bearer <user_access_token>`
- **Request Body:** None

#### Response Payload (`200 OK`):
```json
{
  "success": true,
  "message": "Notification marked as read.",
  "notification": {
    "id": 1,
    "is_read": true,
    "read_at": "2026-10-06T20:15:00Z"
  }
}
```

---

### D. Mark All Notifications as Read
Triggered via a "Mark all as read" button in the notifications header.

- **Method:** `POST`
- **URL:** `/api/notifications/mark-all-read/`
- **Headers:** `Authorization: Bearer <user_access_token>`
- **Request Body:** None

#### Response Payload (`200 OK`):
```json
{
  "success": true,
  "updated_count": 2,
  "message": "All notifications marked as read."
}
```

---

## 4. Frontend Implementation & Code Example (React Native / TypeScript)

### A. TypeScript Service (`services/notificationService.ts`)

```typescript
import axios from 'axios';

const API_BASE_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:8000';

const getAuthHeaders = () => {
  const token = localStorage.getItem('access_token');
  return {
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  };
};

export interface UserNotification {
  id: number;
  notification_type: 'offer' | 'reminder' | 'streak' | 'system';
  type_display: string;
  title: string;
  message: string;
  time_display: string;
  link: string;
  is_read: boolean;
  read_at: string | null;
  created_at: string;
}

export const notificationService = {
  // 1. Fetch all notifications
  getAll: async (): Promise<UserNotification[]> => {
    const res = await axios.get<UserNotification[]>(`${API_BASE_URL}/api/notifications/`, getAuthHeaders());
    return res.data;
  },

  // 2. Fetch unread count for badge
  getUnreadCount: async (): Promise<number> => {
    const res = await axios.get<{ unread_count: number }>(`${API_BASE_URL}/api/notifications/unread-count/`, getAuthHeaders());
    return res.data.unread_count;
  },

  // 3. Mark single notification as read
  markAsRead: async (id: number): Promise<void> => {
    await axios.patch(`${API_BASE_URL}/api/notifications/${id}/mark-read/`, {}, getAuthHeaders());
  },

  // 4. Mark all as read
  markAllAsRead: async (): Promise<void> => {
    await axios.post(`${API_BASE_URL}/api/notifications/mark-all-read/`, {}, getAuthHeaders());
  },
};
```

---

### B. Notifications Screen Component (`screens/NotificationsScreen.tsx`)

```tsx
import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, TouchableOpacity, ActivityIndicator, StyleSheet } from 'react-native';
import { notificationService, UserNotification } from '../services/notificationService';

export const NotificationsScreen = ({ navigation }: any) => {
  const [notifications, setNotifications] = useState<UserNotification[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  const fetchNotifications = async () => {
    try {
      setLoading(true);
      const data = await notificationService.getAll();
      setNotifications(data);
    } catch (error) {
      console.error('Failed to load notifications:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchNotifications();
  }, []);

  const handleNotificationPress = async (item: UserNotification) => {
    if (!item.is_read) {
      // Optimistic update
      setNotifications((prev) =>
        prev.map((n) => (n.id === item.id ? { ...n, is_read: true } : n))
      );
      await notificationService.markAsRead(item.id);
    }

    // Optional navigation if link exists
    if (item.link) {
      navigation.navigate(item.link);
    }
  };

  const renderItem = ({ item }: { item: UserNotification }) => (
    <TouchableOpacity
      style={[styles.card, !item.is_read && styles.unreadCard]}
      onPress={() => handleNotificationPress(item)}
      activeOpacity={0.7}
    >
      <View style={styles.cardHeader}>
        <Text style={styles.title}>{item.title}</Text>
        <Text style={styles.timestamp}>{item.time_display}</Text>
      </View>
      <Text style={styles.message}>{item.message}</Text>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.headerRow}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Text style={styles.backText}>‹</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Notifications</Text>
        <View style={{ width: 40 }} />
      </View>

      {/* Content */}
      {loading ? (
        <ActivityIndicator size="large" color="#00D1FF" style={styles.center} />
      ) : notifications.length === 0 ? (
        <View style={styles.center}>
          <Text style={styles.emptyText}>No notifications yet.</Text>
        </View>
      ) : (
        <FlatList
          data={notifications}
          keyExtractor={(item) => item.id.toString()}
          renderItem={renderItem}
          contentContainerStyle={styles.listContainer}
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FFFFFF' },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingTop: 50,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#F0F0F0',
  },
  backBtn: { width: 40, height: 40, justifyContent: 'center' },
  backText: { fontSize: 32, color: '#1A1A1A', fontWeight: '300' },
  headerTitle: { fontSize: 18, fontWeight: 'bold', color: '#1A1A1A' },
  listContainer: { padding: 16 },
  card: {
    backgroundColor: '#F7F8FA',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
  },
  unreadCard: {
    backgroundColor: '#F0F5FA',
    borderLeftWidth: 3,
    borderLeftColor: '#00D1FF',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 6,
  },
  title: { fontSize: 16, fontWeight: 'bold', color: '#1A1A1A' },
  timestamp: { fontSize: 12, color: '#8F9CAE', fontWeight: '500' },
  message: { fontSize: 14, color: '#5E6B7A', lineHeight: 20 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  emptyText: { color: '#8F9CAE', fontSize: 15 },
});
```

---

## 5. Backend Service: How to Trigger User Notifications

Anywhere in the backend, you can trigger notifications for users by calling:

```python
from dashboard.services import create_user_notification

# 1. Send Offer / Promo to a user
create_user_notification(
    user=user,
    title='20% off',
    message='You will get flat 20% off next 3 months.',
    notification_type='offer',
    link='/subscriptions/',
    metadata={'promo': '20OFF'}
)

# 2. Workout Reminder
create_user_notification(
    user=user,
    title='Time to Train!',
    message='Today is Chest & Triceps day. Keep up your streak!',
    notification_type='reminder',
    link='/workouts/'
)

# 3. Global Announcement (user=None reaches all users)
create_user_notification(
    user=None,
    title='New AI Scan Features Added',
    message='You can now scan and detect barbell equipment with 98% accuracy.',
    notification_type='system'
)
```
