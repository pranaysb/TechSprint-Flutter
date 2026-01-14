import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details_page.dart';

class ItemList extends StatelessWidget {
  final String type; // "lost" or "found"
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
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                SizedBox(height: 10),
                Text("No ${type} items yet", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 80), // Extra bottom padding for FAB
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildCard(context, docs[index], data);
          },
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, DocumentSnapshot doc, Map<String, dynamic> data) {
    final photoUrl = data["photoUrl"];
    final bool isLost = type == "lost";

    return Container(
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsPage(doc: doc))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. IMAGE AREA (Fixed Height for consistency)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: photoUrl != null
                      ? Image.network(photoUrl, fit: BoxFit.cover)
                      : Center(
                          child: Icon(Icons.image_not_supported_outlined, 
                            size: 40, color: Colors.grey[400])
                        ),
                ),
              ),

              // 2. CONTENT AREA
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge & Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isLost ? Colors.red.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: TextStyle(
                              color: isLost ? Colors.red : Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward, size: 16, color: Colors.grey[400])
                      ],
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Title
                    Text(
                      data["title"] ?? "No Title",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 6),

                    // Description (Limited lines to prevent overflow)
                    Text(
                      data["description"] ?? "",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 16),
                    Divider(height: 1),
                    SizedBox(height: 12),

                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.indigo),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            data["location"] ?? "Unknown Location",
                            style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}