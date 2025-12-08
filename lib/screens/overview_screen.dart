import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import 'new_entry_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
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
    const bangladeshCenter = LatLng(23.6850, 90.3563);

    return FutureBuilder<List<Landmark>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final landmarks = snapshot.data ?? [];

        final markers = landmarks.map((lm) {
          return Marker(
            width: 40,
            height: 40,
            point: LatLng(lm.lat, lm.lon),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => _LandmarkBottomSheet(
                    landmark: lm,
                    onEdited: _reload,
                    onDeleted: _reload,
                  ),
                );
              },
              child: const Icon(
                Icons.location_on,
                color: Colors.tealAccent,
                size: 32,
              ),
            ),
          );
        }).toList();

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                center: bangladeshCenter,
                zoom: 6.5,
              ),
              children: [
                TileLayer(
                  // You can change this URL to a dark-themed tile server if you want
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              right: 16,
              top: 40,
              child: FloatingActionButton(
                heroTag: 'refresh_map',
                onPressed: _reload,
                child: const Icon(Icons.refresh),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LandmarkBottomSheet extends StatelessWidget {
  final Landmark landmark;
  final VoidCallback onEdited;
  final VoidCallback onDeleted;

  const _LandmarkBottomSheet({
    required this.landmark,
    required this.onEdited,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          runSpacing: 16,
          children: [
            ListTile(
              title: Text(landmark.title),
              subtitle: Text(
                'Lat: ${landmark.lat.toStringAsFixed(4)}, '
                'Lon: ${landmark.lon.toStringAsFixed(4)}',
              ),
            ),
            if (landmark.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  landmark.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Text('Image not available'),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () async {
                    Navigator.pop(context); // close sheet
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewEntryScreen(existing: landmark),
                      ),
                    );
                    onEdited();
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  onPressed: () async {
                    final api = ApiService();
                    try {
                      await api.deleteLandmark(landmark.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Landmark deleted'),
                          ),
                        );
                      }
                      onDeleted();
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Error'),
                          content: Text(e.toString()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
