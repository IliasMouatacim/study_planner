// lib/utils/constants.dart

import 'package:flutter/material.dart';

class AppConstants {
  // Pomodoro Durations (in minutes)
  static const int defaultWorkDuration = 25;
  static const int defaultShortBreakDuration = 5;
  static const int defaultLongBreakDuration = 15;
  static const int cyclesBeforeLongBreak = 4;
  
  // Database
  static const String tasksBoxName = 'tasks';
  static const String sessionsBoxName = 'sessions';
  static const String settingsBoxName = 'settings';
  
  // Settings Keys
  static const String workDurationKey = 'work_duration';
  static const String shortBreakKey = 'short_break_duration';
  static const String longBreakKey = 'long_break_duration';
  static const String soundEnabledKey = 'sound_enabled';
  static const String notificationEnabledKey = 'notification_enabled';
  static const String userNameKey = 'user_name';
  static const String englishNotesKey = 'english_notes';
  static const String themeDarkModeKey = 'theme_dark_mode';
  static const String themePrimaryColorKey = 'theme_primary_color';
  static const String themeSecondaryColorKey = 'theme_secondary_color';
  static const String themeAppBarColorKey = 'theme_app_bar_color';
  static const String themeFontScaleKey = 'theme_font_scale';
  static const String themeCardShapeKey = 'theme_card_shape';
  static const String themeAppBarStyleKey = 'theme_app_bar_style';
  static const String themeAppBarShapeKey = 'theme_app_bar_shape';
  static const String themeUiDensityKey = 'theme_ui_density';
  static const String studentTodoItemsKey = 'student_todo_items';

  static const List<String> pomodoroPreferenceKeys = [
    workDurationKey,
    shortBreakKey,
    longBreakKey,
    notificationEnabledKey,
    soundEnabledKey,
  ];

  static const List<String> themePreferenceKeys = [
    themeDarkModeKey,
    themePrimaryColorKey,
    themeSecondaryColorKey,
    themeAppBarColorKey,
    themeFontScaleKey,
    themeCardShapeKey,
    themeAppBarStyleKey,
    themeAppBarShapeKey,
    themeUiDensityKey,
  ];
  
  // Task Priorities
  static const Map<int, String> priorities = {
    0: 'Basse',
    1: 'Moyenne',
    2: 'Haute',
  };
  
  static const Map<int, Color> priorityColors = {
    0: Colors.green,
    1: Colors.orange,
    2: Colors.red,
  };
  
  // Task Status
  static const String statusTodo = 'todo';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  
  // Pomodoro States
  static const String stateWork = 'work';
  static const String stateShortBreak = 'short_break';
  static const String stateLongBreak = 'long_break';
  
  // State Labels
  static const Map<String, String> stateLabels = {
    stateWork: 'Travail',
    stateShortBreak: 'Pause Courte',
    stateLongBreak: 'Pause Longue',
  };
  
  // Task Categories
  static const List<String> taskCategories = [
    'General',
    'Math',
    'Science',
    'Languages',
    'History',
    'Literature',
    'Computer Science',
    'Art',
    'Music',
    'Sports',
    'Other',
  ];

  static const Map<String, IconData> categoryIcons = {};
  
  // Notes Box
  static const String notesBoxName = 'notes_items';
  
  // Notification IDs
  static const int pomodoroNotificationId = 0;
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
}
