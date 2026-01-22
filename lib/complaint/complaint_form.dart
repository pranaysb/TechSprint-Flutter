import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'complaint_service.dart';

class ComplaintForm extends StatefulWidget {
  @override
  _ComplaintFormState createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final title = TextEditingController();
  final desc = TextEditingController();
  bool loading=false;

  submit() async {
    setState(()=>loading=true);

    final ai = await analyzeComplaint(desc.text);

    await FirebaseFirestore.instance.collection("complaints").add({
      "title": title.text,
      "description": desc.text,
      "category": ai["category"],
      "department": ai["department"],
      "priority": ai["priority"],
      "status": "Pending",
      "userEmail": FirebaseAuth.instance.currentUser!.email,
      "createdAt": FieldValue.serverTimestamp()
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Complaint")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children:[
          TextField(controller:title, decoration: InputDecoration(labelText:"Title")),
          SizedBox(height:12),
          TextField(controller:desc, maxLines:5, decoration: InputDecoration(labelText:"Description")),
          SizedBox(height:20),
          ElevatedButton(
            onPressed: loading?null:submit,
            child: loading?CircularProgressIndicator():Text("Submit Complaint"),
          )
        ]),
      ),
    );
  }
}