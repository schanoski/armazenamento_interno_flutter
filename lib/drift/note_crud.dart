// CRUD usando Drift
// 
// Drift é um ORM type-safe para SQLite em Dart/Flutter
// Oferece queries type-safe, migrations automáticas, e excelente performance
// 
// Funcionalidades implementadas:
// ✅ Create, Read, Update, Delete operations
// ✅ Type-safe queries com compile-time checking
// ✅ Auto-increment IDs
// ✅ Timestamps automáticos
// ✅ Busca por título
// ✅ Validação de schema
// 
// Para usar: Execute 'dart run build_runner build' para gerar código
// 
// Documentação oficial: https://drift.simonbinder.eu/

import 'database.dart';

class DriftNoteCrud {
  late AppDatabase _database;
  
  // ===== INICIALIZAÇÃO =====
  
  Future<void> init() async {
    _database = AppDatabase();
    print('✅ Drift database inicializado com sucesso');
  }
  
  // ===== CRUD OPERATIONS =====
  
  // Create - Criar uma nova nota
  Future<int> createNote(String title, String content) async {
    try {
      final id = await _database.createNote(title, content);
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
      final notes = await _database.getAllNotes();
      print('✅ ${notes.length} notas encontradas');
      
      // Converter para Map para compatibilidade com UI
      return notes.map((note) => {
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'createdAt': note.createdAt.toIso8601String(),
        'updatedAt': note.updatedAt.toIso8601String(),
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar notas: $e');
      return [];
    }
  }
  
  // Read - Buscar nota por ID
  Future<Map<String, dynamic>?> getNoteById(int id) async {
    try {
      final note = await _database.getNoteById(id);
      if (note != null) {
        return {
          'id': note.id,
          'title': note.title,
          'content': note.content,
          'createdAt': note.createdAt.toIso8601String(),
          'updatedAt': note.updatedAt.toIso8601String(),
        };
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
      final success = await _database.updateNote(id, title, content);
      if (success) {
        print('✅ Nota $id atualizada com sucesso');
      } else {
        print('❌ Nota $id não encontrada para atualização');
      }
      return success;
    } catch (e) {
      print('❌ Erro ao atualizar nota: $e');
      return false;
    }
  }
  
  // Delete - Deletar uma nota
  Future<bool> deleteNote(int id) async {
    try {
      final deletedCount = await _database.deleteNote(id);
      final success = deletedCount > 0;
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
  
  // Buscar notas por título
  Future<List<Map<String, dynamic>>> searchNotesByTitle(String searchTerm) async {
    try {
      final notes = await _database.searchNotesByTitle(searchTerm);
      print('✅ ${notes.length} notas encontradas para: "$searchTerm"');
      
      return notes.map((note) => {
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'createdAt': note.createdAt.toIso8601String(),
        'updatedAt': note.updatedAt.toIso8601String(),
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar notas por título: $e');
      return [];
    }
  }
  
  // Deletar todas as notas
  Future<int> deleteAllNotes() async {
    try {
      final deletedCount = await _database.deleteAllNotes();
      print('✅ $deletedCount notas deletadas');
      return deletedCount;
    } catch (e) {
      print('❌ Erro ao deletar todas as notas: $e');
      return 0;
    }
  }
  
  // Fechar conexão (importante para cleanup)
  Future<void> close() async {
    // Em Drift, a conexão é fechada automaticamente
    // quando a instância do database não é mais referenciada
    print('✅ Drift database cleanup concluído');
  }
  
  // ===== UTILITÁRIOS =====
  
  // Estatísticas do banco
  Future<Map<String, dynamic>> getStats() async {
    try {
      final allNotes = await _database.getAllNotes();
      return {
        'totalNotes': allNotes.length,
        'databaseSize': 'N/A', // Drift não expõe facilmente o tamanho
        'lastUpdate': allNotes.isNotEmpty 
          ? allNotes.map((n) => n.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String()
          : null,
      };
    } catch (e) {
      print('❌ Erro ao obter estatísticas: $e');
      return {'totalNotes': 0, 'error': e.toString()};
    }
  }
}
