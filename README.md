# 📦 Armazenamento Interno no Flutter - Guia Prático de Bancos de Dados

Este projeto demonstra como implementar operações **CRUD (Create, Read, Update, Delete)** usando diferentes tecnologias de armazenamento interno no Flutter.  
Cada implementação utiliza a entidade `Note` como exemplo prático.

---

## 📚 Tecnologias Abordadas

- **SharedPreferences** → Para configurações e dados simples  
- **Hive** → Banco NoSQL rápido e leve  
- **SQLite (sqflite)** → Banco relacional tradicional  
- **Drift** → ORM reativo type-safe para SQLite  
- **ObjectBox** → Banco NoSQL super rápido  
- **Isar** → Banco NoSQL moderno e otimizado para Flutter  

---

## 📖 Histórico e Curiosidades

### 1. SharedPreferences
- **História:** Criado no Android em 2008, inspirado no NSUserDefaults do iOS. No Flutter, o pacote `shared_preferences` abstrai APIs nativas.  
- **Curiosidade:** Usado em praticamente todo app mobile para guardar preferências do usuário, como tema, idioma e login automático.  

---

### 2. Hive
- **História:** Criado por Simon Leier em 2018 para ser rápido, leve e 100% em Dart. Inspirado em Realm e CouchDB.  
- **Curiosidade:** O nome "Hive" vem de colmeia 🐝, simbolizando organização e rapidez.  

---

### 3. SQLite (sqflite)
- **História:** Criado por D. Richard Hipp em 2000, é o banco de dados mais utilizado no mundo.  
- **Curiosidade:** O "Lite" vem do fato de ser pequeno e eficiente. Está presente em todos os Androids e iPhones.  

---

### 4. Drift
- **História:** Criado em 2018 como "Moor", rebatizado em 2021 para "Drift". É um ORM reativo e type-safe.  
- **Curiosidade:** Permite queries SQL escritas diretamente em Dart com checagem de tipos.  

---

### 5. ObjectBox
- **História:** Criado em 2017 por Markus Junginger e Vivien Müller (fundadores do greenDAO). Voltado para performance extrema em mobile e IoT.  
- **Curiosidade:** Usado até em carros conectados e automação industrial.  

---

### 6. Isar
- **História:** Criado em 2020 por Alexander Nozik, inspirado no Realm. O nome vem do rio que corta Munique (Alemanha).  
- **Curiosidade:** Lida com milhões de registros facilmente, com foco total em Flutter.  

---

**Este README é um guia prático e completo** para implementar armazenamento interno em Flutter usando:  
**SharedPreferences, Hive, SQLite (sqflite), Drift, ObjectBox e Isar**. Cada seção traz: configuração, estrutura de pastas sugerida, modelos, implementação completa do CRUD (serviço/repositório), exemplos de uso, testes básicos e dicas/armadilhas.

> Observação: este guia foca em código Flutter/Dart. Para ObjectBox, Isar e Hive você precisa rodar `build_runner` quando indicado.

---

## Índice

1. SharedPreferences  
2. Hive  
3. SQLite (sqflite)  
4. Drift  
5. ObjectBox  
6. Isar  
7. Estrutura de pastas sugerida  
8. Scripts úteis & comandos  
9. Testes básicos e checklist antes do release  
10. Licença

---

## Convenções usadas neste guia

- Entidade de exemplo: `Note` com campos: `id` (int), `title` (String), `content` (String), `createdAt` (DateTime), `updatedAt` (DateTime?).
- Dart SDK >= 2.17 / Flutter >= 3.x.
- Arquivos mostrados são exemplo; ajuste nomes e caminhos conforme seu projeto.

---

# 1) SharedPreferences

**Quando usar:** configurações, preferências, tokens pequenos (<1MB), flags.

### Dependência
```yaml
dependencies:
  shared_preferences: ^2.2.0
```

### Estrutura de arquivos sugerida
```
lib/
  shared_preferences/
    models/
      note_sp.dart
    services/
      shared_prefs_service.dart
    shared_prefs_note_repository.dart
```

### Modelo (serialização JSON)
`lib/shared_preferences/models/note_sp.dart`
```dart
class NoteSP {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NoteSP({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory NoteSP.fromJson(Map<String, dynamic> json) => NoteSP(
    id: json['id'] as int,
    title: json['title'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
  );
}
```

