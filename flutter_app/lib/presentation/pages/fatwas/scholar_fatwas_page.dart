import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Provider to fetch fatwas for a specific scholar
final scholarFatwasProvider = FutureProvider.family<List<dynamic>, String>((ref, scholarName) async {
  // Pass the scholar name as a query parameter
  final Uri apiUrl = Uri.parse('http://127.0.0.1:8000/fatwas').replace(
    queryParameters: {
      'scholar': scholarName,
      'page': '1', 
    },
  );

  final response = await http.get(apiUrl);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data['fatwas']; // Returns the list of fatwa dictionaries
  } else {
    throw Exception('Failed to load fatwas');
  }
});

class ScholarFatwasPage extends ConsumerWidget {
  final String scholarName;

  const ScholarFatwasPage({super.key, required this.scholarName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fatwasAsyncValue = ref.watch(scholarFatwasProvider(scholarName));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(scholarName),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: fatwasAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (fatwas) {
          if (fatwas.isEmpty) {
            return const Center(child: Text('No fatwas found on this page.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: fatwas.length,
            itemBuilder: (context, index) {
              final fatwa = fatwas[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fatwa['title'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fatwa['summary'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}