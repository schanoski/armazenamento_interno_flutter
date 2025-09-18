import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

/// CRUD usando SQLite (sqflite)
/// 
/// SQLite é o banco de dados relacional mais usado no mundo.
/// Ideal para aplicações que precisam de consultas SQL complexas.
/// 
/// Vantagens:
/// - SQL completo
/// - Transações ACID
/// - Muito maduro e estável
/// - Excelente performance
/// 
/// Desvantagens:
/// - Mais verboso que outras soluções
/// - Requer conhecimento SQL
/// - Dependência nativa

class SqliteNoteCrud {
  static Database? _database;
  static const String _tableName = 'notes';

  /// Inicializar o banco de dados
  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'notes_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $_tableName('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title TEXT NOT NULL, '
          'content TEXT NOT NULL, '
          'created_at INTEGER NOT NULL, '
          'updated_at INTEGER'
          ')',
        );
      },
      version: 1,
    );
  }

  Database get _db {
    if (_database == null) {
      throw StateError('Database not initialized. Call init() first.');
    }
    return _database!;
  }

  /// Criar uma nova nota
  Future<Note> createNote(String title, String content) async {
    final now = DateTime.now();
    final id = await _db.insert(
      _tableName,
      {
        'title': title,
        'content': content,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': null,
      },
    );

    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: now,
    );
  }

  /// Ler todas as notas
  Future<List<Note>> getAllNotes() async {
    final List<Map<String, dynamic>> maps = await _db.query(_tableName);
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Ler uma nota específica por ID
  Future<Note?> getNoteById(int id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  /// Atualizar uma nota
  Future<Note?> updateNote(int id, {String? title, String? content}) async {
    final existingNote = await getNoteById(id);
    if (existingNote == null) return null;

    final updatedNote = existingNote.copyWith(
      title: title ?? existingNote.title,
      content: content ?? existingNote.content,
      updatedAt: DateTime.now(),
    );

    await _db.update(
      _tableName,
      updatedNote.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    return updatedNote;
  }

  /// Deletar uma nota
  Future<bool> deleteNote(int id) async {
    final count = await _db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  /// Deletar todas as notas
  Future<void> deleteAllNotes() async {
    await _db.delete(_tableName);
  }

  /// Buscar notas por título ou conteúdo
  Future<List<Note>> searchNotes(String query) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      _tableName,
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Contar total de notas
  Future<int> getNotesCount() async {
    final result = await _db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Obter notas paginadas
  Future<List<Note>> getNotesPaginated({int page = 0, int limit = 10}) async {
    final offset = page * limit;
    final List<Map<String, dynamic>> maps = await _db.query(
      _tableName,
      limit: limit,
      offset: offset,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Obter notas ordenadas por data
  Future<List<Note>> getNotesOrderedByDate({bool ascending = false}) async {
    final orderBy = ascending ? 'created_at ASC' : 'created_at DESC';
    final List<Map<String, dynamic>> maps = await _db.query(
      _tableName,
      orderBy: orderBy,
    );

    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Fechar o banco de dados
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
