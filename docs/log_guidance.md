# Comprehensive Frontend Guidance: Workout Plan, Timed Logging, Analytics & Notifications

This guide provides the complete end-to-end integration specifications for the Hawiisaac mobile app, covering:
1. **Workout Plan Overview (Screen 1)**
2. **Timed Circuit Workout Logging & Progression (Screens 2 & 3)**
3. **Empty Log State (Screen 4)**
4. **Progress & Analytics Integration (1RM & Volume Charts)**
5. **System Architecture: Notifications, WebSockets & FCM Status**

---

## 1. Flow Breakdown for the 4 Workout Screens

```
[Screen 1: Plan Overview]  ──(Start Exercise)──>  [Screen 2: Active Timed Session]
  "Bodyweight Burn"                                 Squat Jump [00][45] ──> Click "Next"
         │                                                      │
         ▼                                                      ▼
[Screen 4: Empty State]   <──(Finish Workout)──  [Screen 3: Next Exercise & Done Badges]
  "Add any workout..."                              Squat Jump [Done], Push-Up [00][45]
```

---

## 2. Screen 1: Workout Plan Overview (`Bodyweight Burn`)

### A. Endpoint
- **URL:** `GET /api/plans/<plan_id>/`
- **Method:** `GET`
- **Headers:** `Authorization: Bearer <token>`

### B. UI Mapping from API Response

| UI Element in Screenshot | API Response Field | Example Value |
| :--- | :--- | :--- |
| **Top Subtitle / Category** | `plan.category.name` | `"Chest"` or `"Body warm-up"` |
| **Main Title** | `plan.title` | `"Bodyweight Burn"` |
| **Equipment & Level Subtitle**| `${plan.equipment_note} . ${plan.category.name} . ${plan.level}` | `"No equipment . Chest . Beginner"` |
| **Badge 1: Calorie Burn** | `plan.estimated_calories` | `"60 CAL BURN"` |
| **Badge 2: Exercises Count**| `plan.exercises.length` | `"5 EXERCISES"` |
| **Badge 3: Difficulty Level**| `plan.level` | `"BGN LEVEL"` |
| **Today's Exercise List** | `plan.exercises[]` | Array of timed exercises |
| ↳ Exercise Item Title | `exercise.title` | `"Squat Jump"`, `"Push-Up"` |
| ↳ Exercise Target Muscles | `exercise.subtitle` or `exercise.target_muscles.join(' . ')` | `"Legs . Power"`, `"Chest . Triceps"` |
| ↳ Time Duration Badge | `${exercise.time_seconds}s` | `"45s"` |
| **"Start Exercise" Button** | Triggers Session Start API | `POST /api/workout-sessions/start/` |

### C. Action: "Start Exercise" Button Click
When the user taps **"Start Exercise"**, call:
```http
POST /api/workout-sessions/start/
Content-Type: application/json
Authorization: Bearer <token>

{
  "plan_id": 1,
  "resume": false
}
```
**Backend Action:** Automatically copies all 5 plan exercises into an active `WorkoutSession`, sets the first exercise (`Squat Jump`) to `in_progress`, starts the timer, and returns the full session payload. The frontend then navigates to **Screen 2**.

---

## 3. Screens 2 & 3: Active Timed Workout Session (`Logging`)

### A. Endpoint to Fetch Current Active State
- **URL:** `GET /api/workout-sessions/active/`
- **Method:** `GET`
- **Headers:** `Authorization: Bearer <token>`

### B. Active Exercise Display (Screen 2)

```json
{
  "has_active_session": true,
  "timer_display": "24:13",
  "elapsed_seconds": 1453,
  "exercises": [
    {
      "id": 101,
      "exercise_id": 5,
      "title": "Squat Jump",
      "status": "in_progress",
      "is_done": false,
      "target_time_seconds": 45,
      "target_minutes": "00",
      "target_seconds": "45",
      "timer_presets": ["00", "45"]
    },
    {
      "id": 102,
      "exercise_id": 6,
      "title": "Push-Up",
      "status": "pending",
      "is_done": false,
      "time_display": "45s"
    },
    {
      "id": 103,
      "exercise_id": 7,
      "title": "Mountain Climber",
      "status": "pending",
      "is_done": false,
      "time_display": "45s"
    }
  ]
}
```

- **Top Right Header Timer (`24:13`):** Use `timer_display` or start a local interval with `elapsed_seconds`.
- **Countdown Display:** `exercise.timer_presets[0]` (`"00"`) and `exercise.timer_presets[1]` (`"45"`).
- **Active Exercise Card:** Highlights the exercise where `status === 'in_progress'`.
- **Upcoming Queue:** Renders items where `status === 'pending'`.

---

### C. Transition from Screen 2 to Screen 3 (Clicking "Next")

When the countdown finishes or the user taps **"Next"**:
```http
POST /api/workout-sessions/active/exercises/<exercise_id>/complete/
Authorization: Bearer <token>
```
*(where `<exercise_id>` is `101` for Squat Jump)*.

