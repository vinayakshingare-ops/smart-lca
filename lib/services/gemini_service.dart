import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String _apiKey = 'AIzaSyBPDEBOi7jNUMs74QzZC4ri-W6Un0ApXYk';
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  Future<String> sendMessage(String userMessage) async {
    final url = Uri.parse('$_apiUrl?key=$_apiKey');

    final payload = {
      "systemInstruction": {
        "parts": [
          {
            "text": "You are Eco Chan, a friendly environmental chatbot. Help users with recycling, sustainability, eco-friendly products, carbon footprint reduction, and mining environmental impact. Keep answers concise, helpful, and friendly. Use emojis."
          }
        ]
      },
      "contents": [
        {
          "parts": [
            {"text": userMessage}
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String textResponse =
            data['candidates'][0]['content']['parts'][0]['text'];
        return textResponse.trim();
      } else {
        return "Oops! I encountered an error. 😓 Error code: ${response.statusCode}";
      }
    } catch (e) {
      return "Oh no! Could not reach the server. 🥺 Please check your connection.";
    }
  }
}
