import 'package:objectbox/objectbox.dart';

// Modelo de dados para ObjectBox
// Usa @Entity para definir uma entidade no banco ObjectBox
@Entity()
class ObjectBoxNote {
  @Id()
  int id = 0; // ObjectBox gerencia automaticamente o ID

  String title;
  String content;
  
  @Property(type: PropertyType.date)
  DateTime createdAt;
  
  @Property(type: PropertyType.date)  
  DateTime updatedAt;

  ObjectBoxNote({
    this.id = 0,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

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
    return 'ObjectBoxNote{id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
