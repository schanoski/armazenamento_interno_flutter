import 'package:flutter/material.dart';
import 'note_crud.dart';
import 'note_model.dart';

/// Exemplo de uso do Hive CRUD
/// 
/// Este exemplo mostra como usar o HiveNoteCrud para:
/// - Inicializar o Hive
/// - Criar, ler, atualizar e deletar notas
/// - Buscar e ordenar notas
/// 
/// Para usar este exemplo:
/// 1. Certifique-se que as dependências estão instaladas
/// 2. Execute: dart run build_runner build (para gerar os adapters)
/// 3. Importe este arquivo em seu main.dart ou widget

class HiveExample extends StatefulWidget {
  const HiveExample({super.key});

  @override
  State<HiveExample> createState() => _HiveExampleState();
}

class _HiveExampleState extends State<HiveExample> {
  final HiveNoteCrud _hiveCrud = HiveNoteCrud();
  List<HiveNote> _notes = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      await _hiveCrud.init();
      await _loadNotes();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Erro ao inicializar Hive: $e');
    }
  }

  Future<void> _loadNotes() async {
    final notes = _hiveCrud.getAllNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addNote() async {
    final note = await _hiveCrud.createNote(
      'Nota ${_notes.length + 1}',
      'Conteúdo da nota ${_notes.length + 1}',
    );
    print('Nota criada: $note');
    await _loadNotes();
  }

  Future<void> _updateNote(int id) async {
    final updatedNote = await _hiveCrud.updateNote(
      id,
      title: 'Nota Atualizada',
      content: 'Conteúdo atualizado em ${DateTime.now()}',
    );
    print('Nota atualizada: $updatedNote');
    await _loadNotes();
  }

  Future<void> _deleteNote(int id) async {
    final success = await _hiveCrud.deleteNote(id);
    print('Nota deletada: $success');
    await _loadNotes();
  }

  Future<void> _searchNotes() async {
    final results = _hiveCrud.searchNotes('Atualizada');
    print('Resultados da busca: ${results.length} notas encontradas');
    for (final note in results) {
      print('- ${note.title}: ${note.content}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive CRUD Example'),
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

  @override
  void dispose() {
    _hiveCrud.close();
    super.dispose();
  }
}

/// Exemplo de uso programático (sem UI)
class HiveProgrammaticExample {
  static Future<void> runExample() async {
    final crud = HiveNoteCrud();
    
    try {
      // 1. Inicializar
      print('=== Inicializando Hive ===');
      await crud.init();
      
      // 2. Criar notas
      print('\n=== Criando Notas ===');
      final note1 = await crud.createNote('Minha primeira nota', 'Conteúdo da primeira nota');
      final note2 = await crud.createNote('Segunda nota', 'Conteúdo da segunda nota');
      final note3 = await crud.createNote('Terceira nota', 'Conteúdo importante');
      
      print('Nota 1 criada: ${note1.title}');
      print('Nota 2 criada: ${note2.title}');
      print('Nota 3 criada: ${note3.title}');
      
      // 3. Ler todas as notas
      print('\n=== Lendo Todas as Notas ===');
      final allNotes = crud.getAllNotes();
      print('Total de notas: ${allNotes.length}');
      for (final note in allNotes) {
        print('- ID: ${note.id}, Título: ${note.title}');
      }
      
      // 4. Ler nota específica
      print('\n=== Lendo Nota Específica ===');
      final specificNote = crud.getNoteById(1);
      if (specificNote != null) {
        print('Nota encontrada: ${specificNote.title}');
      }
      
      // 5. Atualizar nota
      print('\n=== Atualizando Nota ===');
      final updatedNote = await crud.updateNote(1, 
        title: 'Primeira nota (atualizada)',
        content: 'Conteúdo atualizado!');
      if (updatedNote != null) {
        print('Nota atualizada: ${updatedNote.title}');
      }
      
      // 6. Buscar notas
      print('\n=== Buscando Notas ===');
      final searchResults = crud.searchNotes('importante');
      print('Notas com "importante": ${searchResults.length}');
      for (final note in searchResults) {
        print('- ${note.title}');
      }
      
      // 7. Ordenar notas por data
      print('\n=== Ordenando Notas por Data ===');
      final orderedNotes = crud.getNotesOrderedByDate(ascending: true);
      print('Notas ordenadas (mais antigas primeiro):');
      for (final note in orderedNotes) {
        print('- ${note.title} (${note.createdAt.toString().substring(0, 19)})');
      }
      
      // 8. Paginação
      print('\n=== Paginação ===');
      final firstPage = crud.getNotesPaginated(page: 0, limit: 2);
      print('Primeira página (2 itens): ${firstPage.length}');
      for (final note in firstPage) {
        print('- ${note.title}');
      }
      
      // 9. Deletar nota
      print('\n=== Deletando Nota ===');
      final deleted = await crud.deleteNote(2);
      print('Nota 2 deletada: $deleted');
      print('Total de notas após deleção: ${crud.getNotesCount()}');
      
      // 10. Estatísticas
      print('\n=== Estatísticas ===');
      print('Total de notas: ${crud.getNotesCount()}');
      print('Box está aberta: ${crud.isOpen}');
      
    } catch (e) {
      print('Erro: $e');
    } finally {
      await crud.close();
      print('\n=== Hive fechado ===');
    }
  }
}
