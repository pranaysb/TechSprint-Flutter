import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details_page.dart';

class MatchView extends StatelessWidget {
  final DocumentSnapshot myItem;
  final DocumentSnapshot foundItem;
  final double score;
  final String reasoning;

  MatchView({
    required this.myItem,
    required this.foundItem,
    required this.score,
    required this.reasoning,
  });

  @override
  Widget build(BuildContext context) {
    final myData = myItem.data() as Map<String, dynamic>;
    final foundData = foundItem.data() as Map<String, dynamic>;
    final bool isHigh = score > 0.7;

    return Scaffold(
      appBar: AppBar(title: Text("Match Details")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. The Match Score Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isHigh 
                      ? [Colors.green.shade700, Colors.green.shade400]
                      : [Colors.orange.shade700, Colors.orange.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isHigh ? Colors.green : Colors.orange).withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 8),
                  )
                ]
              ),
              child: Column(
                children: [
                  Text(
                    "${(score * 100).toInt()}%",
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  Text(
                    isHigh ? "HIGH PROBABILITY MATCH" : "MODERATE MATCH",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // 2. Comparison Section
            Row(
              children: [
                Expanded(child: _miniItemCard(context, "Your Item", myData, true)),
                SizedBox(width: 12),
                Icon(Icons.compare_arrows, size: 30, color: Colors.grey),
                SizedBox(width: 12),
                Expanded(child: _miniItemCard(context, "Found Item", foundData, false)),
              ],
            ),

            SizedBox(height: 30),

            // 3. AI Reasoning Box
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text("AI Analysis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    reasoning,
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // 4. Action Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsPage(doc: foundItem)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: Text("CONTACT FINDER / VIEW DETAILS", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _miniItemCard(BuildContext context, String label, Map<String, dynamic> data, bool isMine) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600], fontSize: 12)),
        SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[200],
            image: data["photoUrl"] != null
                ? DecorationImage(image: NetworkImage(data["photoUrl"]), fit: BoxFit.cover)
                : null,
          ),
          child: data["photoUrl"] == null ? Center(child: Icon(Icons.image, color: Colors.grey)) : null,
        ),
        SizedBox(height: 8),
        Text(
          data["title"] ?? "", 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}