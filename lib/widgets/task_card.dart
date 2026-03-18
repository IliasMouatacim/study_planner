// lib/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == AppConstants.statusCompleted;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: FontAwesomeIcons.trash,
              label: 'Supprimer',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: isCompleted
                  ? Colors.green.withOpacity(0.18)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.08),
              width: 1.2,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: onToggleComplete,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              width: 2.2,
                            ),
                            color: isCompleted
                                ? Colors.green
                                : Theme.of(context).colorScheme.surface,
                            boxShadow: isCompleted
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.18),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: isCompleted
                              ? const Icon(
                                  FontAwesomeIcons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Title
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? Colors.grey[500]
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Priority indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.priorityColors[task.priority]!
                              .withOpacity(0.13),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          AppConstants.priorities[task.priority]!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.priorityColors[task.priority],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Description
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      task.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Subtasks progress
                  if (task.subtasks.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.listCheck, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(
                          '${task.subtasksDone.where((d) => d).length}/${task.subtasks.length} sous-taches',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: task.subtasks.isEmpty
                                  ? 0
                                  : task.subtasksDone.where((d) => d).length /
                                      task.subtasks.length,
                              minHeight: 4,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // Footer (due date, time spent)
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Category badge
                      if (task.category != 'General') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Due date
                      if (task.dueDate != null) ...[
                        Icon(
                          FontAwesomeIcons.calendar,
                          size: 12,
                          color: task.isOverdue ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(task.dueDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: task.isOverdue ? Colors.red : Colors.grey[600],
                            fontWeight: task.isOverdue ? FontWeight.bold : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      
                      // Time spent
                      if (task.totalTimeSpent > 0) ...[
                        const Icon(
                          FontAwesomeIcons.clock,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.formattedTimeSpent,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      
                      const Spacer(),
                      
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(task.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusLabel(task.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(task.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusTodo:
        return Colors.blue;
      case AppConstants.statusInProgress:
        return Colors.orange;
      case AppConstants.statusCompleted:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusLabel(String status) {
    switch (status) {
      case AppConstants.statusTodo:
        return 'À faire';
      case AppConstants.statusInProgress:
        return 'En cours';
      case AppConstants.statusCompleted:
        return 'Terminé';
      default:
        return status;
    }
  }
}