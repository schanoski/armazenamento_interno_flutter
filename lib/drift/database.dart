import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'note_model.dart';

// Incluir as tabelas definidas
part 'database.g.dart';

// Classe principal do banco de dados Drift
@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ===== CRUD OPERATIONS =====

  // Create - Criar uma nova nota
  Future<int> createNote(String title, String content) {
    return into(notes).insert(NotesCompanion(
      title: Value(title),
      content: Value(content),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // Read - Buscar todas as notas
  Future<List<Note>> getAllNotes() => select(notes).get();

  // Read - Buscar nota por ID
  Future<Note?> getNoteById(int id) {
    return (select(notes)..where((note) => note.id.equals(id))).getSingleOrNull();
  }

  // Update - Atualizar uma nota
  Future<bool> updateNote(int id, String title, String content) {
    return update(notes).replace(NotesCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // Delete - Deletar uma nota
  Future<int> deleteNote(int id) {
    return (delete(notes)..where((note) => note.id.equals(id))).go();
  }

  // Delete - Deletar todas as notas
  Future<int> deleteAllNotes() {
    return delete(notes).go();
  }

  // Buscar notas por título (demonstração de query personalizada)
  Future<List<Note>> searchNotesByTitle(String searchTerm) {
    return (select(notes)
          ..where((note) => note.title.like('%$searchTerm%'))
          ..orderBy([(note) => OrderingTerm.desc(note.createdAt)]))
        .get();
  }
}

// Configuração da conexão com o banco
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Diretório para salvar o banco de dados
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'drift_notes.db'));
    
    return NativeDatabase.createInBackground(file);
  });
}
