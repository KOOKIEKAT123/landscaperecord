import 'package:flutter/material.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import 'new_entry_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final ApiService _api = ApiService();
  late Future<List<Landmark>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getLandmarks();
  }

  void _reload() {
    setState(() {
      _future = _api.getLandmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmark Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<List<Landmark>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final landmarks = snapshot.data ?? [];
          if (landmarks.isEmpty) {
            return const Center(child: Text('No landmarks yet'));
          }

          return ListView.builder(
            itemCount: landmarks.length,
            itemBuilder: (context, index) {
              final lm = landmarks[index];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Dismissible(
                  key: ValueKey(lm.id),
                  background: Container(
                    color: Colors.blueGrey,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Edit
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NewEntryScreen(existing: lm),
                        ),
                      );
                      _reload();
                      return false; // don't remove item from list
                    } else {
                      // Delete
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Landmark'),
                          content: Text(
                              'Are you sure you want to delete "${lm.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          await _api.deleteLandmark(lm.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Landmark deleted'),
                            ),
                          );
                          _reload();
                          return true;
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Error'),
                              content: Text(e.toString()),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return false;
                        }
                      }
                      return false;
                    }
                  },
                  child: Card(
                    child: ListTile(
                      leading: lm.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                lm.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text(lm.title),
                      subtitle: Text(
                        'Lat: ${lm.lat.toStringAsFixed(3)}, '
                        'Lon: ${lm.lon.toStringAsFixed(3)}',
                      ),
                    ),
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
