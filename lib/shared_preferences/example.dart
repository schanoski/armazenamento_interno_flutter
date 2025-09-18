import 'package:flutter/material.dart';
import 'note_crud.dart';
import '../models/note.dart';

/// Exemplo de uso do SharedPreferences CRUD
/// 
/// Este exemplo mostra como usar o SharedPreferencesNoteCrud para:
/// - Criar, ler, atualizar e deletar notas
/// - Buscar notas
/// - Gerenciar dados simples com SharedPreferences

class SharedPreferencesExample extends StatefulWidget {
  const SharedPreferencesExample({super.key});

  @override
  State<SharedPreferencesExample> createState() => _SharedPreferencesExampleState();
}

class _SharedPreferencesExampleState extends State<SharedPreferencesExample> {
  final SharedPreferencesNoteCrud _crud = SharedPreferencesNoteCrud();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _crud.getAllNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addNote() async {
    final note = await _crud.createNote(
      'Nota ${_notes.length + 1}',
      'Conteúdo da nota ${_notes.length + 1}',
    );
    print('Nota criada: $note');
    await _loadNotes();
  }

  Future<void> _updateNote(int id) async {
    final updatedNote = await _crud.updateNote(
      id,
      title: 'Nota Atualizada',
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

  Future<void> _searchNotes() async {
    final results = await _crud.searchNotes('Atualizada');
    print('Resultados da busca: ${results.length} notas encontradas');
    for (final note in results) {
      print('- ${note.title}: ${note.content}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SharedPreferences CRUD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchNotes,
          ),
        ],
      ),
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note.content),
                        const SizedBox(height: 4),
                        Text(
                          'Criado: ${note.createdAt.toString().substring(0, 19)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (note.updatedAt != null)
                          Text(
                            'Atualizado: ${note.updatedAt.toString().substring(0, 19)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
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
}

/// Exemplo de uso programático (sem UI)
class SharedPreferencesProgrammaticExample {
  static Future<void> runExample() async {
    final crud = SharedPreferencesNoteCrud();
    
    try {
      print('=== SharedPreferences CRUD Example ===');
      
      // 1. Criar notas
      print('\n--- Criando Notas ---');
      final note1 = await crud.createNote('Primeira nota', 'Conteúdo da primeira nota');
      final note2 = await crud.createNote('Segunda nota', 'Conteúdo da segunda nota');
      final note3 = await crud.createNote('Terceira nota', 'Conteúdo importante');
      
      print('Nota 1 criada: ${note1.title}');
      print('Nota 2 criada: ${note2.title}');
      print('Nota 3 criada: ${note3.title}');
      
      // 2. Ler todas as notas
      print('\n--- Lendo Todas as Notas ---');
      final allNotes = await crud.getAllNotes();
      print('Total de notas: ${allNotes.length}');
      for (final note in allNotes) {
        print('- ID: ${note.id}, Título: ${note.title}');
      }
      
      // 3. Ler nota específica
      print('\n--- Lendo Nota Específica ---');
      final specificNote = await crud.getNoteById(1);
      if (specificNote != null) {
        print('Nota encontrada: ${specificNote.title}');
      }
      
      // 4. Atualizar nota
      print('\n--- Atualizando Nota ---');
      final updatedNote = await crud.updateNote(1, 
        title: 'Primeira nota (atualizada)',
        content: 'Conteúdo atualizado!');
      if (updatedNote != null) {
        print('Nota atualizada: ${updatedNote.title}');
      }
      
      // 5. Buscar notas
      print('\n--- Buscando Notas ---');
      final searchResults = await crud.searchNotes('importante');
      print('Notas com "importante": ${searchResults.length}');
      for (final note in searchResults) {
        print('- ${note.title}');
      }
      
      // 6. Deletar nota
      print('\n--- Deletando Nota ---');
      final deleted = await crud.deleteNote(2);
      print('Nota 2 deletada: $deleted');
      print('Total de notas após deleção: ${await crud.getNotesCount()}');
      
    } catch (e) {
      print('Erro: $e');
    }
  }
}