### Serviço (wrapper)
`lib/shared_preferences/services/shared_prefs_service.dart`
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _notesKey = 'notes_list_v1';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> _readNotesRaw() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_notesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _writeNotesRaw(List<Map<String, dynamic>> notes) async {
    final prefs = await _prefs;
    await prefs.setString(_notesKey, jsonEncode(notes));
  }

  Future<List<Map<String, dynamic>>> getAllNotesRaw() => _readNotesRaw();
}
```

### Repositório CRUD para `Note`
`lib/shared_preferences/shared_prefs_note_repository.dart`
```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'models/note_sp.dart';
import 'services/shared_prefs_service.dart';

class SharedPreferencesNoteRepository {
  final SharedPrefsService _service = SharedPrefsService();

  Future<List<NoteSP>> getAll() async {
    final raw = await _service.getAllNotesRaw();
    return raw.map((e) => NoteSP.fromJson(e)).toList();
  }

  Future<NoteSP> create({required String title, required String content}) async {
    final list = await _service.getAllNotesRaw();
    final id = (list.isEmpty ? 0 : (list.map((e) => e['id'] as int).reduce((a,b) => a > b ? a : b))) + 1;
    final now = DateTime.now();
    final note = NoteSP(id: id, title: title, content: content, createdAt: now);
    list.add(note.toJson());
    await _service._writeNotesRaw(list);
    return note;
  }

  Future<NoteSP?> getById(int id) async {
    final list = await _service.getAllNotesRaw();
    final json = list.firstWhere((e) => e['id'] == id, orElse: () => {});
    if (json.isEmpty) return null;
    return NoteSP.fromJson(json);
  }

