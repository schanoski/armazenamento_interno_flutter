import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

/// CRUD usando SharedPreferences
/// 
/// SharedPreferences é ideal para armazenar configurações simples e dados pequenos
/// como preferências do usuário, configurações da aplicação, etc.
/// 
/// Vantagens:
/// - Muito simples de usar
/// - Ideal para dados pequenos e configurações
/// - Multiplataforma
/// 
/// Desvantagens:
/// - Não é adequado para grandes volumes de dados
/// - Não suporta consultas complexas
/// - Carrega todos os dados na memória
class SharedPreferencesNoteCrud {
  static const String _notesKey = 'notes';
  static const String _counterKey = 'notes_counter';

  /// Criar uma nova nota
  Future<Note> createNote(String title, String content) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Gerar ID único usando um contador
    final int id = (prefs.getInt(_counterKey) ?? 0) + 1;
    await prefs.setInt(_counterKey, id);
    
    final note = Note(
      id: id,
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    
    // Obter notas existentes
    final notes = await getAllNotes();
    notes.add(note);
    
    // Salvar de volta
    await _saveNotes(notes);
    
    return note;
  }

  /// Ler todas as notas
  Future<List<Note>> getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString(_notesKey);
    
    if (notesJson == null) return [];
    
    final List<dynamic> notesList = json.decode(notesJson);
    return notesList.map((json) => Note.fromJson(json)).toList();
  }

  /// Ler uma nota específica por ID
  Future<Note?> getNoteById(int id) async {
    final notes = await getAllNotes();
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Atualizar uma nota
  Future<Note?> updateNote(int id, {String? title, String? content}) async {
    final notes = await getAllNotes();
    final index = notes.indexWhere((note) => note.id == id);
    
    if (index == -1) return null;
    
    final updatedNote = notes[index].copyWith(
      title: title ?? notes[index].title,
      content: content ?? notes[index].content,
      updatedAt: DateTime.now(),
    );
    
    notes[index] = updatedNote;
    await _saveNotes(notes);
    
    return updatedNote;
  }

  /// Deletar uma nota
  Future<bool> deleteNote(int id) async {
    final notes = await getAllNotes();
    final initialLength = notes.length;
    
    notes.removeWhere((note) => note.id == id);
    
    if (notes.length < initialLength) {
      await _saveNotes(notes);
      return true;
    }
    
    return false;
  }

  /// Deletar todas as notas
  Future<void> deleteAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notesKey);
    await prefs.remove(_counterKey);
  }

  /// Buscar notas por título ou conteúdo
  Future<List<Note>> searchNotes(String query) async {
    final notes = await getAllNotes();
    final lowercaseQuery = query.toLowerCase();
    
    return notes.where((note) =>
      note.title.toLowerCase().contains(lowercaseQuery) ||
      note.content.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  /// Salvar lista de notas no SharedPreferences
  Future<void> _saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(notes.map((note) => note.toJson()).toList());
    await prefs.setString(_notesKey, notesJson);
  }

  /// Contar total de notas
  Future<int> getNotesCount() async {
    final notes = await getAllNotes();
    return notes.length;
  }
}
