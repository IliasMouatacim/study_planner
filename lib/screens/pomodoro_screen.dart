// lib/screens/pomodoro_screen.dart - FINAL FIX

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/pomodoro_service.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/custom_app_bar.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    // Import CustomAppBar
    // ignore: unused_import
    return Scaffold(
      extendBody: true,
      appBar: CustomAppBar(
        title: 'Timer',
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.arrowsRotate),
            onPressed: () {
              final pomodoroService = context.read<PomodoroService>();
              if (!pomodoroService.isRunning) {
                pomodoroService.reset();
              }
            },
            tooltip: 'Réinitialiser',
          ),
        ],
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
        child: Consumer<PomodoroService>(
          builder: (context, pomodoroService, child) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Phase indicator
                    _buildPhaseIndicator(pomodoroService),
                    const SizedBox(height: 28),
                    // Glass card for timer
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
                      child: Column(
                        children: [
                          _buildCircularTimer(pomodoroService),
                          const SizedBox(height: 24),
                          _buildControlButtons(pomodoroService),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Glass card for cycles
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: _buildCyclesCounter(pomodoroService),
                    ),
                    const SizedBox(height: 20),
                    // Glass card for task selector
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: _buildTaskSelector(pomodoroService),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildPhaseIndicator(PomodoroService service) {
    Color phaseColor;
    IconData phaseIcon;
    
    switch (service.currentPhase) {
      case AppConstants.stateWork:
        phaseColor = AppTheme.workColor;
        phaseIcon = FontAwesomeIcons.briefcase;
        break;
      case AppConstants.stateShortBreak:
        phaseColor = AppTheme.shortBreakColor;
        phaseIcon = FontAwesomeIcons.mugSaucer;
        break;
      case AppConstants.stateLongBreak:
        phaseColor = AppTheme.longBreakColor;
        phaseIcon = FontAwesomeIcons.umbrellaBeach;
        break;
      default:
        phaseColor = Colors.grey;
        phaseIcon = FontAwesomeIcons.clock;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: phaseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: phaseColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(phaseIcon, color: phaseColor, size: 20),
          const SizedBox(width: 12),
          Text(
            service.currentPhaseLabel,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: phaseColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCircularTimer(PomodoroService service) {
    Color phaseColor;
    
    switch (service.currentPhase) {
      case AppConstants.stateWork:
        phaseColor = AppTheme.workColor;
        break;
      case AppConstants.stateShortBreak:
        phaseColor = AppTheme.shortBreakColor;
        break;
      case AppConstants.stateLongBreak:
        phaseColor = AppTheme.longBreakColor;
        break;
      default:
        phaseColor = Colors.grey;
    }
    
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress circle
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: service.progress,
              strokeWidth: 12,
              backgroundColor: phaseColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
            ),
          ),
          
          // Time display
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                service.formattedTime,
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: phaseColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (service.isRunning)
                Text(
                  'En cours...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                )
              else if (service.isPaused)
                Text(
                  'En pause',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCyclesCounter(PomodoroService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FontAwesomeIcons.repeat, size: 20),
            const SizedBox(width: 12),
            Text(
              'Cycles complétés: ${service.completedCycles}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${service.completedCycles % AppConstants.cyclesBeforeLongBreak}/${AppConstants.cyclesBeforeLongBreak})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTaskSelector(PomodoroService service) {
    final tasks = _db.getTasksByStatus(AppConstants.statusTodo) +
                  _db.getTasksByStatus(AppConstants.statusInProgress);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(FontAwesomeIcons.bullseye, size: 18),
                SizedBox(width: 8),
                Text(
                  'Tâche actuelle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              const Text(
                'Aucune tâche disponible',
                style: TextStyle(color: Colors.grey),
              )
            else
              DropdownButtonFormField<String?>(
                initialValue: service.currentTask?.id,
                decoration: const InputDecoration(
                  hintText: 'Sélectionner une tâche',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                isExpanded: true, // FIXED: Added this to make dropdown work properly
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Aucune tâche sélectionnée'),
                  ),
                  ...tasks.map((task) {
                    return DropdownMenuItem<String?>(
                      value: task.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppConstants.priorityColors[task.priority],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible( // FIXED: Changed from Expanded to Flexible
                            child: Text(
                              task.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: service.isRunning
                    ? null
                    : (String? value) {
                        if (value == null) {
                          service.setCurrentTask(null);
                        } else {
                          final task = tasks.firstWhere(
                            (t) => t.id == value,
                          );
                          service.setCurrentTask(task);
                        }
                      },
              ),
            if (service.currentTask != null) ...[
              const SizedBox(height: 8),
              Text(
                'Temps passé: ${service.currentTask!.formattedTimeSpent}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildControlButtons(PomodoroService service) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip button
        if (service.isRunning || service.isPaused)
          ElevatedButton.icon(
            onPressed: service.skipPhase,
            icon: const Icon(FontAwesomeIcons.forward),
            label: const Text('Passer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        
        const SizedBox(width: 16),
        
        // Main control button
        ElevatedButton.icon(
          onPressed: () {
            if (service.isRunning) {
              service.pause();
            } else if (service.isPaused) {
              service.resume();
            } else {
              service.start();
            }
          },
          icon: Icon(
            service.isRunning
                ? FontAwesomeIcons.pause
                : FontAwesomeIcons.play,
            size: 20,
          ),
          label: Text(
            service.isRunning
                ? 'Pause'
                : (service.isPaused ? 'Reprendre' : 'Démarrer'),
            style: const TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            backgroundColor: service.isRunning
                ? Colors.orange
                : Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}