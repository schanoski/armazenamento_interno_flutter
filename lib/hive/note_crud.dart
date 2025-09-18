import 'package:hive_flutter/hive_flutter.dart';
import 'note_model.dart';

/// CRUD usando Hive
/// 
/// Hive é um banco de dados NoSQL rápido e leve, escrito em Dart.
/// É uma excelente escolha para aplicações Flutter.
/// 
/// Vantagens:
/// - Muito rápido (escrito em Dart)
/// - Sem dependências nativas
/// - Suporte a encriptação
/// - Tipo seguro com códigos gerados
/// - Suporte a lazy loading
/// 
/// Desvantagens:
/// - Menor comunidade que SQLite
/// - Não tem SQL (NoSQL)
/// - Requer configuração de adapters para objetos customizados
/// 
/// Para gerar o adapter automaticamente, execute:
/// dart run build_runner build

class HiveNoteCrud {
  static const String _boxName = 'notes';
  late Box<HiveNote> _box;
  int _counter = 0;

  /// Inicializar o Hive e abrir a box
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Registrar o adapter se ainda não foi registrado
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HiveNoteAdapter());
    }
    
    _box = await Hive.openBox<HiveNote>(_boxName);
    
    // Inicializar contador baseado no maior ID existente
    _counter = _box.values.fold<int>(0, (maxId, note) {
      return note.id != null && note.id! > maxId ? note.id! : maxId;
    });
  }

  /// Criar uma nova nota
  Future<HiveNote> createNote(String title, String content) async {
    final id = ++_counter;
    final note = HiveNote(
      id: id,
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    
    await _box.put(id, note);
    return note;
  }

  /// Ler todas as notas
  List<HiveNote> getAllNotes() {
    return _box.values.toList();
  }

  /// Ler uma nota específica por ID
  HiveNote? getNoteById(int id) {
    return _box.get(id);
  }

  /// Atualizar uma nota
  Future<HiveNote?> updateNote(int id, {String? title, String? content}) async {
    final existingNote = _box.get(id);
    if (existingNote == null) return null;
    
    final updatedNote = existingNote.copyWith(
      title: title ?? existingNote.title,
      content: content ?? existingNote.content,
      updatedAt: DateTime.now(),
    );
    
    await _box.put(id, updatedNote);
    return updatedNote;
  }

  /// Deletar uma nota
  Future<bool> deleteNote(int id) async {
    if (_box.containsKey(id)) {
      await _box.delete(id);
      return true;
    }
    return false;
  }

  /// Deletar todas as notas
  Future<void> deleteAllNotes() async {
    await _box.clear();
    _counter = 0;
  }

  /// Buscar notas por título ou conteúdo
  List<HiveNote> searchNotes(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _box.values.where((note) =>
      note.title.toLowerCase().contains(lowercaseQuery) ||
      note.content.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  /// Contar total de notas
  int getNotesCount() {
    return _box.length;
  }

  /// Obter notas paginadas
  List<HiveNote> getNotesPaginated({int page = 0, int limit = 10}) {
    final allNotes = getAllNotes();
    final startIndex = page * limit;
    final endIndex = (startIndex + limit).clamp(0, allNotes.length);
    
    if (startIndex >= allNotes.length) return [];
    
    return allNotes.sublist(startIndex, endIndex);
  }

  /// Obter notas ordenadas por data
  List<HiveNote> getNotesOrderedByDate({bool ascending = false}) {
    final notes = getAllNotes();
    notes.sort((a, b) => ascending 
      ? a.createdAt.compareTo(b.createdAt)
      : b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  /// Fechar a box (importante para liberar recursos)
  Future<void> close() async {
    await _box.close();
  }

  /// Compactar a box (otimização de espaço)
  Future<void> compact() async {
    await _box.compact();
  }

  /// Verificar se a box está aberta
  bool get isOpen => _box.isOpen;

  /// Escutar mudanças na box
  Stream<BoxEvent> get watchChanges => _box.watch();
}
