# HYKX Fitness API - Mobile Developer Integration Guide
**Version:** 2.1 (Bespoke Plans, Sessions, Progress Summary & Subscriptions)  
**Target Environment:** Local (`http://127.0.0.1:9003`) & Live Production (`https://api.hykxapp.com`)

---

## 1. Overview & Base Configuration

### Base URLs
- **Production API:** `https://api.hykxapp.com`
- **Local Dev Server:** `http://127.0.0.1:9003`

### Authentication Headers
For all authenticated endpoints, supply the JWT Bearer token:
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

---

## 2. Bespoke Workout Plans & Schedules

The backend provides full schedule support for the bespoke programs:
1. **Gym / Resistance Training** (4-day cycle)
   - Day 1: **Push** (Chest, shoulders, triceps)
   - Day 2: **Pull** (Back, biceps, lower back)
   - Day 3: **Legs** (Quadriceps, hamstrings, calves, core)
   - Day 4: **Rest** (Recovery & rest instructions)
2. **Home / Minimal Equipment** (4-day cycle)
   - Day 1: **Push** (Bodyweight / dumbbell push)
   - Day 2: **Pull** (Bodyweight / dumbbell pull)
   - Day 3: **Legs** (Bodyweight / dumbbell legs and core)
   - Day 4: **Rest** (Recovery)

---

### Endpoint 2.1: List Workout Plans
- **Method:** `GET`
- **URL:** `/api/v1/plans/` or `/api/plans/`
- **Auth:** Public / Optional Bearer
- **Query Parameters:**
  - `location`: `gym` or `home` (optional)
  - `goal`: `muscle_gain`, `fat_loss`, `strength`, `general_fitness` (optional)
  - `level`: `beginner`, `intermediate`, `advanced` (optional)

#### Response (200 OK)
```json
[
  {
    "id": 61,
    "title": "Resistance Training - Full Body Split Program",
    "description": "Comprehensive 4-Day Cycle Resistance Training Program covering Day 1 Push, Day 2 Pull, Day 3 Legs & Core, with Day 4 Rest & Recovery.",
    "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1200&q=80",
    "goal": "muscle_gain",
    "location": "gym",
    "min_session_duration": 20,
    "max_session_duration": 45,
    "min_days_per_week": 3,
    "max_days_per_week": 4,
    "total_time_seconds": 4050,
    "duration_minutes": 30,
    "duration_display": "30 min",
    "level": "intermediate",
    "level_display": "INT",
    "estimated_calories": 210,
    "calories_burn": 210,
    "equipment_note": "Free Weights & Machines",
    "category": 7,
    "category_name": "Strength & Weights",
    "subtitle": "Free Weights & Machines • Strength & Weights • Intermediate",
    "total_days": 4,
    "exercise_count": 30
  }
]
```

---

### Endpoint 2.2: Retrieve Plan Details & Full 4-Day Schedule
- **Method:** `GET`
- **URL:** `/api/v1/plans/{id}/` or `/api/plans/{id}/`
- **Auth:** Public / Optional Bearer
- **Optional Day Filtering:**
  - `?day=1` or `?day=push` -> Filters `exercises` to Day 1: Push exercises only
  - `?day=2` or `?day=pull` -> Filters `exercises` to Day 2: Pull exercises only
  - `?day=3` or `?day=legs` -> Filters `exercises` to Day 3: Legs exercises only
  - `?day=4` or `?day=rest` -> Returns rest instructions with `is_rest_day: true`

