# FitTrack Workout API Documentation (v1)

This document provides complete API reference, query parameters, request/response structures, and cURL / Dart examples for the FitTrack fitness application features implemented in the backend.

---

## Base URLs

- **Production**: `https://hykxapp.com/api/v1/`
- **Development**: `http://localhost:8000/api/v1/`
- **Backward-Compatible Unversioned Base**: `/api/` (all new endpoints are aliased to `/api/` as well as `/api/v1/`)

---

## Authentication

| Type | Header | Notes |
|---|---|---|
| JWT Bearer Token | `Authorization: Bearer <access_token>` | Required for recording workouts, progress history, and personalized metrics. Public endpoints allow guest access. |

---

## 1. Feature A: Home Screen API

Returns dynamic data configured for the mobile Home Screen:
- Dynamic greeting based on user profile and time of day (Morning/Afternoon/Evening)
- Quick action shortcuts (AI Equipment Scan, Browse Workouts, My Progress) with icons and target routes
- User workout statistics (streak, weekly workouts, calories burned, active minutes)
- Body region categories & carousel
- Featured / recommended workout cards
- Recent user activity / last completed sessions
- Server-driven bottom navigation configuration

### Endpoint
```http
GET /api/v1/home/
```
*Also accessible at: `GET /api/home/`*

### Permissions
- **Public / Optional Auth**: If authenticated, returns personalized user stats and recent activity; if unauthenticated, returns general greeting and 0 stats.

### Sample Request
```bash
curl -X GET "https://hykxapp.com/api/v1/home/" \
     -H "Authorization: Bearer <your_access_token>"
```

### Sample Response (200 OK)
```json
{
  "greeting": "Good Morning, AlexTrainer!",
  "subtitle": "Ready to crush your workout today?",
  "user_stats": {
    "streak_days": 5,
    "weekly_workouts": 3,
    "calories_burned": 640,
    "total_minutes": 85
  },
  "quick_actions": [
    {
      "id": "scan_equipment",
      "title": "Scan Equipment",
      "subtitle": "Scan machines with AI",
      "icon": "camera",
      "action_url": "/api/v1/equipment/scan/"
    },
    {
      "id": "browse_workouts",
      "title": "Browse Workouts",
      "subtitle": "Explore 250+ targeted exercises",
      "icon": "dumbbell",
      "action_url": "/api/v1/workouts/"
    },
    {
      "id": "my_progress",
      "title": "My Progress",
      "subtitle": "Track sets, reps & PRs",
      "icon": "chart",
      "action_url": "/api/v1/progress/"
    }
  ],
  "body_regions": [
    {"key": "all", "label": "All"},
    {"key": "upper_body", "label": "Upper Body"},
    {"key": "lower_body", "label": "Lower Body"},
    {"key": "core", "label": "Core"}
  ],
  "categories": [
    {
      "id": 1,
      "name": "Shoulders",
      "slug": "shoulders",
      "body_region": "upper_body",
      "icon": "body-shoulders",
      "image": null,
      "workout_count": 18
    },
    {
      "id": 2,
      "name": "Chest",
      "slug": "chest",
      "body_region": "upper_body",
      "icon": "body-chest",
      "image": null,
      "workout_count": 22
    },
    {
      "id": 3,
      "name": "Back",
      "slug": "back",
      "body_region": "upper_body",
      "icon": "body-back",
      "image": null,
      "workout_count": 25
    },
    {
      "id": 4,
      "name": "Arms",
      "slug": "arms",
      "body_region": "upper_body",
      "icon": "body-arms",
      "image": null,
      "workout_count": 20
    },
    {
      "id": 5,
      "name": "Legs",
      "slug": "legs",
      "body_region": "lower_body",
      "icon": "body-legs",
      "image": null,
      "workout_count": 30
    },
    {
      "id": 6,
      "name": "Core",
      "slug": "core",
      "body_region": "core",
      "icon": "body-core",
      "image": null,
      "workout_count": 15
    }
  ],
  "featured_workouts": [
    {
      "id": 14,
      "name": "Dumbbell Shoulder Press",
      "title": "Dumbbell Shoulder Press",
      "slug": "dumbbell-shoulder-press-14",
      "thumbnail_url": "https://res.cloudinary.com/.../workouts/shoulder_press.jpg",
      "image": "https://res.cloudinary.com/.../workouts/shoulder_press.jpg",
      "video": null,
      "category": {
        "id": 1,
        "name": "Shoulders",
        "slug": "shoulders",
        "body_region": "upper_body",
        "icon": "body-shoulders"
      },
      "body_part": "Shoulders",
      "body_region": "upper_body",
      "sets": "3-4",
      "reps": "10-12",
      "rest": "60s",
      "duration_minutes": 25,
      "calories": 180,
      "difficulty": "beginner",
      "level": "beginner",
      "target_muscles": ["Anterior Deltoids", "Lateral Deltoids", "Triceps"],
      "equipment_requirements": ["Dumbbell"],
      "equipment_names": ["Dumbbell"],
      "short_description": "Sit on bench with dumbbells at shoulder level, palms facing forward.",
      "is_bookmarked": false
    }
  ],
  "recent_activity": [
    {
      "id": 8,
      "workout_id": 14,
      "workout_title": "Dumbbell Shoulder Press",
      "workout_slug": "dumbbell-shoulder-press-14",
      "workout_image": "https://res.cloudinary.com/.../workouts/shoulder_press.jpg",
      "category_name": "Shoulders",
      "duration_minutes": 25,
      "calories_burned": 180,
      "note": "Felt great!",
      "logged_at": "2026-10-20T08:30:00Z",
      "sets": [
        {"id": 21, "kg": 20.0, "reps": 12, "is_checked": true},
        {"id": 22, "kg": 22.5, "reps": 10, "is_checked": true}
      ]
    }
  ],
  "bottom_navigation": [
    {"id": "home", "title": "Home", "icon": "home", "route": "/home", "is_default": true},
    {"id": "workouts", "title": "Workouts", "icon": "dumbbell", "route": "/workouts", "is_default": false},
    {"id": "scan", "title": "Scan", "icon": "camera", "route": "/scan", "is_default": false},
    {"id": "progress", "title": "Progress", "icon": "bar_chart", "route": "/progress", "is_default": false},
    {"id": "profile", "title": "Profile", "icon": "person", "route": "/profile", "is_default": false}
  ]
}
```

