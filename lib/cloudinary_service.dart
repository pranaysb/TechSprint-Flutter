import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const CLOUD_NAME = "dmopsxmo3"; 
const UPLOAD_PRESET = "findit_upload"; 

Future<String?> uploadToCloudinary(File file) async {
  if (CLOUD_NAME.isEmpty) return null;

  try {
    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$CLOUD_NAME/image/upload");
    final request = http.MultipartRequest("POST", uri)
      ..fields["upload_preset"] = UPLOAD_PRESET
      ..files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final resStr = await response.stream.bytesToString();
    final data = jsonDecode(resStr);
    return data["secure_url"];
  } catch (e) {
    print("Upload Error: $e");
    return null;
  }
}