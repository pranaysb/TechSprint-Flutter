import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'match_view.dart';

class ItemList extends StatelessWidget {
  final String type;
  ItemList({required this.type});

  @override
  Widget build(BuildContext context) {
return StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection("items")
      .where("type", isEqualTo: type)
      .where("active", isEqualTo: true)
      .orderBy("createdAt", descending: true)
      .snapshots(),
  builder: (context, snapshot) {

    // Still connecting
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    // Error case
  //   if (snapshot.hasError) {
  // return Center(child: Text(snapshot.error.toString()));
  //   }
    if (snapshot.hasError) {
      return Center(child: Text("Error loading items"));
}

    final docs = snapshot.data!.docs;

    if (docs.isEmpty) {
      return Center(child: Text("No items found"));
    }

    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (c, i) {
        final d = docs[i];
        return Card(
          child: ListTile(
            leading: d["photoUrl"] != null
    ? Image.network(d["photoUrl"], width: 60, fit: BoxFit.cover)
    : Icon(Icons.image_not_supported),
            title: Text(d["title"]),
            subtitle: Text(d["description"]),
            trailing: Text(d["location"]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MatchView(d),
                  ),
                );
              }
          ),
        );
      },
    );
  },
);
  }
}