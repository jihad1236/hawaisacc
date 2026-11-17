# HYKX Workout Plans & Resistance Training Planner API Documentation

Complete specification for Workout Plans powered by the **Resistance Training Planner** (270+ exercises across all major muscle groups and difficulty levels).

---

## 1. Overview & Data Architecture

The HYKX Workout Plan system is seeded directly from the comprehensive **Resistance Training Planner** (`resources/resist_train_planner.xls`), containing **270 exercises** spanning all major human muscle groups, categorized into **41 curated routines** across difficulty tiers.

### Exercise Breakdown
- **Total Exercises**: 270 planner exercises (plus core Figma demo routines = 357 total exercises)
- **16 Major Muscle Groups**:
  - `Abdominals - Lower`
  - `Abdominals - Obliques`
  - `Abdominals - Total`
  - `Abdominals - Upper`
  - `Back - Lat.Dorsi/Rhomboids`
  - `Back - Latissimus Dorsi`
  - `Biceps`
  - `Calves - Gastrocnemius`
  - `Calves - Soleus`
  - `Chest - Pectoralis`
  - `Legs - Hamstrings`
  - `Legs - Quadriceps`
  - `Lower Back - Erector Spinae`
  - `Shoulders - Delts/Traps`
  - `Shoulders - Rotator Cuff`
  - `Triceps`
- **Difficulty Levels**:
  - `beginner` (Display: `BGN`)
  - `intermediate` (Display: `INT`)
  - `advanced` (Display: `ADV`)
- **Modalities**:
  - `Free Weights` (Dumbbells, Barbells, EZ-Curl bars)
  - `Cables` (Pulleys, high/low rows, cable presses)
  - `Machine` (Plate-loaded & selectorized pin machines)
- **Movement Mechanics**:
  - `Push`, `Pull`, and `Static`
  - `Multi-Joint (Compound)` and `Single-Joint (Isolation)`

---

## 2. API Endpoints Quick Reference

| Endpoint | Method | Auth Required | Description |
|---|---|---|---|
| `/api/plans/` | `GET` | No (Public) | List all plans with filters (level, goal, category, search, tab) |
| `/api/plans/<id>/` | `GET` | No (Public) | Get full plan details including complete array of exercises |
| `/api/plans/<id>/complete/` | `POST` | Yes (Bearer) | Mark plan as completed, record calories, and increment user streak |
| `/api/dashboard/plans/` | `GET` | No (Public) | Dashboard alias for plan list |
| `/api/dashboard/plans/<id>/` | `GET` | No (Public) | Dashboard alias for plan details |
| `/api/dashboard/for-you/plans/` | `GET` | No (Public) | Pre-filtered plans for "For You" dashboard tab |
| `/api/dashboard/browse/plans/` | `GET` | No (Public) | Pre-filtered plans for "Browse" dashboard tab |
| `/api/dashboard/trending/plans/` | `GET` | No (Public) | Trending plans for dashboard |
| `/api/trending/plans/` | `GET` | No (Public) | Direct trending plans list |
| `/api/admin/plans/` | `GET`, `POST` | Yes (Admin) | Admin list and create plans |
| `/api/admin/plans/<id>/` | `GET`, `PUT`, `PATCH`, `DELETE` | Yes (Admin) | Admin retrieve, update, and delete plans |

---

## 3. Endpoints Specification

### 3.1 List Workout Plans

Fetch all active workout plans with flexible search and filtering capabilities.

- **Method**: `GET`
- **URL**: `{{baseurl}}/api/plans/`
- **Headers**:
  ```http
  Authorization: Bearer <access_token>   # Optional
  ```

#### Query Parameters

| Parameter | Type | Allowed Values / Examples | Description |
|---|---|---|---|
| `level` | `string` | `beginner`, `intermediate`, `advanced` | Filter by user difficulty level |
| `goal` | `string` | `weight_loss`, `muscle_gain`, `endurance`, `strength` | Filter by target fitness goal |
| `location` | `string` | `gym`, `home`, `outdoor` | Filter by workout environment |
| `category` | `integer` | e.g. `14` (Strength & Weights) | Filter by category ID |
| `search` | `string` | e.g. `Chest`, `Triceps`, `Biceps`, `Squat` | Case-insensitive search on title, description, and equipment note |
| `tab` | `string` | `for-you`, `browse`, `trending` | Filter based on dashboard display tabs |

