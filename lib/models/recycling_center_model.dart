class RecyclingCenter {
  final String id;
  final String centerName;
  final double latitude;
  final double longitude;
  final List<String> acceptedMaterials;
  final String openingHours;
  final String address;
  final double distanceKm;
  final String contactPhone;

  RecyclingCenter({
    required this.id,
    required this.centerName,
    required this.latitude,
    required this.longitude,
    required this.acceptedMaterials,
    required this.openingHours,
    required this.address,
    this.distanceKm = 0.0,
    this.contactPhone = '',
  });
}
