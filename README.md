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

## 🚀 Como Usar Este Projeto

### Instalação
```bash
flutter pub get
```

### Build Runner (para Hive, Drift, ObjectBox e Isar)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Executar
```bash
flutter run
```

---

## 📝 Exemplos CRUD por Tecnologia

### 1. SharedPreferences
```dart
final prefs = await SharedPreferences.getInstance();
// CREATE
prefs.setString('note_1', '{"title": "Minha Nota", "content": "Conteúdo"}');
// READ
final noteJson = prefs.getString('note_1');
// UPDATE
prefs.setString('note_1', '{"title": "Nota Editada", "content": "Novo conteúdo"}');
// DELETE
prefs.remove('note_1');
```

---

### 2. Hive
```dart
final box = await Hive.openBox<HiveNote>('notes');
// CREATE
box.add(HiveNote(title: 'Minha Nota', content: 'Conteúdo'));
// READ
final notes = box.values.toList();
// UPDATE
final note = box.getAt(0);
note?.title = 'Nota Editada';
note?.save();
// DELETE
box.deleteAt(0);
```

---

### 3. SQLite (sqflite)
```dart
final db = await openDatabase('notes.db', version: 1,
  onCreate: (db, version) {
    return db.execute('CREATE TABLE notes(id INTEGER PRIMARY KEY, title TEXT, content TEXT)');
  },
);
// CREATE
await db.insert('notes', {'title': 'Minha Nota', 'content': 'Conteúdo'});
// READ
final notes = await db.query('notes');
// UPDATE
await db.update('notes', {'title': 'Nota Editada'}, where: 'id = ?', whereArgs: [1]);
// DELETE
await db.delete('notes', where: 'id = ?', whereArgs: [1]);
```

---

### 4. Drift
```dart
// CREATE
await db.into(db.notes).insert(NotesCompanion(
  title: Value('Minha Nota'),
  content: Value('Conteúdo'),
));
// READ
final notes = await db.select(db.notes).get();
// UPDATE
await db.update(db.notes).replace(NotesCompanion(
  id: Value(1),
  title: Value('Nota Editada'),
  content: Value('Novo conteúdo'),
));
// DELETE
await (db.delete(db.notes)..where((tbl) => tbl.id.equals(1))).go();
```

---

### 5. ObjectBox
```dart
final store = await openStore();
final box = store.box<ObjectBoxNote>();
// CREATE
box.put(ObjectBoxNote(title: 'Minha Nota', content: 'Conteúdo'));
// READ
final notes = box.getAll();
// UPDATE
final note = box.get(1);
note?.title = 'Nota Editada';
if (note != null) box.put(note);
// DELETE
box.remove(1);
```

---

### 6. Isar
```dart
final isar = await Isar.open([IsarNoteSchema]);
// CREATE
await isar.writeTxn(() => isar.isarNotes.put(IsarNote(title: 'Minha Nota', content: 'Conteúdo')));
// READ
final notes = await isar.isarNotes.where().findAll();
// UPDATE
await isar.writeTxn(() async {
  final note = await isar.isarNotes.get(1);
  if (note != null) {
    note.title = 'Nota Editada';
    await isar.isarNotes.put(note);
  }
});
// DELETE
await isar.writeTxn(() => isar.isarNotes.delete(1));
```

---

## 🔍 Comparação de Performance

| Tecnologia       | Velocidade Leitura | Velocidade Escrita | Facilidade de Uso | Type Safety |
|------------------|-------------------|-------------------|------------------|-------------|
| SharedPreferences | Baixa             | Baixa             | ⭐⭐⭐⭐⭐            | ⭐⭐          |
| Hive              | ⭐⭐⭐⭐⭐             | ⭐⭐⭐⭐⭐             | ⭐⭐⭐⭐             | ⭐⭐⭐⭐        |
| SQLite            | ⭐⭐⭐⭐              | ⭐⭐⭐               | ⭐⭐               | ⭐⭐          |
| Drift             | ⭐⭐⭐⭐              | ⭐⭐⭐               | ⭐⭐⭐              | ⭐⭐⭐⭐⭐       |
| ObjectBox         | ⭐⭐⭐⭐⭐             | ⭐⭐⭐⭐⭐             | ⭐⭐⭐              | ⭐⭐⭐⭐        |
| Isar              | ⭐⭐⭐⭐⭐             | ⭐⭐⭐⭐⭐             | ⭐⭐⭐⭐             | ⭐⭐⭐⭐⭐       |

---

## 🎯 Quando Usar

- **SharedPreferences:** dados simples, preferências, <1MB.  
- **Hive:** rápido, leve, sem dependências nativas.  
- **SQLite:** queries SQL, dados relacionais complexos.  
- **Drift:** type-safety, reatividade, migrations automáticas.  
- **ObjectBox:** performance extrema, IoT, dados orientados a objetos.  
- **Isar:** moderno, schema flexível, milhões de registros.  

---

## 🏗️ Arquitetura Recomendada (Repository Pattern)

```dart
abstract class NoteRepository {
  Future<Note> createNote(String title, String content);
  Future<List<Note>> getAllNotes();
  Future<Note?> getNoteById(int id);
  Future<Note?> updateNote(int id, {String? title, String? content});
  Future<bool> deleteNote(int id);
}

class HiveNoteRepository implements NoteRepository {
  final HiveNoteCrud _crud = HiveNoteCrud();
  
  @override
  Future<Note> createNote(String title, String content) =>
      _crud.createNote(title, content);
  
  // ... implementar outros métodos
}
```

---

## 📚 Recursos Adicionais
- [SharedPreferences](https://pub.dev/packages/shared_preferences)  
- [Hive](https://docs.hivedb.dev/)  
- [sqflite](https://pub.dev/packages/sqflite)  
- [Drift](https://drift.simonbinder.eu/)  
- [ObjectBox](https://docs.objectbox.io/)  
- [Isar](https://isar.dev/)  

---

## 👥 Grupo de Estudo Gralha Azul
Este projeto faz parte dos estudos do **Grupo de Estudo Gralha Azul**, onde exploramos práticas e tecnologias Flutter.  
Junte-se a nós para aprender e compartilhar conhecimento! 🚀  
