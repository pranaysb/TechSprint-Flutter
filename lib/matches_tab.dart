import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gemini_service.dart';
import 'details_page.dart'; // To show details of matched item

class MatchesTab extends StatefulWidget {
  @override
  _MatchesTabState createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  // We store the results here
  List<Map<String, dynamic>> aiMatches = [];
  bool scanning = false;

  // 1. Get My Active Lost Items
  Future<void> scanForMatches() async {
    setState(() { scanning = true; aiMatches.clear(); });
    
    final user = FirebaseAuth.instance.currentUser!;

    try {
      // A. Get MY Lost items
      final myLostSnap = await FirebaseFirestore.instance
          .collection("items")
          .where("ownerUid", isEqualTo: user.uid)
          .where("type", isEqualTo: "lost")
          .where("active", isEqualTo: true)
          .get();

      // B. Get ALL Found items (excluding mine)
      final allFoundSnap = await FirebaseFirestore.instance
          .collection("items")
          .where("type", isEqualTo: "found")
          .where("active", isEqualTo: true)
          .get();

      // Filter out my own found items locally (since Firestore != query is limited)
      final othersFoundDocs = allFoundSnap.docs.where((doc) => doc["ownerUid"] != user.uid).toList();

      if (myLostSnap.docs.isEmpty || othersFoundDocs.isEmpty) {
        setState(() => scanning = false);
        return;
      }

      // C. AI Comparison Loop (Careful with API limits)
      // We compare every LOST item of mine against every FOUND item
      for (var myItem in myLostSnap.docs) {
        for (var foundItem in othersFoundDocs) {
          try {
            // Call Gemini
            final result = await match(myItem["description"], foundItem["description"]);
            
            if (result["similarity_score"] >= 0.5) { // Threshold
              aiMatches.add({
                "my_item": myItem,
                "found_item": foundItem,
                "score": result["similarity_score"],
                "reason": result["reasoning"],
              });
            }
          } catch (e) {
            print("AI Error: $e");
          }
        }
      }

    } catch (e) {
      print("Error scanning: $e");
    }

    setState(() => scanning = false);
  }

  @override
  Widget build(BuildContext context) {
    if (scanning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("AI is analyzing descriptions...", style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (aiMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 80, color: Colors.indigo.shade200),
            SizedBox(height: 20),
            Text("No matches found yet.", style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.radar),
              label: Text("SCAN NOW"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: scanForMatches,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("This compares your 'Lost' items with everyone's 'Found' items using Gemini AI.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            )
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: aiMatches.length,
        itemBuilder: (ctx, i) {
          final m = aiMatches[i];
          final double score = m["score"];
          final bool isHigh = score > 0.8;
          final foundData = m["found_item"].data();
          final myData = m["my_item"].data();

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Header: Match Score
                Container(
                  padding: EdgeInsets.all(12),
                  color: isHigh ? Colors.green.shade50 : Colors.amber.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: isHigh ? Colors.green : Colors.amber),
                      SizedBox(width: 10),
                      Text(isHigh ? "HIGH MATCH" : "POSSIBLE MATCH", style: TextStyle(fontWeight: FontWeight.bold, color: isHigh ? Colors.green.shade800 : Colors.amber.shade800)),
                      Spacer(),
                      Text("${(score * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                    ],
                  ),
                ),
                
                // Body: Comparison
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your Item: ${myData['title']}", style: TextStyle(fontWeight: FontWeight.w600)),
                      Text("Matches with: ${foundData['title']}", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo)),
                      Divider(),
                      Text("AI Reasoning:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(m["reason"], style: TextStyle(fontStyle: FontStyle.italic)),
                      SizedBox(height: 15),
                      
                      // Action
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          child: Text("VIEW FOUND ITEM DETAILS"),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsPage(doc: m["found_item"])));
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: scanForMatches,
      ),
    );
  }
}