# Frontend Integration Guidance: Workout Profile & Units

This document provides a comprehensive integration guide for the **User Workout Profile** and **Units Preference** endpoints in the Hawiisaac Backend.

---

## 1. Overview of Endpoints

| Endpoint | Supported Methods | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `/api/auth/workout-profile/` | `GET`, `PUT`, `PATCH` | Retrieve or update workout preferences & fitness goals | **Yes** (`Bearer <token>`) |
| `/api/auth/units/` | `GET`, `PUT`, `PATCH` | Retrieve or update measurement units (kg/lbs, km/miles, cm/in) | **Yes** (`Bearer <token>`) |

---

## 2. User Workout Profile (`/api/auth/workout-profile/`)

### A. Field Definitions & Choices

| Field Name | Type | Allowed Values | Nullable | Required for Completion | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `goal` | `string` | `'muscle_gain'`, `'fat_loss'`, `'strength'`, `'endurance'`, `'general_fitness'` | Yes | **Yes** | Primary fitness objective |
| `level` | `string` | `'beginner'`, `'intermediate'`, `'advanced'` | Yes | **Yes** | User experience level |
| `location` | `string` | `'home'`, `'gym'` | Yes | **Yes** | Primary workout environment |
| `workout_days` | `integer` | `1` to `7` (positive integer) | Yes | **Yes** | Target workout days per week |
| `session_duration` | `integer` | positive integer in minutes (e.g. `15`, `30`, `45`, `60`, `90`) | Yes | **Yes** | Minutes per workout session |
| `is_completed` | `boolean` | `true` or `false` | No | **Read-Only** | Automatically calculated by backend. Returns `true` only when all 5 fields above are valid and non-empty. |

---

### B. Choice Constants (Ready to copy-paste for Frontend)

```typescript
// constants/workoutProfile.ts

export const WORKOUT_GOAL_OPTIONS = [
  { value: 'muscle_gain', label: 'Muscle Gain' },
  { value: 'fat_loss', label: 'Fat Loss' },
  { value: 'strength', label: 'Strength' },
  { value: 'endurance', label: 'Endurance' },
  { value: 'general_fitness', label: 'General Fitness' },
] as const;

export const WORKOUT_LEVEL_OPTIONS = [
  { value: 'beginner', label: 'Beginner' },
  { value: 'intermediate', label: 'Intermediate' },
  { value: 'advanced', label: 'Advanced' },
] as const;

export const WORKOUT_LOCATION_OPTIONS = [
  { value: 'home', label: 'Home' },
  { value: 'gym', label: 'Gym' },
] as const;

export const WORKOUT_DAYS_OPTIONS = [
  { value: 1, label: '1 day / week' },
  { value: 2, label: '2 days / week' },
  { value: 3, label: '3 days / week' },
  { value: 4, label: '4 days / week' },
  { value: 5, label: '5 days / week' },
  { value: 6, label: '6 days / week' },
  { value: 7, label: '7 days / week' },
];

export const WORKOUT_DURATION_OPTIONS = [
  { value: 15, label: '15 mins' },
  { value: 30, label: '30 mins' },
  { value: 45, label: '45 mins' },
  { value: 60, label: '60 mins' },
  { value: 90, label: '90 mins' },
];
```

---

### C. TypeScript Interfaces

```typescript
// types/workoutProfile.ts

export type WorkoutGoal = 'muscle_gain' | 'fat_loss' | 'strength' | 'endurance' | 'general_fitness';
export type WorkoutLevel = 'beginner' | 'intermediate' | 'advanced';
export type WorkoutLocation = 'home' | 'gym';

export interface UserWorkoutProfile {
  goal: WorkoutGoal | null;
  level: WorkoutLevel | null;
  location: WorkoutLocation | null;
  workout_days: number | null;
  session_duration: number | null;
  is_completed: boolean;
}

// Payload for PUT / PATCH
export type UpdateWorkoutProfilePayload = Partial<Omit<UserWorkoutProfile, 'is_completed'>>;
```

---

### D. API Requests & Responses

#### 1. Fetch Current Profile
- **Method:** `GET`
- **URL:** `/api/auth/workout-profile/`
- **Headers:** `Authorization: Bearer <access_token>`

**Response (`200 OK`) — When newly registered (not completed):**
```json
{
  "goal": null,
  "level": null,
  "location": null,
  "workout_days": null,
  "session_duration": null,
  "is_completed": false
}
```

**Response (`200 OK`) — When completed:**
```json
{
  "goal": "muscle_gain",
  "level": "intermediate",
  "location": "gym",
  "workout_days": 4,
  "session_duration": 45,
  "is_completed": true
}
```

#### 2. Create or Fully Update Profile
- **Method:** `PUT`
- **URL:** `/api/auth/workout-profile/`
- **Headers:** 
  - `Authorization: Bearer <access_token>`
  - `Content-Type: application/json`

**Request Body:**
```json
{
  "goal": "muscle_gain",
  "level": "intermediate",
  "location": "gym",
  "workout_days": 4,
  "session_duration": 45
}
```

**Response (`200 OK`):**
```json
{
  "goal": "muscle_gain",
  "level": "intermediate",
  "location": "gym",
  "workout_days": 4,
  "session_duration": 45,
  "is_completed": true
}
```

#### 3. Partial Update Profile (e.g. User changes only goal in Settings)
- **Method:** `PATCH`
- **URL:** `/api/auth/workout-profile/`
- **Headers:** 
  - `Authorization: Bearer <access_token>`
  - `Content-Type: application/json`

