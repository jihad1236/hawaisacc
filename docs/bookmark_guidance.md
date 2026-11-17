# Frontend API Guidance: Workout Bookmark Integration

This document provides exact, step-by-step API calling specifications (methods, URLs, headers, request bodies, response payloads, and code examples) for integrating the **Workout Bookmark** feature in the mobile/web frontend.

---

## 1. Quick API Reference Table

| Action | HTTP Method | Endpoint URL | Request Body | Auth Header |
| :--- | :--- | :--- | :--- | :--- |
| **Toggle Bookmark** | `POST` | `/api/workouts/<id>/bookmark/` | `{}` (Empty) | `Bearer <access_token>` |
| **Get All Bookmarks** | `GET` | `/api/bookmarks/` | None | `Bearer <access_token>` |
| **Get Exercise Detail** | `GET` | `/api/workouts/<id>/` | None | `Bearer <access_token>` |
| **Get Exercise List** | `GET` | `/api/workouts/` | None | `Bearer <access_token>` |

---

## 2. Detailed API Specifications

### A. Toggle Bookmark (Add / Remove)

Call this when the user clicks the bookmark icon on an exercise card or detail page. The backend automatically adds the bookmark if not already saved, or deletes it if already saved.

- **Method:** `POST`
- **URL:** `/api/workouts/{workout_id}/bookmark/`  
  *(Alternative alias supported: `/api/exercises/{exercise_id}/bookmark/`)*
- **Headers:**
  ```http
  Authorization: Bearer <user_access_token>
  Content-Type: application/json
  ```
- **Request Body:**
  ```json
  {}
  ```
  *(No body payload is required; sending `{}` or empty is valid)*

#### Response Scenarios:

**Scenario 1: Exercise was bookmarked successfully (`200 OK`)**
```json
{
  "bookmarked": true
}
```

**Scenario 2: Exercise was already bookmarked, now un-bookmarked / removed (`200 OK`)**
```json
{
  "bookmarked": false
}
```

**Scenario 3: Exercise not found (`404 NOT FOUND`)**
```json
{
  "detail": "Not found."
}
```

**Scenario 4: User token expired or missing (`401 UNAUTHORIZED`)**
```json
{
  "detail": "Authentication credentials were not provided."
}
```

---

### B. Fetch All Bookmarked Workouts

Call this when opening the **"Saved"**, **"Favorites"**, or **"Bookmarks"** screen in the app.

- **Method:** `GET`
- **URL:** `/api/bookmarks/`
- **Headers:**
  ```http
  Authorization: Bearer <user_access_token>
  ```
- **Request Body:** None

#### Response Payload (`200 OK`):
Returns an array of all active bookmarked workouts for the authenticated user:

```json
[
  {
    "id": 101,
    "title": "Barbell Bench Press",
    "name": "Barbell Bench Press",
    "image": "https://res.cloudinary.com/.../workouts/bench_press.jpg",
    "video": null,
    "description": "Lie flat on the bench and grip the bar slightly wider than shoulder-width.",
    "tags": ["Pectoralis", "Anterior Delt", "Triceps"],
    "muscles": {
      "primary": "Pectoralis",
      "secondary": ["Anterior Delt", "Triceps"]
    },
    "difficulty": "intermediate",
    "level": "intermediate",
    "exercise_type": "gym",
    "flag": "gym",
    "sets": "3-5",
    "reps": "6-12",
    "rest": "60s-90s",
    "duration_minutes": 0,
    "category_name": "Chest",
    "log_type": "strength",
    "is_bookmarked": true,
    "recommendation": {
      "sets": 3,
      "reps": "6-12",
      "rest_seconds": 60
    }
  },
  {
    "id": 105,
    "title": "Incline Dumbbell Press",
    "name": "Incline Dumbbell Press",
    "image": "https://res.cloudinary.com/.../workouts/incline_press.jpg",
    "video": null,
    "description": "Adjust the bench to 30-45 degrees.",
    "tags": ["Upper Chest", "Front Delt"],
    "difficulty": "beginner",
    "level": "beginner",
    "exercise_type": "gym",
    "category_name": "Chest",
    "log_type": "strength",
    "is_bookmarked": true
  }
]
```

---

### C. Check Bookmark Status from Workout Details or List

When fetching an exercise detail or list, the backend automatically sets `"is_bookmarked": true` or `false` based on the logged-in user.

- **Method:** `GET`
- **URL:** `/api/workouts/{workout_id}/`
- **Headers:** `Authorization: Bearer <user_access_token>`

#### Response Payload (`200 OK`):
```json
{
  "id": 101,
  "title": "Barbell Bench Press",
  "category_name": "Chest",
  "difficulty": "intermediate",
  "is_bookmarked": true
}
```

