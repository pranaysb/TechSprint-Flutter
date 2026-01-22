import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'status_timeline.dart';

class ComplaintStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser!.email;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("complaints")
          .where("userEmail", isEqualTo: email)
          .snapshots(),
      builder: (_, snap) {
        if(!snap.hasData) return Center(child:CircularProgressIndicator());

        final docs = snap.data!.docs;

        return ListView(
          padding: EdgeInsets.all(20),
          children: docs.map((d){
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text(d["title"], style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height:6),
                    Text(d["department"]),
                    SizedBox(height:12),
                    StatusTimeline(d["status"])
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}