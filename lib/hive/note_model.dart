import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class HiveNote extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? updatedAt;

  HiveNote({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  HiveNote copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HiveNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'HiveNote{id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
