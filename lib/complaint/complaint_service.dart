import 'dart:convert';
import 'package:http/http.dart' as http;

const GEMINI_KEY = "YOUR_KEY";

Future<Map<String, String>> analyzeComplaint(String text) async {
  final prompt = """
Analyze this complaint and return JSON:

{
 "category":"",
 "department":"",
 "priority":"Low/Medium/High"
}

Complaint:
$text
""";

  final res = await http.post(
    Uri.parse("https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$GEMINI_KEY"),
    headers: {"Content-Type":"application/json"},
    body: jsonEncode({
      "contents":[{"parts":[{"text":prompt}]}]
    }),
  );

  final raw = jsonDecode(res.body);
  final txt = raw["candidates"][0]["content"]["parts"][0]["text"];
  return jsonDecode(txt.replaceAll("```","").trim());
}