---

## 3. Frontend Implementation & API Calling Code

### A. TypeScript API Service (`services/bookmarkService.ts`)

```typescript
import axios from 'axios';

const API_BASE_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:8000';

const getAuthHeaders = () => {
  const token = localStorage.getItem('access_token'); // or await SecureStore.getItemAsync('token')
  return {
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  };
};

export interface BookmarkToggleResponse {
  bookmarked: boolean;
}

export interface BookmarkedWorkout {
  id: number;
  title: string;
  image: string | null;
  category_name: string;
  difficulty: string;
  sets: string;
  reps: string;
  is_bookmarked: boolean;
}

// 1. Toggle Bookmark (Add / Remove)
export const toggleWorkoutBookmark = async (workoutId: number): Promise<boolean> => {
  const response = await axios.post<BookmarkToggleResponse>(
    `${API_BASE_URL}/api/workouts/${workoutId}/bookmark/`,
    {},
    getAuthHeaders()
  );
  return response.data.bookmarked;
};

// 2. Fetch All Bookmarked Workouts
export const getBookmarkedWorkouts = async (): Promise<BookmarkedWorkout[]> => {
  const response = await axios.get<BookmarkedWorkout[]>(
    `${API_BASE_URL}/api/bookmarks/`,
    getAuthHeaders()
  );
  return response.data;
};
```

---

### B. Bookmark Button Component with Optimistic UI Update (`components/BookmarkButton.tsx`)

This component handles instant UI feedback so the user doesn't experience network latency:

```tsx
import React, { useState } from 'react';
import { TouchableOpacity, Text, ActivityIndicator, StyleSheet } from 'react-native';
import { toggleWorkoutBookmark } from '../services/bookmarkService';

interface BookmarkButtonProps {
  workoutId: number;
  initialIsBookmarked: boolean;
  onToggleSuccess?: (newState: boolean) => void;
}

export const BookmarkButton: React.FC<BookmarkButtonProps> = ({
  workoutId,
  initialIsBookmarked,
  onToggleSuccess,
}) => {
  const [isBookmarked, setIsBookmarked] = useState<boolean>(initialIsBookmarked);
  const [loading, setLoading] = useState<boolean>(false);

  const handlePress = async () => {
    // 1. Optimistic UI: Update icon instantly
    const previousState = isBookmarked;
    const newState = !previousState;
    setIsBookmarked(newState);

    try {
      setLoading(true);
      // 2. Call API: POST /api/workouts/{id}/bookmark/
      const serverResult = await toggleWorkoutBookmark(workoutId);
      
      // 3. Confirm with server response
      setIsBookmarked(serverResult);
      if (onToggleSuccess) {
        onToggleSuccess(serverResult);
      }
    } catch (error) {
      // 4. Revert UI if API fails
      console.error('Failed to toggle bookmark:', error);
      setIsBookmarked(previousState);
    } finally {
      setLoading(false);
    }
  };

  return (
    <TouchableOpacity
      onPress={handlePress}
      disabled={loading}
      style={styles.button}
      accessibilityLabel={isBookmarked ? 'Remove bookmark' : 'Bookmark this workout'}
    >
      <Text style={styles.icon}>
        {isBookmarked ? '🔖' : '🏷️'}
      </Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    padding: 8,
  },
  icon: {
    fontSize: 22,
  },
});
```

---

### C. Bookmarks Screen Component (`screens/BookmarksScreen.tsx`)

```tsx
import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, ActivityIndicator, StyleSheet } from 'react-native';
import { getBookmarkedWorkouts, BookmarkedWorkout } from '../services/bookmarkService';
import { WorkoutCard } from '../components/WorkoutCard';

export const BookmarksScreen = () => {
  const [bookmarks, setBookmarks] = useState<BookmarkedWorkout[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  const fetchBookmarks = async () => {
    try {
      setLoading(true);
      const data = await getBookmarkedWorkouts();
      setBookmarks(data);
    } catch (error) {
      console.error('Failed to load bookmarks:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBookmarks();
  }, []);

  if (loading) {
    return <ActivityIndicator size="large" style={styles.centered} />;
  }

  if (bookmarks.length === 0) {
    return (
      <View style={styles.centered}>
        <Text style={styles.emptyText}>No bookmarked workouts yet.</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.header}>Saved Workouts</Text>
      <FlatList
        data={bookmarks}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <WorkoutCard
            workout={item}
            onBookmarkToggled={() => fetchBookmarks()}
          />
        )}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, padding: 16, backgroundColor: '#fff' },
  header: { fontSize: 24, fontWeight: 'bold', marginBottom: 16 },
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  emptyText: { color: '#888', fontSize: 16 },
});
```
