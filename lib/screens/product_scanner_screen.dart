import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/database_service.dart';
import '../models/product_model.dart';
import '../services/gemini_service.dart';
import '../utils/app_theme.dart';

class ProductScannerScreen extends StatefulWidget {
  const ProductScannerScreen({super.key});

  @override
  State<ProductScannerScreen> createState() => _ProductScannerScreenState();
}

class _ProductScannerScreenState extends State<ProductScannerScreen> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture, DatabaseService db) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.rawValue ?? '';
      
      setState(() {
        _isProcessing = true;
      });

      // Show mock lookup first
      ProductModel? product = db.getProductByBarcode(code) ?? db.products.first;
      db.addEcoCoins(5); // Reward for scanning!

      // Ask Gemini for analysis
      final gemini = GeminiService();
      final aiAnalysis = await gemini.analyzeProduct(
          "Analyze the environmental impact of a product scanned via barcode '$code'. "
          "The system thinks it is a '${product.name}'. "
          "Provide a short 3 sentence summary of: 1) Its environmental impact, "
          "2) General recycling instructions, and 3) An eco-friendly alternative."
      );

      if (mounted) {
        _showResultDialog(context, product, aiAnalysis);
      }
    }
  }

  void _showResultDialog(BuildContext context, ProductModel product, String aiAnalysis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Material: ${product.materialType}', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.secondaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text('Eco Score: ${product.ecoScore}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text('CO2 Footprint: ${product.carbonImpact} kg', style: const TextStyle(fontSize: 16, color: Colors.black87)),
              const Divider(height: 30, thickness: 1),
              const Row(
                children: [
                   Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                   SizedBox(width: 8),
                   Text('AI Analysis (Gemini):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(aiAnalysis, style: const TextStyle(fontSize: 15)),
              ),
              const Divider(height: 30, thickness: 1),
              const Text('Recycling Instructions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(product.recyclingInstructionsEn, style: const TextStyle(fontSize: 15)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(product.recyclingInstructionsHi, style: const TextStyle(fontSize: 15, fontFamily: 'Noto Sans Devanagari')),
              ),
              const SizedBox(height: 20),
              if (product.ecoAlternatives.isNotEmpty) ...[
                const Divider(height: 30, thickness: 1),
                const Text('🌿 Eco-Friendly Alternatives:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: product.ecoAlternatives.length,
                    itemBuilder: (ctx, i) {
                      final alt = product.ecoAlternatives[i];
                      return Container(
                        width: 240,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alt.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('₹${alt.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('+${alt.ecoScoreImprovement} Score', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Text('-${alt.carbonSavingsPerYear} kg CO2/yr', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  final uri = Uri.parse(alt.purchaseLink);
                                  launchUrl(uri, mode: LaunchMode.externalApplication);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  backgroundColor: AppTheme.secondaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Buy'),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Awesome! (+5 EcoCoins)'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _isProcessing = false;
                    });
                  },
                ),
              )
            ],
          ),
        ),
      );
      }
    ).then((_) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Product')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) => _onDetect(capture, db),
          ),
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.secondaryColor, width: 4),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Align barcode or object in frame',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.secondaryColor),
              ),
            ),
        ],
      ),
    );
  }
}
