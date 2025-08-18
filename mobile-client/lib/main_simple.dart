import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core Services
import 'core/config/environment_config.dart';

// Simple test screen
class SimpleTestScreen extends StatelessWidget {
  const SimpleTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GrabEat Test'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'GrabEat',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Connected to Cloud Services',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    print('🚀 Initializing GrabEat...');

    // Initialize environment configuration
    await EnvironmentConfig.initialize();
    print('✅ Environment config loaded');
    
    // Print configuration status
    EnvironmentConfig.printConfigStatus();

    // Initialize Supabase with environment configuration
    await Supabase.initialize(
      url: EnvironmentConfig.supabaseUrl,
      anonKey: EnvironmentConfig.supabaseAnonKey,
    );
    print('✅ Supabase initialized');

    runApp(
      const ProviderScope(
        child: GrabEatApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('❌ Error initializing app: $e');
    print('Stack trace: $stackTrace');
    
    // Run minimal app with error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 100, color: Colors.red),
                const SizedBox(height: 20),
                const Text('Initialization Error', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 10),
                Text('$e', style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GrabEatApp extends ConsumerWidget {
  const GrabEatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'GrabEat',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const SimpleTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}