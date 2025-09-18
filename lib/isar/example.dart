import 'package:flutter/material.dart';
import 'note_crud.dart';

class IsarExample extends StatefulWidget {
  const IsarExample({super.key});

  @override
  State<IsarExample> createState() => _IsarExampleState();
}

class _IsarExampleState extends State<IsarExample> {
  final IsarNoteCrud _crud = IsarNoteCrud();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = false;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _analysis;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await _crud.init();
      await _loadNotes();
      await _loadStats();
      await _loadAnalysis();
    } catch (e) {
      _showSnackBar('Erro ao inicializar: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await _crud.getAllNotes();
      setState(() => _notes = notes);
    } catch (e) {
      _showSnackBar('Erro ao carregar notas: $e', isError: true);
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _crud.getStats();
      setState(() => _stats = stats);
    } catch (e) {
      _showSnackBar('Erro ao carregar estatísticas: $e', isError: true);
    }
  }

  Future<void> _loadAnalysis() async {
    try {
      final analysis = await _crud.getContentAnalysis();
      setState(() => _analysis = analysis);
    } catch (e) {
      _showSnackBar('Erro ao carregar análise: $e', isError: true);
    }
  }

  Future<void> _addNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      _showSnackBar('Preencha título e conteúdo!', isError: true);
      return;
    }

    try {
      await _crud.createNote(_titleController.text, _contentController.text);
      _titleController.clear();
      _contentController.clear();
      await _loadNotes();
      await _loadStats();
      await _loadAnalysis();
      _showSnackBar('✅ Nota criada com sucesso!');
    } catch (e) {
      _showSnackBar('Erro ao criar nota: $e', isError: true);
    }
  }

  Future<void> _deleteNote(int id) async {
    try {
      final success = await _crud.deleteNote(id);
      if (success) {
        await _loadNotes();
        await _loadStats();
        await _loadAnalysis();
        _showSnackBar('✅ Nota deletada!');
      } else {
        _showSnackBar('❌ Nota não encontrada!', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erro ao deletar: $e', isError: true);
    }
  }

  Future<void> _searchNotes() async {
    if (_searchController.text.isEmpty) {
      await _loadNotes();
      return;
    }

    try {
      final notes = await _crud.searchNotesByTitle(_searchController.text);
      setState(() => _notes = notes);
    } catch (e) {
      _showSnackBar('Erro na busca: $e', isError: true);
    }
  }

  Future<void> _loadTodayNotes() async {
    try {
      final notes = await _crud.getNotesCreatedToday();
      setState(() => _notes = notes);
      _showSnackBar('📅 Mostrando notas de hoje (${notes.length})');
    } catch (e) {
      _showSnackBar('Erro ao carregar notas de hoje: $e', isError: true);
    }
  }

  Future<void> _loadThisWeekNotes() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));
      
      final notes = await _crud.getNotesByDateRange(startOfWeek, endOfWeek);
      setState(() => _notes = notes);
      _showSnackBar('📅 Mostrando notas desta semana (${notes.length})');
    } catch (e) {
      _showSnackBar('Erro ao carregar notas da semana: $e', isError: true);
    }
  }

  Future<void> _clearAllNotes() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deletar todas as notas?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Deletar')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final deletedCount = await _crud.deleteAllNotes();
        await _loadNotes();
        await _loadStats();
        await _loadAnalysis();
        _showSnackBar('✅ $deletedCount notas deletadas!');
      } catch (e) {
        _showSnackBar('Erro ao deletar todas: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isar Example'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Stats Card
                  if (_stats != null) ...[
                    Card(
                      color: Colors.cyan.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text('${_stats!['totalNotes']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                    const Text('Notas', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('${_stats!['todayNotes'] ?? 0}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                    const Text('Hoje', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Modern', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const Text('NoSQL', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            if (_analysis != null && _analysis!['totalWords'] != null) ...[
                              const SizedBox(height: 8),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text('${_analysis!['totalWords']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const Text('Palavras', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text('${_analysis!['avgWordsPerNote']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const Text('Média/Nota', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Add Note Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Título da Nota',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.title),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _contentController,
                            decoration: const InputDecoration(
                              labelText: 'Conteúdo',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _addNote,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Adicionar Nota'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyan,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _clearAllNotes,
                                icon: const Icon(Icons.delete_sweep),
                                label: const Text('Limpar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search and Filters
                  Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar por título',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadNotes();
                            },
                          ),
                        ),
                        onChanged: (_) => _searchNotes(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _loadTodayNotes,
                              icon: const Icon(Icons.today),
                              label: const Text('Hoje'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _loadThisWeekNotes,
                              icon: const Icon(Icons.date_range),
                              label: const Text('Esta Semana'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _loadNotes,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Todos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Notes List
                  Expanded(
                    child: _notes.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flash_on, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Nenhuma nota encontrada!\nCrie sua primeira nota usando Isar.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _notes.length,
                            itemBuilder: (context, index) {
                              final note = _notes[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                    note['title'] ?? 'Sem título',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(note['content'] ?? 'Sem conteúdo'),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'ID: ${note['id']} • ',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                          Text(
                                            'Palavras: ${(note['content'] ?? '').split(' ').length} • ',
                                            style: const TextStyle(fontSize: 12, color: Colors.cyan),
                                          ),
                                          Text(
                                            'Criado: ${DateTime.parse(note['createdAt']).toLocal().toString().split(' ')[0]}',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteNote(note['id']),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.cyan,
                                    child: Text(
                                      '${note['id']}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    _crud.close();
    super.dispose();
  }
}
