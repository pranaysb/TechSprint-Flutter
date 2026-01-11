import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cloudinary_service.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  File? image;
  String type = "lost";

  final title = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();

  Future pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

Future submit() async {
  try {
    final user = FirebaseAuth.instance.currentUser!;
    String? imageUrl;

    if (image != null) {
      imageUrl = await uploadToCloudinary(image!);
    }

    await FirebaseFirestore.instance.collection("items").add({
      "title": title.text,
      "description": description.text,
      "location": location.text,
      "type": type,
      "photoUrl": imageUrl,
      "ownerId": user.uid,
      "email": user.email,
      "active": true,
      "createdAt": FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  } catch (e) {
    print("POST ERROR: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Post")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButton<String>(
              value: type,
              items: ["lost", "found"]
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => type = v!),
            ),

            TextField(controller: title, decoration: InputDecoration(labelText: "Title")),
            TextField(controller: description, decoration: InputDecoration(labelText: "Description")),
            TextField(controller: location, decoration: InputDecoration(labelText: "Location")),

            SizedBox(height: 10),

            image == null
                ? TextButton.icon(
                    icon: Icon(Icons.image),
                    label: Text("Pick Image"),
                    onPressed: pickImage,
                  )
                : Image.file(image!, height: 150),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: submit,
              child: Text("Post"),
            )
          ],
        ),
      ),
    );
  }
}