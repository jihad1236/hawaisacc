class WorkoutProfile {
  const WorkoutProfile({
    this.goal,
    this.level,
    this.location,
    this.workoutDays,
    this.sessionDuration,
    this.isCompleted = false,
  });

  final String? goal;
  final String? level;
  final String? location;
  final int? workoutDays;
  final int? sessionDuration;
  final bool isCompleted;

  factory WorkoutProfile.fromJson(Map<String, dynamic> json) {
    return WorkoutProfile(
      goal: json['goal']?.toString(),
      level: json['level']?.toString(),
      location: json['location']?.toString(),
      workoutDays: json['workout_days'] != null
          ? int.tryParse(json['workout_days'].toString())
          : null,
      sessionDuration: json['session_duration'] != null
          ? int.tryParse(json['session_duration'].toString())
          : null,
      isCompleted: json['is_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'goal': goal,
      'level': level,
      'location': location,
      'workout_days': workoutDays,
      'session_duration': sessionDuration,
      'is_completed': isCompleted,
    };
  }

  WorkoutProfile copyWith({
    String? goal,
    String? level,
    String? location,
    int? workoutDays,
    int? sessionDuration,
    bool? isCompleted,
  }) {
    return WorkoutProfile(
      goal: goal ?? this.goal,
      level: level ?? this.level,
      location: location ?? this.location,
      workoutDays: workoutDays ?? this.workoutDays,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