#### Sample Requests
```http
GET {{baseurl}}/api/plans/?level=beginner
GET {{baseurl}}/api/plans/?search=Chest
GET {{baseurl}}/api/plans/?tab=for-you&level=intermediate
GET {{baseurl}}/api/plans/?location=gym&goal=strength
```

#### Response `200 OK`
```json
[
  {
    "id": 58,
    "title": "Triceps - Beginner Routine",
    "description": "Curated Beginner resistance training routine targeting Triceps. Features 16 targeted exercises covering free weights & machines modalities.",
    "image": null,
    "goal": "strength",
    "location": "gym",
    "min_session_duration": 26,
    "max_session_duration": 46,
    "min_days_per_week": 3,
    "max_days_per_week": 4,
    "total_time_seconds": 2160,
    "duration_minutes": 36,
    "duration_display": "36 min",
    "level": "beginner",
    "level_display": "BGN",
    "estimated_calories": 252,
    "calories_burn": 252,
    "equipment_note": "Free Weights & Machines",
    "category": 14,
    "category_name": "Strength & Weights",
    "subtitle": "36 min • Strength & Weights • Beginner",
    "exercise_count": 16
  },
  {
    "id": 59,
    "title": "Legs - Quadriceps - Intermediate Routine",
    "description": "Curated Intermediate resistance training routine targeting Legs - Quadriceps. Features 12 targeted exercises covering free weights & machines modalities.",
    "image": null,
    "goal": "strength",
    "location": "gym",
    "min_session_duration": 25,
    "max_session_duration": 45,
    "min_days_per_week": 3,
    "max_days_per_week": 4,
    "total_time_seconds": 2100,
    "duration_minutes": 35,
    "duration_display": "35 min",
    "level": "intermediate",
    "level_display": "INT",
    "estimated_calories": 245,
    "calories_burn": 245,
    "equipment_note": "Free Weights & Machines",
    "category": 14,
    "category_name": "Strength & Weights",
    "subtitle": "35 min • Strength & Weights • Intermediate",
    "exercise_count": 12
  }
]
```

---

### 3.2 Get Workout Plan Details (with Exercise List)

Fetch a single plan with its complete, ordered list of exercises.

- **Method**: `GET`
- **URL**: `{{baseurl}}/api/plans/<id>/`
- **Headers**:
  ```http
  Authorization: Bearer <access_token>   # Optional
  ```

#### Response `200 OK`
```json
{
  "id": 58,
  "title": "Triceps - Beginner Routine",
  "description": "Curated Beginner resistance training routine targeting Triceps. Features 16 targeted exercises covering free weights & machines modalities.",
  "image": null,
  "goal": "strength",
  "location": "gym",
  "min_session_duration": 26,
  "max_session_duration": 46,
  "min_days_per_week": 3,
  "max_days_per_week": 4,
  "total_time_seconds": 2160,
  "duration_minutes": 36,
  "duration_display": "36 min",
  "level": "beginner",
  "level_display": "BGN",
  "estimated_calories": 252,
  "calories_burn": 252,
  "equipment_note": "Free Weights & Machines",
  "category": 14,
  "category_name": "Strength & Weights",
  "subtitle": "Free Weights & Machines • Strength & Weights • Beginner",
  "exercise_count": 16,
  "exercises": [
    {
      "id": 360,
      "order": 1,
      "title": "Assisted Dips",
      "subtitle": "Triceps • Free Weights",
      "target_muscles": [
        "Triceps",
        "Upper Body"
      ],
      "description": "Push movement targeting Triceps. Modality: Free Weights. Joint mechanics: Multi-Joint (Compound).",
      "time_seconds": 45,
      "time_display": "45s",
      "workout_id": null
    },
    {
      "id": 361,
      "order": 2,
      "title": "Machine Dips",
      "subtitle": "Triceps • Machine",
      "target_muscles": [
        "Triceps",
        "Upper Body"
      ],
      "description": "Push movement targeting Triceps. Modality: Machine. Joint mechanics: Multi-Joint (Compound).",
      "time_seconds": 45,
      "time_display": "45s",
      "workout_id": null
    },
    {
      "id": 362,
      "order": 3,
      "title": "Dumbbell Kickback",
      "subtitle": "Triceps • Free Weights",
      "target_muscles": [
        "Triceps",
        "Upper Body"
      ],
      "description": "Push movement targeting Triceps. Modality: Free Weights. Joint mechanics: Single-Joint (Isolation).",
      "time_seconds": 45,
      "time_display": "45s",
      "workout_id": null
    },
    {
      "id": 363,
      "order": 4,
      "title": "Kneeling Cable Triceps Extension",
      "subtitle": "Triceps • Cables",
      "target_muscles": [
        "Triceps",
        "Upper Body"
      ],
      "description": "Push movement targeting Triceps. Modality: Cables. Joint mechanics: Single-Joint (Isolation).",
      "time_seconds": 45,
      "time_display": "45s",
      "workout_id": null
    },
    {
      "id": 364,
      "order": 5,
      "title": "Lying Single Dumbbell Triceps Extension",
      "subtitle": "Triceps • Free Weights",
      "target_muscles": [
        "Triceps",
        "Upper Body"
      ],
      "description": "Push movement targeting Triceps. Modality: Free Weights. Joint mechanics: Single-Joint (Isolation).",
      "time_seconds": 45,
      "time_display": "45s",
      "workout_id": null
    },
    {
      "id": 375,
      "order": 16,
      "title": "V-Bar Tricep Pushdown",
      "subtitle": "Triceps • Cables",
      "target_muscles": [
        "Triceps",
        "Upper Body"
      ],
      "description": "Push movement targeting Triceps. Modality: Cables. Joint mechanics: Single-Joint (Isolation).",
      "time_seconds": 45,
      "time_display": "45s",
      "workout_id": null
    }
  ]
}
```

