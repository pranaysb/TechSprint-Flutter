import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gemini_service.dart';
import 'match_view.dart'; // 🔹 IMPORTED THE NEW VIEW

class MatchesTab extends StatefulWidget {
  @override
  _MatchesTabState createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  bool scanning = false;
  List<Map<String, dynamic>> matches = [];

  Future<void> scan() async {
    setState(() { scanning = true; matches.clear(); });
    final user = FirebaseAuth.instance.currentUser!;

    try {
      // 1. My LOST items
      final myLost = await FirebaseFirestore.instance
          .collection("items")
          .where("ownerUid", isEqualTo: user.uid)
          .where("type", isEqualTo: "lost")
          .where("active", isEqualTo: true)
          .get();

      // 2. Others' FOUND items
      final allFound = await FirebaseFirestore.instance
          .collection("items")
          .where("type", isEqualTo: "found")
          .where("active", isEqualTo: true)
          .get();

      final othersFound = allFound.docs.where((doc) => doc["ownerUid"] != user.uid).toList();

      if (myLost.docs.isEmpty || othersFound.isEmpty) {
        setState(() => scanning = false);
        return;
      }

      // 3. AI Compare
      for (var lostItem in myLost.docs) {
        for (var foundItem in othersFound) {
          try {
            final res = await match(lostItem["description"], foundItem["description"]);
            if (res["similarity_score"] >= 0.4) { // Threshold
              matches.add({
                "my_item": lostItem,
                "found_item": foundItem,
                "score": res["similarity_score"],
                "reason": res["reasoning"]
              });
            }
          } catch (e) {
            print("AI Error: $e");
          }
        }
      }
    } catch (e) {
      print("Scan Error: $e");
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
            CircularProgressIndicator(color: Colors.indigo),
            SizedBox(height: 24),
            Text("AI is analyzing descriptions...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.radar, size: 60, color: Colors.indigo),
            ),
            SizedBox(height: 24),
            Text("No AI Matches Yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Scan to compare your lost items\nwith found items nearby.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.search),
              label: Text("START AI SCAN"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: scan,
            )
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, i) {
        final m = matches[i];
        final foundDoc = m["found_item"] as DocumentSnapshot;
        final myDoc = m["my_item"] as DocumentSnapshot;
        final foundData = foundDoc.data() as Map<String, dynamic>;
        
        final double rawScore = m["score"];
        final int score = (rawScore * 100).toInt();
        final bool isHigh = score > 75;

        return Card(
          margin: EdgeInsets.only(bottom: 20),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shadowColor: Colors.black26,
          child: InkWell(
            onTap: () {
              // 🔹 NAVIGATE TO THE DETAILED MATCH VIEW
              Navigator.push(context, MaterialPageRoute(builder: (_) => MatchView(
                myItem: myDoc,
                foundItem: foundDoc,
                score: rawScore,
                reasoning: m["reason"],
              )));
            },
            child: Column(
              children: [
                // Header Gradient
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isHigh 
                        ? [Colors.green.shade600, Colors.green.shade400]
                        : [Colors.orange.shade600, Colors.orange.shade400]
                    )
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        isHigh ? "HIGH MATCH" : "POSSIBLE MATCH",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Text("$score%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      )
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Found Item Image Thumbnail
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                          image: foundData["photoUrl"] != null 
                              ? DecorationImage(image: NetworkImage(foundData["photoUrl"]), fit: BoxFit.cover)
                              : null
                        ),
                        child: foundData["photoUrl"] == null ? Icon(Icons.image, color: Colors.grey) : null,
                      ),
                      
                      SizedBox(width: 16),

                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Found: ${foundData['title']}", 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                            SizedBox(height: 4),
                            Text("Your Item: ${m['my_item']['title']}", 
                              style: TextStyle(fontSize: 14, color: Colors.grey[600])
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Tap to view AI analysis >", 
                              style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}