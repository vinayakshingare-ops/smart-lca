import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/recycling_center_model.dart';

class DatabaseService with ChangeNotifier {
  final FirebaseFirestore? _db = _initFirestore();

  static FirebaseFirestore? _initFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("Firestore not initialized, falling back to mock");
      return null;
    }
  }

  // Mock Data Fallbacks
  UserModel? currentUser;
  List<ProductModel> products = [];
  List<RecyclingCenter> recyclingCenters = [];
  List<EcoProduct> ecoProducts = [];

  DatabaseService() {
    _initMockData();
    if (_db != null) {
      fetchEcoProducts();
      fetchCurrentUser();
    }
  }

  Future<void> fetchEcoProducts() async {
    if (_db == null) return;
    try {
      final snapshot = await _db!.collection('eco_products').get();
      ecoProducts = snapshot.docs.map((doc) {
        final data = doc.data();
        return EcoProduct(
          id: data['id'] ?? doc.id,
          nameEn: data['name_en'] ?? '',
          nameHi: data['name_hi'] ?? '',
          imageUrl: data['image_url'] ?? '',
          ecoScoreBadge: data['eco_score'] ?? 'B',
          lcaSummary: data['lca_summary'] ?? '',
          price: (data['price'] ?? 0).toInt(),
          category: data['category'] ?? 'Other',
          carbonSaved: (data['carbon_saved'] ?? 0.0).toDouble(),
          stock: (data['stock'] ?? 0).toInt(),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching eco products: $e");
    }
  }

  Future<void> fetchCurrentUser() async {
    if (_db == null) return;
    try {
      // Mocking fetching 'user123'
      final doc = await _db!.collection('users').doc('user123').get();
      if (doc.exists) {
        final data = doc.data()!;
        currentUser = UserModel(
          userId: doc.id,
          name: data['name'] ?? 'Eco Warrior',
          ecoCoins: data['ecoCoins'] ?? 120,
          rank: data['rank'] ?? 42,
          scanHistory: [],
          recyclingHistory: [],
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    }
  }

  void _initMockData() {
    currentUser = UserModel(
      userId: 'user123',
      name: 'Eco Warrior',
      ecoCoins: 120,
      rank: 42,
      scanHistory: [],
      recyclingHistory: [],
    );

    // Pune Recycling Centers
    recyclingCenters = [
      RecyclingCenter(
        id: 'rc1',
        centerName: 'Swachh Pune Kabadiwala',
        latitude: 18.5204,
        longitude: 73.8567,
        acceptedMaterials: ['Plastic', 'Paper', 'Metal'],
        openingHours: '9:00 AM - 6:00 PM',
        address: 'Shivaji Nagar, Pune',
      ),
      RecyclingCenter(
        id: 'rc2',
        centerName: 'Green Earth Recycling',
        latitude: 18.5590,
        longitude: 73.7868,
        acceptedMaterials: ['Glass', 'E-Waste', 'Plastic'],
        openingHours: '10:00 AM - 5:00 PM',
        address: 'Baner, Pune',
      ),
      RecyclingCenter(
        id: 'rc3',
        centerName: 'Pimpri E-Waste Hub',
        latitude: 18.6296,
        longitude: 73.8014,
        acceptedMaterials: ['E-Waste', 'Batteries', 'Metal'],
        openingHours: '9:00 AM - 7:00 PM',
        address: 'Pimpri-Chinchwad, Pune',
      ),
    ];

    // Mock Products
    products = [
      ProductModel(
        productId: 'p1',
        barcode: '123456789',
        name: 'Plastic Water Bottle',
        materialType: 'PET Plastic',
        ecoScore: 30,
        carbonImpact: 0.3,
        recyclingInstructionsEn: 'Empty the bottle, crush it, and put it in the dry waste bin.',
        recyclingInstructionsHi: 'Isse khaali karein, crush karein, aur dry waste bin me daalein.',
        ecoAlternatives: [
          EcoAlternative(
            name: 'Steel Water Bottle',
            price: 299,
            imageUrl: 'assets/images/steel_bottle_bambrew.png',
            ecoScoreImprovement: 60,
            carbonSavingsPerYear: 5.2,
            purchaseLink: 'https://example.com/buy-steel-bottle',
          ),
        ],
      )
    ];

    ecoProducts = [
      EcoProduct(id: '1', nameEn: 'Bamboo Straw Set', nameHi: 'बांस के स्ट्रॉ का सेट', imageUrl: '', ecoScoreBadge: 'A++', lcaSummary: 'Zero plastic, reusable 1yr', price: 150, category: 'Utensils', carbonSaved: 2.5, stock: 50),
      EcoProduct(id: '2', nameEn: 'Stainless Steel Bottle (Bambrew)', nameHi: 'स्टेनलेस स्टील की बोतल', imageUrl: '', ecoScoreBadge: 'A', lcaSummary: 'Steel vs plastic: 90% less CO2', price: 800, category: 'Bottles', carbonSaved: 5.0, stock: 20),
      EcoProduct(id: '3', nameEn: 'Jute Shopping Bag', nameHi: 'जूट शॉपिंग बैग', imageUrl: '', ecoScoreBadge: 'A+', lcaSummary: 'Biodegradable, 1000x reusable', price: 200, category: 'Bags', carbonSaved: 4.0, stock: 100),
      EcoProduct(id: '4', nameEn: 'Wooden Toothbrush', nameHi: 'लकड़ी का टूथब्रश', imageUrl: '', ecoScoreBadge: 'A++', lcaSummary: 'Compostable handle', price: 100, category: 'Personal Care', carbonSaved: 0.5, stock: 200),
    ];
  }

  ProductModel? getProductByBarcode(String barcode) {
    try {
      return products.firstWhere((p) => p.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  void addEcoCoins(int amount) {
    if (currentUser != null) {
      final newCoins = currentUser!.ecoCoins + amount;
      currentUser = UserModel(
        userId: currentUser!.userId,
        name: currentUser!.name,
        ecoCoins: newCoins,
        rank: currentUser!.rank,
        scanHistory: currentUser!.scanHistory,
        recyclingHistory: currentUser!.recyclingHistory,
      );
      
      // Update in Firestore
      if (_db != null) {
        _db!.collection('users').doc(currentUser!.userId).set({
          'ecoCoins': newCoins,
        }, SetOptions(merge: true));
      }
      
      notifyListeners();
    }
  }
}