---

### 3.3 Complete a Workout Plan (Streak & Calorie Tracking)

When a user completes a plan routine on mobile, this records the workout completion, logs calories burned, and automatically increments the user's active streak.

- **Method**: `POST`
- **URL**: `{{baseurl}}/api/plans/<id>/complete/`
- **Headers**:
  ```http
  Authorization: Bearer <access_token>
  Content-Type: application/json
  ```
- **Request Body**:
  ```json
  {
    "calories_burned": 250
  }
  ```

#### Response `201 Created`
```json
{
  "id": 12,
  "plan": 58,
  "plan_title": "Triceps - Beginner Routine",
  "calories_burned": 250,
  "completed_at": "2026-10-15T10:45:00Z"
}
```

---

### 3.4 Dashboard Tab Integrations

For seamless integration with mobile tab screens:

#### For You Tab Plans
- **URL**: `{{baseurl}}/api/dashboard/for-you/plans/` or `{{baseurl}}/api/plans/?tab=for-you`
- **Description**: Returns recommended plans matched to the user's selected difficulty or primary goals.

#### Browse Tab Plans
- **URL**: `{{baseurl}}/api/dashboard/browse/plans/` or `{{baseurl}}/api/plans/?tab=browse`
- **Description**: Returns the comprehensive catalog of plans for exploration. Supports query parameters `?level=`, `?goal=`, `?search=`.

#### Trending Tab Plans
- **URL**: `{{baseurl}}/api/dashboard/trending/plans/` or `{{baseurl}}/api/trending/plans/`
- **Description**: Returns the top trending workout routines.

---

## 4. Postman Testing Guide

### Environment Variables
Configure in your Postman Environment:
- `baseurl`: `https://api.hykxapp.com` (Production) or `http://127.0.0.1:8000` (Local)
- `access_token`: `<your_jwt_access_token>`

### Postman Test Flow

1. **Get All Plans**:
   - `GET {{baseurl}}/api/plans/`
   - Test: Status is 200, returns array of plans.

2. **Filter by Muscle / Exercise Keyword**:
   - `GET {{baseurl}}/api/plans/?search=Chest`
   - Test: Returns routines specifically targeting Chest (e.g. `Chest - Pectoralis - Beginner Routine`, `Chest - Pectoralis - Intermediate Routine`, `Chest - Pectoralis - Advanced Routine`).

3. **Filter by Difficulty Level**:
   - `GET {{baseurl}}/api/plans/?level=intermediate`
   - Test: All returned plans have `"level": "intermediate"` and `"level_display": "INT"`.

4. **Get Specific Plan Details**:
   - `GET {{baseurl}}/api/plans/58/`
   - Test: Returns details with populated `exercises` array containing title, subtitle, target muscles, modality, and joint mechanics.

5. **Complete a Plan**:
   - `POST {{baseurl}}/api/plans/58/complete/`
   - Body: `{"calories_burned": 220}`
   - Test: Status is 201 Created, user streak is updated.

