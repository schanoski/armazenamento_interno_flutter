// CRUD usando Isar
// 
// Isar é um banco NoSQL moderno para Flutter
// Oferece excelente performance, queries poderosas e facilidade de uso
// 
// Funcionalidades implementadas:
// ✅ Create, Read, Update, Delete operations
// ✅ Isar instance management
// ✅ @collection annotations e code generation
// ✅ Queries rápidas com indexação automática
// ✅ Busca por título com filtros avançados
// ✅ Estatísticas e análises do banco
// 
// Para usar: Execute 'dart run build_runner build' para gerar código
// 
// Documentação oficial: https://isar.dev/

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'note_model.dart';

class IsarNoteCrud {
  late Isar _isar;
  
  // ===== INICIALIZAÇÃO =====
  
  Future<void> init() async {
    try {
      // Obter diretório para armazenamento
      final dir = await getApplicationDocumentsDirectory();
      
      // Abrir instância do Isar
      _isar = await Isar.open(
        [IsarNoteSchema],
        directory: dir.path,
        name: 'isar_notes',
      );
      
      print('✅ Isar database inicializado com sucesso');
      print('📊 Caminho do banco: ${dir.path}');
    } catch (e) {
      print('❌ Erro ao inicializar Isar: $e');
      rethrow;
    }
  }
  
  // ===== CRUD OPERATIONS =====
  
  // Create - Criar uma nova nota
  Future<int> createNote(String title, String content) async {
    try {
      final note = IsarNote(
        title: title,
        content: content,
      );
      
      final id = await _isar.writeTxn(() async {
        return await _isar.isarNotes.put(note);
      });
      
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
      final notes = await _isar.isarNotes.where().findAll();
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
      final note = await _isar.isarNotes.get(id);
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
      final note = await _isar.isarNotes.get(id);
      if (note != null) {
        note.title = title;
        note.content = content;
        note.updateTimestamp();
        
        await _isar.writeTxn(() async {
          await _isar.isarNotes.put(note);
        });
        
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
      final success = await _isar.writeTxn(() async {
        return await _isar.isarNotes.delete(id);
      });
      
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
  
  // Buscar notas por título usando filtros do Isar
  Future<List<Map<String, dynamic>>> searchNotesByTitle(String searchTerm) async {
    try {
      final notes = await _isar.isarNotes
          .filter()
          .titleContains(searchTerm, caseSensitive: false)
          .findAll();
      
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
      final count = await _isar.writeTxn(() async {
        return await _isar.isarNotes.where().deleteAll();
      });
      
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
      
      final notes = await _isar.isarNotes
          .filter()
          .createdAtBetween(startOfDay, endOfDay)
          .findAll();
      
      print('✅ ${notes.length} notas criadas hoje');
      return notes.map((note) => note.toMap()).toList();
    } catch (e) {
      print('❌ Erro ao buscar notas de hoje: $e');
      return [];
    }
  }
  
  // Buscar notas por período de criação
  Future<List<Map<String, dynamic>>> getNotesByDateRange(DateTime start, DateTime end) async {
    try {
      final notes = await _isar.isarNotes
          .filter()
          .createdAtBetween(start, end)
          .sortByCreatedAtDesc()
          .findAll();
      
      print('✅ ${notes.length} notas encontradas no período');
      return notes.map((note) => note.toMap()).toList();
    } catch (e) {
      print('❌ Erro ao buscar notas por período: $e');
      return [];
    }
  }
  
  // Fechar conexão (importante para cleanup)
  Future<void> close() async {
    try {
      await _isar.close();
      print('✅ Isar instance fechado');
    } catch (e) {
      print('❌ Erro ao fechar Isar instance: $e');
    }
  }
  
  // ===== UTILITÁRIOS =====
  
  // Estatísticas do banco
  Future<Map<String, dynamic>> getStats() async {
    try {
      final allNotes = await _isar.isarNotes.where().findAll();
      final todayNotes = await getNotesCreatedToday();
      
      return {
        'totalNotes': allNotes.length,
        'todayNotes': todayNotes.length,
        'databaseSize': '${await _isar.getSize()} bytes',
        'lastUpdate': allNotes.isNotEmpty 
          ? allNotes.map((n) => n.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String()
          : null,
        'performance': 'Modern NoSQL',
        'type': 'Flutter-optimized database',
      };
    } catch (e) {
      print('❌ Erro ao obter estatísticas: $e');
      return {'totalNotes': 0, 'error': e.toString()};
    }
  }
  
  // Análise de conteúdo
  Future<Map<String, dynamic>> getContentAnalysis() async {
    try {
      final allNotes = await _isar.isarNotes.where().findAll();
      
      if (allNotes.isEmpty) {
        return {'analysis': 'Nenhuma nota para analisar'};
      }
      
      final totalWords = allNotes.fold<int>(0, (sum, note) => 
        sum + note.content.split(' ').length);
      
      final avgWordsPerNote = totalWords / allNotes.length;
      
      final longestNote = allNotes.reduce((a, b) => 
        a.content.length > b.content.length ? a : b);
      
      return {
        'totalWords': totalWords,
        'avgWordsPerNote': avgWordsPerNote.toStringAsFixed(1),
        'longestNoteId': longestNote.id,
        'longestNoteLength': longestNote.content.length,
      };
    } catch (e) {
      print('❌ Erro na análise de conteúdo: $e');
      return {'error': e.toString()};
    }
  }
}
