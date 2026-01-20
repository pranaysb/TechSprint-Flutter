import 'dart:convert';
import 'package:http/http.dart' as http;

const String GEMINI_API_KEY = "AIzaSyDdyLUbjdIvHgp4049Gj-fsqkgprm1jQuo";

Future<Map<String, dynamic>> match(String a, String b) async {
  if (GEMINI_API_KEY.isEmpty) {
    return {
      "similarity_score": 0.0,
      "reasoning": "No API Key"
    };
  }

  final prompt = """
Compare these two descriptions for a Lost & Found match.

Lost item: $a
Found item: $b

Return ONLY valid JSON:

{
  "similarity_score": 0.0 to 1.0,
  "reasoning": "Short explanation"
}
""";

  try {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      print("Gemini HTTP Error ${response.statusCode}");
      return {"similarity_score": 0.0, "reasoning": "HTTP Error"};
    }

    final raw = jsonDecode(response.body);
    final text =
        raw["candidates"][0]["content"]["parts"][0]["text"];

    final cleaned = text
        .replaceAll("```json", "")
        .replaceAll("```", "")
        .trim();

    return jsonDecode(cleaned);
  } catch (e) {
    print("Gemini Error: $e");
    return {"similarity_score": 0.0, "reasoning": "Exception"};
  }
}