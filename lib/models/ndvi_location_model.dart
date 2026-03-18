import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class NDVILocation {
  final String id;
  final String name;
  final String country;
  final LatLng coordinates;
  final double ndviCurrent;
  final double ndviBaseline;
  final List<double> ndviHistory; // 12 months
  final double vegetationLossPercent;
  final String riskLevel; // 'Low', 'Medium', 'High', 'Critical'
  final String carbonImpact; // 'Low', 'Medium', 'High'
  final String biodiversityRisk; // 'Low', 'Medium', 'High'
  final String lastUpdated;
  final List<String> recoveryActions;

  const NDVILocation({
    required this.id,
    required this.name,
    required this.country,
    required this.coordinates,
    required this.ndviCurrent,
    required this.ndviBaseline,
    required this.ndviHistory,
    required this.vegetationLossPercent,
    required this.riskLevel,
    required this.carbonImpact,
    required this.biodiversityRisk,
    required this.lastUpdated,
    required this.recoveryActions,
  });

  Color get markerColor {
    if (ndviCurrent >= 0.5) return const Color(0xFF2E7D32); // Forest Green
    if (ndviCurrent >= 0.3) return const Color(0xFFF9A825); // Amber/Yellow
    return const Color(0xFFD32F2F); // Red
  }

  String get healthStatus {
    if (ndviCurrent >= 0.5) return 'Healthy';
    if (ndviCurrent >= 0.3) return 'Moderate Stress';
    return 'Severe Loss';
  }

  IconData get riskIcon {
    switch (riskLevel) {
      case 'Low':
        return Icons.check_circle_outline;
      case 'Medium':
        return Icons.warning_amber_outlined;
      case 'High':
        return Icons.warning_rounded;
      case 'Critical':
        return Icons.dangerous_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
