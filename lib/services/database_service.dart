// lib/services/database_service.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/pomodoro_session.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Boxes
  late Box<Task> tasksBox;
  late Box<PomodoroSession> sessionsBox;
  late Box settingsBox;
  late Box notesBox;

  // Initialize Hive
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PomodoroSessionAdapter());
    }

    // Open boxes
    tasksBox = await Hive.openBox<Task>(AppConstants.tasksBoxName);
    sessionsBox =
        await Hive.openBox<PomodoroSession>(AppConstants.sessionsBoxName);
    settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
    notesBox = await Hive.openBox(AppConstants.notesBoxName);

    // Initialize default settings if not exist
    await _initializeDefaultSettings();

    unawaited(syncWithCloud());
  }

  CollectionReference<Map<String, dynamic>> _userCollection(String name) {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Cannot sync without a signed-in user.');
    }
    return _firestore.collection('users').doc(user.uid).collection(name);
  }

  DocumentReference<Map<String, dynamic>> _userPreferencesDoc(String docId) {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Cannot sync without a signed-in user.');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('preferences')
        .doc(docId);
  }

  Future<void> syncWithCloud() async {
    if (_auth.currentUser == null) return;

    try {
      await _pushLocalTasks();
      await _pushLocalNotes();
      await _pushLocalSessions();
      await _pushLocalStudentTodos();
      await _pushLocalPreferences();

      await _pullCloudTasks();
      await _pullCloudNotes();
      await _pullCloudSessions();
      await _pullCloudStudentTodos();
      await _pullCloudPreferences();
    } catch (e) {
      debugPrint('Cloud sync failed: $e');
    }
  }

  Future<void> _pushLocalTasks() async {
    final tasksRef = _userCollection('tasks');
    for (final task in tasksBox.values) {
      await tasksRef.doc(task.id).set(task.toMap(), SetOptions(merge: true));
    }
  }

  Future<void> _pullCloudTasks() async {
    final snapshot = await _userCollection('tasks').get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['id'] == null || (data['id'] as String).isEmpty) {
        data['id'] = doc.id;
      }
      final task = Task.fromMap(data);
      await tasksBox.put(task.id, task);
    }
  }

  Future<void> _pushLocalNotes() async {
    final notesRef = _userCollection('notes');
    for (final key in notesBox.keys) {
      final raw = notesBox.get(key);
      if (raw is! Map) continue;
      final note = _normalizeNoteData(
        (raw['id'] ?? key).toString(),
        Map<String, dynamic>.from(raw),
      );
      await notesRef
          .doc(note['id'].toString())
          .set(note, SetOptions(merge: true));
    }
  }

  Future<void> _pullCloudNotes() async {
    final snapshot = await _userCollection('notes').get();
    for (final doc in snapshot.docs) {
      final note = _normalizeNoteData(doc.id, doc.data());
      await notesBox.put(note['id'], note);
    }
  }

  Future<void> _pushLocalSessions() async {
    final sessionsRef = _userCollection('sessions');
    for (final session in sessionsBox.values) {
      await sessionsRef
          .doc(session.id)
          .set(session.toMap(), SetOptions(merge: true));
    }
  }

  Future<void> _pullCloudSessions() async {
    final snapshot = await _userCollection('sessions').get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['id'] == null || (data['id'] as String).isEmpty) {
        data['id'] = doc.id;
      }
      final session = PomodoroSession.fromMap(data);
      await sessionsBox.put(session.id, session);
    }
  }

  Future<void> _pushLocalStudentTodos() async {
    final localItems = getStudentTodoItems();
    final todosRef = _userCollection('student_todos');
    final snapshot = await todosRef.get();

    final localIds = localItems.map((item) => item['id'].toString()).toSet();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      if (!localIds.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    for (final item in localItems) {
      final id = item['id'].toString();
      batch.set(todosRef.doc(id), item, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> _pullCloudStudentTodos() async {
    final snapshot = await _userCollection('student_todos').get();
    final items = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      items.add(_normalizeStudentTodoData(doc.id, doc.data()));
    }

    items.sort((a, b) {
      final aDate = DateTime.tryParse(a['createdAt'].toString()) ?? DateTime(2000);
      final bDate = DateTime.tryParse(b['createdAt'].toString()) ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    await settingsBox.put(AppConstants.studentTodoItemsKey, items);
  }

  Future<void> _pushLocalPreferences() async {
    await _pushLocalPomodoroPreferences();
    await _pushLocalThemePreferences();
  }

  Future<void> _pullCloudPreferences() async {
    await _pullCloudPomodoroPreferences();
    await _pullCloudThemePreferences();
  }

  Future<void> _pushLocalPomodoroPreferences() async {
    final payload = <String, dynamic>{
      'workDuration': getWorkDuration(),
      'shortBreak': getShortBreakDuration(),
      'longBreak': getLongBreakDuration(),
      'notificationsEnabled': isNotificationEnabled(),
      'soundEnabled': isSoundEnabled(),
    };

    await _userPreferencesDoc('pomodoro').set(payload, SetOptions(merge: true));
  }

  Future<void> _pullCloudPomodoroPreferences() async {
    final snapshot = await _userPreferencesDoc('pomodoro').get();
    if (!snapshot.exists) return;

    final raw = snapshot.data();
    if (raw == null) return;

    final workDuration = raw['workDuration'];
    if (workDuration is num) {
      await settingsBox.put(AppConstants.workDurationKey, workDuration.round());
    }

    final shortBreak = raw['shortBreak'];
    if (shortBreak is num) {
      await settingsBox.put(AppConstants.shortBreakKey, shortBreak.round());
    }

    final longBreak = raw['longBreak'];
    if (longBreak is num) {
      await settingsBox.put(AppConstants.longBreakKey, longBreak.round());
    }

    final notificationsEnabled = raw['notificationsEnabled'];
    if (notificationsEnabled is bool) {
      await settingsBox.put(
          AppConstants.notificationEnabledKey, notificationsEnabled);
    }

    final soundEnabled = raw['soundEnabled'];
    if (soundEnabled is bool) {
      await settingsBox.put(AppConstants.soundEnabledKey, soundEnabled);
    }
  }

  Future<void> _pushLocalThemePreferences() async {
    final payload = <String, dynamic>{
      'darkMode': getSetting<bool>(AppConstants.themeDarkModeKey) ?? false,
      'primaryColor': getSetting<int>(AppConstants.themePrimaryColorKey),
      'cardStyle': getSetting<String>(AppConstants.themeCardShapeKey) ?? 'Rounded',
      'appBarStyle':
          getSetting<String>(AppConstants.themeAppBarStyleKey) ?? 'Classic',
      'fontScale': getSetting<double>(AppConstants.themeFontScaleKey) ?? 1.0,
      'density':
          getSetting<String>(AppConstants.themeUiDensityKey) ?? 'Comfortable',
      'secondaryColor': getSetting<int>(AppConstants.themeSecondaryColorKey),
      'appBarColor': getSetting<int>(AppConstants.themeAppBarColorKey),
      'appBarShape': getSetting<String>(AppConstants.themeAppBarShapeKey),
    };

    await _userPreferencesDoc('theme').set(payload, SetOptions(merge: true));
  }

  Future<void> _pullCloudThemePreferences() async {
    final snapshot = await _userPreferencesDoc('theme').get();
    if (!snapshot.exists) return;

    final raw = snapshot.data();
    if (raw == null) return;

    final darkMode = raw['darkMode'];
    if (darkMode is bool) {
      await settingsBox.put(AppConstants.themeDarkModeKey, darkMode);
    }

    final primaryColor = raw['primaryColor'];
    if (primaryColor is num) {
      await settingsBox.put(AppConstants.themePrimaryColorKey, primaryColor.toInt());
    }

    final cardStyle = raw['cardStyle'];
    if (cardStyle is String) {
      await settingsBox.put(AppConstants.themeCardShapeKey, cardStyle);
    }

    final appBarStyle = raw['appBarStyle'];
    if (appBarStyle is String) {
      await settingsBox.put(AppConstants.themeAppBarStyleKey, appBarStyle);
    }

    final fontScale = raw['fontScale'];
    if (fontScale is num) {
      await settingsBox.put(AppConstants.themeFontScaleKey, fontScale.toDouble());
    }

    final density = raw['density'];
    if (density is String) {
      await settingsBox.put(AppConstants.themeUiDensityKey, density);
    }

    final secondaryColor = raw['secondaryColor'];
    if (secondaryColor is num) {
      await settingsBox.put(
          AppConstants.themeSecondaryColorKey, secondaryColor.toInt());
    }

    final appBarColor = raw['appBarColor'];
    if (appBarColor is num) {
      await settingsBox.put(AppConstants.themeAppBarColorKey, appBarColor.toInt());
    }

    final appBarShape = raw['appBarShape'];
    if (appBarShape is String) {
      await settingsBox.put(AppConstants.themeAppBarShapeKey, appBarShape);
    }
  }

  Future<void> _runCloudOp(Future<void> Function() operation,
      {required String context}) async {
    try {
      await operation();
    } catch (e) {
      debugPrint('Cloud operation failed ($context): $e');
    }
  }

  Map<String, dynamic> _normalizeNoteData(
      String docId, Map<String, dynamic> raw) {
    String asIsoString(dynamic value, String fallback) {
      if (value is Timestamp) return value.toDate().toIso8601String();
      if (value is DateTime) return value.toIso8601String();
      if (value is String && value.isNotEmpty) return value;
      return fallback;
    }

    final now = DateTime.now().toIso8601String();
    final note = <String, dynamic>{
      'id': (raw['id'] ?? docId).toString(),
      'title': (raw['title'] ?? '').toString(),
      'content': (raw['content'] ?? '').toString(),
      'isPinned': raw['isPinned'] == true || raw['pinned'] == true,
      'createdAt': asIsoString(raw['createdAt'], now),
      'updatedAt': asIsoString(raw['updatedAt'], now),
    };

    final color = raw['color'];
    if (color is int) {
      note['color'] = color;
    } else if (color is String) {
      note['color'] = int.tryParse(color) ?? 0xFF2C2C2E;
    } else {
      note['color'] = 0xFF2C2C2E;
    }

    return note;
  }

  Map<String, dynamic> _normalizeStudentTodoData(
      String docId, Map<String, dynamic> raw) {
    final now = DateTime.now().toIso8601String();
    final createdAt = raw['createdAt'];

    return {
      'id': (raw['id'] ?? docId).toString(),
      'text': (raw['text'] ?? '').toString(),
      'isCompleted': raw['isCompleted'] == true || raw['done'] == true,
      'createdAt': createdAt is Timestamp
          ? createdAt.toDate().toIso8601String()
          : (createdAt?.toString() ?? now),
    };
  }

  Future<void> _initializeDefaultSettings() async {
    if (!settingsBox.containsKey(AppConstants.workDurationKey)) {
      await settingsBox.put(
          AppConstants.workDurationKey, AppConstants.defaultWorkDuration);
    }
    if (!settingsBox.containsKey(AppConstants.shortBreakKey)) {
      await settingsBox.put(
          AppConstants.shortBreakKey, AppConstants.defaultShortBreakDuration);
    }
    if (!settingsBox.containsKey(AppConstants.longBreakKey)) {
      await settingsBox.put(
          AppConstants.longBreakKey, AppConstants.defaultLongBreakDuration);
    }
    if (!settingsBox.containsKey(AppConstants.soundEnabledKey)) {
      await settingsBox.put(AppConstants.soundEnabledKey, true);
    }
    if (!settingsBox.containsKey(AppConstants.notificationEnabledKey)) {
      await settingsBox.put(AppConstants.notificationEnabledKey, true);
    }
  }

  // Task CRUD Operations
  Future<void> addTask(Task task) async {
    await tasksBox.put(task.id, task);
    if (_auth.currentUser != null) {
      await _runCloudOp(
        () => _userCollection('tasks')
            .doc(task.id)
            .set(task.toMap(), SetOptions(merge: true)),
        context: 'addTask',
      );
    }
  }

  Future<void> updateTask(Task task) async {
    await tasksBox.put(task.id, task);
    if (_auth.currentUser != null) {
      await _runCloudOp(
        () => _userCollection('tasks')
            .doc(task.id)
            .set(task.toMap(), SetOptions(merge: true)),
        context: 'updateTask',
      );
    }
  }

  Future<void> deleteTask(String taskId) async {
    await tasksBox.delete(taskId);
    if (_auth.currentUser != null) {
      await _runCloudOp(
        () => _userCollection('tasks').doc(taskId).delete(),
        context: 'deleteTask',
      );
    }
  }

  Task? getTask(String taskId) {
    return tasksBox.get(taskId);
  }

  List<Task> getAllTasks() {
    return tasksBox.values.toList();
  }

  List<Task> getTasksByStatus(String status) {
    return tasksBox.values.where((task) => task.status == status).toList();
  }

  // Session Operations
  Future<void> addSession(PomodoroSession session) async {
    await sessionsBox.put(session.id, session);
    if (_auth.currentUser != null) {
      await _runCloudOp(
        () => _userCollection('sessions')
            .doc(session.id)
            .set(session.toMap(), SetOptions(merge: true)),
        context: 'addSession',
      );
    }
  }

  List<PomodoroSession> getAllSessions() {
    return sessionsBox.values.toList();
  }

  List<PomodoroSession> getSessionsByDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return sessionsBox.values.where((session) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      return sessionDate == targetDate;
    }).toList();
  }

  List<PomodoroSession> getSessionsByDateRange(DateTime start, DateTime end) {
    return sessionsBox.values.where((session) {
      return session.startTime.isAfter(start) &&
          session.startTime.isBefore(end);
    }).toList();
  }

  List<PomodoroSession> getSessionsByTaskId(String taskId) {
    return sessionsBox.values
        .where((session) => session.taskId == taskId)
        .toList();
  }

  // Settings Operations
  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);

    if (_auth.currentUser == null) return;

    if (key == AppConstants.studentTodoItemsKey) {
      await _runCloudOp(
        _pushLocalStudentTodos,
        context: 'saveSetting.studentTodos',
      );
      return;
    }

    if (AppConstants.pomodoroPreferenceKeys.contains(key)) {
      await _runCloudOp(
        _pushLocalPomodoroPreferences,
        context: 'saveSetting.pomodoroPreferences',
      );
      return;
    }

    if (AppConstants.themePreferenceKeys.contains(key)) {
      await _runCloudOp(
        _pushLocalThemePreferences,
        context: 'saveSetting.themePreferences',
      );
    }
  }

  T? getSetting<T>(String key) {
    return settingsBox.get(key) as T?;
  }

  int getWorkDuration() {
    return settingsBox.get(AppConstants.workDurationKey,
        defaultValue: AppConstants.defaultWorkDuration);
  }

  int getShortBreakDuration() {
    return settingsBox.get(AppConstants.shortBreakKey,
        defaultValue: AppConstants.defaultShortBreakDuration);
  }

  int getLongBreakDuration() {
    return settingsBox.get(AppConstants.longBreakKey,
        defaultValue: AppConstants.defaultLongBreakDuration);
  }

  bool isSoundEnabled() {
    return settingsBox.get(AppConstants.soundEnabledKey, defaultValue: true);
  }

  bool isNotificationEnabled() {
    return settingsBox.get(AppConstants.notificationEnabledKey,
        defaultValue: true);
  }

  // Notes Operations
  List<String> getEnglishNotes() {
    final stored = settingsBox
        .get(AppConstants.englishNotesKey, defaultValue: <dynamic>[]);
    if (stored is List) {
      return stored.map((item) => item.toString()).toList();
    }
    return [];
  }

  Future<void> saveEnglishNotes(List<String> notes) async {
    await settingsBox.put(AppConstants.englishNotesKey, notes);
  }

  List<Map<String, dynamic>> getEnglishNoteItems() {
    final stored = settingsBox
        .get(AppConstants.englishNotesKey, defaultValue: <dynamic>[]);
    final now = DateTime.now().toIso8601String();

    if (stored is List) {
      final items = <Map<String, dynamic>>[];

      for (var i = 0; i < stored.length; i++) {
        final entry = stored[i];
        if (entry is Map) {
          final text = (entry['text'] ?? '').toString().trim();
          if (text.isEmpty) continue;
          items.add({
            'id': (entry['id'] ?? '${DateTime.now().millisecondsSinceEpoch}_$i')
                .toString(),
            'text': text,
            'isPinned': entry['isPinned'] == true || entry['pinned'] == true,
            'createdAt': (entry['createdAt'] ?? now).toString(),
            'updatedAt':
                (entry['updatedAt'] ?? entry['createdAt'] ?? now).toString(),
          });
        } else {
          final text = entry.toString().trim();
          if (text.isEmpty) continue;
          items.add({
            'id': '${DateTime.now().millisecondsSinceEpoch}_$i',
            'text': text,
            'isPinned': false,
            'createdAt': now,
            'updatedAt': now,
          });
        }
      }

      return items;
    }

    return [];
  }

  Future<void> saveEnglishNoteItems(List<Map<String, dynamic>> notes) async {
    await settingsBox.put(AppConstants.englishNotesKey, notes);
  }

  // Analytics helpers
  int getTotalStudyTime() {
    return sessionsBox.values
        .where((s) => s.isWorkSession && s.completed)
        .fold(0, (sum, session) => sum + session.duration);
  }

  int getCompletedPomodoros() {
    return sessionsBox.values
        .where((s) => s.isWorkSession && s.completed)
        .length;
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    await tasksBox.clear();
    await sessionsBox.clear();
    await notesBox.clear();
  }

  // ─── Notes CRUD ───
  List<Map<String, dynamic>> getAllNotes() {
    final items = <Map<String, dynamic>>[];
    for (final key in notesBox.keys) {
      final raw = notesBox.get(key);
      if (raw is Map) {
        items.add(Map<String, dynamic>.from(raw));
      }
    }
    // Sort: isPinned first, then by updatedAt descending
    items.sort((a, b) {
      final aPinned = a['isPinned'] == true || a['pinned'] == true ? 0 : 1;
      final bPinned = b['isPinned'] == true || b['pinned'] == true ? 0 : 1;
      if (aPinned != bPinned) return aPinned.compareTo(bPinned);
      final aDate = DateTime.tryParse(a['updatedAt'] ?? '') ?? DateTime(2000);
      final bDate = DateTime.tryParse(b['updatedAt'] ?? '') ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });
    return items;
  }

  List<Map<String, dynamic>> getStudentTodoItems() {
    final stored = settingsBox
        .get(AppConstants.studentTodoItemsKey, defaultValue: <dynamic>[]);
    final items = <Map<String, dynamic>>[];

    if (stored is! List) return items;

    final now = DateTime.now().toIso8601String();
    for (var i = 0; i < stored.length; i++) {
      final entry = stored[i];
      if (entry is! Map) continue;
      final item = _normalizeStudentTodoData(
        (entry['id'] ?? '${DateTime.now().millisecondsSinceEpoch}_$i').toString(),
        Map<String, dynamic>.from(entry),
      );
      if (item['text'].toString().trim().isEmpty) continue;
      item['createdAt'] = item['createdAt'].toString().isEmpty ? now : item['createdAt'];
      items.add(item);
    }

    return items;
  }

  Future<void> saveStudentTodoItems(List<Map<String, dynamic>> items) async {
    final normalized = items
        .map((e) => _normalizeStudentTodoData(
              (e['id'] ?? '').toString(),
              Map<String, dynamic>.from(e),
            ))
        .where((e) => e['text'].toString().trim().isNotEmpty)
        .toList();

    await saveSetting(AppConstants.studentTodoItemsKey, normalized);
  }

  Future<void> addNote(Map<String, dynamic> note) async {
    final normalized = _normalizeNoteData(note['id']?.toString() ?? '', note);
    await notesBox.put(normalized['id'], normalized);
    if (_auth.currentUser != null) {
      await _runCloudOp(
        () => _userCollection('notes')
            .doc(normalized['id'].toString())
            .set(normalized, SetOptions(merge: true)),
        context: 'addNote',
      );
    }
  }

  Future<void> updateNote(Map<String, dynamic> note) async {
    final normalized = _normalizeNoteData(note['id']?.toString() ?? '', note);
    await notesBox.put(normalized['id'], normalized);
    if (_auth.currentUser != null) {
      await _runCloudOp(
        () => _userCollection('notes')
            .doc(normalized['id'].toString())
            .set(normalized, SetOptions(merge: true)),
        context: 'updateNote',
      );
    }
  }

  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
    if (_auth.currentUser != null) {
      await _runCloudOp(
        () => _userCollection('notes').doc(id).delete(),
        context: 'deleteNote',
      );
    }
  }

  Map<String, dynamic>? getNote(String id) {
    final raw = notesBox.get(id);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  // ─── CSV Export ───
  String exportTasksToCSV() {
    final buffer = StringBuffer();
    buffer.writeln(
        'ID,Title,Description,Priority,Category,Status,DueDate,CreatedAt,CompletedAt,TimeSpent(s)');
    for (final task in getAllTasks()) {
      buffer.writeln(
        '"${task.id}","${_escapeCsv(task.title)}","${_escapeCsv(task.description ?? '')}",${task.priority},"${_escapeCsv(task.category)}","${task.status}","${task.dueDate?.toIso8601String() ?? ''}","${task.createdAt.toIso8601String()}","${task.completedAt?.toIso8601String() ?? ''}",${task.totalTimeSpent}',
      );
    }
    return buffer.toString();
  }

  String exportSessionsToCSV() {
    final buffer = StringBuffer();
    buffer.writeln(
        'ID,TaskID,SessionType,Duration(s),StartTime,EndTime,Completed');
    for (final s in getAllSessions()) {
      buffer.writeln(
        '"${s.id}","${s.taskId ?? ''}","${s.sessionType}",${s.duration},"${s.startTime.toIso8601String()}","${s.endTime.toIso8601String()}",${s.completed}',
      );
    }
    return buffer.toString();
  }

  String _escapeCsv(String value) {
    return value.replaceAll('"', '""');
  }

  // ─── Streak ───
  int getCurrentStreak() {
    final sessions = getAllSessions()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    if (sessions.isEmpty) return 0;

    final workSessions =
        sessions.where((s) => s.isWorkSession && s.completed).toList();
    if (workSessions.isEmpty) return 0;

    final Set<String> studyDays = {};
    for (final s in workSessions) {
      final d = s.startTime;
      studyDays.add('${d.year}-${d.month}-${d.day}');
    }

    int streak = 0;
    DateTime day = DateTime.now();
    // Check if today has sessions; if not, start from yesterday
    final todayKey = '${day.year}-${day.month}-${day.day}';
    if (!studyDays.contains(todayKey)) {
      day = day.subtract(const Duration(days: 1));
    }

    while (true) {
      final key = '${day.year}-${day.month}-${day.day}';
      if (studyDays.contains(key)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int getLongestStreak() {
    final sessions = getAllSessions();
    if (sessions.isEmpty) return 0;

    final workSessions =
        sessions.where((s) => s.isWorkSession && s.completed).toList();
    if (workSessions.isEmpty) return 0;

    final Set<DateTime> studyDays = {};
    for (final s in workSessions) {
      final d = s.startTime;
      studyDays.add(DateTime(d.year, d.month, d.day));
    }

    final sorted = studyDays.toList()..sort();
    int longest = 1;
    int current = 1;

    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }
}
