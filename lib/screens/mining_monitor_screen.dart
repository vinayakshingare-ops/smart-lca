import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../utils/app_theme.dart';

class MiningMonitorScreen extends StatefulWidget {
  const MiningMonitorScreen({super.key});

  @override
  State<MiningMonitorScreen> createState() => _MiningMonitorScreenState();
}

class _MiningMonitorScreenState extends State<MiningMonitorScreen> {
  bool _isLoadingGee = true;
  String _geeAlert = 'Evaluating latest Sentinel-2 NDVI data...';

  @override
  void initState() {
    super.initState();
    _fetchGeeData();
  }

  Future<void> _fetchGeeData() async {
    // Simulate fetching from GEE Backend Proxy
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isLoadingGee = false;
        _geeAlert =
            'Alert: Deforestation +15% detected in Sector B (Odisha Mining Belt) over the last 6 months.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mining & NDVI Monitor'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map with Satellite Imagery (Esri World Imagery - free)
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  FlutterMap(
                    options: const MapOptions(
                      initialCenter:
                          LatLng(21.7679, 85.0985), // Keonjhar, Odisha
                      initialZoom: 11,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                        userAgentPackageName: 'com.example.smart_lca_mine',
                      ),
                      // NDVI-style overlay markers for mining zones
                      if (!_isLoadingGee)
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: const LatLng(21.7679, 85.0985),
                              radius: 60,
                              color: Colors.red.withAlpha(50),
                              borderColor: Colors.red.withAlpha(120),
                              borderStrokeWidth: 2,
                            ),
                            CircleMarker(
                              point: const LatLng(21.80, 85.12),
                              radius: 40,
                              color: Colors.orange.withAlpha(50),
                              borderColor: Colors.orange.withAlpha(120),
                              borderStrokeWidth: 2,
                            ),
                            CircleMarker(
                              point: const LatLng(21.73, 85.05),
                              radius: 35,
                              color: Colors.green.withAlpha(50),
                              borderColor: Colors.green.withAlpha(120),
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                      // Legend markers
                      if (!_isLoadingGee)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: const LatLng(21.7679, 85.0985),
                              width: 120,
                              height: 30,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(200),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '⚠ High Impact',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (_isLoadingGee)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text('Connecting to GEE JS API...',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Live Sentinel-2 Feed',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  )
                ],
              ),
            ),

            // Alert System
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isLoadingGee
                    ? Colors.grey.withAlpha(25)
                    : AppTheme.warningColor.withAlpha(25),
                border: Border.all(
                    color:
                        _isLoadingGee ? Colors.grey : AppTheme.warningColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                      _isLoadingGee
                          ? Icons.sync
                          : Icons.warning_amber_rounded,
                      color:
                          _isLoadingGee ? Colors.grey : AppTheme.warningColor,
                      size: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            _isLoadingGee
                                ? 'Analysis in Progress'
                                : 'Environmental Alert',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isLoadingGee
                                    ? Colors.grey
                                    : AppTheme.warningColor)),
                        const SizedBox(height: 4),
                        Text(_geeAlert,
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // NDVI Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vegetation Health Trend',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.black12)),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 0.75),
                              FlSpot(1, 0.72),
                              FlSpot(2, 0.68),
                              FlSpot(3, 0.60),
                              FlSpot(4, 0.55),
                              FlSpot(5, 0.45),
                            ],
                            isCurved: true,
                            color: AppTheme.primaryColor,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                                show: true,
                                color:
                                    AppTheme.primaryColor.withAlpha(25)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