---

## 2. Feature B: Workout Categories & Body-Part Filters

Retrieves database-backed body-part categories with stable IDs, unique slugs, body region mappings, and active workout counts.

### Endpoint
```http
GET /api/v1/workouts/categories/
```
*Also accessible at: `GET /api/workouts/categories/`*

### Query Parameters

| Parameter | Type | Required | Description | Allowed Values |
|---|---|---|---|---|
| `region` or `body_region` | string | No | Filter categories by anatomy region | `all`, `upper_body`, `lower_body`, `core` |

### Sample Requests
```bash
# 1. Get all categories
curl -X GET "https://hykxapp.com/api/v1/workouts/categories/"

# 2. Filter upper body categories only
curl -X GET "https://hykxapp.com/api/v1/workouts/categories/?region=upper_body"

# 3. Filter lower body categories
curl -X GET "https://hykxapp.com/api/v1/workouts/categories/?region=lower_body"
```

### Sample Response (200 OK)
```json
[
  {
    "id": 1,
    "name": "Shoulders",
    "slug": "shoulders",
    "body_region": "upper_body",
    "icon": "body-shoulders",
    "image": null,
    "workout_count": 18
  },
  {
    "id": 2,
    "name": "Chest",
    "slug": "chest",
    "body_region": "upper_body",
    "icon": "body-chest",
    "image": null,
    "workout_count": 22
  },
  {
    "id": 3,
    "name": "Back",
    "slug": "back",
    "body_region": "upper_body",
    "icon": "body-back",
    "image": null,
    "workout_count": 25
  },
  {
    "id": 4,
    "name": "Arms",
    "slug": "arms",
    "body_region": "upper_body",
    "icon": "body-arms",
    "image": null,
    "workout_count": 20
  }
]
```

### Error Response (400 Bad Request)
```json
{
  "detail": "Invalid region 'legs'. Allowed options: all, core, lower_body, upper_body."
}
```

---

## 3. Feature C: Workout Listing & Filtering

Lists active workouts with filtering, keyword search, and pagination.

### Endpoint
```http
GET /api/v1/workouts/
```
*Also accessible at: `GET /api/workouts/`*

### Query Parameters

