import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gemini_service.dart';

class MatchView extends StatefulWidget {
  final DocumentSnapshot item;
  MatchView(this.item);

  @override
  _MatchViewState createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  bool loading = true;
  List matches = [];

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    try {
      final oppositeType =
          widget.item["type"] == "lost" ? "found" : "lost";

      final snap = await FirebaseFirestore.instance
          .collection("items")
          .where("type", isEqualTo: oppositeType)
          .where("active", isEqualTo: true)
          .get();

      matches.clear();

      for (var d in snap.docs) {
        final result = await match(
          widget.item["description"],
          d["description"],
        );

        final score = result["similarity_score"];

        // 👉 ONLY HIGH CONFIDENCE MATCHES
        if (score >= 0.6) {
          matches.add({
            "item": d,
            "score": score,
            "reason": result["reasoning"]
          });
        }
      }
    } catch (e) {
      print("MATCH ERROR: $e");
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("High Confidence Matches")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : matches.isEmpty
              ? Center(child: Text("No high confidence matches found"))
              : ListView(
                  children: matches.map((m) {
                    return 
                    Card(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // 🔹 IMAGE
      if (m["item"]["photoUrl"] != null)
        Image.network(
          m["item"]["photoUrl"],
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
        ),

      // 🔹 TEXT CONTENT
      ListTile(
        title: Text(m["item"]["title"]),
        subtitle: Text(m["reason"]),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${(m["score"] * 100).toInt()}%"),
            Text("High",
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ],
  ),
);
                  }).toList(),
                ),
    );
  }
}