import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../widgets/custom_app_bar.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _notes = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<Color> _noteColors = [
    Color(0xFF2C2C2E),
    Color(0xFFE53935),
    Color(0xFFFB8C00),
    Color.fromARGB(255, 255, 242, 0),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
  ];

  @override
  void initState() {
    super.initState();
    unawaited(_loadNotes());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    await _db.syncWithCloud();
    if (!mounted) return;

    setState(() {
      _notes = _db.getAllNotes();
    });
  }

  List<Map<String, dynamic>> get _filteredNotes {
    if (_searchQuery.isEmpty) return _notes;
    final q = _searchQuery.toLowerCase();
    return _notes.where((n) {
      final title = (n['title'] ?? '').toString().toLowerCase();
      final content = (n['content'] ?? '').toString().toLowerCase();
      return title.contains(q) || content.contains(q);
    }).toList();
  }

  void _openNoteEditor({Map<String, dynamic>? existing}) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final contentCtrl = TextEditingController(text: existing?['content'] ?? '');
    int selectedColorIndex = 0;
    bool isPinned = existing?['isPinned'] ?? false;

    if (existing != null) {
      final savedColor = existing['color'] as int? ?? _noteColors[0].value;
      selectedColorIndex = _noteColors.indexWhere((c) => c.value == savedColor);
      if (selectedColorIndex < 0) selectedColorIndex = 0;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existing != null
                              ? 'Modifier la note'
                              : 'Nouvelle note',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isPinned
                                    ? Icons.push_pin
                                    : Icons.push_pin_outlined,
                                color: isPinned
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              onPressed: () =>
                                  setModalState(() => isPinned = !isPinned),
                            ),
                            TextButton(
                              onPressed: () async {
                                final title = titleCtrl.text.trim();
                                final content = contentCtrl.text.trim();
                                if (title.isEmpty && content.isEmpty) {
                                  Navigator.pop(ctx);
                                  return;
                                }
                                final now = DateTime.now().toIso8601String();
                                final note = <String, dynamic>{
                                  'id': existing?['id'] ??
                                      DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString(),
                                  'title': title,
                                  'content': content,
                                  'color':
                                      _noteColors[selectedColorIndex].value,
                                  'isPinned': isPinned,
                                  'createdAt': existing?['createdAt'] ?? now,
                                  'updatedAt': now,
                                };
                                if (existing != null) {
                                  await _db.updateNote(note);
                                } else {
                                  await _db.addNote(note);
                                }
                                await _loadNotes();
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                              child: const Text('Enregistrer'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _noteColors.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final isSelected = i == selectedColorIndex;
                          return GestureDetector(
                            onTap: () =>
                                setModalState(() => selectedColorIndex = i),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _noteColors[i],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      size: 18, color: Colors.white)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleCtrl,
                      style: Theme.of(context).textTheme.titleMedium,
                      decoration: const InputDecoration(
                        hintText: 'Titre',
                        border: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const Divider(height: 1),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      child: TextField(
                        controller: contentCtrl,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Contenu de la note...',
                          border: InputBorder.none,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteNote(Map<String, dynamic> note) async {
    await _db.deleteNote(note['id']);
    await _loadNotes();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note supprimee'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () async {
            await _db.addNote(note);
            await _loadNotes();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = _filteredNotes;
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      appBar: const CustomAppBar(title: 'Notes'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une note...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.note_add_outlined,
                              size: 48,
                              color:
                                  theme.colorScheme.primary.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Aucun resultat'
                              : 'Aucune note pour le moment',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        if (_searchQuery.isEmpty)
                          Text(
                            'Appuyez sur + pour creer votre premiere note',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[500]),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: notes.length,
                    itemBuilder: (_, i) => _buildNoteCard(notes[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final color = Color(note['color'] as int? ?? _noteColors[0].value);
    final isPinned = note['isPinned'] == true;
    final updatedAt = DateTime.tryParse(note['updatedAt'] ?? '');
    final dateStr = updatedAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(updatedAt)
        : '';

    return Dismissible(
      key: ValueKey(note['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteNote(note),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: color.withOpacity(0.15),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openNoteEditor(existing: note),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isPinned)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.push_pin,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    Expanded(
                      child: Text(
                        (note['title'] ?? '').toString().isNotEmpty
                            ? note['title']
                            : 'Sans titre',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'pin',
                            child: Text(isPinned ? 'Desepingler' : 'Epingler')),
                        const PopupMenuItem(
                            value: 'delete', child: Text('Supprimer')),
                      ],
                      onSelected: (val) async {
                        if (val == 'pin') {
                          final updated = Map<String, dynamic>.from(note);
                          updated['isPinned'] = !isPinned;
                          updated['updatedAt'] =
                              DateTime.now().toIso8601String();
                          await _db.updateNote(updated);
                          await _loadNotes();
                        } else if (val == 'delete') {
                          _deleteNote(note);
                        }
                      },
                    ),
                  ],
                ),
                if ((note['content'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    note['content'],
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[400]),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const Spacer(),
                    Text(
                      dateStr,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
