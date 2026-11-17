# Frontend Guidance: Active Workout & Logging Screen Integration

This guide explains how the **Workout Logging Screen** (and the flow from Equipment Scan & Exercise Details to Logging) is handled in the backend, based on the mobile UI designs.

---

## 1. Core Concept & Flow

The flow matches your 4 mobile UI screens:

```
[1. Matched Equipment] ──> [2. Manual Select / Scan Again] ──> [3. Exercise Details] ──> [4. Logging Screen]
(Scan Barbell)               (If wrong match)                  ("Add to workout")          (Active Session)
                                                                       │                           ▲
                                                                       └───────────────────────────┘
```

1. **Screen 1 & 2 (Scan & Match):** User scans equipment (e.g. Barbell), gets recommended exercises.
2. **Screen 3 (Exercise Details):** User views muscle anatomy, tags, reps/sets recommendation, and clicks **"Add to workout"**.
   - API Call: `POST /api/workout-sessions/active/add-exercise/` with `{ "exercise_id": <id> }`
3. **Screen 4 (Logging Screen):** User opens the **+ Log** tab or is redirected to `/workout-sessions/active/`.
   - The backend provides a dynamic **`log_type`** for each exercise so the frontend knows exactly which UI component to render (Strength sets vs. Cardio metrics).

---

## 2. Dynamic UI Based on `log_type`

When you fetch the active session (`GET /api/workout-sessions/active/`), every item in the `exercises[]` list contains a **`log_type`** property:

| `log_type` | UI Component to Render (as in Screenshot) | Relevant API Endpoint for logging |
| :--- | :--- | :--- |
| **`"strength"`** | **Weight & Reps Table** (`SET`, `KG`, `REPS`, Checkbox `[✓]`) + `+ Add set` button | `POST /api/workout-sessions/active/sets/` |
| **`"cardio"`** | **Cardio Metrics Grid** (`Time`, `Distance`, `Speed`, `Incline`) + `+ Add set` button | `POST /api/workout-sessions/active/cardio/` |
| **`"duration"`** | **Timed Hold / Stopwatch** (e.g., Plank, Stretching) | `POST /api/workout-sessions/active/cardio/` or sets |
| **`"bodyweight"`** | **Bodyweight Sets** (`SET`, `REPS`, Checkbox) without weight | `POST /api/workout-sessions/active/sets/` |

---

## 3. Endpoints Breakdown

All active session endpoints use `/api/workout-sessions/active/...` (no explicit session ID needed).

### A. Fetch Active Session & Timer
- **Endpoint:** `GET /api/workout-sessions/active/`
- **Headers:** `Authorization: Bearer <token>`
- **Response if no active session:**
  ```json
  {
    "active_session": null,
    "has_active_session": false,
    "message": "Add any workout to show your log"
  }
  ```
- **Response if active session exists (`200 OK`):**
  ```json
  {
    "id": 12,
    "session_id": 12,
    "title": "Custom Workout",
    "status": "in_progress",
    "has_active_session": true,
    "timer_display": "34:13",
    "elapsed_seconds": 2053,
    "calories_burned": 0,
    "total_exercises": 2,
    "completed_exercises": 0,
    "exercises": [
      {
        "id": 45,
        "exercise_id": 101,
        "title": "Barbell Bench Press",
        "log_type": "strength",
        "category_name": "Chest",
        "muscles": ["Pectoralis", "Anterior Delt", "Triceps", "Serratus"],
        "status": "in_progress",
        "is_done": false,
        "note": "",
        "sets": [
          { "set_number": 1, "weight_kg": 80.0, "reps": 9, "is_completed": true },
          { "set_number": 2, "weight_kg": 82.0, "reps": 8, "is_completed": false },
          { "set_number": 3, "weight_kg": 85.0, "reps": 6, "is_completed": false }
        ],
        "cardio_logs": []
      },
      {
        "id": 46,
        "exercise_id": 204,
        "title": "Treadmill workout",
        "log_type": "cardio",
        "category_name": "Cardio",
        "muscles": ["Quads", "Calves"],
        "status": "pending",
        "is_done": false,
        "note": "",
        "sets": [],
        "cardio_logs": [
          {
            "duration_seconds": 600,
            "distance_km": 4.0,
            "speed_kmh": 24.0,
            "incline_percent": 9.0
          }
        ]
      }
    ]
  }
  ```

---

### B. Add Exercise to Active Session ("Add to workout" button)
- **Endpoint:** `POST /api/workout-sessions/active/add-exercise/`
- **Request Body:**
  ```json
  {
    "exercise_id": 101,
    "target_time_seconds": 45
  }
  ```