| Parameter | Type | Required | Description | Examples |
|---|---|---|---|---|
| `category` | string / int | No | Filter by category slug, category name, or category ID | `shoulders`, `chest`, `1` |
| `body_region` or `region` | string | No | Filter by anatomical region | `upper_body`, `lower_body`, `core` |
| `difficulty` or `level` | string | No | Filter by difficulty level (auto-maps `advanced` to `hard`) | `beginner`, `intermediate`, `hard`, `advanced` |
| `equipment` | string / int | No | Filter by equipment ID or equipment title | `1`, `dumbbell`, `barbell` |
| `search` or `q` | string | No | Text search across exercise title, description, or target muscles | `press`, `squat`, `deltoids` |
| `page` | int | No | 1-based page number (default: 1) | `1`, `2` |
| `page_size` | int | No | Page size between 1 and 100 (default: 10) | `10`, `20` |

### Sample Request
```bash
curl -X GET "https://hykxapp.com/api/v1/workouts/?category=shoulders&difficulty=beginner&page=1&page_size=10"
```

### Sample Response (200 OK)
```json
{
  "count": 18,
  "page": 1,
  "page_size": 10,
  "total_pages": 2,
  "next": "https://hykxapp.com/api/v1/workouts/?category=shoulders&difficulty=beginner&page=2&page_size=10",
  "previous": null,
  "results": [
    {
      "id": 14,
      "name": "Dumbbell Shoulder Press",
      "title": "Dumbbell Shoulder Press",
      "slug": "dumbbell-shoulder-press-14",
      "thumbnail_url": "https://res.cloudinary.com/.../workouts/shoulder_press.jpg",
      "image": "https://res.cloudinary.com/.../workouts/shoulder_press.jpg",
      "video": null,
      "category": {
        "id": 1,
        "name": "Shoulders",
        "slug": "shoulders",
        "body_region": "upper_body",
        "icon": "body-shoulders"
      },
      "body_part": "Shoulders",
      "body_region": "upper_body",
      "sets": "3-4",
      "reps": "10-12",
      "rest": "60s",
      "duration_minutes": 25,
      "calories": 180,
      "difficulty": "beginner",
      "level": "beginner",
      "target_muscles": ["Anterior Deltoids", "Lateral Deltoids", "Triceps"],
      "equipment_requirements": ["Dumbbell"],
      "equipment_names": ["Dumbbell"],
      "short_description": "Sit on bench with dumbbells at shoulder level, palms facing forward.",
      "is_bookmarked": false
    }
  ]
}
```

---

## 4. Feature D: Workout Details & Instructions

Fetches complete exercise details including ordered steps, equipment list, target muscle list, and related workout recommendations.

### Endpoint
```http
GET /api/v1/workouts/{id_or_slug}/
```

### Sample Request
```bash
curl -X GET "https://hykxapp.com/api/v1/workouts/14/"
```

### Sample Response (200 OK)
```json
{
  "id": 14,
  "name": "Dumbbell Shoulder Press",
  "title": "Dumbbell Shoulder Press",
  "slug": "dumbbell-shoulder-press-14",
  "thumbnail_url": "https://res.cloudinary.com/.../workouts/shoulder_press.jpg",
  "image": "https://res.cloudinary.com/.../workouts/shoulder_press.jpg",
  "video": null,
  "category": {
    "id": 1,
    "name": "Shoulders",
    "slug": "shoulders",
    "body_region": "upper_body",
    "icon": "body-shoulders"
  },
  "body_part": "Shoulders",
  "body_region": "upper_body",
  "sets": "3-4",
  "reps": "10-12",
  "rest": "60s",
  "duration_minutes": 25,
  "calories": 180,
  "difficulty": "beginner",
  "level": "beginner",
  "target_muscles": ["Anterior Deltoids", "Lateral Deltoids", "Triceps"],
  "equipment_requirements": ["Dumbbell"],
  "equipment_names": ["Dumbbell"],
  "short_description": "Sit on bench with dumbbells at shoulder level, palms facing forward.",
  "is_bookmarked": false,
  "description": "Sit on bench with dumbbells at shoulder level, palms facing forward.",
  "instructions": [
    {
      "id": 31,
      "order": 1,
      "step_number": 1,
      "description": "Sit on bench with dumbbells at shoulder level, palms facing forward.",
      "text": "Sit on bench with dumbbells at shoulder level, palms facing forward."
    },
    {
      "id": 32,
      "order": 2,
      "step_number": 2,
      "description": "Push weights overhead smoothly until arms are extended but not locked.",
      "text": "Push weights overhead smoothly until arms are extended but not locked."
    },
    {
      "id": 33,
      "order": 3,
      "step_number": 3,
      "description": "Lower slowly back to ear level and repeat.",
      "text": "Lower slowly back to ear level and repeat."
    }
  ],
  "required_equipment": [
    {
      "id": 2,
      "title": "Dumbbell",
      "description": "Adjustable dumbbells for free weight training",
      "image": null
    }
  ],
  "related_workouts": [
    {
      "id": 15,
      "name": "Lateral Dumbbell Raise",
      "title": "Lateral Dumbbell Raise",
      "slug": "lateral-dumbbell-raise-15",
      "thumbnail_url": null,
      "difficulty": "beginner",
      "sets": "3",
      "reps": "12-15"
    }
  ]
}
```

