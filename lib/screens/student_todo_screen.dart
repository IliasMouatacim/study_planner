import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../widgets/custom_app_bar.dart';

class StudentTodoScreen extends StatefulWidget {
  const StudentTodoScreen({super.key});

  @override
  State<StudentTodoScreen> createState() => _StudentTodoScreenState();
}

class _StudentTodoScreenState extends State<StudentTodoScreen> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _controller = TextEditingController();
  final List<_TodoItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadItems() {
    final stored = _db.getStudentTodoItems();
    _items
      ..clear()
      ..addAll(
        stored.map(
          (e) => _TodoItem(
            id: (e['id'] ?? '').toString(),
            text: (e['text'] ?? '').toString(),
            isCompleted: e['isCompleted'] == true,
            createdAt: DateTime.tryParse((e['createdAt'] ?? '').toString()) ??
                DateTime.now(),
          ),
        ),
      )
      ..removeWhere((e) => e.text.trim().isEmpty);
    setState(() {});
  }

  Future<void> _saveItems() async {
    await _db.saveStudentTodoItems(
      _items
          .map(
            (e) => {
              'id': e.id,
              'text': e.text,
              'isCompleted': e.isCompleted,
              'createdAt': e.createdAt.toIso8601String(),
            },
          )
          .toList(),
    );
  }

  Future<void> _addItem() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.insert(
        0,
        _TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          createdAt: DateTime.now(),
        ),
      );
    });
    _controller.clear();
    await _saveItems();
  }

  Future<void> _toggleDone(int index) async {
    setState(() {
      _items[index].isCompleted = !_items[index].isCompleted;
    });
    await _saveItems();
  }

  Future<void> _deleteItem(int index) async {
    setState(() {
      _items.removeAt(index);
    });
    await _saveItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const CustomAppBar(
        title: 'Student To-Do',
        showBack: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Add a task...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addItem,
                ),
              ),
              onSubmitted: (_) => _addItem(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks yet',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          child: CheckboxListTile(
                            value: item.isCompleted,
                            onChanged: (_) => _toggleDone(index),
                            title: Text(
                              item.text,
                              style: TextStyle(
                                decoration: item.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            secondary: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteItem(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoItem {
  _TodoItem({
    required this.id,
    required this.text,
    required this.createdAt,
    this.isCompleted = false,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  bool isCompleted;
}
