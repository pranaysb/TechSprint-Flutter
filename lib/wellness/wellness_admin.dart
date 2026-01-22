import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WellnessAdmin extends StatelessWidget {
  const WellnessAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wellness Analytics")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("wellness_chats")
            .snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator());

          return ListView(
            children: [
              ListTile(
                title: Text("Total Conversations"),
                trailing: Text(snap.data!.docs.length.toString()),
              )
            ],
          );
        },
      ),
    );
  }
}