import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/recycling_center_model.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class RecyclingMapScreen extends StatefulWidget {
  const RecyclingMapScreen({super.key});

  @override
  State<RecyclingMapScreen> createState() => _RecyclingMapScreenState();
}

class _RecyclingMapScreenState extends State<RecyclingMapScreen> {
  final MapController _mapController = MapController();
  final LatLng _center = const LatLng(18.5430, 73.8567); // Pune center

  bool _isMapView = true;
  String? _selectedFilter; // null = all

  static const List<String> _wasteTypes = [
    'Plastic', 'E-Waste', 'Batteries', 'Metal', 'Paper', 'Glass', 'Organic Waste'
  ];

  static const Map<String, Color> _wasteColors = {
    'Plastic': Color(0xFF1565C0),
    'E-Waste': Color(0xFF6A1B9A),
    'Batteries': Color(0xFFF57F17),
    'Metal': Color(0xFF37474F),
    'Paper': Color(0xFF558B2F),
    'Glass': Color(0xFF00838F),
    'Organic Waste': Color(0xFF4E342E),
  };

  List<RecyclingCenter> _filteredCenters(List<RecyclingCenter> all) {
    if (_selectedFilter == null) return all;
    return all.where((c) => c.acceptedMaterials.contains(_selectedFilter)).toList();
  }

  void _openNavigation(double lat, double lng, String name) async {
    final uri = Uri.parse('https://maps.google.com/?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _callHub(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final filtered = _filteredCenters(db.recyclingCenters);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('♻️ Recycling Hubs'),
        actions: [
          // Toggle Map / List
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _ToggleTab(icon: Icons.map_outlined, label: 'Map', isActive: _isMapView,
                    onTap: () => setState(() => _isMapView = true)),
                _ToggleTab(icon: Icons.list_alt_rounded, label: 'List', isActive: !_isMapView,
                    onTap: () => setState(() => _isMapView = false)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── FILTER CHIPS ────────────────────────────────────────────────
          Container(
            height: 50,
            color: AppTheme.primaryColor,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _FilterChip(label: 'All', isSelected: _selectedFilter == null,
                    color: Colors.white,
                    onTap: () => setState(() => _selectedFilter = null)),
                ..._wasteTypes.map((type) => _FilterChip(
                  label: type,
                  isSelected: _selectedFilter == type,
                  color: _wasteColors[type] ?? Colors.grey,
                  onTap: () => setState(() => _selectedFilter = _selectedFilter == type ? null : type),
                )),
              ],
            ),
          ),

          // ── CONTENT ─────────────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _isMapView
                  ? _buildMapView(filtered)
                  : _buildListView(filtered),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'recycling-fab',
        onPressed: () {
          db.addEcoCoins(20);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('♻️ Recycled successfully! +20 EcoCoins'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        label: const Text('Log Recycling', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.recycling, color: Colors.white),
      ),
    );
  }

  // ── MAP VIEW ──────────────────────────────────────────────────────────────
  Widget _buildMapView(List<RecyclingCenter> centers) {
    return FlutterMap(
      key: const ValueKey('map'),
      mapController: _mapController,
      options: MapOptions(initialCenter: _center, initialZoom: 12.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.smart_lca_mine',
        ),
        MarkerLayer(
          markers: centers.map((center) {
            return Marker(
              point: LatLng(center.latitude, center.longitude),
              width: 56,
              height: 56,
              child: GestureDetector(
                onTap: () => _showHubSheet(center),
                child: Column(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withAlpha(100), blurRadius: 8, spreadRadius: 2)],
                      ),
                      child: const Icon(Icons.recycling, color: Colors.white, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
                      ),
                      child: Text(
                        '${center.distanceKm.toStringAsFixed(1)}km',
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── LIST VIEW ─────────────────────────────────────────────────────────────
  Widget _buildListView(List<RecyclingCenter> centers) {
    final sorted = List<RecyclingCenter>.from(centers)
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return ListView.builder(
      key: const ValueKey('list'),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: sorted.length,
      itemBuilder: (ctx, i) => _HubCard(
        center: sorted[i],
        wasteColors: _wasteColors,
        onNavigate: () => _openNavigation(sorted[i].latitude, sorted[i].longitude, sorted[i].centerName),
        onCall: () => _callHub(sorted[i].contactPhone),
      ),
    );
  }

  // ── HUB BOTTOM SHEET ──────────────────────────────────────────────────────
  void _showHubSheet(RecyclingCenter center) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.recycling, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text(center.centerName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${center.distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('📍 ${center.address}', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text('🕐 ${center.openingHours}', style: const TextStyle(color: Colors.black54)),
            if (center.contactPhone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('📞 ${center.contactPhone}', style: const TextStyle(color: Colors.black54)),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: center.acceptedMaterials.map((m) => Chip(
                label: Text(m, style: const TextStyle(fontSize: 11, color: Colors.white)),
                backgroundColor: _wasteColors[m] ?? AppTheme.primaryColor,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.navigation_rounded),
                    label: const Text('Navigate'),
                    onPressed: () => _openNavigation(center.latitude, center.longitude, center.centerName),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.call, color: AppTheme.primaryColor),
                  label: const Text('Call', style: TextStyle(color: AppTheme.primaryColor)),
                  onPressed: () => _callHub(center.contactPhone),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── WIDGET HELPERS ─────────────────────────────────────────────────────────

class _ToggleTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _ToggleTab({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: isActive ? AppTheme.primaryColor : Colors.white70),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: isActive ? AppTheme.primaryColor : Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
      ),
      child: Text(label,
          style: TextStyle(
              color: isSelected ? color : Colors.white70,
              fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
    ),
  );
}

class _HubCard extends StatelessWidget {
  final RecyclingCenter center;
  final Map<String, Color> wasteColors;
  final VoidCallback onNavigate;
  final VoidCallback onCall;
  const _HubCard({required this.center, required this.wasteColors, required this.onNavigate, required this.onCall});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.primaryColor.withAlpha(20), shape: BoxShape.circle),
                child: const Icon(Icons.recycling, color: AppTheme.primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(center.centerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('📍 ${center.address}', style: const TextStyle(color: Colors.black54, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
                child: Text('${center.distanceKm.toStringAsFixed(1)} km',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        // Details row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 13, color: Colors.black38),
              const SizedBox(width: 4),
              Text(center.openingHours, style: const TextStyle(color: Colors.black54, fontSize: 11)),
              const Spacer(),
              if (center.contactPhone.isNotEmpty) ...[
                const Icon(Icons.phone, size: 13, color: Colors.black38),
                const SizedBox(width: 4),
                Text('${center.contactPhone.substring(0, 7)}…',
                    style: const TextStyle(color: Colors.black54, fontSize: 11)),
              ],
            ],
          ),
        ),
        // Waste type chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Wrap(
            spacing: 6, runSpacing: 4,
            children: center.acceptedMaterials.map((m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (wasteColors[m] ?? AppTheme.primaryColor).withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: (wasteColors[m] ?? AppTheme.primaryColor).withAlpha(80)),
              ),
              child: Text(m, style: TextStyle(color: wasteColors[m] ?? AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ),
        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.navigation_rounded, size: 16),
                  label: const Text('Navigate', style: TextStyle(fontSize: 12)),
                  onPressed: onNavigate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.call, size: 16, color: AppTheme.primaryColor),
                label: const Text('Call', style: TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
                onPressed: onCall,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  side: const BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
