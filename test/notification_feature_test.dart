import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hawiisaac/features/home/model/notification_item.dart';

void main() {
  group('NotificationItem Tests', () {
    test('parses notification JSON accurately', () {
      const rawJson = '''
      {
        "id": "notif_123",
        "title": "Workout Reminder",
        "message": "Time for your afternoon stretch!",
        "time": "10:30 AM",
        "is_read": false,
        "type": "reminder"
      }
      ''';

      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      final item = NotificationItem.fromJson(map);

      expect(item.id, 'notif_123');
      expect(item.title, 'Workout Reminder');
      expect(item.message, 'Time for your afternoon stretch!');
      expect(item['title'], 'Workout Reminder');
      expect(item['message'], 'Time for your afternoon stretch!');
      expect(item.isRead, isFalse);
    });

    test('copyWith works correctly', () {
      const item = NotificationItem(
        id: '1',
        title: 'Title',
        message: 'Message',
        isRead: false,
      );

      final updated = item.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.id, '1');
    });
  });
}
