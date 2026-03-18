// lib/screens/settings_screen.dart - UPDATED with auth

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  
  late int _workDuration;
  late int _shortBreakDuration;
  late int _longBreakDuration;
  late bool _soundEnabled;
  late bool _notificationEnabled;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  void _loadSettings() {
    setState(() {
      _workDuration = _db.getWorkDuration();
      _shortBreakDuration = _db.getShortBreakDuration();
      _longBreakDuration = _db.getLongBreakDuration();
      _soundEnabled = _db.isSoundEnabled();
      _notificationEnabled = _db.isNotificationEnabled();
      
      // Load user name from Firebase or database
      final userName = _authService.currentUser?.displayName ?? 
                       _db.getSetting<String>(AppConstants.userNameKey);
      _nameController.text = userName ?? '';
    });
  }
  
  Future<void> _saveSetting(String key, dynamic value) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    await _db.saveSetting(key, value);
    if (mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Paramètre enregistré'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _exportData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final tasksFile = File('${dir.path}/tasks_export.csv');
      final sessionsFile = File('${dir.path}/sessions_export.csv');
      
      await tasksFile.writeAsString(_db.exportTasksToCSV());
      await sessionsFile.writeAsString(_db.exportSessionsToCSV());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exporte vers ${dir.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await _authService.signOut();
      // Navigation will be handled by auth state listener
    }
  }

  @override
  Widget build(BuildContext context) {
    // Import CustomAppBar
    // ignore: unused_import
    return Scaffold(
      extendBody: true,
      appBar: const CustomAppBar(
        title: 'Réglages',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          children: [
            _glassCard(child: _buildProfileSection()),
            const SizedBox(height: 20),
            _glassCard(child: _buildPomodoroSettings()),
            const SizedBox(height: 20),
            _glassCard(child: _buildNotificationsSettings()),
            const SizedBox(height: 20),
            _glassCard(child: _buildDataManagement()),
            const SizedBox(height: 20),
            _glassCard(child: _buildAccountSection()),
            const SizedBox(height: 20),
            _glassCard(child: _buildAboutSection()),
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
  
  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(FontAwesomeIcons.user, size: 18),
                SizedBox(width: 8),
                Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Display email
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(FontAwesomeIcons.envelope),
              title: const Text('Email'),
              subtitle: Text(_authService.currentUser?.email ?? 'Non disponible'),
            ),
            
            const Divider(),
            
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Entrez votre nom',
                prefixIcon: Icon(FontAwesomeIcons.solidUser),
              ),
              onChanged: (value) {
                _saveSetting(AppConstants.userNameKey, value);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPomodoroSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(FontAwesomeIcons.clock, size: 18),
                SizedBox(width: 8),
                Text(
                  'Durées Pomodoro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Work duration
            _buildDurationSlider(
              label: 'Durée de travail',
              value: _workDuration,
              min: 15,
              max: 60,
              divisions: 9,
              onChanged: (value) {
                setState(() => _workDuration = value.round());
              },
              onChangeEnd: (value) {
                _saveSetting(AppConstants.workDurationKey, value.round());
              },
            ),
            const SizedBox(height: 16),
            
            // Short break duration
            _buildDurationSlider(
              label: 'Pause courte',
              value: _shortBreakDuration,
              min: 3,
              max: 10,
              divisions: 7,
              onChanged: (value) {
                setState(() => _shortBreakDuration = value.round());
              },
              onChangeEnd: (value) {
                _saveSetting(AppConstants.shortBreakKey, value.round());
              },
            ),
            const SizedBox(height: 16),
            
            // Long break duration
            _buildDurationSlider(
              label: 'Pause longue',
              value: _longBreakDuration,
              min: 15,
              max: 45,
              divisions: 6,
              onChanged: (value) {
                setState(() => _longBreakDuration = value.round());
              },
              onChangeEnd: (value) {
                _saveSetting(AppConstants.longBreakKey, value.round());
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDurationSlider({
    required String label,
    required int value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '$value min',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          label: '$value min',
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
  
  Widget _buildNotificationsSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(FontAwesomeIcons.bell, size: 18),
                SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Activer les notifications'),
              subtitle: const Text('Recevoir des alertes de fin de session'),
              value: _notificationEnabled,
              onChanged: (value) {
                setState(() => _notificationEnabled = value);
                _saveSetting(AppConstants.notificationEnabledKey, value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Son'),
              subtitle: const Text('Jouer un son à la fin des sessions'),
              value: _soundEnabled,
              onChanged: (value) {
                setState(() => _soundEnabled = value);
                _saveSetting(AppConstants.soundEnabledKey, value);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDataManagement() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(FontAwesomeIcons.database, size: 18),
                SizedBox(width: 8),
                Text(
                  'Gestion des données',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(FontAwesomeIcons.chartSimple),
              title: const Text('Statistiques'),
              subtitle: Text(
                'Tâches: ${_db.getAllTasks().length} | Sessions: ${_db.getAllSessions().length}',
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(FontAwesomeIcons.fileExport, color: Colors.blue),
              title: const Text('Exporter les donnees (CSV)'),
              subtitle: const Text('Exporter taches et sessions en CSV'),
              onTap: _exportData,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(FontAwesomeIcons.trashCan, color: Colors.red),
              title: const Text('Effacer toutes les données'),
              subtitle: const Text('Supprimer toutes les tâches et sessions'),
              onTap: _showClearDataDialog,
            ),
          ],
        ),
      ),
    );
  }
  
  // NEW: Account section with logout
  Widget _buildAccountSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(FontAwesomeIcons.userGear, size: 18),
                SizedBox(width: 8),
                Text(
                  'Compte',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                FontAwesomeIcons.rightFromBracket,
                color: Colors.orange,
              ),
              title: const Text('Se déconnecter'),
              subtitle: const Text('Déconnectez-vous de votre compte'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAboutSection() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.circleInfo, size: 18),
                SizedBox(width: 8),
                Text(
                  'À propos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(FontAwesomeIcons.mobileScreen),
              title: Text('Study Planner / Pomodoro'),
              subtitle: Text('Version 1.0.0'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(FontAwesomeIcons.code),
              title: Text('Développé avec Flutter'),
              subtitle: Text('© 2026 Ilias Mouatacim'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Effacer toutes les données'),
          content: const Text(
            'Cette action supprimera définitivemente toutes vos tâches et sessions. '
            'Cette action ne peut pas être annulée.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                await _db.clearAllData();
                if (mounted) {
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Toutes les données ont été supprimées'),
                    ),
                  );
                  _loadSettings();
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}