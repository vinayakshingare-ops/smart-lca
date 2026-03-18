import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  final String _apiKey = 'AIzaSyBPDEBOi7jNUMs74QzZC4ri-W6Un0ApXYk';
  late final GenerativeModel _chatModel;
  late final GenerativeModel _visionModel;

  GeminiService() {
    _chatModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system("You are Eco Chan, a friendly environmental chatbot. Help users with recycling, sustainability, eco-friendly products, carbon footprint reduction, and mining environmental impact. Keep answers concise, helpful, and friendly. Use emojis.")
    );
    
    _visionModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await _chatModel.generateContent([
        Content.text(userMessage)
      ]);
      return response.text?.trim() ?? "No response";
    } catch (e) {
      debugPrint('Gemini Chat Error: $e');
      return "Oh no! Could not reach the server. 🥺 Please check your connection.";
    }
  }

  Future<String> analyzeProduct(String prompt) async {
    try {
      final response = await _visionModel.generateContent([
        Content.text(prompt)
      ]);
      return response.text?.trim() ?? "No response";
    } catch (e) {
      debugPrint('Gemini Vision Error: $e');
      return "Error connecting to AI analysis.";
    }
  }
}
