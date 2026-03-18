import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../screens/chatbot_screen.dart';

class EcoChanFab extends StatelessWidget {
  const EcoChanFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'eco-chan-fab',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatbotScreen()),
        );
      },
      backgroundColor: AppTheme.primaryColor,
      elevation: 4,
      tooltip: 'Chat with Eco Chan',
      child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
    );
  }
}
