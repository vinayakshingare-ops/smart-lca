class EcoAlternative {
  final String name;
  final int price;
  final String imageUrl;
  final int ecoScoreImprovement;
  final double carbonSavingsPerYear;
  final String purchaseLink;

  EcoAlternative({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.ecoScoreImprovement,
    required this.carbonSavingsPerYear,
    required this.purchaseLink,
  });
}

class ProductModel {
  final String productId;
  final String barcode;
  final String name;
  final String materialType;
  final int ecoScore; // 0-100
  final double carbonImpact; // kg of CO2
  final String recyclingInstructionsEn;
  final String recyclingInstructionsHi;
  final List<EcoAlternative> ecoAlternatives;

  ProductModel({
    required this.productId,
    required this.barcode,
    required this.name,
    required this.materialType,
    required this.ecoScore,
    required this.carbonImpact,
    required this.recyclingInstructionsEn,
    required this.recyclingInstructionsHi,
    required this.ecoAlternatives,
  });
}

class EcoProduct {
  final String id;
  final String nameEn;
  final String nameHi;
  final String imageUrl;
  final String ecoScoreBadge; // A++, A+, A, B+, etc.
  final String lcaSummary;
  final int price;
  final String category;
  final double carbonSaved;
  final int stock;

  EcoProduct({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.imageUrl,
    required this.ecoScoreBadge,
    required this.lcaSummary,
    required this.price,
    required this.category,
    required this.carbonSaved,
    required this.stock,
  });
}
