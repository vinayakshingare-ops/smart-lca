import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/database_service.dart';
import '../models/product_model.dart';
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

      // Mock processing delay to simulate API/ML load
      await Future.delayed(const Duration(seconds: 1));
      
      // Fallback search to show a scanned product (we just mock it as always returning p1 if nothing matches)
      ProductModel? product = db.getProductByBarcode(code) ?? db.products.first;

      db.addEcoCoins(5); // Reward for scanning!

      if (mounted) {
        _showResultDialog(context, product);
      }
    }
  }

  void _showResultDialog(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
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
