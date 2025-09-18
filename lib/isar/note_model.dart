import 'package:isar/isar.dart';

part 'note_model.g.dart';

// Modelo de dados para Isar
// Usa @collection para definir uma coleção no banco Isar
@collection
class IsarNote {
  Id id = Isar.autoIncrement; // Isar gerencia automaticamente o ID

  @Index()
  late String title;
  
  late String content;
  
  @Index()
  late DateTime createdAt;
  
  late DateTime updatedAt;

  IsarNote({
    this.id = Isar.autoIncrement,
    required this.title,
    required this.content,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  // Método para atualizar timestamp
  void updateTimestamp() {
    updatedAt = DateTime.now();
  }

  // Conversão para Map (para compatibilidade com UI)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'IsarNote{id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
