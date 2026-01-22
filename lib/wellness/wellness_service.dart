import 'dart:convert';
import 'package:http/http.dart' as http;

const String GEMINI_API_KEY = "YOUR_API_KEY";

Future<String> getWellnessReply(String msg) async {
  final prompt = """
You are a mental wellness assistant for students.
Reply empathetically, calmly and supportively.
Do not diagnose. Do not judge.

Student says:
"$msg"
""";

  final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$GEMINI_API_KEY");

  final res = await http.post(url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }));

  final raw = jsonDecode(res.body);
  return raw["candidates"][0]["content"]["parts"][0]["text"];
}