**Request Body:**
```json
{
  "goal": "strength"
}
```

**Response (`200 OK`):**
```json
{
  "goal": "strength",
  "level": "intermediate",
  "location": "gym",
  "workout_days": 4,
  "session_duration": 45,
  "is_completed": true
}
```

---

## 3. User Units (`/api/auth/units/`)

### A. Field Definitions & Choices

| Field Name | Type | Allowed Values | Default Value | Description |
| :--- | :--- | :--- | :--- | :--- |
| `weight` | `string` | `'kg'`, `'lbs'` | `'kg'` | Weight unit |
| `distance` | `string` | `'km'`, `'miles'` | `'km'` | Running/walking distance unit |
| `body_measurements` | `string` | `'cm'`, `'in'` | `'cm'` | Body dimensions/circumference unit |

---

### B. Choice Constants & Types

```typescript
// constants/units.ts

export const WEIGHT_UNITS = [
  { value: 'kg', label: 'Kilograms (kg)' },
  { value: 'lbs', label: 'Pounds (lbs)' },
] as const;

export const DISTANCE_UNITS = [
  { value: 'km', label: 'Kilometers (km)' },
  { value: 'miles', label: 'Miles (mi)' },
] as const;

export const MEASUREMENT_UNITS = [
  { value: 'cm', label: 'Centimeters (cm)' },
  { value: 'in', label: 'Inches (in)' },
] as const;

export interface UserUnits {
  weight: 'kg' | 'lbs';
  distance: 'km' | 'miles';
  body_measurements: 'cm' | 'in';
}
```

---

### C. API Requests & Responses

#### 1. Fetch Units
- **Method:** `GET`
- **URL:** `/api/auth/units/`
- **Headers:** `Authorization: Bearer <access_token>`

**Response (`200 OK`):**
```json
{
  "weight": "kg",
  "distance": "km",
  "body_measurements": "cm"
}
```

#### 2. Update Units
- **Method:** `PUT` or `PATCH`
- **URL:** `/api/auth/units/`
- **Headers:** 
  - `Authorization: Bearer <access_token>`
  - `Content-Type: application/json`

**Request Body:**
```json
{
  "weight": "lbs",
  "distance": "miles",
  "body_measurements": "in"
}
```

**Response (`200 OK`):**
```json
{
  "weight": "lbs",
  "distance": "miles",
  "body_measurements": "in"
}
```

---

## 4. Frontend Flow & Routing Architecture

### A. Post-Login / Post-Registration Onboarding Guard

After authentication (Login, Register, OTP verification, or Social login):

```javascript
// Example Next.js / React Router navigation guard
async function handlePostAuthNavigation(router) {
  try {
    const profile = await api.get('/api/auth/workout-profile/');
    
    if (!profile.data.is_completed) {
      // User has not finished onboarding -> send to onboarding
      router.push('/onboarding');
    } else {
      // User already setup profile -> go to home dashboard
      router.push('/dashboard');
    }
  } catch (error) {
    console.error('Failed to check workout profile status', error);
  }
}
```

---

### B. UI Screen Breakdown

```
[Onboarding Wizard]
  ├── Step 1: Units Selection (/api/auth/units/)
  │     ├── Weight (kg / lbs)
  │     ├── Distance (km / miles)
  │     └── Measurement (cm / in)
  │
  ├── Step 2: Fitness Goal (/api/auth/workout-profile/)
  │     └── Select Card: Muscle Gain | Fat Loss | Strength | Endurance | General Fitness
  │
  ├── Step 3: Experience Level
  │     └── Select Card: Beginner | Intermediate | Advanced
  │
  ├── Step 4: Workout Location
  │     └── Select Card: Home | Gym
  │
  └── Step 5: Routine Commitment
        ├── Days per week (1 - 7 Stepper)
        └── Session Duration (15, 30, 45, 60 min Chips)
        └── [ Finish / Submit -> PUT /api/auth/workout-profile/ ]

[Settings / Profile Page]
  └── "Workout Preferences" Menu
        ├── Loads current data via GET /api/auth/workout-profile/
        ├── Editable fields
        └── Save button sends PATCH /api/auth/workout-profile/
```

---

## 5. Sample API Client Implementation (Axios)

```typescript
// services/authProfileService.ts
import axios from 'axios';
import { UserWorkoutProfile, UpdateWorkoutProfilePayload } from '../types/workoutProfile';
import { UserUnits } from '../types/units';

const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000',
});

// Interceptor to attach JWT token
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// 1. Workout Profile API
export const workoutProfileApi = {
  get: () => apiClient.get<UserWorkoutProfile>('/api/auth/workout-profile/').then((res) => res.data),
  
  updateFull: (payload: UpdateWorkoutProfilePayload) =>
    apiClient.put<UserWorkoutProfile>('/api/auth/workout-profile/', payload).then((res) => res.data),
    
  updatePartial: (payload: UpdateWorkoutProfilePayload) =>
    apiClient.patch<UserWorkoutProfile>('/api/auth/workout-profile/', payload).then((res) => res.data),
};

// 2. Units API
export const unitsApi = {
  get: () => apiClient.get<UserUnits>('/api/auth/units/').then((res) => res.data),
  
  update: (payload: Partial<UserUnits>) =>
    apiClient.patch<UserUnits>('/api/auth/units/', payload).then((res) => res.data),
};
```
