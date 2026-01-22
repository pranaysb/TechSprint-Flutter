import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  final String department="Hostel Office";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("complaints")
            .where("department", isEqualTo: department)
            .snapshots(),
        builder: (_, snap){
          if(!snap.hasData) return Center(child:CircularProgressIndicator());
          final docs=snap.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder:(_,i){
              final d=docs[i];
              return Card(
                child: ListTile(
                  title: Text(d["title"]),
                  subtitle: Text(d["status"]),
                  trailing: PopupMenuButton(
                    onSelected:(v){
                      FirebaseFirestore.instance
                          .collection("complaints")
                          .doc(d.id)
                          .update({"status":v});
                    },
                    itemBuilder:(_)=>[
                      PopupMenuItem(value:"Pending",child:Text("Pending")),
                      PopupMenuItem(value:"In Progress",child:Text("In Progress")),
                      PopupMenuItem(value:"Resolved",child:Text("Resolved")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}