#### Response (200 OK)
```json
{
  "id": 61,
  "title": "Resistance Training - Full Body Split Program",
  "description": "Comprehensive 4-Day Cycle Resistance Training Program...",
  "image": "https://images.unsplash.com/...",
  "location": "gym",
  "level": "intermediate",
  "level_display": "INT",
  "duration_minutes": 30,
  "duration_display": "30 min",
  "estimated_calories": 210,
  "calories_burn": 210,
  "total_days": 4,
  "exercise_count": 30,
  "schedule": [
    {
      "id": 5,
      "day_number": 1,
      "day_name": "Day 1",
      "split_name": "Push",
      "title": "Day 1: Push",
      "focus": "Chest, shoulders, triceps",
      "is_rest_day": false,
      "rest_note": "",
      "order": 1,
      "exercise_count": 10,
      "exercises": [
        {
          "id": 181,
          "order": 1,
          "title": "Alternating Dumbbell Bench Press",
          "subtitle": "Chest - Pectoralis • Free Weights",
          "target_muscles": ["Chest - Pectoralis", "Upper Body"],
          "description": "Push movement targeting Chest - Pectoralis. Modality: Free Weights. Mechanics: Multi-Joint (Compound).",
          "time_seconds": 45,
          "time_display": "45s",
          "workout_id": 41,
          "image": "https://res.cloudinary.com/dnu0axtez/image/upload/v1792484797/equipment/dumbbell.png",
          "plan_day": 5,
          "day_number": 1,
          "day_name": "Push",
          "muscle_group": "Chest - Pectoralis",
          "difficulty_level": "Intermediate",
          "ulc": "Upper",
          "movement_pattern": "Push",
          "modality": "Free Weights",
          "joint": "Multi-Joint (Compound)"
        }
      ]
    },
    {
      "id": 6,
      "day_number": 2,
      "day_name": "Day 2",
      "split_name": "Pull",
      "title": "Day 2: Pull",
      "focus": "Back, biceps, lower back",
      "is_rest_day": false,
      "order": 2,
      "exercise_count": 10,
      "exercises": [...]
    },
    {
      "id": 7,
      "day_number": 3,
      "day_name": "Day 3",
      "split_name": "Legs",
      "title": "Day 3: Legs",
      "focus": "Quadriceps, hamstrings, calves, core",
      "is_rest_day": false,
      "order": 3,
      "exercise_count": 10,
      "exercises": [...]
    },
    {
      "id": 8,
      "day_number": 4,
      "day_name": "Day 4",
      "split_name": "Rest",
      "title": "Day 4: Rest / Recovery",
      "focus": "Recovery; repeat cycle or take additional rest days",
      "is_rest_day": true,
      "rest_note": "Recovery; repeat cycle or take additional rest days",
      "order": 4,
      "exercise_count": 0,
      "exercises": []
    }
  ]
}
```

---

### Endpoint 2.3: Retrieve Schedule Only
- **Method:** `GET`
- **URL:** `/api/v1/plans/{id}/schedule/` or `/api/plans/{id}/schedule/`
- **Auth:** Public / Optional Bearer

Returns array of 4 days: Day 1 Push, Day 2 Pull, Day 3 Legs, Day 4 Rest.

---

### Endpoint 2.4: Retrieve Selected Day Exercises & Instructions
- **Method:** `GET`
- **URL:** `/api/v1/plans/{id}/days/{day}/` or `/api/plans/{id}/days/{day}/`
- **Parameters:** `{day}` can be `1`, `2`, `3`, `4` or `push`, `pull`, `legs`, `rest`.

#### Response (200 OK)
```json
{
  "id": 5,
  "day_number": 1,
  "day_name": "Day 1",
  "split_name": "Push",
  "title": "Day 1: Push",
  "focus": "Chest, shoulders, triceps",
  "is_rest_day": false,
  "rest_note": "",
  "exercise_count": 10,
  "exercises": [
    {
      "id": 181,
      "order": 1,
      "title": "Alternating Dumbbell Bench Press",
      "subtitle": "Chest - Pectoralis • Free Weights",
      "target_muscles": ["Chest - Pectoralis", "Upper Body"],
      "description": "Push movement targeting Chest - Pectoralis. Modality: Free Weights. Mechanics: Multi-Joint (Compound).",
      "time_seconds": 45,
      "time_display": "45s",
      "workout_id": 41,
      "image": "https://res.cloudinary.com/...",
      "day_number": 1,
      "day_name": "Push",
      "muscle_group": "Chest - Pectoralis",
      "difficulty_level": "Intermediate",
      "ulc": "Upper",
      "movement_pattern": "Push",
      "modality": "Free Weights",
      "joint": "Multi-Joint (Compound)"
    }
  ],
  "plan_id": 61,
  "plan_title": "Resistance Training - Full Body Split Program",
  "plan_location": "gym"
}
```

---

## 3. Workout Session Tracking & Direct Recording

Use this to record workouts completed in the app (either from a bespoke plan day or custom exercises).

### Endpoint 3.1: Record Completed Workout Session
- **Method:** `POST`
- **URL:** `/api/v1/workout-sessions/record/` or `/api/workout-sessions/record/`
- **Auth:** `Bearer <token>` (Required)

