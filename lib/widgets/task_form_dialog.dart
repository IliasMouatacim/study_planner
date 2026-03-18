// lib/widgets/task_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/constants.dart';

class TaskFormDialog extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;

  const TaskFormDialog({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _priority;
  DateTime? _dueDate;
  late String _category;
  late List<String> _subtasks;
  late List<bool> _subtasksDone;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? 1;
    _dueDate = widget.task?.dueDate;
    _category = widget.task?.category ?? 'General';
    _subtasks = List<String>.from(widget.task?.subtasks ?? []);
    _subtasksDone = List<bool>.from(widget.task?.subtasksDone ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final task = widget.task?.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        category: _category,
        subtasks: _subtasks,
        subtasksDone: _subtasksDone,
      ) ?? Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        createdAt: DateTime.now(),
        category: _category,
        subtasks: _subtasks,
        subtasksDone: _subtasksDone,
      );

      widget.onSave(task);
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks.add(text);
      _subtasksDone.add(false);
      _subtaskController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.listCheck,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.task == null ? 'Nouvelle tâche' : 'Modifier la tâche',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre *',
                      hintText: 'Ex: Réviser les mathématiques',
                      prefixIcon: Icon(FontAwesomeIcons.heading),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le titre est requis';
                      }
                      return null;
                    },
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Détails de la tâche...',
                      prefixIcon: Icon(FontAwesomeIcons.alignLeft),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // Priority selector
                  const Text(
                    'Priorité',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityChip(0, 'Basse', Colors.green),
                      const SizedBox(width: 8),
                      _buildPriorityChip(1, 'Moyenne', Colors.orange),
                      const SizedBox(width: 8),
                      _buildPriorityChip(2, 'Haute', Colors.red),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Due date picker
                  const Text(
                    'Date d\'échéance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(FontAwesomeIcons.calendar, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            _dueDate == null
                                ? 'Aucune date'
                                : DateFormat('dd/MM/yyyy').format(_dueDate!),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          if (_dueDate != null)
                            IconButton(
                              icon: const Icon(FontAwesomeIcons.xmark, size: 18),
                              onPressed: () {
                                setState(() {
                                  _dueDate = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category selector
                  const Text(
                    'Categorie',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(FontAwesomeIcons.tag),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: AppConstants.taskCategories.map((cat) {
                      return DropdownMenuItem<String>(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Subtasks
                  const Text(
                    'Sous-taches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subtaskController,
                          decoration: const InputDecoration(
                            hintText: 'Ajouter une sous-tache',
                            prefixIcon: Icon(FontAwesomeIcons.plus, size: 14),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onSubmitted: (_) => _addSubtask(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addSubtask,
                        icon: Icon(FontAwesomeIcons.circlePlus,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                  if (_subtasks.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...List.generate(_subtasks.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _subtasksDone[index] = !_subtasksDone[index];
                                });
                              },
                              child: Icon(
                                _subtasksDone[index]
                                    ? FontAwesomeIcons.solidSquareCheck
                                    : FontAwesomeIcons.square,
                                size: 18,
                                color: _subtasksDone[index] ? Colors.green : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _subtasks[index],
                                style: TextStyle(
                                  decoration: _subtasksDone[index]
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: _subtasksDone[index] ? Colors.grey : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(FontAwesomeIcons.xmark, size: 14, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _subtasks.removeAt(index);
                                  _subtasksDone.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(FontAwesomeIcons.check, size: 16),
                        label: Text(widget.task == null ? 'Créer' : 'Enregistrer'),
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

  Widget _buildPriorityChip(int priority, String label, Color color) {
    final isSelected = _priority == priority;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _priority = priority;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}