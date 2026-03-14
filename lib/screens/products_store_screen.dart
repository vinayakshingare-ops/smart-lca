import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/translation_provider.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class ProductsStoreScreen extends StatefulWidget {
  const ProductsStoreScreen({super.key});

  @override
  State<ProductsStoreScreen> createState() => _ProductsStoreScreenState();
}

class _ProductsStoreScreenState extends State<ProductsStoreScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<TranslationProvider>(context);
    final db = Provider.of<DatabaseService>(context);

    // Use Firestore data if available, else mock fallback (which in this case we didn't add to DB Service explicitly, but we can do it)
    List<EcoProduct> availableProducts = db.ecoProducts;

    // Filtering logic
    List<EcoProduct> filteredList = availableProducts.where((p) {
      final matchesSearch = p.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            p.nameHi.contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(tp.isHindi ? 'घरदे इको फ्रेंडली प्रोडक्ट' : 'Eco-Friendly Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => tp.toggleLanguage(),
          )
        ],
      ),
      body: availableProducts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(tp),
                _buildFilterChips(),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(filteredList[index], tp, db);
                    },
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildSearchBar(TranslationProvider tp) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: tp.isHindi ? 'प्रोडक्ट खोजें...' : 'Search products...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final categories = ['All', 'Bottles', 'Bags', 'Utensils'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCategory = cat);
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(EcoProduct product, TranslationProvider tp, DatabaseService db) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder with Badge
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.ecoScoreBadge,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                )
              ],
            ),
          ),
          // Details
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tp.isHindi ? product.nameHi : product.nameEn,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '₹${product.price}',
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    product.lcaSummary,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Mock By / Add to Cart & Gamification
                        db.addEcoCoins(10);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${product.nameEn} to Cart! Earned 10 EcoCoins!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(tp.isHindi ? 'अभी खरीदें' : 'Buy Now', style: const TextStyle(fontSize: 12)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
