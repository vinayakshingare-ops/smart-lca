import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import 'mining_monitor_screen.dart';
import 'product_scanner_screen.dart';
import 'eco_swap_screen.dart';
import '../widgets/eco_chan_fab.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final user = db.currentUser;

    return Scaffold(
      floatingActionButton: const EcoChanFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(
        title: const Text('SmartLCA Mine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          )
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Stats Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCol('EcoCoins', '${user.ecoCoins}', Icons.monetization_on, AppTheme.warningColor),
                        _buildStatCol('City Rank', '#${user.rank}', Icons.leaderboard, AppTheme.primaryColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Tools',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildMenuCard(
                          context,
                          'Mining Monitor',
                          'Satellite NDVI map & deforestation alerts',
                          Icons.satellite_alt,
                          const MiningMonitorScreen(),
                        ),
                        const SizedBox(height: 16),
                        _buildMenuCard(
                          context,
                          'Scan Product',
                          'Waste classification & recycling info',
                          Icons.qr_code_scanner,
                          const ProductScannerScreen(),
                        ),
                        const SizedBox(height: 16),
                        _buildMenuCard(
                          context,
                          'Eco Store',
                          'Eco-friendly alternatives marketplace',
                          Icons.storefront,
                          const EcoSwapScreen(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCol(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 32),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