---

## 5. Feature E: AI Equipment Scanning Integration

Uploads an equipment photo captured by the user's mobile camera, runs Gemini Vision AI recognition, and returns matching exercises with fallback handling.

### Endpoint
```http
POST /api/v1/equipment/scan/
```
*Also accessible at: `POST /api/scan/`*

### Request Format
- Content-Type: `multipart/form-data`

| Form Field | Type | Required | Description |
|---|---|---|---|
| `image` (or `upload_image`) | File | Yes | Image binary (JPEG, JPG, PNG, WEBP) |

### Sample Request
```bash
curl -X POST "https://hykxapp.com/api/v1/equipment/scan/" \
     -H "Authorization: Bearer <your_access_token>" \
     -F "image=@/path/to/gym_machine.jpg"
```

### Response Scenarios

#### Scenario 1: Confident Match (Status 200 OK)
```json
{
  "scan_id": 42,
  "status": "completed",
  "match": {
    "equipment": {
      "id": 2,
      "title": "Dumbbell",
      "name": "Dumbbell",
      "description": "Adjustable dumbbells for free weight training",
      "image": "https://res.cloudinary.com/.../equipment/dumbbell.jpg"
    },
    "confidence": 0.94
  },
  "recommended_workouts": [
    {
      "id": 14,
      "name": "Dumbbell Shoulder Press",
      "difficulty": "beginner",
      "sets": "3-4",
      "reps": "10-12",
      "instructions": [...]
    }
  ],
  "recommended_exercises": [...]
}
```

#### Scenario 2: Low Confidence / No Database Match (Status 200 OK)
```json
{
  "scan_id": 43,
  "status": "no_match",
  "message": "No high-confidence match found for this equipment. Try scanning from another angle or select manually.",
  "detected_name": "elliptical trainer",
  "confidence": 0.42,
  "match": null,
  "suggested_equipment": [
    {"id": 1, "title": "Barbell", "image": null},
    {"id": 2, "title": "Dumbbell", "image": null}
  ],
  "recommended_workouts": [],
  "recommended_exercises": []
}
```

#### Scenario 3: Missing File / Bad Format (Status 400 Bad Request)
```json
{
  "detail": "Unsupported image format. Allowed formats: .jpg, .jpeg, .png, .webp."
}
```

---

## 6. Feature F: Workout Completion & Progress Tracking

### 6.1 Complete a Workout
Records workout execution, sets/reps lifted, updates streaks, and checks personal records (PRs).

### Endpoint
```http
POST /api/v1/workouts/{id}/complete/
```
*Also accessible at: `POST /api/workouts/{id}/complete/`*

### Permissions
- **Requires Authentication** (`Authorization: Bearer <token>`)

### Request Body (JSON)
```json
{
  "duration_minutes": 28,
  "calories_burned": 210,
  "note": "Great shoulder burn with 22.5kg",
  "completed_sets": [
    {
      "kg": 18.0,
      "reps": 12,
      "is_checked": true
    },
    {
      "kg": 20.0,
      "reps": 10,
      "is_checked": true
    },
    {
      "kg": 22.5,
      "reps": 8,
      "is_checked": true
    }
  ]
}
```

