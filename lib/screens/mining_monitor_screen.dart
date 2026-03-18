import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/ndvi_location_model.dart';
import '../services/ndvi_service.dart';
import '../utils/app_theme.dart';

class MiningMonitorScreen extends StatefulWidget {
  const MiningMonitorScreen({super.key});

  @override
  State<MiningMonitorScreen> createState() => _MiningMonitorScreenState();
}

class _MiningMonitorScreenState extends State<MiningMonitorScreen>
    with TickerProviderStateMixin {
  bool _isMapLoaded = false;
  late List<NDVILocation> _locations;
  late NDVILocation _selectedLocation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final MapController _mapController = MapController();

  static const List<String> _months = [
    'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep',
    'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'
  ];

  @override
  void initState() {
    super.initState();
    _locations = NDVIService().getGlobalNDVILocations();
    _selectedLocation = _locations[0];

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Simulate map tile load time
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isMapLoaded = true);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _selectLocation(NDVILocation loc) {
    setState(() => _selectedLocation = loc);
    _mapController.move(loc.coordinates, 5.0);
  }

  Color _riskColor(String risk) {
    switch (risk) {
      case 'Low': return Colors.green;
      case 'Medium': return Colors.amber;
      case 'High': return Colors.orange;
      case 'Critical': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text(
          '🛰️ NDVI Environmental Monitor',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── MAP SECTION ──────────────────────────────────────────────
            _buildMapSection(),

            // ── SELECTED LOCATION HEADER ─────────────────────────────────
            _buildLocationHeader(),

            // ── NDVI TREND CHART ─────────────────────────────────────────
            _buildTrendChart(),

            // ── INSIGHTS PANEL ────────────────────────────────────────────
            _buildInsightsPanel(),

            // ── LOCATIONS LIST ────────────────────────────────────────────
            _buildLocationsList(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── MAP ──────────────────────────────────────────────────────────────────
  Widget _buildMapSection() {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF0D1B2A)),
      child: Stack(
        children: [
          // Map
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation.coordinates,
                initialZoom: 3.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.example.smart_lca_mine',
                ),
                // Pulse ring on selected location
                if (_isMapLoaded)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, __) => CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _selectedLocation.coordinates,
                          radius: _pulseAnimation.value,
                          color: _selectedLocation.markerColor.withAlpha(30),
                          borderColor: _selectedLocation.markerColor.withAlpha(120),
                          borderStrokeWidth: 2,
                          useRadiusInMeter: false,
                        ),
                      ],
                    ),
                  ),
                // All location markers
                if (_isMapLoaded)
                  CircleLayer(
                    circles: _locations.map((loc) {
                      final isSelected = loc.id == _selectedLocation.id;
                      return CircleMarker(
                        point: loc.coordinates,
                        radius: isSelected ? 12 : 7,
                        color: loc.markerColor.withAlpha(isSelected ? 220 : 160),
                        borderColor: Colors.white,
                        borderStrokeWidth: isSelected ? 2 : 1,
                        useRadiusInMeter: false,
                      );
                    }).toList(),
                  ),
                // Tap targets
                if (_isMapLoaded)
                  MarkerLayer(
                    markers: _locations.map((loc) {
                      return Marker(
                        point: loc.coordinates,
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => _selectLocation(loc),
                          child: const SizedBox.expand(),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

          // Skeleton loader
          if (!_isMapLoaded)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade800, Colors.grey.shade700, Colors.grey.shade800],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF4CAF50)),
                    SizedBox(height: 16),
                    Text('Loading Sentinel-2 Satellite Feed…',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),

          // Legend
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NDVI Legend', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  _LegendRow(color: Color(0xFF2E7D32), label: '● Healthy (>0.5)'),
                  _LegendRow(color: Color(0xFFF9A825), label: '● Moderate (0.3–0.5)'),
                  _LegendRow(color: Color(0xFFD32F2F), label: '● Severe (<0.3)'),
                ],
              ),
            ),
          ),

          // Satellite badge
          Positioned(
            bottom: 14,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(160),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.greenAccent.withAlpha(80)),
              ),
              child: const Text('🛰️ Live Sentinel-2',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── LOCATION HEADER ───────────────────────────────────────────────────────
  Widget _buildLocationHeader() {
    final loc = _selectedLocation;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(loc.id),
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E3B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: loc.markerColor.withAlpha(120)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(loc.riskIcon, color: loc.markerColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('${loc.country} · Updated ${loc.lastUpdated}',
                          style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _riskColor(loc.riskLevel).withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _riskColor(loc.riskLevel)),
                  ),
                  child: Text(loc.riskLevel,
                      style: TextStyle(color: _riskColor(loc.riskLevel), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(label: 'NDVI Now', value: loc.ndviCurrent.toStringAsFixed(2), color: loc.markerColor),
                _StatChip(label: 'Baseline', value: loc.ndviBaseline.toStringAsFixed(2), color: Colors.white60),
                _StatChip(label: 'Veg. Loss', value: '${loc.vegetationLossPercent.toStringAsFixed(1)}%', color: Colors.redAccent),
                _StatChip(label: 'Health', value: loc.healthStatus, color: loc.markerColor, isText: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── TREND CHART ───────────────────────────────────────────────────────────
  Widget _buildTrendChart() {
    final hist = _selectedLocation.ndviHistory;
    final spots = List.generate(hist.length, (i) => FlSpot(i.toDouble(), hist[i]));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey('${_selectedLocation.id}_chart'),
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E3B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('12-Month NDVI Vegetation Trend',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${_selectedLocation.name} · Apr 2025 – Mar 2026',
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 1.0,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.1,
                    getDrawingHorizontalLine: (v) => FlLine(color: Colors.white12, strokeWidth: 1),
                  ),
                  // Color-coded health zone bands
                  rangeAnnotations: RangeAnnotations(
                    horizontalRangeAnnotations: [
                      HorizontalRangeAnnotation(y1: 0.5, y2: 1.0, color: AppTheme.primaryColor.withAlpha(18)),
                      HorizontalRangeAnnotation(y1: 0.3, y2: 0.5, color: Colors.amber.withAlpha(18)),
                      HorizontalRangeAnnotation(y1: 0.0, y2: 0.3, color: Colors.red.withAlpha(18)),
                    ],
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 0.2,
                        getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= _months.length) return const SizedBox();
                          return Text(_months[i],
                              style: const TextStyle(color: Colors.white38, fontSize: 9));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: _selectedLocation.markerColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      shadow: Shadow(color: _selectedLocation.markerColor.withAlpha(80), blurRadius: 8),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _selectedLocation.markerColor.withAlpha(80),
                            _selectedLocation.markerColor.withAlpha(0),
                          ],
                        ),
                      ),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Zone legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ZoneLegend(color: AppTheme.primaryColor, label: 'Healthy (>0.5)'),
                const SizedBox(width: 12),
                _ZoneLegend(color: Colors.amber, label: 'Moderate (0.3–0.5)'),
                const SizedBox(width: 12),
                _ZoneLegend(color: Colors.red, label: 'Severe (<0.3)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── INSIGHTS PANEL ────────────────────────────────────────────────────────
  Widget _buildInsightsPanel() {
    final loc = _selectedLocation;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey('${loc.id}_insights'),
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E3B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Environmental Impact Insights',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Row(
              children: [
                _InsightCard(label: 'Vegetation Loss', value: '${loc.vegetationLossPercent.toStringAsFixed(1)}%', color: Colors.redAccent),
                const SizedBox(width: 10),
                _InsightCard(label: 'Carbon Impact', value: loc.carbonImpact, color: Colors.orangeAccent),
                const SizedBox(width: 10),
                _InsightCard(label: 'Biodiversity Risk', value: loc.biodiversityRisk, color: Colors.purpleAccent),
              ],
            ),
            const SizedBox(height: 14),
            const Text('🌱 Recommended Recovery Actions',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...loc.recoveryActions.map((action) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco, color: Color(0xFF4CAF50), size: 14),
                  const SizedBox(width: 6),
                  Expanded(child: Text(action, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ── LOCATIONS LIST ────────────────────────────────────────────────────────
  Widget _buildLocationsList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌍 Monitored Mining Locations',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._locations.map((loc) {
            final isSelected = loc.id == _selectedLocation.id;
            return GestureDetector(
              onTap: () => _selectLocation(loc),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? loc.markerColor.withAlpha(30) : const Color(0xFF1A2E3B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? loc.markerColor : Colors.white12,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(color: loc.markerColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.name,
                              style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('${loc.country} · NDVI ${loc.ndviCurrent.toStringAsFixed(2)} · ${loc.healthStatus}',
                              style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _riskColor(loc.riskLevel).withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _riskColor(loc.riskLevel).withAlpha(100)),
                      ),
                      child: Text('${loc.vegetationLossPercent.toStringAsFixed(0)}% loss',
                          style: TextStyle(color: _riskColor(loc.riskLevel), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── HELPERS ───────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Text(label, style: TextStyle(color: color, fontSize: 9)),
  );
}

class _ZoneLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ZoneLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color.withAlpha(80), borderRadius: BorderRadius.circular(2), border: Border.all(color: color))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
    ],
  );
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isText;
  const _StatChip({required this.label, required this.value, required this.color, this.isText = false});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value,
          style: TextStyle(color: color, fontSize: isText ? 10 : 16, fontWeight: FontWeight.bold),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
    ],
  );
}

class _InsightCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InsightCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
