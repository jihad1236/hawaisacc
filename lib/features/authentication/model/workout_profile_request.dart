class WorkoutProfileRequest {
  const WorkoutProfileRequest({
    required this.goal,
    required this.level,
    required this.location,
    required this.workoutDays,
    required this.sessionDuration,
  });

  final String goal;
  final String level;
  final String location;
  final int workoutDays;
  final int sessionDuration;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'goal': goal,
      'level': level,
      'location': location,
      'workout_days': workoutDays,
      'session_duration': sessionDuration,
    };
  }
}