- **Response:** Returns updated session object. If no session is currently active, calling `POST /api/workout-sessions/start/` with `{ "workout_id": 101 }` automatically starts one.

---

### C. Log a Strength Set (`log_type === 'strength'`)
Called whenever the user clicks **`+ Add set`** or toggles the checkmark for a set:
- **Endpoint:** `POST /api/workout-sessions/active/sets/`
- **Request Body:**
  ```json
  {
    "exercise_id": 101,
    "set_number": 1,
    "weight_kg": 80.0,
    "reps": 9,
    "is_completed": true
  }
  ```
- **Response (`201 Created`):**
  ```json
  {
    "id": 89,
    "set_number": 1,
    "weight_kg": 80.0,
    "reps": 9,
    "is_completed": true
  }
  ```

---

### D. Log Cardio Metrics (`log_type === 'cardio'`)
Called on the Treadmill / Cardio card:
- **Endpoint:** `POST /api/workout-sessions/active/cardio/`
- **Request Body:**
  ```json
  {
    "exercise_id": 204,
    "duration_seconds": 600,
    "distance_km": 4.0,
    "speed_kmh": 24.0,
    "incline_percent": 9.0
  }
  ```
- **Response (`201 Created`):**
  ```json
  {
    "id": 15,
    "duration_seconds": 600,
    "distance_km": 4.0,
    "speed_kmh": 24.0,
    "incline_percent": 9.0
  }
  ```

---

### E. Add / Update Exercise Note ("Add a note about this exercise...")
- **Endpoint:** `POST /api/workout-sessions/active/notes/`
- **Request Body:**
  ```json
  {
    "exercise_id": 101,
    "note": "Felt good, increase weight by 2.5kg next session."
  }
  ```
- **Response (`200 OK`):**
  ```json
  {
    "success": true,
    "exercise_id": 101,
    "note": "Felt good, increase weight by 2.5kg next session."
  }
  ```

---

### F. Complete Exercise & Finish Workout

1. **Mark single exercise complete:**
   - `POST /api/workout-sessions/active/exercises/<exercise_id>/complete/`
   - Advances `current_exercise` to the next exercise in order.

2. **Finish the whole session:**
   - `POST /api/workout-sessions/active/finish/`
   - Marks session completed, calculates calories burned, updates user streak, and records history.

---

## 4. Frontend Component Architecture (React / React Native Example)

```tsx
// components/LoggingScreen.tsx
import React, { useEffect, useState } from 'react';
import { StrengthLoggingCard } from './StrengthLoggingCard';
import { CardioLoggingCard } from './CardioLoggingCard';
import { ActiveSessionTimer } from './ActiveSessionTimer';
import { api } from '../services/api';

export const LoggingScreen = () => {
  const [session, setSession] = useState<any>(null);

  const fetchSession = async () => {
    const res = await api.get('/api/workout-sessions/active/');
    setSession(res.data);
  };

  useEffect(() => {
    fetchSession();
  }, []);

  if (!session?.has_active_session) {
    return <EmptyLogState message={session?.message || "Add any workout to show your log"} />;
  }

  return (
    <div className="logging-container">
      {/* Top Header with Timer (e.g. 34:13) */}
      <div className="header">
        <h2>Logging</h2>
        <ActiveSessionTimer initialSeconds={session.elapsed_seconds} />
      </div>

      {/* Render Exercise List based on log_type */}
      {session.exercises.map((ex: any) => {
        switch (ex.log_type) {
          case 'strength':
          case 'bodyweight':
            return (
              <StrengthLoggingCard
                key={ex.id}
                exercise={ex}
                onAddSet={(setData) => api.post('/api/workout-sessions/active/sets/', setData)}
                onUpdateNote={(note) => api.post('/api/workout-sessions/active/notes/', { exercise_id: ex.exercise_id, note })}
              />
            );

          case 'cardio':
            return (
              <CardioLoggingCard
                key={ex.id}
                exercise={ex}
                onSaveCardio={(cardioData) => api.post('/api/workout-sessions/active/cardio/', cardioData)}
                onUpdateNote={(note) => api.post('/api/workout-sessions/active/notes/', { exercise_id: ex.exercise_id, note })}
              />
            );

          default:
            return <StrengthLoggingCard key={ex.id} exercise={ex} />;
        }
      })}

      <button onClick={() => api.post('/api/workout-sessions/active/finish/')}>
        Finish Workout
      </button>
    </div>
  );
};
```
