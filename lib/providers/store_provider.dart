import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class StoreProvider extends ChangeNotifier {
  List<EcoProduct> _products = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Getters
  bool get isLoading => _isLoading;
  List<EcoProduct> get products => _products;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Filtered Products Getter
  List<EcoProduct> get filteredProducts {
    return _products.where((p) {
      final matchesSearch =
          p.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.nameHi.contains(_searchQuery);
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Setters for UI interactions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Load products from Service Layer
  Future<void> loadProducts(DatabaseService db) async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await db.getEcoProducts();
    } catch (e) {
      debugPrint('Error loading products: $e');
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
