// lib/models/pomodoro_session.dart

import 'package:hive/hive.dart';

part 'pomodoro_session.g.dart';

@HiveType(typeId: 1)
class PomodoroSession extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String? taskId; // Associated task ID (optional)
  
  @HiveField(2)
  String sessionType; // 'work', 'short_break', 'long_break'
  
  @HiveField(3)
  int duration; // in seconds
  
  @HiveField(4)
  DateTime startTime;
  
  @HiveField(5)
  DateTime endTime;
  
  @HiveField(6)
  bool completed; // Whether the session was completed or skipped
  
  PomodoroSession({
    required this.id,
    this.taskId,
    required this.sessionType,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.completed = true,
  });
  
  factory PomodoroSession.fromMap(Map<String, dynamic> map) {
    return PomodoroSession(
      id: map['id'] ?? '',
      taskId: map['taskId'],
      sessionType: map['sessionType'] ?? 'work',
      duration: map['duration'] ?? 0,
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      completed: map['completed'] ?? true,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'sessionType': sessionType,
      'duration': duration,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'completed': completed,
    };
  }
  
  // Get date without time component
  DateTime get dateOnly {
    return DateTime(startTime.year, startTime.month, startTime.day);
  }
  
  // Check if session is a work session
  bool get isWorkSession => sessionType == 'work';
  
  // Format duration
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}min ${seconds}s';
  }
}