### Sample Response (201 Created)
```json
{
  "status": "success",
  "message": "Workout completed successfully!",
  "log": {
    "id": 12,
    "workout_id": 14,
    "workout_title": "Dumbbell Shoulder Press",
    "duration_minutes": 28,
    "calories_burned": 210,
    "sets_count": 3,
    "logged_at": "2026-10-20T09:45:00.123456Z"
  },
  "streak": {
    "current_streak": 6,
    "longest_streak": 12,
    "last_logged_date": "2026-10-20"
  }
}
```

---

### 6.2 Workout History
Retrieves the authenticated user's completion history with summary metrics and set breakdown.

### Endpoint
```http
GET /api/v1/progress/history/
```
*Also accessible at: `GET /api/progress/history/`*

### Permissions
- **Requires Authentication** (`Authorization: Bearer <token>`)

### Query Parameters
- `page`: int (default: 1)
- `page_size`: int (default: 10, max: 100)

### Sample Response (200 OK)
```json
{
  "summary": {
    "total_completed_workouts": 14,
    "total_minutes_trained": 420,
    "total_calories_burned": 3250,
    "current_streak": 6
  },
  "count": 14,
  "page": 1,
  "page_size": 10,
  "total_pages": 2,
  "next": "https://hykxapp.com/api/v1/progress/history/?page=2&page_size=10",
  "previous": null,
  "results": [
    {
      "id": 12,
      "workout_id": 14,
      "workout_title": "Dumbbell Shoulder Press",
      "workout_slug": "dumbbell-shoulder-press-14",
      "workout_image": "https://res.cloudinary.com/.../workouts/shoulder_press.jpg",
      "category_name": "Shoulders",
      "duration_minutes": 28,
      "calories_burned": 210,
      "note": "Great shoulder burn with 22.5kg",
      "logged_at": "2026-10-20T09:45:00.123456Z",
      "sets": [
        {"id": 41, "kg": 18.0, "reps": 12, "is_checked": true},
        {"id": 42, "kg": 20.0, "reps": 10, "is_checked": true},
        {"id": 43, "kg": 22.5, "reps": 8, "is_checked": true}
      ]
    }
  ]
}
```

---

### 6.3 Progress Analytics Overview
Retrieves volume chart data, personal records, and metrics over timeframes (`1w`, `1m`, `3m`, `all`).

### Endpoint
```http
GET /api/v1/progress/?period=1m
```
*Also accessible at: `GET /api/progress/?period=1m`*

### Permissions
- **Requires Authentication**

### Sample Response (200 OK)
```json
{
  "period": "1m",
  "date_range_display": "Sep 20 - Oct 20, 2026",
  "start_date": "2026-09-20",
  "end_date": "2026-10-20",
  "total_volume_lifted": 14250.0,
  "total_volume_display": "14,250 kg",
  "volume_unit": "kg",
  "volume_subtitle": "Total Weight Lifted",
  "volume_trend_direction": "up",
  "volume_delta_display": "+12.4%",
  "volume_chart": [
    {"date": "2026-09-25", "label": "Sep 25", "volume": 2800.0},
    {"date": "2026-10-02", "label": "Oct 02", "volume": 3450.0},
    {"date": "2026-10-09", "label": "Oct 09", "volume": 3900.0},
    {"date": "2026-10-16", "label": "Oct 16", "volume": 4100.0}
  ],
  "metrics": {
    "workouts": {
      "value": 18,
      "display": "18",
      "subtitle": "↑ 3 sessions",
      "delta": "+3",
      "trend_direction": "up"
    },
    "avg_duration": {
      "value_minutes": 38,
      "display": "38m",
      "subtitle": "→ Stable",
      "trend_direction": "stable"
    },
    "total_sets": {
      "value": 240,
      "display": "240",
      "subtitle": "↑ 24 sets",
      "delta": "+24",
      "trend_direction": "up"
    },
    "best_streak": {
      "value_days": 14,
      "display": "14d",
      "subtitle": "↑ New PR",
      "trend_direction": "up"
    }
  },
  "personal_records": [
    {
      "exercise_name": "Dumbbell Shoulder Press",
      "weight_kg": 22.5,
      "reps": 1,
      "achieved_date": "2026-10-20",
      "equipment_note": "Dumbbell",
      "delta_display": "New PR",
      "icon": "fitness"
    }
  ]
}
```

