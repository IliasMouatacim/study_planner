import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/task.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_dialog.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<Task> _tasks = [];
  bool _showUrgentOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() => setState(() {}));
    unawaited(_loadTasks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    await _db.syncWithCloud();
    if (!mounted) return;

    setState(() {
      _tasks = _db.getAllTasks();
      _tasks.sort((a, b) {
        if (a.status == AppConstants.statusCompleted &&
            b.status != AppConstants.statusCompleted) {
          return 1;
        }
        if (b.status == AppConstants.statusCompleted &&
            a.status != AppConstants.statusCompleted) {
          return -1;
        }

        final urgencyCompare = _urgencyRank(a).compareTo(_urgencyRank(b));
        if (urgencyCompare != 0) return urgencyCompare;

        final priorityCompare = b.priority.compareTo(a.priority);
        if (priorityCompare != 0) return priorityCompare;

        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;

        return b.createdAt.compareTo(a.createdAt);
      });
    });
  }

  int _urgencyRank(Task task) {
    if (task.status == AppConstants.statusCompleted) return 5;
    if (task.isOverdue) return 0;
    if (task.isDueToday) return 1;
    final days = task.daysUntilDue;
    if (days != null && days <= 2) return 2;
    if (task.dueDate != null) return 3;
    return 4;
  }

  bool _isUrgent(Task task) {
    if (task.status == AppConstants.statusCompleted) return false;
    if (task.isOverdue || task.isDueToday) return true;
    final days = task.daysUntilDue;
    return days != null && days <= 2;
  }

  List<Task> _getTasksByStatus(String status) {
    final query = _searchController.text.trim().toLowerCase();
    return _tasks.where((task) {
      if (task.status != status) return false;
      if (_showUrgentOnly && !_isUrgent(task)) return false;

      if (query.isEmpty) return true;
      final inTitle = task.title.toLowerCase().contains(query);
      final inDescription =
          (task.description ?? '').toLowerCase().contains(query);
      return inTitle || inDescription;
    }).toList();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        onSave: (task) {
          unawaited(_db.addTask(task));
          unawaited(_loadTasks());
        },
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        task: task,
        onSave: (updatedTask) {
          unawaited(_db.updateTask(updatedTask));
          unawaited(_loadTasks());
        },
      ),
    );
  }

  void _deleteTask(Task task) {
    // Delete immediately and show undo snackbar
    unawaited(_db.deleteTask(task.id));
    unawaited(_loadTasks());

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.title}" supprimee'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            unawaited(_db.addTask(task));
            unawaited(_loadTasks());
          },
        ),
      ),
    );
  }

  void _toggleTaskStatus(Task task) {
    final newStatus = task.status == AppConstants.statusCompleted
        ? AppConstants.statusTodo
        : AppConstants.statusCompleted;

    final updatedTask = task.copyWith(
      status: newStatus,
      completedAt:
          newStatus == AppConstants.statusCompleted ? DateTime.now() : null,
    );

    unawaited(_db.updateTask(updatedTask));
    unawaited(_loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    final todoTasks = _getTasksByStatus(AppConstants.statusTodo);
    final inProgressTasks = _getTasksByStatus(AppConstants.statusInProgress);
    final completedTasks = _getTasksByStatus(AppConstants.statusCompleted);

    final urgentCount = _tasks.where(_isUrgent).length;
    final totalActive =
        _tasks.where((t) => t.status != AppConstants.statusCompleted).length;

    return Scaffold(
      extendBody: true,
      appBar: const CustomAppBar(
        title: 'Study Tasks',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.06),
              Theme.of(context).colorScheme.secondary.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(18),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.18),
                ),
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                tabs: [
                  _buildTab('To Do', todoTasks.length),
                  _buildTab('In Progress', inProgressTasks.length),
                  _buildTab('Completed', completedTasks.length),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _searchController.clear,
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilterChip(
                    selected: _showUrgentOnly,
                    onSelected: (value) {
                      setState(() {
                        _showUrgentOnly = value;
                      });
                    },
                    label: Text('Urgent ($urgentCount)'),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Active: $totalActive',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(todoTasks),
                  _buildTaskList(inProgressTasks),
                  _buildTaskList(completedTasks),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(FontAwesomeIcons.plus),
        label: const Text('New Task'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      final hasSearch =
          _searchController.text.trim().isNotEmpty || _showUrgentOnly;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch
                    ? FontAwesomeIcons.magnifyingGlass
                    : FontAwesomeIcons.clipboardList,
                size: 42,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch ? 'Aucune tache trouvee' : 'Aucune tache ici',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Essayez de modifier vos filtres'
                  : 'Appuyez sur + pour ajouter une tache',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onTap: () => _showEditTaskDialog(task),
            onDelete: () => _deleteTask(task),
            onToggleComplete: () => _toggleTaskStatus(task),
          );
        },
      ),
    );
  }
}
