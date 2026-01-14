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
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  Future submit() async {
    if (title.text.isEmpty || description.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Title and Description are required")));
      return;
    }

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
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed. Try again.")));
      setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Post ${type.toUpperCase()} Item")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                  image: image != null ? DecorationImage(image: FileImage(image!), fit: BoxFit.cover) : null,
                ),
                child: image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[600]),
                          SizedBox(height: 8),
                          Text("Add Photo", style: TextStyle(color: Colors.grey[600])),
                        ],
                      )
                    : null,
              ),
            ),
            
            SizedBox(height: 24),
            
            TextField(
              controller: title,
              decoration: InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: description,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description",
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: location,
              decoration: InputDecoration(
                labelText: "Location",
                prefixIcon: Icon(Icons.pin_drop_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            
            SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Post Anonymously"),
              value: anonymous,
              onChanged: (v) => setState(() => anonymous = v),
            ),

            SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: uploading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: uploading 
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : Text("PUBLISH POST", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}