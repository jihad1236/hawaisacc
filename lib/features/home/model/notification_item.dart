import 'package:intl/intl.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final String? type;
  final String? link;
  final DateTime? createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.time = '',
    this.isRead = false,
    this.type,
    this.link,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? '';
    final message =
        (json['message'] ?? json['body'] ?? json['description'])?.toString() ??
        '';
    final isRead = json['is_read'] == true;
    final type = json['type']?.toString();
    final link = json['link']?.toString() ?? json['action_url']?.toString();
    final rawCreatedAt =
        json['created_at']?.toString() ?? json['createdAt']?.toString();
    final rawTime = json['time']?.toString() ?? '';
    final createdAt = DateTime.tryParse(rawCreatedAt ?? rawTime);

    return NotificationItem(
      id: id,
      title: title,
      message: message,
      time: rawTime.isNotEmpty ? rawTime : (rawCreatedAt ?? ''),
      isRead: isRead,
      type: type,
      link: link,
      createdAt: createdAt,
    );
  }

  String get notificationType => type ?? 'system';
  String get timeDisplay {
    final date = createdAt;
    if (date == null) return time;

    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(local.year, local.month, local.day);
    final dayDifference = today.difference(dateOnly).inDays;

    if (dayDifference == 0) {
      return 'Today, ${DateFormat('h:mm a').format(local)}';
    }
    if (dayDifference == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(local)}';
    }
    return DateFormat('MMM d, yyyy • h:mm a').format(local);
  }

  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;
      case 'title':
        return title;
      case 'message':
      case 'body':
      case 'description':
        return message;
      case 'time':
        return time;
      case 'is_read':
        return isRead;
      case 'type':
        return type;
      default:
        return null;
    }
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    bool? isRead,
    String? type,
    String? link,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      link: link ?? this.link,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time,
      'is_read': isRead,
      'type': type,
      'link': link,
    };
  }
}
