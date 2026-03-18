// lib/models/task.dart

import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  int priority; // 0: Low, 1: Medium, 2: High
  
  @HiveField(4)
  DateTime? dueDate;
  
  @HiveField(5)
  String status; // 'todo', 'in_progress', 'completed'
  
  @HiveField(6)
  DateTime createdAt;
  
  @HiveField(7)
  DateTime? completedAt;
  
  @HiveField(8)
  int totalTimeSpent; // in seconds

  @HiveField(9)
  String category; // task category

  @HiveField(10)
  List<String> subtasks; // subtask texts

  @HiveField(11)
  List<bool> subtasksDone; // subtask completion states
  
  Task({
    required this.id,
    required this.title,
    this.description,
    this.priority = 1,
    this.dueDate,
    this.status = 'todo',
    required this.createdAt,
    this.completedAt,
    this.totalTimeSpent = 0,
    this.category = 'General',
    List<String>? subtasks,
    List<bool>? subtasksDone,
  })  : subtasks = subtasks ?? [],
        subtasksDone = subtasksDone ?? [];
  
  // Factory constructor to create Task from Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      priority: map['priority'] ?? 1,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      status: map['status'] ?? 'todo',
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      totalTimeSpent: map['totalTimeSpent'] ?? 0,
      category: map['category'] ?? 'General',
      subtasks: (map['subtasks'] as List?)?.cast<String>() ?? [],
      subtasksDone: (map['subtasksDone'] as List?)?.cast<bool>() ?? [],
    );
  }
  
  // Convert Task to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'totalTimeSpent': totalTimeSpent,
      'category': category,
      'subtasks': subtasks,
      'subtasksDone': subtasksDone,
    };
  }
  
  // Copy with method for updating tasks
  Task copyWith({
    String? id,
    String? title,
    String? description,
    int? priority,
    DateTime? dueDate,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
    int? totalTimeSpent,
    String? category,
    List<String>? subtasks,
    List<bool>? subtasksDone,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      category: category ?? this.category,
      subtasks: subtasks ?? List.from(this.subtasks),
      subtasksDone: subtasksDone ?? List.from(this.subtasksDone),
    );
  }
  
  bool get isOverdue {
    if (dueDate == null || status == 'completed') return false;
    final endOfDueDay = DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
      23,
      59,
      59,
    );
    return DateTime.now().isAfter(endOfDueDay);
  }

  bool get isDueToday {
    if (dueDate == null || status == 'completed') return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  int? get daysUntilDue {
    if (dueDate == null || status == 'completed') return null;
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.difference(startOfToday).inDays;
  }
  
  String get formattedTimeSpent {
    final hours = totalTimeSpent ~/ 3600;
    final minutes = (totalTimeSpent % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}