#### Request Body
```json
{
  "plan_id": 61,
  "workout_day": "Day 1: Push",
  "day_number": 1,
  "workout_date": "2026-11-01",
  "duration_minutes": 45,
  "calories_burned": 280,
  "note": "Completed all push sets, felt strong on bench.",
  "exercises": [
    {
      "workout_id": 41,
      "custom_title": "Alternating Dumbbell Bench Press",
      "note": "Felt good",
      "sets": [
        {
          "set_number": 1,
          "weight_kg": 20.0,
          "reps": 12,
          "is_completed": true
        },
        {
          "set_number": 2,
          "weight_kg": 22.5,
          "reps": 10,
          "is_completed": true
        },
        {
          "set_number": 3,
          "weight_kg": 25.0,
          "reps": 8,
          "is_completed": true
        }
      ]
    }
  ]
}
```

#### Response (201 Created)
```json
{
  "session_id": 14,
  "id": 14,
  "title": "Resistance Training - Full Body Split Program - Day 1: Push",
  "status": "completed",
  "has_active_session": false,
  "plan_id": 61,
  "plan_title": "Resistance Training - Full Body Split Program",
  "workout_day": "Day 1: Push",
  "day_number": 1,
  "workout_date": "2026-11-01",
  "started_at": "2026-11-01T04:35:00Z",
  "completed_at": "2026-11-01T05:20:00Z",
  "duration_seconds": 2700,
  "elapsed_seconds": 2700,
  "timer_display": "45:00",
  "calories_burned": 280,
  "total_volume": 665.0,
  "total_volume_display": "665 kg",
  "total_sets": 3,
  "exercise_count": 1,
  "muscle_groups": ["Chest - Pectoralis", "Upper Body"],
  "note": "Completed all push sets, felt strong on bench.",
  "total_exercises": 1,
  "completed_exercises": 1,
  "exercises": [...]
}
```

**Automated Server-Side Operations on Record:**
1. Calculates **total volume lifted** = $\sum (\text{weight\_kg} \times \text{reps})$.
2. Automatically increments user streak (`current_streak`, `longest_streak`).
3. Automatically evaluates and creates/updates Personal Records (PRs / 1RM).
4. Persists historical workout log for analytics.

---

## 4. Workout Progress Summary APIs

Designed specifically for the mobile app's **My Progress** screen and for **sharing progress summaries** (single day, week, month, or custom date range).

### Endpoint 4.1: Progress Summary Endpoint
- **Method:** `GET`
- **URL:** `/api/v1/progress/summary/` or `/api/progress/summary/`
- **Auth:** `Bearer <token>` (Required)

#### Query Parameters
| Parameter | Type | Example | Description |
|---|---|---|---|
| `date` | String | `2026-11-01` | Single-day summary for a specific date |
| `period` | String | `today`, `1w`, `1m`, `3m`, `custom` | Preset period (`1w` is 7 days, default) |
| `start_date` | String | `2026-10-25` | Custom range start date (`YYYY-MM-DD`) |
| `end_date` | String | `2026-11-01` | Custom range end date (`YYYY-MM-DD`) |

---

### Example A: Single Day Summary (`GET /api/v1/progress/summary/?date=2026-11-01`)
```json
{
  "period": "today",
  "is_single_day": true,
  "date_range": {
    "start_date": "2026-11-01",
    "end_date": "2026-11-01",
    "display": "Nov 01, 2026"
  },
  "workout_date": "2026-11-01",
  "summary": {
    "workouts_count": 1,
    "exercise_count": 6,
    "total_duration_minutes": 45,
    "total_volume_kg": 3200.0,
    "total_volume_display": "3,200 kg",
    "total_sets": 18,
    "calories_burned": 280,
    "muscle_groups_trained": ["Chest", "Shoulders", "Triceps"]
  },
  "daily_breakdown": [
    {
      "date": "2026-11-01",
      "day_name": "Sunday",
      "workouts_count": 1,
      "duration_minutes": 45,
      "volume_kg": 3200.0,
      "sets": 18,
      "exercise_count": 6,
      "muscle_groups": ["Chest", "Shoulders", "Triceps"]
    }
  ],
  "sessions": [
    {
      "session_id": 14,
      "title": "Resistance Training - Full Body Split Program - Day 1: Push",
      "status": "completed",
      "workout_day": "Day 1: Push",
      "total_volume": 3200.0,
      "total_volume_display": "3,200 kg",
      "total_sets": 18,
      "duration_seconds": 2700,
      "calories_burned": 280
    }
  ],
  "best_streak_days": 5
}
```