**Backend Action:**
1. Marks `Squat Jump` as `status: 'completed'` (`is_done: true`).
2. Automatically advances `Push-Up` to `status: 'in_progress'`.
3. Returns the updated session.

**Screen 3 UI Changes:**
- `Squat Jump` now shows a **`Done`** badge.
- `Push-Up` becomes the active card with the `[00]` `[45]` countdown and `Next` button.

---

### D. Action: "Finish workout" Button
When the user taps the cyan **"Finish workout"** button:
```http
POST /api/workout-sessions/active/finish/
Authorization: Bearer <token>
```
- Sets session `status = 'completed'`.
- Calculates total duration & calories burned.
- Automatically updates user streak (`UserStreak`).
- Redirects to summary or empty log state.

---

## 4. Screen 4: Empty Log State

When the user opens the **+ Log** tab but has no session in progress:
- **Call:** `GET /api/workout-sessions/active/`
- **Response:**
  ```json
  {
    "active_session": null,
    "has_active_session": false,
    "detail": "No active workout session found.",
    "message": "Add any workout to show your log"
  }
  ```
- **UI:** Show centered empty state text: **`Add any workout to show your log`** (exactly as in Screen 4).

---

## 5. Progress & Analytics Guidance (`GET /api/progress/`)

This powers the **Progress / Analytics** screen (Line Chart, 2x2 Stats, and Personal Records).

### A. Endpoint & Query Filter
- **URL:** `GET /api/progress/?period=1m`
- **Allowed Query Values:** `period=all` | `1w` | `1m` | `3m` (Default: `1m`)
- **Headers:** `Authorization: Bearer <token>`

### B. UI Mapping

```
[Screen Header]
  • Title: "Progress"
  • Subtitle: data.date_range_display  ────────> "Apr 1 - Apr 18, 2026"
  • Filter Buttons: period = 'all' | '1w' | '1m' | '3m'

[Total Volume Lifted Card]
  • Value: data.total_volume_display   ────────> "48,200 kg"
  • Subtitle: data.volume_subtitle     ────────> "↑ Total Volume Lifted"

[Line Chart]
  • Points: data.volume_chart          ────────> Array of { date, label, volume }

[2x2 Stat Cards]
  • Workout:      data.metrics.workouts.display ("18") & subtitle ("↑ 3 sessions")
  • Avg Duration: data.metrics.avg_duration.display ("46m") & subtitle ("→ Stable")
  • Total Sets:   data.metrics.total_sets.display ("312") & subtitle ("↑ 28 sets")
  • Best Streak:  data.metrics.best_streak.display ("14d") & subtitle ("↑ New PR")

[Your Best (Personal Records / 1RM)]
  • List: data.personal_records
      1. Bench Press 1RM  ───> 102.5 kg | Apr 12 . barbell | ↑ +5kg
      2. Back Squat 1RM   ───> 135 kg   | April 8          | ↑ +7.5kg
      3. Deadlift 1RM     ───> 160 kg   | April 3 . barbell| ↑ +10kg
```

---

## 6. System Architecture: Notifications, WebSockets & FCM Status

### A. Is WebSocket / Socket in use?
* **No.** The project currently does **not** use WebSockets or Django Channels.
* Communication is handled via standard, stateless HTTP REST requests (`django-rest-framework`).

### B. Is Firebase Cloud Messaging (FCM) Connected?
* **No.** There is **no** `firebase-admin` or FCM push integration in the backend right now.
* The backend does **not** send push notifications to mobile devices.

### C. How are Notifications currently handled in the Backend?

1. **Admin In-App Notifications (Polling/REST):**
   - Model: `AdminNotification` (`dashboard/models.py`).
   - Triggered internally via `create_admin_notification()` when:
     - A new user registers (`new_user_registration`).
     - A user purchases/cancels a subscription (`new_subscription`, `subscription_cancelled`).
     - An equipment scan has low confidence (`low_confidence_scan`).
   - Accessible strictly by admin/staff at:
     ```http
     GET /api/admin-panel/notifications/
     PATCH /api/admin-panel/notifications/<id>/mark-read/
     POST /api/admin-panel/notifications/mark-all-read/
     ```

2. **Email Notifications (Transactional OTPs):**
   - Uses Django standard email backend (`send_mail`).
   - Used for Email Verification OTP and Password Reset OTP.

### D. How to implement Mobile FCM Push Notifications (Recommended Path):
If you want mobile push notifications (e.g. workout reminders, streak alerts):
1. **Backend:**
   - Install `firebase-admin`.
   - Add a `FCMDevice` model (storing `user`, `registration_token`, `device_type`).
   - Create an endpoint `POST /api/auth/fcm-token/` for the mobile app to register its FCM push token after login.
   - Send push notifications via Firebase Admin SDK.
2. **Frontend (React Native / Flutter):**
   - Request notification permissions on app start.
   - Fetch FCM token using `@react-native-firebase/messaging` or Flutter Firebase Messaging.
   - Send token to `POST /api/auth/fcm-token/`.
