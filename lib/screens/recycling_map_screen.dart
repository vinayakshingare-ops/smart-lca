import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class RecyclingMapScreen extends StatefulWidget {
  const RecyclingMapScreen({super.key});

  @override
  State<RecyclingMapScreen> createState() => _RecyclingMapScreenState();
}

class _RecyclingMapScreenState extends State<RecyclingMapScreen> {
  final MapController _mapController = MapController();
  final LatLng _center = const LatLng(18.6296, 73.8014); // Pimpri Center

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    // Generate markers
    List<Marker> markers = db.recyclingCenters.map((center) {
      return Marker(
        point: LatLng(center.latitude, center.longitude),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(center.centerName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('📍 ${center.address}'),
                    const SizedBox(height: 4),
                    Text('🕐 ${center.openingHours}'),
                    const SizedBox(height: 4),
                    Text(
                        '♻️ Accepts: ${center.acceptedMaterials.join(', ')}'),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withAlpha(80),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child:
                    const Icon(Icons.recycling, color: Colors.white, size: 22),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 2)
                  ],
                ),
                child: Text(
                  center.centerName.split(' ').first,
                  style: const TextStyle(
                      fontSize: 8, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    // Mock Route Polyline
    List<Polyline> polylines = [
      Polyline(
        points: const [
          LatLng(18.6280, 73.8000),
          LatLng(18.6285, 73.8005),
          LatLng(18.6296, 73.8014),
        ],
        color: Colors.blue,
        strokeWidth: 4.0,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Recycling Hubs'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.smart_lca_mine',
          ),
          PolylineLayer(polylines: polylines),
          MarkerLayer(markers: markers),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          db.addEcoCoins(20);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recycled successfully! +20 EcoCoins')));
        },
        label: const Text('Log Recycling'),
        icon: const Icon(Icons.recycling),
      ),
    );
  }
}
