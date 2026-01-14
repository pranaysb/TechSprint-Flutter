import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cloudinary_service.dart';

class CreatePost extends StatefulWidget {
  final String defaultType; 
  CreatePost({required this.defaultType});

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  File? image;
  late String type;
  bool anonymous = false;
  bool uploading = false;

  final title = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();

  @override
  void initState() {
    super.initState();
    type = widget.defaultType;
  }

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => image = File(picked.path));
  }

  Future submit() async {
    if (title.text.isEmpty) return;
    setState(() => uploading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser!;
      String? imageUrl;

      if (image != null) {
        imageUrl = await uploadToCloudinary(image!);
      }

      await FirebaseFirestore.instance.collection("items").add({
        "title": title.text.trim(),
        "description": description.text.trim(),
        "location": location.text.trim(),
        "type": type,
        "photoUrl": imageUrl,
        "ownerUid": user.uid,
        "ownerEmail": user.email,
        "ownerName": anonymous ? "Anonymous" : (user.displayName ?? "User"),
        "active": true,
        "createdAt": FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      print("POST ERROR: $e");
      setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Post")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("What did you ${type}?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            
            // Image Picker
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  image: image != null ? DecorationImage(image: FileImage(image!), fit: BoxFit.cover) : null,
                ),
                child: image == null 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.add_a_photo, size: 40, color: Colors.grey), Text("Add Photo", style: TextStyle(color: Colors.grey))]
                    )
                  : null,
              ),
            ),
            
            SizedBox(height: 20),
            TextField(
              controller: title,
              decoration: InputDecoration(labelText: "Title (e.g., Red Wallet)", border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: description,
              decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder(), alignLabelWithHint: true),
              maxLines: 4,
            ),
            SizedBox(height: 15),
            TextField(
              controller: location,
              decoration: InputDecoration(labelText: "Location", border: OutlineInputBorder(), prefixIcon: Icon(Icons.pin_drop)),
            ),
            SizedBox(height: 10),
            SwitchListTile(
              title: Text("Post Anonymously"),
              value: anonymous,
              onChanged: (v) => setState(() => anonymous = v),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: uploading ? null : submit,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                child: uploading ? CircularProgressIndicator(color: Colors.white) : Text("POST NOW"),
              ),
            )
          ],
        ),
      ),
    );
  }
}