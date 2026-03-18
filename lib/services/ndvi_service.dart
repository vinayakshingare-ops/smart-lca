import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/ndvi_location_model.dart';

class NDVIService {
  // Use 10.0.2.2 for Android Emulator, localhost for Web/iOS
  final String _baseUrl = 'http://10.0.2.2:3000';

  Future<Map<String, dynamic>?> getNDVIData() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/ndvi-monitor'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Failed to connect to NDVIService Backend: $e');
    }
    return null;
  }

  /// Returns 10 globally monitored mining locations with full NDVI detail
  List<NDVILocation> getGlobalNDVILocations() {
    return [
      NDVILocation(
        id: 'odisha',
        name: 'Odisha Iron Belt',
        country: 'India',
        coordinates: const LatLng(21.7679, 85.0985),
        ndviCurrent: 0.38,
        ndviBaseline: 0.62,
        ndviHistory: [0.62, 0.60, 0.57, 0.55, 0.52, 0.49, 0.46, 0.44, 0.42, 0.40, 0.39, 0.38],
        vegetationLossPercent: 38.7,
        riskLevel: 'High',
        carbonImpact: 'High',
        biodiversityRisk: 'High',
        lastUpdated: '2026-03-01',
        recoveryActions: ['Restore native forest cover', 'Halt new mine expansion', 'Implement green buffer zones'],
      ),
      NDVILocation(
        id: 'jharkhand',
        name: 'Jharkhand Coal Fields',
        country: 'India',
        coordinates: const LatLng(23.6102, 85.2799),
        ndviCurrent: 0.32,
        ndviBaseline: 0.58,
        ndviHistory: [0.58, 0.55, 0.52, 0.47, 0.44, 0.41, 0.39, 0.37, 0.35, 0.34, 0.33, 0.32],
        vegetationLossPercent: 44.8,
        riskLevel: 'Critical',
        carbonImpact: 'High',
        biodiversityRisk: 'High',
        lastUpdated: '2026-03-01',
        recoveryActions: ['Mandatory mine reclamation', 'Plant fast-growing native species', 'Reduce open-cast mining'],
      ),
      NDVILocation(
        id: 'amazon',
        name: 'Amazon Mining Zone',
        country: 'Brazil',
        coordinates: const LatLng(-3.4653, -62.2159),
        ndviCurrent: 0.51,
        ndviBaseline: 0.85,
        ndviHistory: [0.85, 0.82, 0.78, 0.74, 0.69, 0.65, 0.60, 0.57, 0.55, 0.54, 0.52, 0.51],
        vegetationLossPercent: 40.0,
        riskLevel: 'Critical',
        carbonImpact: 'High',
        biodiversityRisk: 'High',
        lastUpdated: '2026-02-28',
        recoveryActions: ['Enforce deforestation moratorium', 'Support indigenous land rights', 'Carbon offset investments'],
      ),
      NDVILocation(
        id: 'congo',
        name: 'Congo Basin Mining Area',
        country: 'DRC',
        coordinates: const LatLng(-2.8770, 23.6560),
        ndviCurrent: 0.58,
        ndviBaseline: 0.80,
        ndviHistory: [0.80, 0.78, 0.76, 0.74, 0.72, 0.70, 0.68, 0.65, 0.63, 0.61, 0.59, 0.58],
        vegetationLossPercent: 27.5,
        riskLevel: 'High',
        carbonImpact: 'High',
        biodiversityRisk: 'High',
        lastUpdated: '2026-03-01',
        recoveryActions: ['Strengthen protected area enforcement', 'Sustainable artisanal mining regulations'],
      ),
      NDVILocation(
        id: 'carajas',
        name: 'Brazil Carajás Mining Complex',
        country: 'Brazil',
        coordinates: const LatLng(-6.0581, -50.1616),
        ndviCurrent: 0.44,
        ndviBaseline: 0.71,
        ndviHistory: [0.71, 0.69, 0.66, 0.63, 0.60, 0.57, 0.54, 0.51, 0.49, 0.47, 0.45, 0.44],
        vegetationLossPercent: 38.0,
        riskLevel: 'High',
        carbonImpact: 'High',
        biodiversityRisk: 'Medium',
        lastUpdated: '2026-02-28',
        recoveryActions: ['Mine restoration fund allocation', 'Cerrado vegetation recovery programs'],
      ),
      NDVILocation(
        id: 'peru_gold',
        name: 'Peru Gold Mining Region',
        country: 'Peru',
        coordinates: const LatLng(-12.9184, -70.0935),
        ndviCurrent: 0.28,
        ndviBaseline: 0.68,
        ndviHistory: [0.68, 0.64, 0.60, 0.54, 0.49, 0.43, 0.38, 0.35, 0.32, 0.30, 0.29, 0.28],
        vegetationLossPercent: 58.8,
        riskLevel: 'Critical',
        carbonImpact: 'High',
        biodiversityRisk: 'High',
        lastUpdated: '2026-03-01',
        recoveryActions: ['Mercury pollution cleanup', 'Illegal mining crackdown', 'Indigenous territory protection'],
      ),
      NDVILocation(
        id: 'south_africa',
        name: 'South Africa Platinum Mines',
        country: 'South Africa',
        coordinates: const LatLng(-25.6503, 27.2310),
        ndviCurrent: 0.35,
        ndviBaseline: 0.52,
        ndviHistory: [0.52, 0.51, 0.50, 0.48, 0.46, 0.44, 0.42, 0.40, 0.38, 0.37, 0.36, 0.35],
        vegetationLossPercent: 32.7,
        riskLevel: 'High',
        carbonImpact: 'Medium',
        biodiversityRisk: 'Medium',
        lastUpdated: '2026-03-01',
        recoveryActions: ['Revegetate tailings dams', 'Water conservation measures', 'Biodiversity offset programs'],
      ),
      NDVILocation(
        id: 'indonesia',
        name: 'Indonesia Nickel Mines',
        country: 'Indonesia',
        coordinates: const LatLng(-3.5000, 122.0000),
        ndviCurrent: 0.42,
        ndviBaseline: 0.76,
        ndviHistory: [0.76, 0.73, 0.70, 0.66, 0.62, 0.58, 0.53, 0.50, 0.47, 0.45, 0.43, 0.42],
        vegetationLossPercent: 44.7,
        riskLevel: 'Critical',
        carbonImpact: 'High',
        biodiversityRisk: 'High',
        lastUpdated: '2026-02-28',
        recoveryActions: ['Halt new nickel concessions in primary forests', 'Coral reef protection buffers'],
      ),
      NDVILocation(
        id: 'western_australia',
        name: 'Western Australia Mining Zone',
        country: 'Australia',
        coordinates: const LatLng(-25.0000, 118.0000),
        ndviCurrent: 0.48,
        ndviBaseline: 0.55,
        ndviHistory: [0.55, 0.54, 0.54, 0.53, 0.52, 0.52, 0.51, 0.50, 0.50, 0.49, 0.49, 0.48],
        vegetationLossPercent: 12.7,
        riskLevel: 'Medium',
        carbonImpact: 'Medium',
        biodiversityRisk: 'Medium',
        lastUpdated: '2026-03-01',
        recoveryActions: ['Native species replanting', 'Soil rehabilitation post-mining', 'Water table monitoring'],
      ),
      NDVILocation(
        id: 'canada_oil',
        name: 'Canada Oil Sands Region',
        country: 'Canada',
        coordinates: const LatLng(56.7267, -111.3790),
        ndviCurrent: 0.41,
        ndviBaseline: 0.68,
        ndviHistory: [0.68, 0.67, 0.65, 0.62, 0.58, 0.54, 0.51, 0.49, 0.46, 0.44, 0.42, 0.41],
        vegetationLossPercent: 39.7,
        riskLevel: 'High',
        carbonImpact: 'High',
        biodiversityRisk: 'Medium',
        lastUpdated: '2026-03-01',
        recoveryActions: ['Boreal forest reclamation', 'Wetland restoration programs', 'Reduce tailings pond expansion'],
      ),
    ];
  }
}
