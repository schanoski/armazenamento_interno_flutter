import 'package:flutter/material.dart';

// Importar exemplos das diferentes tecnologias
import 'shared_preferences/example.dart';
import 'hive/example.dart';
import 'sqflite/example.dart';
import 'drift/example.dart';
import 'objectbox/example.dart';
import 'isar/example.dart';

void main() {
  runApp(const ArmazenamentoInternoApp());
}

class ArmazenamentoInternoApp extends StatelessWidget {
  const ArmazenamentoInternoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Armazenamento Interno Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StorageSelectionPage(),
    );
  }
}

class StorageSelectionPage extends StatelessWidget {
  const StorageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tipos de Armazenamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Escolha uma tecnologia de armazenamento para ver o exemplo:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            _buildStorageOption(
              context,
              'SharedPreferences',
              'Ideal para configurações simples',
              Icons.settings,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SharedPreferencesExample(),
                ),
              ),
            ),
            
            _buildStorageOption(
              context,
              'Hive',
              'NoSQL rápido e leve',
              Icons.speed,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HiveExample(),
                ),
              ),
            ),
            
            _buildStorageOption(
              context,
              'SQLite',
              'Banco relacional tradicional',
              Icons.storage,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SqliteExample(),
                ),
              ),
            ),
            
            _buildStorageOption(
              context,
              'Drift',
              'ORM type-safe para SQLite',
              Icons.code,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DriftExample(),
                ),
              ),
            ),
            
            _buildStorageOption(
              context,
              'ObjectBox',
              'Banco orientado a objetos',
              Icons.storage_outlined,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ObjectBoxExample(),
                ),
              ),
            ),
            
            _buildStorageOption(
              context,
              'Isar',
              'NoSQL moderno para Flutter',
              Icons.flash_on,
              Colors.cyan,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IsarExample(),
                ),
              ),
            ),
            
            const Spacer(),
            
            Card(
              color: Colors.grey[100],
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'Cada tecnologia tem suas vantagens específicas. '
                      'Explore os exemplos para entender as diferenças!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showNotImplemented(BuildContext context, String technology) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(technology),
        content: Text(
          'O exemplo para $technology será implementado em breve!\n\n'
          'Por enquanto, você pode encontrar a estrutura básica em:\n'
          'lib/${technology.toLowerCase()}/',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Exemplos programáticos para teste
class ExampleRunner {
  static Future<void> runAllExamples() async {
    print('=== Executando Exemplos de Armazenamento ===\n');
    
    // SharedPreferences
    print('🔵 SharedPreferences:');
    try {
      await SharedPreferencesProgrammaticExample.runExample();
    } catch (e) {
      print('Erro no SharedPreferences: $e');
    }
    
    print('\n' + '='*50 + '\n');
    
    // Hive
    print('🟠 Hive:');
    try {
      await HiveProgrammaticExample.runExample();
    } catch (e) {
      print('Erro no Hive: $e');
    }
    
    print('\n' + '='*50 + '\n');
    print('✅ Exemplos concluídos!');
  }
}
