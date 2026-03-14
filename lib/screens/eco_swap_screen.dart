import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class EcoSwapScreen extends StatelessWidget {
  const EcoSwapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Collect all alternatives from all products
    final db = Provider.of<DatabaseService>(context);
    final alternatives = db.products.expand((p) => p.ecoAlternatives).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Store / Alternatives'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alternatives.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final alt = alternatives[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                      // Placeholder for actual image
                      child: Icon(Icons.shopping_bag, size: 50, color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alt.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('₹${alt.price}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('+${alt.ecoScoreImprovement} Eco Score', style: const TextStyle(fontSize: 12, color: Colors.green)),
                      Text('${alt.carbonSavingsPerYear}kg CO2 saved/yr', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final url = Uri.parse(alt.purchaseLink);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                            // Reward user
                            db.addEcoCoins(50);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase verified! +50 EcoCoins')));
                            }
                          },
                          style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, textStyle: const TextStyle(fontSize: 12)),
                          child: const Text('BUY NOW'),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
