import 'package:intl/intl.dart';

class CardioLogItem {
  final int id;
  final int workout;
  final String note;
  final int timeMinutes;
  final String distanceKm;
  final String speedKmh;
  final String incline;
  final DateTime? loggedAt;

  const CardioLogItem({
    required this.id,
    required this.workout,
    required this.note,
    required this.timeMinutes,
    required this.distanceKm,
    required this.speedKmh,
    required this.incline,
    this.loggedAt,
  });

  factory CardioLogItem.fromJson(Map<String, dynamic> json) {
    return CardioLogItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      workout: int.tryParse(json['workout']?.toString() ?? '') ?? 0,
      note: json['note']?.toString() ?? '',
      timeMinutes: int.tryParse(json['time_minutes']?.toString() ?? '') ?? 0,
      distanceKm: json['distance_km']?.toString() ?? '0.00',
      speedKmh: json['speed_kmh']?.toString() ?? '0.00',
      incline: json['incline']?.toString() ?? '0.0',
      loggedAt: DateTime.tryParse(json['logged_at']?.toString() ?? ''),
    );
  }

  String get displayTitle {
    if (note.trim().isNotEmpty) {
      return note.trim();
    }
    return 'Cardio Workout #$workout';
  }

  String get formattedDate {
    if (loggedAt == null) return 'Recent';

    final now = DateTime.now();
    final local = loggedAt!.toLocal();
    final difference = now.difference(local);

    if (difference.inDays == 0 && now.day == local.day) {
      return 'Today, ${DateFormat('h:mm a').format(local)}';
    } else if (difference.inDays <= 1 && now.day - local.day == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(local)}';
    } else {
      return DateFormat('MMM d, yyyy • h:mm a').format(local);
    }
  }

  String get timeLabel => '$timeMinutes min';
  String get distanceLabel => '$distanceKm km';
  String get speedLabel => '$speedKmh km/h';
  String get inclineLabel => '$incline°';
}
