import 'package:flutter/material.dart';
import 'note_crud.dart';
import '../models/note.dart';

/// Exemplo de uso do SQLite CRUD

class SqliteExample extends StatefulWidget {
  const SqliteExample({super.key});

  @override
  State<SqliteExample> createState() => _SqliteExampleState();
}

class _SqliteExampleState extends State<SqliteExample> {
  final SqliteNoteCrud _crud = SqliteNoteCrud();
  List<Note> _notes = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await _crud.init();
      await _loadNotes();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Erro ao inicializar SQLite: $e');
    }
  }

  Future<void> _loadNotes() async {
    final notes = await _crud.getAllNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addNote() async {
    final note = await _crud.createNote(
      'Nota SQLite ${_notes.length + 1}',
      'Conteúdo da nota SQLite ${_notes.length + 1}',
    );
    print('Nota criada: $note');
    await _loadNotes();
  }

  Future<void> _updateNote(int id) async {
    final updatedNote = await _crud.updateNote(
      id,
      title: 'Nota SQLite Atualizada',
      content: 'Conteúdo atualizado em ${DateTime.now()}',
    );
    print('Nota atualizada: $updatedNote');
    await _loadNotes();
  }

  Future<void> _deleteNote(int id) async {
    final success = await _crud.deleteNote(id);
    print('Nota deletada: $success');
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('SQLite CRUD')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _addNote,
                  child: const Text('Adicionar Nota'),
                ),
                const SizedBox(width: 8),
                Text('Total: ${_notes.length} notas'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.content),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _updateNote(note.id!),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteNote(note.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _crud.close();
    super.dispose();
  }
}
