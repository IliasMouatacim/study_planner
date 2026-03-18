// lib/services/pomodoro_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/pomodoro_session.dart';
import '../utils/constants.dart';
import 'database_service.dart';
import 'notification_service.dart';

enum TimerState { idle, running, paused }

class PomodoroService extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  
  // Timer state
  TimerState _timerState = TimerState.idle;
  String _currentPhase = AppConstants.stateWork;
  int _remainingSeconds = 0;
  int _completedCycles = 0;
  Task? _currentTask;
  
  // Session tracking
  DateTime? _sessionStartTime;
  
  Timer? _timer;
  
  // Getters
  TimerState get timerState => _timerState;
  String get currentPhase => _currentPhase;
  int get remainingSeconds => _remainingSeconds;
  int get completedCycles => _completedCycles;
  Task? get currentTask => _currentTask;
  
  bool get isRunning => _timerState == TimerState.running;
  bool get isPaused => _timerState == TimerState.paused;
  bool get isIdle => _timerState == TimerState.idle;
  bool get isWorkPhase => _currentPhase == AppConstants.stateWork;
  
  String get currentPhaseLabel => AppConstants.stateLabels[_currentPhase] ?? '';
  
  int get totalSeconds {
    switch (_currentPhase) {
      case AppConstants.stateWork:
        return _db.getWorkDuration() * 60;
      case AppConstants.stateShortBreak:
        return _db.getShortBreakDuration() * 60;
      case AppConstants.stateLongBreak:
        return _db.getLongBreakDuration() * 60;
      default:
        return 0;
    }
  }
  
  double get progress {
    if (totalSeconds == 0) return 0;
    return (_remainingSeconds / totalSeconds);
  }
  
  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Set current task
  void setCurrentTask(Task? task) {
    _currentTask = task;
    notifyListeners();
  }
  
  // Start timer
  void start() {
    if (_timerState == TimerState.idle) {
      _remainingSeconds = totalSeconds;
      _sessionStartTime = DateTime.now();
    }
    
    _timerState = TimerState.running;
    _startTimer();
    notifyListeners();
  }
  
  // Pause timer
  void pause() {
    _timerState = TimerState.paused;
    _timer?.cancel();
    notifyListeners();
  }
  
  // Resume timer
  void resume() {
    if (_timerState == TimerState.paused) {
      _timerState = TimerState.running;
      _startTimer();
      notifyListeners();
    }
  }
  
  // Reset timer
  void reset() {
    _timer?.cancel();
    _timerState = TimerState.idle;
    _remainingSeconds = totalSeconds;
    _sessionStartTime = null;
    notifyListeners();
  }
  
  // Skip to next phase
  void skipPhase() {
    _timer?.cancel();
    _saveSession(completed: false);
    _moveToNextPhase();
  }
  
  // Start the countdown
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
  }
  
  // Handle timer completion
  void _onTimerComplete() {
    _timer?.cancel();
    _timerState = TimerState.idle;
    
    // Save session
    _saveSession(completed: true);
    
    // Show notification
    _showCompletionNotification();
    
    // Move to next phase
    _moveToNextPhase();
  }
  
  void _moveToNextPhase() {
    if (_currentPhase == AppConstants.stateWork) {
      _completedCycles++;
      
      // Check if it's time for a long break
      if (_completedCycles % AppConstants.cyclesBeforeLongBreak == 0) {
        _currentPhase = AppConstants.stateLongBreak;
      } else {
        _currentPhase = AppConstants.stateShortBreak;
      }
    } else {
      // After any break, go back to work
      _currentPhase = AppConstants.stateWork;
    }
    
    _remainingSeconds = totalSeconds;
    _sessionStartTime = null;
    notifyListeners();
  }
  
  void _saveSession({required bool completed}) {
    if (_sessionStartTime == null) return;
    
    final session = PomodoroSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: _currentTask?.id,
      sessionType: _currentPhase,
      duration: totalSeconds - _remainingSeconds,
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      completed: completed,
    );
    
    _db.addSession(session);
    
    // Update task time spent
    if (_currentTask != null && _currentPhase == AppConstants.stateWork) {
      final updatedTask = _currentTask!.copyWith(
        totalTimeSpent: _currentTask!.totalTimeSpent + (totalSeconds - _remainingSeconds),
        status: _currentTask!.status == AppConstants.statusTodo 
            ? AppConstants.statusInProgress 
            : _currentTask!.status,
      );
      _db.updateTask(updatedTask);
      _currentTask = updatedTask;
    }
  }
  
  void _showCompletionNotification() {
    if (!_db.isNotificationEnabled()) return;
    
    switch (_currentPhase) {
      case AppConstants.stateWork:
        _notificationService.showWorkSessionComplete();
        break;
      case AppConstants.stateShortBreak:
        _notificationService.showBreakComplete();
        break;
      case AppConstants.stateLongBreak:
        _notificationService.showLongBreakComplete();
        break;
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}