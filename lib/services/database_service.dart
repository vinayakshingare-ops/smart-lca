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
      fetchCurrentUser();
    }
  }

  Future<List<EcoProduct>> getEcoProducts() async {
    if (_db != null) {
      try {
        final snapshot = await _db!.collection('eco_products').get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
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
        }
      } catch (e) {
        debugPrint("Error fetching eco products: $e");
      }
    }
    // Fallback to mock data if Firestore fetch fails or is null
    return ecoProducts;
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
        openingHours: '9:00 AM – 6:00 PM',
        address: 'Shivaji Nagar, Pune',
        distanceKm: 1.2,
        contactPhone: '+91 98765 43210',
      ),
      RecyclingCenter(
        id: 'rc2',
        centerName: 'Green Earth Recycling',
        latitude: 18.5590,
        longitude: 73.7868,
        acceptedMaterials: ['Glass', 'E-Waste', 'Plastic'],
        openingHours: '10:00 AM – 5:00 PM',
        address: 'Baner, Pune',
        distanceKm: 3.4,
        contactPhone: '+91 98100 22334',
      ),
      RecyclingCenter(
        id: 'rc3',
        centerName: 'Pimpri E-Waste Hub',
        latitude: 18.6296,
        longitude: 73.8014,
        acceptedMaterials: ['E-Waste', 'Batteries', 'Metal'],
        openingHours: '9:00 AM – 7:00 PM',
        address: 'Pimpri-Chinchwad, Pune',
        distanceKm: 5.6,
        contactPhone: '+91 90284 11122',
      ),
      RecyclingCenter(
        id: 'rc4',
        centerName: 'Eco Circle Kothrud',
        latitude: 18.5074,
        longitude: 73.8077,
        acceptedMaterials: ['Plastic', 'Paper', 'Glass', 'Batteries'],
        openingHours: '8:00 AM – 6:00 PM',
        address: 'Kothrud, Pune',
        distanceKm: 6.2,
        contactPhone: '+91 91300 55667',
      ),
      RecyclingCenter(
        id: 'rc5',
        centerName: 'WasteWise Hadapsar',
        latitude: 18.5049,
        longitude: 73.9306,
        acceptedMaterials: ['E-Waste', 'Plastic', 'Metal', 'Glass'],
        openingHours: '9:00 AM – 8:00 PM',
        address: 'Hadapsar, Pune',
        distanceKm: 8.9,
        contactPhone: '+91 99200 11223',
      ),
      RecyclingCenter(
        id: 'rc6',
        centerName: 'CleanPlanet Viman Nagar',
        latitude: 18.5676,
        longitude: 73.9143,
        acceptedMaterials: ['Paper', 'Plastic', 'E-Waste'],
        openingHours: '10:00 AM – 7:00 PM',
        address: 'Viman Nagar, Pune',
        distanceKm: 9.3,
        contactPhone: '+91 88011 44556',
      ),
      RecyclingCenter(
        id: 'rc7',
        centerName: 'GreenSpark Deccan',
        latitude: 18.5186,
        longitude: 73.8445,
        acceptedMaterials: ['Batteries', 'E-Waste', 'Metal'],
        openingHours: '9:30 AM – 6:30 PM',
        address: 'Deccan Gymkhana, Pune',
        distanceKm: 4.1,
        contactPhone: '+91 87654 32100',
      ),
      RecyclingCenter(
        id: 'rc8',
        centerName: 'ReNew Aundh',
        latitude: 18.5590,
        longitude: 73.8080,
        acceptedMaterials: ['Plastic', 'Paper', 'Glass', 'Metal'],
        openingHours: '8:30 AM – 5:30 PM',
        address: 'Aundh, Pune',
        distanceKm: 3.7,
        contactPhone: '+91 90000 12345',
      ),
      RecyclingCenter(
        id: 'rc9',
        centerName: 'EcoHub Wakad',
        latitude: 18.5975,
        longitude: 73.7720,
        acceptedMaterials: ['Glass', 'Plastic', 'Paper'],
        openingHours: '9:00 AM – 6:00 PM',
        address: 'Wakad, Pune',
        distanceKm: 11.2,
        contactPhone: '+91 91234 56789',
      ),
      RecyclingCenter(
        id: 'rc10',
        centerName: 'BioLoop Pashan',
        latitude: 18.5320,
        longitude: 73.7900,
        acceptedMaterials: ['Organic Waste', 'Paper', 'Plastic'],
        openingHours: '7:00 AM – 3:00 PM',
        address: 'Pashan, Pune',
        distanceKm: 7.5,
        contactPhone: '+91 98111 22334',
      ),
      RecyclingCenter(
        id: 'rc11',
        centerName: 'MetalMart Chinchwad',
        latitude: 18.6449,
        longitude: 73.7972,
        acceptedMaterials: ['Metal', 'E-Waste', 'Batteries'],
        openingHours: '9:00 AM – 7:00 PM',
        address: 'Chinchwad, Pune',
        distanceKm: 13.6,
        contactPhone: '+91 99876 54321',
      ),
      RecyclingCenter(
        id: 'rc12',
        centerName: 'EcoGreen Kharadi',
        latitude: 18.5502,
        longitude: 73.9437,
        acceptedMaterials: ['Plastic', 'Glass', 'Paper'],
        openingHours: '10:00 AM – 6:00 PM',
        address: 'Kharadi, Pune',
        distanceKm: 15.3,
        contactPhone: '+91 88900 55123',
      ),
      RecyclingCenter(
        id: 'rc13',
        centerName: 'CircleEco Magarpatta',
        latitude: 18.5130,
        longitude: 73.9210,
        acceptedMaterials: ['E-Waste', 'Plastic', 'Paper', 'Metal'],
        openingHours: '9:00 AM – 6:00 PM',
        address: 'Magarpatta, Pune',
        distanceKm: 12.0,
        contactPhone: '+91 97654 11223',
      ),
      RecyclingCenter(
        id: 'rc14',
        centerName: 'RecycleRight Hinjewadi',
        latitude: 18.5910,
        longitude: 73.7210,
        acceptedMaterials: ['E-Waste', 'Batteries', 'Metal', 'Plastic'],
        openingHours: '8:00 AM – 6:00 PM',
        address: 'Hinjewadi IT Park, Pune',
        distanceKm: 17.4,
        contactPhone: '+91 89000 33455',
      ),
      RecyclingCenter(
        id: 'rc15',
        centerName: 'GreenCycle Kondhwa',
        latitude: 18.4660,
        longitude: 73.8786,
        acceptedMaterials: ['Plastic', 'Paper', 'Glass'],
        openingHours: '9:00 AM – 5:00 PM',
        address: 'Kondhwa Budruk, Pune',
        distanceKm: 14.1,
        contactPhone: '+91 90012 34567',
      ),
      RecyclingCenter(
        id: 'rc16',
        centerName: 'WasteSeg Katraj',
        latitude: 18.4560,
        longitude: 73.8660,
        acceptedMaterials: ['Organic Waste', 'Batteries', 'E-Waste'],
        openingHours: '8:00 AM – 4:00 PM',
        address: 'Katraj, Pune',
        distanceKm: 16.5,
        contactPhone: '+91 70400 22111',
      ),
      RecyclingCenter(
        id: 'rc17',
        centerName: 'EcoDrive Sinhagad Rd',
        latitude: 18.4780,
        longitude: 73.8270,
        acceptedMaterials: ['Plastic', 'Glass', 'Metal', 'Paper'],
        openingHours: '9:00 AM – 6:30 PM',
        address: 'Sinhagad Road, Pune',
        distanceKm: 12.8,
        contactPhone: '+91 91234 00011',
      ),
      RecyclingCenter(
        id: 'rc18',
        centerName: 'Greeny Recycle Yerawada',
        latitude: 18.5490,
        longitude: 73.8870,
        acceptedMaterials: ['Glass', 'Paper', 'Plastic'],
        openingHours: '10:00 AM – 5:00 PM',
        address: 'Yerawada, Pune',
        distanceKm: 7.9,
        contactPhone: '+91 98221 33445',
      ),
      RecyclingCenter(
        id: 'rc19',
        centerName: 'ZeroWaste Bopodi',
        latitude: 18.5830,
        longitude: 73.8480,
        acceptedMaterials: ['Organic Waste', 'Paper', 'Plastic', 'Metal'],
        openingHours: '7:30 AM – 3:30 PM',
        address: 'Bopodi, Pune',
        distanceKm: 5.0,
        contactPhone: '+91 99112 77889',
      ),
      RecyclingCenter(
        id: 'rc20',
        centerName: 'EcoSpark Bhosari',
        latitude: 18.6560,
        longitude: 73.8610,
        acceptedMaterials: ['Metal', 'E-Waste', 'Batteries', 'Plastic'],
        openingHours: '9:00 AM – 7:00 PM',
        address: 'Bhosari MIDC, Pune',
        distanceKm: 19.2,
        contactPhone: '+91 88223 66554',
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
            imageUrl: 'https://images.unsplash.com/photo-1605600659908-0ef719419d41?auto=format&fit=crop&w=400&q=80',
            ecoScoreImprovement: 60,
            carbonSavingsPerYear: 5.2,
            purchaseLink: 'https://example.com/buy-steel-bottle',
          ),
        ],
      )
    ];

    ecoProducts = [
      EcoProduct(id: '1', nameEn: 'Bamboo Straw Set', nameHi: 'बांस के स्ट्रॉ का सेट', imageUrl: 'https://images.unsplash.com/photo-1590753239841-f62fbcaecc23?auto=format&fit=crop&w=400&q=80', ecoScoreBadge: 'A++', lcaSummary: 'Zero plastic, reusable 1yr', price: 150, category: 'Utensils', carbonSaved: 2.5, stock: 50),
      EcoProduct(id: '2', nameEn: 'Stainless Steel Bottle (Bambrew)', nameHi: 'स्टेनलेस स्टील की बोतल', imageUrl: 'https://images.unsplash.com/photo-1605600659908-0ef719419d41?auto=format&fit=crop&w=400&q=80', ecoScoreBadge: 'A', lcaSummary: 'Steel vs plastic: 90% less CO2', price: 800, category: 'Bottles', carbonSaved: 5.0, stock: 20),
      EcoProduct(id: '3', nameEn: 'Jute Shopping Bag', nameHi: 'जूट शॉपिंग बैग', imageUrl: 'https://images.unsplash.com/photo-1597484661643-2f5fef640df1?auto=format&fit=crop&w=400&q=80', ecoScoreBadge: 'A+', lcaSummary: 'Biodegradable, 1000x reusable', price: 200, category: 'Bags', carbonSaved: 4.0, stock: 100),
      EcoProduct(id: '4', nameEn: 'Wooden Toothbrush', nameHi: 'लकड़ी का टूथब्रश', imageUrl: 'https://images.unsplash.com/photo-1606131336048-52c66d9f6ed3?auto=format&fit=crop&w=400&q=80', ecoScoreBadge: 'A++', lcaSummary: 'Compostable handle', price: 100, category: 'Personal Care', carbonSaved: 0.5, stock: 200),
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
