import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/features/home/model/bookmarked_workout_model.dart';
import 'package:hawiisaac/features/home/model/dashboard_model.dart';

void main() {
  group('BookmarkedWorkoutItem Tests', () {
    test('parses live bookmark payload correctly', () {
      const rawJson = '''
      {
        "id": 36,
        "title": "Cable Machine Twist Down Up",
        "image": "https://example.com/cable.jpg",
        "video": null,
        "description": "Engages core and obliques.",
        "duration_minutes": 30,
        "duration_display": "30 min",
        "level": "intermediate",
        "level_display": "INTERMEDIATE",
        "flag": "gym",
        "category_name": "Core",
        "is_bookmarked": true,
        "equipment_names": ["Cable Machine"],
        "tags": ["core", "rotational"],
        "sets": "3",
        "reps": "12",
        "rest": "60s"
      }
      ''';

      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      final item = BookmarkedWorkoutItem.fromJson(map);

      expect(item.id, 36);
      expect(item.title, 'Cable Machine Twist Down Up');
      expect(item.image, 'https://example.com/cable.jpg');
      expect(item.durationMinutes, 30);
      expect(item.durationDisplay, '30 min');
      expect(item.level, 'intermediate');
      expect(item.levelDisplay, 'INTERMEDIATE');
      expect(item.flag, 'gym');
      expect(item.categoryName, 'Core');
      expect(item.isBookmarked, true);
      expect(item.equipmentNames, ['Cable Machine']);
      expect(item.tags, ['core', 'rotational']);
      expect(item.sets, '3');
      expect(item.reps, '12');
      expect(item.rest, '60s');
      expect(item.metaDisplay, '30 min • INTERMEDIATE • Cable Machine');
    });

    test('handles fallback and null values gracefully', () {
      const rawJson = '''
      {
        "id": "42",
        "title": "Bodyweight Squat",
        "duration_minutes": null,
        "level": "beginner",
        "is_bookmarked": true
      }
      ''';

      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      final item = BookmarkedWorkoutItem.fromJson(map);

      expect(item.id, 42);
      expect(item.title, 'Bodyweight Squat');
      expect(item.image, isNull);
      expect(item.durationMinutes, 0);
      expect(item.level, 'beginner');
      expect(item.levelDisplay, 'BEGINNER');
      expect(item.equipmentNames, isEmpty);
      expect(item.metaDisplay, 'BEGINNER');
    });

    test('verifies ApiEndpoint paths for bookmarks and expert tips', () {
      expect(ApiEndpoint.bookmarks, contains('/api/bookmarks/'));
      expect(ApiEndpoint.workoutBookmark(36), contains('/api/workouts/36/bookmark/'));
      expect(ApiEndpoint.expertTips(), contains('/api/expert-tips/'));
      expect(ApiEndpoint.expertTipById(5), contains('/api/expert-tips/5/'));
    });
  });

  group('DashboardExpertTip Tests', () {
    test('parses live expert-tips/5 payload accurately', () {
      const liveJson = '''
      {
          "id": 5,
          "title": "Cable Machine Angle Optimization",
          "content_type": "guide",
          "description": "How to adjust pulley heights to align tension with muscle fiber orientation.",
          "content_url": "",
          "image": null,
          "equipment_details": [
              {
                  "id": 9,
                  "title": "Cable Machine",
                  "name": "Cable Machine",
                  "image": "http://res.cloudinary.com/dnu0axtez/image/upload/v1/equipment/sctxqtzfnwuneyyzqtq8"
              }
          ],
          "created_at": "2026-09-20T10:19:13.760187Z"
      }
      ''';

      final map = jsonDecode(liveJson) as Map<String, dynamic>;
      final tip = DashboardExpertTip.fromJson(map);

      expect(tip.id, 5);
      expect(tip.title, 'Cable Machine Angle Optimization');
      expect(tip.contentType, 'guide');
      expect(tip.description, 'How to adjust pulley heights to align tension with muscle fiber orientation.');
      expect(tip.image, isNull);
      expect(tip.equipmentDetails.length, 1);
      expect(tip.equipmentDetails.first.id, 9);
      expect(tip.equipmentDetails.first.name, 'Cable Machine');
      expect(tip.equipmentDetails.first.image, contains('sctxqtzfnwuneyyzqtq8'));
      expect(tip.createdAt, '2026-09-20T10:19:13.760187Z');

      // Test copyWith
      final bookmarkedTip = tip.copyWith(isBookmarked: true);
      expect(bookmarkedTip.isBookmarked, true);
    });
  });
}

