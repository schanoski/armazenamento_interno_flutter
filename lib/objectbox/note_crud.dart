// CRUD usando ObjectBox
// 
// ObjectBox é um banco NoSQL super rápido orientado a objetos
// Oferece excelente performance, queries poderosas e facilidade de uso
// 
// Funcionalidades implementadas:
// ✅ Create, Read, Update, Delete operations
// ✅ Store management com ObjectBox
// ✅ @Entity annotations e code generation
// ✅ Queries rápidas e indexação automática
// ✅ Busca por título com QueryBuilder
// ✅ Estatísticas do banco
// 
// Para usar: Execute 'dart run build_runner build' para gerar código
// 
// Documentação oficial: https://docs.objectbox.io/

import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'note_model.dart';
import 'objectbox.g.dart'; // Arquivo gerado pelo build_runner

class ObjectBoxNoteCrud {
  late Store _store;
  late Box<ObjectBoxNote> _box;
  
  // ===== INICIALIZAÇÃO =====
  
  Future<void> init() async {
    try {
      // Obter diretório para armazenamento
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dir.path, 'objectbox_notes');
      
      // Abrir store do ObjectBox
      _store = await openStore(directory: dbPath);
      _box = _store.box<ObjectBoxNote>();
      
      print('✅ ObjectBox database inicializado com sucesso');
      print('📊 Caminho do banco: $dbPath');
    } catch (e) {
      print('❌ Erro ao inicializar ObjectBox: $e');
      rethrow;
    }
  }
  
  // ===== CRUD OPERATIONS =====
  
  // Create - Criar uma nova nota
  Future<int> createNote(String title, String content) async {
    try {
      final note = ObjectBoxNote(
        title: title,
        content: content,
      );
      
      final id = _box.put(note);
      print('✅ Nota criada com ID: $id');
      return id;
    } catch (e) {
      print('❌ Erro ao criar nota: $e');
      rethrow;
    }
  }
  
  // Read - Buscar todas as notas
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    try {
      final notes = _box.getAll();
      print('✅ ${notes.length} notas encontradas');
      
      // Converter para Map para compatibilidade com UI
      return notes.map((note) => note.toMap()).toList();
    } catch (e) {
      print('❌ Erro ao buscar notas: $e');
      return [];
    }
  }
  
  // Read - Buscar nota por ID
  Future<Map<String, dynamic>?> getNoteById(int id) async {
    try {
      final note = _box.get(id);
      if (note != null) {
        return note.toMap();
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar nota por ID: $e');
      return null;
    }
  }
  
  // Update - Atualizar uma nota
  Future<bool> updateNote(int id, String title, String content) async {
    try {
      final note = _box.get(id);
      if (note != null) {
        note.title = title;
        note.content = content;
        note.updateTimestamp();
        
        _box.put(note);
        print('✅ Nota $id atualizada com sucesso');
        return true;
      } else {
        print('❌ Nota $id não encontrada para atualização');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao atualizar nota: $e');
      return false;
    }
  }
  
  // Delete - Deletar uma nota
  Future<bool> deleteNote(int id) async {
    try {
      final success = _box.remove(id);
      if (success) {
        print('✅ Nota $id deletada com sucesso');
      } else {
        print('❌ Nota $id não encontrada para exclusão');
      }
      return success;
    } catch (e) {
      print('❌ Erro ao deletar nota: $e');
      return false;
    }
  }
  
  // ===== OPERAÇÕES EXTRAS =====
  
  // Buscar notas por título usando QueryBuilder
  Future<List<Map<String, dynamic>>> searchNotesByTitle(String searchTerm) async {
    try {
      final query = _box.query(ObjectBoxNote_.title.contains(searchTerm, caseSensitive: false)).build();
      final notes = query.find();
      query.close();
      
      print('✅ ${notes.length} notas encontradas para: "$searchTerm"');
      return notes.map((note) => note.toMap()).toList();
    } catch (e) {
      print('❌ Erro ao buscar notas por título: $e');
      return [];
    }
  }
  
  // Deletar todas as notas
  Future<int> deleteAllNotes() async {
    try {
      final count = _box.count();
      _box.removeAll();
      print('✅ $count notas deletadas');
      return count;
    } catch (e) {
      print('❌ Erro ao deletar todas as notas: $e');
      return 0;
    }
  }
  
  // Buscar notas criadas hoje
  Future<List<Map<String, dynamic>>> getNotesCreatedToday() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final query = _box.query(
        ObjectBoxNote_.createdAt.between(
          startOfDay.millisecondsSinceEpoch,
          endOfDay.millisecondsSinceEpoch,
        )
      ).build();
      
      final notes = query.find();
      query.close();
      
      print('✅ ${notes.length} notas criadas hoje');
      return notes.map((note) => note.toMap()).toList();
    } catch (e) {
      print('❌ Erro ao buscar notas de hoje: $e');
      return [];
    }
  }
  
  // Fechar conexão (importante para cleanup)
  Future<void> close() async {
    try {
      _store.close();
      print('✅ ObjectBox store fechado');
    } catch (e) {
      print('❌ Erro ao fechar ObjectBox store: $e');
    }
  }
  
  // ===== UTILITÁRIOS =====
  
  // Estatísticas do banco
  Future<Map<String, dynamic>> getStats() async {
    try {
      final allNotes = _box.getAll();
      
      return {
        'totalNotes': allNotes.length,
        'databaseSize': 'N/A', // ObjectBox não expõe facilmente o tamanho no Flutter
        'lastUpdate': allNotes.isNotEmpty 
          ? allNotes.map((n) => n.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String()
          : null,
        'performance': 'Ultra-fast NoSQL',
        'type': 'Object-oriented database',
      };
    } catch (e) {
      print('❌ Erro ao obter estatísticas: $e');
      return {'totalNotes': 0, 'error': e.toString()};
    }
  }
}
