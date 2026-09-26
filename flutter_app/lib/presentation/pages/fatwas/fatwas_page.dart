import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
// Adjust this path if your app_router.dart is located elsewhere
import '../../router/app_router.dart';

// --- API Provider ---
// This provider fetches the data from your FastAPI backend.
final scholarsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  // IMPORTANT IP ADDRESS NOTE:
  // If running on an Android Emulator, use 'http://10.0.2.2:8000/scholars'
  // If running on iOS Simulator or Web, use 'http://127.0.0.1:8000/scholars'
  // const String apiUrl = 'http://10.0.2.2:8000/scholars?page=1'; 
  const String apiUrl = 'http://127.0.0.1:8000/scholars?page=1';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> scholarsJson = data['scholars'];
    
    // Map the dynamic list to a List<String>
    return scholarsJson.map((e) => e.toString()).toList();
  } else {
    throw Exception('Failed to load scholars. Status Code: ${response.statusCode}');
  }
});

// --- UI Screen ---
class FatwasPage extends ConsumerWidget {
  const FatwasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to listen for data, loading, or error states
    final scholarsAsyncValue = ref.watch(scholarsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fatwa Scholars'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            MainShell.scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: scholarsAsyncValue.when(
        // 1. Loading State
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        // 2. Error State
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Could not fetch scholars.\nMake sure your FastAPI server is running.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Refresh the provider to try fetching again
                    ref.invalidate(scholarsProvider);
                  },
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
        // 3. Data State
        data: (scholars) {
          if (scholars.isEmpty) {
            return const Center(child: Text('No scholars found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: scholars.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    scholars[index],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios, 
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onTap: () {
                    final selectedScholar = scholars[index];
                    // Navigate to the detail page, passing the scholar's name in the URL
                    context.pushNamed(
                      'scholar-fatwas',
                      pathParameters: {'scholarName': selectedScholar},
                    // Action when a scholar is tapped (e.g., navigate to their specific fatwas)
                    // ScaffoldMessenger.of(context).showSnackBar(
                      // SnackBar(content: Text('Selected: ${scholars[index]}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}