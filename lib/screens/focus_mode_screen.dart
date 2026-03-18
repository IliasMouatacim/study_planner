import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../services/pomodoro_service.dart';
import '../widgets/custom_app_bar.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  bool _focusEnabled = false;
  bool _blockNotifications = true;
  bool _hideNavigation = true;
  bool _autoStartPomodoro = false;

  void _toggleFocusMode() {
    setState(() {
      _focusEnabled = !_focusEnabled;
    });

    if (_focusEnabled && _autoStartPomodoro) {
      final pomodoroService = context.read<PomodoroService>();
      if (pomodoroService.isIdle) {
        pomodoroService.start();
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _focusEnabled ? 'Mode Focus active !' : 'Mode Focus desactive',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const CustomAppBar(
        title: 'Focus Mode',
        showBack: true,
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
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Focus mode hero
            Center(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _focusEnabled
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.1),
                      border: Border.all(
                        color: _focusEnabled
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade400,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      _focusEnabled
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                      size: 48,
                      color: _focusEnabled
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _focusEnabled ? 'Focus Mode Active' : 'Focus Mode Off',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _focusEnabled
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _focusEnabled
                        ? 'Restez concentre sur votre travail !'
                        : 'Activez le mode focus pour minimiser les distractions',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Toggle button
            Center(
              child: ElevatedButton.icon(
                onPressed: _toggleFocusMode,
                icon: Icon(
                  _focusEnabled
                      ? FontAwesomeIcons.powerOff
                      : FontAwesomeIcons.bolt,
                ),
                label: Text(
                  _focusEnabled ? 'Desactiver' : 'Activer Focus Mode',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: _focusEnabled ? Colors.orange : null,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Options
            _glassCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Bloquer les notifications',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Masquer les notifications pendant le focus'),
                    secondary: const Icon(FontAwesomeIcons.bellSlash),
                    value: _blockNotifications,
                    onChanged: (val) => setState(() => _blockNotifications = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Masquer la navigation',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Cacher la barre de navigation'),
                    secondary: const Icon(FontAwesomeIcons.eyeSlash),
                    value: _hideNavigation,
                    onChanged: (val) => setState(() => _hideNavigation = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Auto-start Pomodoro',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Lancer automatiquement un pomodoro'),
                    secondary: const Icon(FontAwesomeIcons.play),
                    value: _autoStartPomodoro,
                    onChanged: (val) => setState(() => _autoStartPomodoro = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Current pomodoro status
            Consumer<PomodoroService>(
              builder: (context, service, _) {
                if (!_focusEnabled) return const SizedBox.shrink();
                return _glassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FontAwesomeIcons.clock, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              service.formattedTime,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          service.currentPhaseLabel,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!service.isRunning)
                              ElevatedButton.icon(
                                onPressed: service.isIdle ? service.start : service.resume,
                                icon: const Icon(FontAwesomeIcons.play, size: 14),
                                label: Text(service.isPaused ? 'Reprendre' : 'Demarrer'),
                              ),
                            if (service.isRunning)
                              ElevatedButton.icon(
                                onPressed: service.pause,
                                icon: const Icon(FontAwesomeIcons.pause, size: 14),
                                label: const Text('Pause'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
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
      child: child,
    );
  }
}
