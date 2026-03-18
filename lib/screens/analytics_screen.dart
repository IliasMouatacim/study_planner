// lib/screens/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/pomodoro_session.dart';
import '../utils/theme.dart';
import '../widgets/stats_card.dart';
import '../widgets/custom_app_bar.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DatabaseService _db = DatabaseService();
  String _selectedPeriod = 'week'; // 'day', 'week', 'month'
  
  @override
  Widget build(BuildContext context) {
    // Import CustomAppBar
    // ignore: unused_import
    return Scaffold(
      extendBody: true,
      appBar: const CustomAppBar(
        title: 'Analytics',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.07),
              Theme.of(context).colorScheme.secondary.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern period selector
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildPeriodSelector(),
                ),
                const SizedBox(height: 20),
                // Stats cards
                _buildStatsCards(),
                const SizedBox(height: 12),
                // Streak cards
                _buildStreakCards(),
                const SizedBox(height: 20),
                // Daily chart
                _buildDailyChart(),
                const SizedBox(height: 20),
                // Tasks time breakdown
                _buildTasksTimeBreakdown(),
                const SizedBox(height: 20),
                // Recent sessions
                _buildRecentSessions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton('day', 'Aujourd\'hui'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPeriodButton('week', 'Semaine'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPeriodButton('month', 'Mois'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          foregroundColor: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          elevation: isSelected ? 3 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        child: Text(label),
      ),
    );
  }
  
  Widget _buildStatsCards() {
    final sessions = _getSessionsForPeriod();
    final workSessions = sessions.where((s) => s.isWorkSession && s.completed).toList();
    
    final totalTime = workSessions.fold<int>(
      0,
      (sum, session) => sum + session.duration,
    );
    
    final completedPomodoros = workSessions.length;
    
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'Temps Total',
            value: _formatDuration(totalTime),
            icon: FontAwesomeIcons.clock,
            color: AppTheme.infoColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            title: 'Pomodoros',
            value: completedPomodoros.toString(),
            icon: FontAwesomeIcons.circleCheck,
            color: AppTheme.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCards() {
    final currentStreak = _db.getCurrentStreak();
    final longestStreak = _db.getLongestStreak();
    
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'Streak actuel',
            value: '$currentStreak jours',
            icon: FontAwesomeIcons.fire,
            color: currentStreak > 0 ? Colors.orange : Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            title: 'Meilleur streak',
            value: '$longestStreak jours',
            icon: FontAwesomeIcons.trophy,
            color: AppTheme.accentColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDailyChart() {
    final sessions = _getSessionsForPeriod();
    final Map<DateTime, int> dailyTime = {};
    
    // Group sessions by day
    for (var session in sessions) {
      if (session.isWorkSession && session.completed) {
        final date = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );
        dailyTime[date] = (dailyTime[date] ?? 0) + session.duration;
      }
    }
    
    // Prepare chart data
    final sortedDates = dailyTime.keys.toList()..sort();
    final List<FlSpot> spots = [];
    
    if (sortedDates.isEmpty) {
      return _buildEmptyChart();
    }
    
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final minutes = (dailyTime[date]! / 60).toDouble();
      spots.add(FlSpot(i.toDouble(), minutes));
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(FontAwesomeIcons.chartLine, size: 18),
                SizedBox(width: 8),
                Text(
                  'Temps d\'étude par jour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 30,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}m',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedDates.length) {
                            return const Text('');
                          }
                          final date = sortedDates[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withAlpha(26),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(FontAwesomeIcons.chartLine, size: 18),
                SizedBox(width: 8),
                Text(
                  'Temps d\'étude par jour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Icon(
              FontAwesomeIcons.chartLine,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée disponible',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTasksTimeBreakdown() {
    final tasks = _db.getAllTasks();
    final tasksWithTime = tasks.where((t) => t.totalTimeSpent > 0).toList()
      ..sort((a, b) => b.totalTimeSpent.compareTo(a.totalTimeSpent));
    
    if (tasksWithTime.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(FontAwesomeIcons.chartPie, size: 18),
                SizedBox(width: 8),
                Text(
                  'Temps par tâche',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...tasksWithTime.take(5).map((task) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            task.formattedTimeSpent,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentSessions() {
    final sessions = _db.getAllSessions()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(FontAwesomeIcons.clockRotateLeft, size: 18),
                SizedBox(width: 8),
                Text(
                  'Sessions récentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sessions.take(10).map((session) {
              final task = session.taskId != null
                  ? _db.getTask(session.taskId!)
                  : null;
              
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  session.isWorkSession
                      ? FontAwesomeIcons.briefcase
                      : FontAwesomeIcons.mugSaucer,
                  color: session.isWorkSession
                      ? AppTheme.workColor
                      : AppTheme.shortBreakColor,
                  size: 20,
                ),
                title: Text(
                  task?.title ?? 'Pas de tâche',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(session.startTime),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  session.formattedDuration,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  List<PomodoroSession> _getSessionsForPeriod() {
    final now = DateTime.now();
    DateTime start;
    
    switch (_selectedPeriod) {
      case 'day':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'month':
        start = DateTime(now.year, now.month, 1);
        break;
      default:
        start = DateTime(now.year, now.month, now.day);
    }
    
    return _db.getSessionsByDateRange(start, now.add(const Duration(days: 1)));
  }
  
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}