  Future<NoteSP?> update(int id, {String? title, String? content}) async {
    final list = await _service.getAllNotesRaw();
    final idx = list.indexWhere((e) => e['id'] == id);
    if (idx == -1) return null;
    final current = NoteSP.fromJson(list[idx]);
    final updated = NoteSP(
      id: current.id,
      title: title ?? current.title,
      content: content ?? current.content,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    list[idx] = updated.toJson();
    await _service._writeNotesRaw(list);
    return updated;
  }

  Future<bool> delete(int id) async {
    final list = await _service.getAllNotesRaw();
    final newList = list.where((e) => e['id'] != id).toList();
    if (newList.length == list.length) return false;
    await _service._writeNotesRaw(newList);
    return true;
  }
}
```

### Observações
- SharedPreferences não é feito para grandes volumes. Evite armazenar muitos objetos grandes.
- Reescrevemos a lista inteira a cada alteração — custo aceitável para poucos itens.

---

# 2) Hive

**Quando usar:** dados estruturados, performance, sem dependências nativas e quando quiser objetos persistidos com adapters.

### Dependências
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.0
  build_runner: ^2.4.0
```

### Estrutura sugerida
```
lib/
  hive/
    models/
      hive_note.dart
    services/
      hive_service.dart
    repositories/
      hive_note_repository.dart
```

### Modelo com TypeAdapter
`lib/hive/models/hive_note.dart`
```dart
import 'package:hive/hive.dart';
part 'hive_note.g.dart';

@HiveType(typeId: 0)
class HiveNote extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? updatedAt;

  HiveNote({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });
}
```

> Rode: `dart run build_runner build --delete-conflicting-outputs` para gerar `hive_note.g.dart`.

### Serviço (inicialização)
`lib/hive/services/hive_service.dart`
```dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive_note.dart';

class HiveService {
  static const String boxName = 'notes_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HiveNoteAdapter());
    }
    await Hive.openBox<HiveNote>(boxName);
  }

  static Box<HiveNote> get box => Hive.box<HiveNote>(boxName);
}
```

### Repositório CRUD
`lib/hive/repositories/hive_note_repository.dart`
```dart
import '../models/hive_note.dart';
import '../services/hive_service.dart';

class HiveNoteRepository {
  Future<List<HiveNote>> getAll() async {
    final box = HiveService.box;
    return box.values.toList();
  }

  Future<HiveNote> create({required String title, required String content}) async {
    final box = HiveService.box;
    final id = (box.isEmpty ? 1 : (box.values.map((e)=>e.id).reduce((a,b) => a>b?a:b) + 1));
    final note = HiveNote(id: id, title: title, content: content, createdAt: DateTime.now());
    await box.add(note);
    return note;
  }

  Future<HiveNote?> getById(int id) async {
    final box = HiveService.box;
    return box.values.firstWhere((e) => e.id == id, orElse: () => null);
  }

  Future<HiveNote?> update(int id, {String? title, String? content}) async {
    final box = HiveService.box;
    final key = box.keys.firstWhere((k) => box.get(k)!.id == id, orElse: () => null);
    if (key == null) return null;
    final note = box.get(key);
    if (note == null) return null;
    note.title = title ?? note.title;
    note.content = content ?? note.content;
    note.updatedAt = DateTime.now();
    await note.save();
    return note;
  }

  Future<bool> delete(int id) async {
    final box = HiveService.box;
    final key = box.keys.firstWhere((k) => box.get(k)!.id == id, orElse: () => null);
    if (key == null) return false;
    await box.delete(key);
    return true;
  }
}
```

### Dicas
- Prefira `box.put(id, note)` se quiser usar id como chave.
- Para grandes boxes, use `LazyBox` ou queries com índices externos.
- Sempre fechar boxes no `dispose` de apps que não rodem continuamente (geralmente não necessário em apps móveis).

---

# 3) SQLite (sqflite)

**Quando usar:** relational schemas, SQL puro, transações e compatibilidade ampla.

### Dependências
```yaml
dependencies:
  sqflite: ^2.2.5
  path_provider: ^2.0.13
  path: ^1.8.3
```

### Estrutura sugerida
```
lib/
  sqflite/
    models/
      note_sql.dart
    services/
      database_helper.dart
    repositories/
      sqlite_note_repository.dart
```

### Modelo (simples)
`lib/sqflite/models/note_sql.dart`
```dart
class NoteSQL {
  int? id;
  String title;
  String content;
  DateTime createdAt;
  DateTime? updatedAt;

  NoteSQL({this.id, required this.title, required this.content, DateTime? createdAt, this.updatedAt})
    : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory NoteSQL.fromMap(Map<String, dynamic> map) => NoteSQL(
    id: map['id'] as int?,
    title: map['title'] as String,
    content: map['content'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
  );
}
```

### Database helper
`lib/sqflite/services/database_helper.dart`
```dart
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/note_sql.dart';
import 'dart:io';

class DatabaseHelper {
  static const _dbName = 'notes_app.db';
  static const _dbVersion = 1;
  static const notesTable = 'notes';

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    _database = await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
    return _database!;
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $notesTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }
}
```

### Repositório CRUD
`lib/sqflite/repositories/sqlite_note_repository.dart`
```dart
import '../models/note_sql.dart';
import '../services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class SqliteNoteRepository {
  Future<NoteSQL> create({required String title, required String content}) async {
    final db = await DatabaseHelper.database;
    final id = await db.insert(DatabaseHelper.notesTable, {
      'title': title,
      'content': content,
      'createdAt': DateTime.now().toIso8601String(),
    });
    final maps = await db.query(DatabaseHelper.notesTable, where: 'id = ?', whereArgs: [id]);
    return NoteSQL.fromMap(maps.first);
  }

  Future<List<NoteSQL>> getAll() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(DatabaseHelper.notesTable, orderBy: 'createdAt DESC');
    return maps.map((m) => NoteSQL.fromMap(m)).toList();
  }

  Future<NoteSQL?> getById(int id) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(DatabaseHelper.notesTable, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return NoteSQL.fromMap(maps.first);
  }

  Future<NoteSQL?> update(int id, {String? title, String? content}) async {
    final db = await DatabaseHelper.database;
    final current = await getById(id);
    if (current == null) return null;
    final updatedAt = DateTime.now().toIso8601String();
    await db.update(DatabaseHelper.notesTable, {
      'title': title ?? current.title,
      'content': content ?? current.content,
      'updatedAt': updatedAt,
    }, where: 'id = ?', whereArgs: [id]);
    return getById(id);
  }

  Future<bool> delete(int id) async {
    final db = await DatabaseHelper.database;
    final rows = await db.delete(DatabaseHelper.notesTable, where: 'id = ?', whereArgs: [id]);
    return rows > 0;
  }
}
```

### Dicas e migrações
- Para evoluir schema, aumente `DATABASE_VERSION` e implemente `onUpgrade`.
- Teste queries com `sqlitebrowser` exportando o arquivo do dispositivo/emulador.
- Use transações (`db.transaction`) para operações críticas.

---

# 4) Drift

**Quando usar:** queres type-safety, geração de código, queries reativas.

### Dependências
```yaml
dependencies:
  drift: ^2.5.0
  sqlite3_flutter_libs: ^0.5.6

dev_dependencies:
  drift_dev: ^2.5.0
  build_runner: ^2.4.0
```

### Estrutura sugerida
```
lib/
  drift/
    db/
      app_database.dart
    models/
      note_drift.dart (opc)
    repositories/
      drift_note_repository.dart
```

### Definição da tabela e Database
`lib/drift/db/app_database.dart`
```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
part 'app_database.g.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text().nullable()();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'drift_notes.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);
  Future<List<Note>> getAllNotes() => select(notes).get();
  Future<Note?> getNoteById(int id) => (select(notes)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<bool> updateNoteData(NotesCompanion note) => update(notes).replace(note);
  Future<int> deleteNoteById(int id) => (delete(notes)..where((t)=>t.id.equals(id))).go();
}
```

> Rode: `dart run build_runner build --delete-conflicting-outputs` para gerar `app_database.g.dart`.

### Repositório de exemplo
`lib/drift/repositories/drift_note_repository.dart`
```dart
import '../db/app_database.dart';

class DriftNoteRepository {
  final AppDatabase db;
  DriftNoteRepository(this.db);

  Future<Note> create({required String title, required String content}) async {
    final id = await db.insertNote(NotesCompanion.insert(
      title: title,
      content: content,
      createdAt: DateTime.now().toIso8601String(),
    ));
    final created = await db.getNoteById(id);
    return created!;
  }

  Future<List<Note>> getAll() => db.getAllNotes();

  Future<Note?> getById(int id) => db.getNoteById(id);

  Future<bool> update(int id, {String? title, String? content}) async {
    final note = await getById(id);
    if (note == null) return false;
    final companion = NotesCompanion(
      id: Value(id),
      title: Value(title ?? note.title),
      content: Value(content ?? note.content),
      createdAt: Value(note.createdAt),
      updatedAt: Value(DateTime.now().toIso8601String()),
    );
    return db.updateNoteData(companion);
  }

  Future<int> delete(int id) => db.deleteNoteById(id);
}
```

### Observações
- Drift gera tipos seguros; aprenda as `Companion` classes.
- Reatividade: use `select(notes).watch()` para streams.

---

# 5) ObjectBox

**Quando usar:** performance extrema, grandes volumes, modelo orientado a objetos.

### Dependências
```yaml
dependencies:
  objectbox: ^1.8.0
  objectbox_flutter_libs: any

dev_dependencies:
  objectbox_generator: any
  build_runner: ^2.4.0
```

### Estrutura sugerida
```
lib/
  objectbox/
    models/
      objectbox_note.dart
    objectbox.g.dart (gerado)
    objectbox_store.dart
    repositories/
      objectbox_note_repository.dart
```

### Modelo
`lib/objectbox/models/objectbox_note.dart`
```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class ObjectBoxNote {
  int id;
  String title;
  String content;
  DateTime createdAt;
  DateTime? updatedAt;

  ObjectBoxNote({
    this.id = 0,
    required this.title,
    required this.content,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
```

### Inicializar Store
`lib/objectbox/objectbox_store.dart`
```dart
import 'objectbox.g.dart'; // gerado
import 'package:objectbox/objectbox.dart';

late final Store _store;

Future<void> initObjectBox() async {
  _store = await openStore();
}

Store get store => _store;
```

> Rode `dart run build_runner build` para gerar `objectbox.g.dart` com o schema.

### Repositório CRUD
`lib/objectbox/repositories/objectbox_note_repository.dart`
```dart
import 'package:objectbox/objectbox.dart';
import '../objectbox_store.dart';
import '../models/objectbox_note.dart';

class ObjectBoxNoteRepository {
  Box<ObjectBoxNote> get _box => store.box<ObjectBoxNote>();

  Future<ObjectBoxNote> create({required String title, required String content}) async {
    final note = ObjectBoxNote(title: title, content: content);
    final id = _box.put(note);
    note.id = id;
    return note;
  }

  List<ObjectBoxNote> getAll() => _box.getAll();

  ObjectBoxNote? getById(int id) => _box.get(id);

  Future<ObjectBoxNote?> update(int id, {String? title, String? content}) async {
    final note = _box.get(id);
    if (note == null) return null;
    note.title = title ?? note.title;
    note.content = content ?? note.content;
    note.updatedAt = DateTime.now();
    _box.put(note);
    return note;
  }

  bool delete(int id) => _box.remove(id);
}
```

### Dicas
- ObjectBox tem suporte a queries indexadas, relações, e observers (`box.query(...).watch()`).
- Gere o código com build_runner sempre que alterar anotações.

---

# 6) Isar

**Quando usar:** performance, APIs modernas, queries reativas e indexadas.

### Dependências
```yaml
dependencies:
  isar: ^4.0.0
  isar_flutter_libs: any

dev_dependencies:
  isar_generator: any
  build_runner: ^2.4.0
```

### Estrutura sugerida
```
lib/
  isar/
    models/
      isar_note.dart
    isar_service.dart
    repositories/
      isar_note_repository.dart
```

### Modelo
`lib/isar/models/isar_note.dart`
```dart
import 'package:isar/isar.dart';

part 'isar_note.g.dart';

@collection
class IsarNote {
  Id id = Isar.autoIncrement;
  late String title;
  late String content;
  late DateTime createdAt;
  DateTime? updatedAt;

  IsarNote({
    this.id = Isar.autoIncrement,
    required this.title,
    required this.content,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
```

> Rode: `dart run build_runner build --delete-conflicting-outputs` para gerar `isar_note.g.dart`.

### Serviço (inicializar)
`lib/isar/isar_service.dart`
```dart
import 'package:isar/isar.dart';
import 'models/isar_note.dart';

class IsarService {
  static late final Future<Isar> _instance;

  static Future<void> init() async {
    _instance = Isar.open([IsarNoteSchema]);
  }

  static Future<Isar> get instance async => await _instance;
}
```

### Repositório CRUD
`lib/isar/repositories/isar_note_repository.dart`
```dart
import '../models/isar_note.dart';
import '../isar_service.dart';

class IsarNoteRepository {
  Future<Isar> get _isar async => await IsarService.instance;

  Future<IsarNote> create({required String title, required String content}) async {
    final isar = await _isar;
    final note = IsarNote(title: title, content: content);
    await isar.writeTxn(() async {
      await isar.isarNotes.put(note);
    });
    return note;
  }

  Future<List<IsarNote>> getAll() async {
    final isar = await _isar;
    return await isar.isarNotes.where().findAll();
  }

  Future<IsarNote?> getById(int id) async {
    final isar = await _isar;
    return await isar.isarNotes.get(id);
  }

  Future<IsarNote?> update(int id, {String? title, String? content}) async {
    final isar = await _isar;
    final note = await isar.isarNotes.get(id);
    if (note == null) return null;
    note.title = title ?? note.title;
    note.content = content ?? note.content;
    note.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.isarNotes.put(note);
    });
    return note;
  }

  Future<bool> delete(int id) async {
    final isar = await _isar;
    return await isar.writeTxn(() async {
      return await isar.isarNotes.delete(id);
    });
  }
}
```

### Dicas
- Isar tem queries muito rápidas e suporte a indices. Marque campos com `@Index()` quando necessário.
- Use `isar.writeTxn` para todas operações que alteram o DB.

---

# 7) Estrutura de pastas sugerida (projeto completo)

```
lib/
  main.dart
  core/
    models/
      note.dart          # modelo genérico usado pela UI (conversores entre storages)
    repositories/        # abstrações (NoteRepository)
  shared_preferences/
    ...
  hive/
    ...
  sqflite/
    ...
  drift/
    ...
  objectbox/
    ...
  isar/
    ...
  ui/
    screens/
      notes_list.dart
      note_edit.dart
    widgets/
      note_card.dart
```

### Exemplo de `core/models/note.dart`
```dart
class Note {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Note({required this.id, required this.title, required this.content, required this.createdAt, this.updatedAt});
}
```

---

# 8) Scripts úteis & comandos

- Instalar deps: `flutter pub get`  
- Gerar código: `dart run build_runner build --delete-conflicting-outputs`  
- Rodar app: `flutter run`  
- Limpar build runner: `dart run build_runner clean`

---



