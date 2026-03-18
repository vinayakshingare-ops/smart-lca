import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../providers/translation_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<TranslationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final db = Provider.of<DatabaseService>(context);
    final user = db.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // User Info
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: const Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Eco Warrior',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompactStat(Icons.monetization_on, '${user?.ecoCoins ?? 0}', AppTheme.warningColor),
                const SizedBox(width: 20),
                _buildCompactStat(Icons.leaderboard, '#${user?.rank ?? 0}', AppTheme.primaryColor),
              ],
            ),
            const Divider(height: 40),
            
            // Settings
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(AppLocalizations.of(context)!.profileLanguage),
              trailing: Switch(
                value: tp.isHindi,
                onChanged: (_) => tp.toggleLanguage(),
              ),
              subtitle: Text(tp.isHindi ? 'हिंदी' : 'English'),
            ),
            ListTile(
              leading: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: Text(AppLocalizations.of(context)!.profileDarkMode),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
            const Divider(height: 40),

            // Leaderboard Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.profileLeaderboard,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // Fake Leaderboard List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10, // Show top 10 for demo
              itemBuilder: (context, index) {
                final isMe = index == 2; // Mock "me" at rank 3
                return Container(
                  color: isMe ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 15,
                      backgroundColor: _getRankColor(index),
                      child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                    title: Text(
                      isMe ? '${user?.name} (You)' : 'User_${1000 + index}',
                      style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
                    ),
                    trailing: Text('${500 - (index * 40)} EcoCoins', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStat(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return Colors.amber;
    if (index == 1) return Colors.grey;
    if (index == 2) return Colors.brown;
    return Colors.green;
  }
}
