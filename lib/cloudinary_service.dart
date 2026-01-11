import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const CLOUD_NAME = ""; // your cloud name
const UPLOAD_PRESET = ""; // your unsigned preset

Future<String> uploadToCloudinary(File file) async {
  final uri =
      Uri.parse("https://api.cloudinary.com/v1_1/$CLOUD_NAME/image/upload");

  final request = http.MultipartRequest("POST", uri)
    ..fields["upload_preset"] = UPLOAD_PRESET
    ..files.add(await http.MultipartFile.fromPath("file", file.path));

  final response = await request.send();
  final resStr = await response.stream.bytesToString();

  print("CLOUDINARY RESPONSE: $resStr");

  final data = jsonDecode(resStr);

  if (data["secure_url"] == null) {
    throw Exception("Cloudinary upload failed");
  }

  return data["secure_url"];
}