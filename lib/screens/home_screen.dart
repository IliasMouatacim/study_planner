// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'tasks_screen.dart';
import 'pomodoro_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'customization_screen.dart';
import 'daily_quotes_screen.dart';
import 'notes_screen.dart';
import 'student_friendly_screen.dart';
import '../widgets/modern_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // FIXED: Added const keyword
  final List<Widget> _screens = [
    const TasksScreen(),
    const PomodoroScreen(),
    const AnalyticsScreen(),
    const DailyQuotesScreen(),
    const NotesScreen(),
    const StudentFriendlyScreen(),
    const CustomizationScreen(),
    const SettingsScreen(),
  ];
  
  // FIXED: Added const keyword
  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.listCheck),
      selectedIcon: FaIcon(FontAwesomeIcons.listCheck),
      label: 'Taches',
    ),
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.clock),
      selectedIcon: FaIcon(FontAwesomeIcons.solidClock),
      label: 'Timer',
    ),
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.chartLine),
      selectedIcon: FaIcon(FontAwesomeIcons.chartLine),
      label: 'Analytics',
    ),
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.quoteLeft),
      selectedIcon: FaIcon(FontAwesomeIcons.quoteRight),
      label: 'Quotes',
    ),
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.noteSticky),
      selectedIcon: FaIcon(FontAwesomeIcons.solidNoteSticky),
      label: 'Notes',
    ),
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.graduationCap),
      selectedIcon: FaIcon(FontAwesomeIcons.graduationCap),
      label: 'Student',
    ),
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.palette),
      selectedIcon: FaIcon(FontAwesomeIcons.palette),
      label: 'Custom',
    ),
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.gear),
      selectedIcon: FaIcon(FontAwesomeIcons.gear),
      label: 'Reglages',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }
}