---

### Example B: Weekly Summary (`GET /api/v1/progress/summary/?period=1w`)
```json
{
  "period": "1w",
  "is_single_day": false,
  "date_range": {
    "start_date": "2026-10-26",
    "end_date": "2026-11-01",
    "display": "Oct 26 - Nov 01, 2026"
  },
  "workout_date": null,
  "summary": {
    "workouts_count": 4,
    "exercise_count": 24,
    "total_duration_minutes": 180,
    "total_volume_kg": 12800.0,
    "total_volume_display": "12,800 kg",
    "total_sets": 72,
    "calories_burned": 1150,
    "muscle_groups_trained": ["Back", "Biceps", "Chest", "Core", "Legs", "Shoulders", "Triceps"]
  },
  "daily_breakdown": [
    {
      "date": "2026-10-26",
      "day_name": "Monday",
      "workouts_count": 1,
      "duration_minutes": 45,
      "volume_kg": 3200.0,
      "sets": 18,
      "exercise_count": 6,
      "muscle_groups": ["Chest", "Triceps"]
    },
    {
      "date": "2026-10-27",
      "day_name": "Tuesday",
      "workouts_count": 1,
      "duration_minutes": 45,
      "volume_kg": 3400.0,
      "sets": 18,
      "exercise_count": 6,
      "muscle_groups": ["Back", "Biceps"]
    },
    {
      "date": "2026-10-28",
      "day_name": "Wednesday",
      "workouts_count": 0,
      "duration_minutes": 0,
      "volume_kg": 0.0,
      "sets": 0,
      "exercise_count": 0,
      "muscle_groups": []
    }, ...
  ],
  "best_streak_days": 5
}
```

---

## 5. Subscription & Premium Entitlement Status

The backend enforces server-side verification of entitlements. The app should check `/api/subscriptions/status/` to determine whether the user is premium.

### Endpoint 5.1: Check Entitlement & Subscription Status
- **Method:** `GET`
- **URL:** `/api/subscriptions/status/` (or `/api/subscriptions/my-subscription/`)
- **Auth:** `Bearer <token>` (Required)

#### Response When Premium (200 OK)
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
    "id": 1,
    "status": "active",
    "billing_cycle": "yearly",
    "payment_source": "google_play",
    "plan": 1,
    "plan_title": "HYKX Pro",
    "plan_tier": "PRO",
    "plan_benefits": ["Bespoke Plans", "AI Scanner", "Advanced Analytics"],
    "is_valid": true,
    "started_at": "2026-10-15T10:00:00Z",
    "current_period_end": "2027-10-15T10:00:00Z",
    "cancel_at_period_end": false,
    "canceled_at": null,
    "created_at": "2026-10-15T10:00:00Z"
  }
}
```

#### Response When Free User (200 OK)
```json
{
  "is_premium": false,
  "has_subscription": false,
  "status": "none",
  "is_valid": false,
  "message": "No active subscription found.",
  "entitlements": [
    "free_workouts",
    "basic_catalog"
  ],
  "subscription": null
}
```

---

### Endpoint 5.2: In-App Purchase Verification

#### A. Google Play (Android)
- **Method:** `POST`
- **URL:** `/api/subscriptions/google-play/verify/`
- **Auth:** `Bearer <token>`
```json
{
  "product_id": "hykx_pro_monthly",
  "purchase_token": "<google_play_purchase_token>",
  "order_id": "GPA.3321-4455-6677-88990",
  "billing_cycle": "monthly"
}
```

#### B. Apple App Store (iOS)
- **Method:** `POST`
- **URL:** `/api/subscriptions/apple/verify/`
- **Auth:** `Bearer <token>`
```json
{
  "product_id": "hykx_pro_yearly",
  "original_transaction_id": "<apple_original_transaction_id>",
  "transaction_id": "<apple_transaction_id>",
  "billing_cycle": "yearly"
}
```

---

## 6. How to Re-Run Bespoke Data Ingestion (Server Admin)

To reload or re-sync all bespoke plans and exercises from `resources/bespoke_workout_plans.xlsx`:
```bash
docker exec hawiisaac_web_server python manage.py load_bespoke_plans
```
This management command is completely idempotent and safe to re-run anytime. It links all 4 schedule days, sets rest days, and maps exercise metadata cleanly.

