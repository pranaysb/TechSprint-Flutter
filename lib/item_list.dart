import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details_page.dart';

class ItemList extends StatelessWidget {
  final String type;
  ItemList({required this.type});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("items")
          .where("type", isEqualTo: type)
          .where("active", isEqualTo: true)
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) return Center(child: CircularProgressIndicator());

        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                Text("No ${type} items yet", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final photo = d["photoUrl"];

            return Hero(
              tag: docs[i].id,
              child: Card(
                margin: EdgeInsets.only(bottom: 20),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsPage(doc: docs[i]))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BIG IMAGE AREA
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: photo != null
                            ? Image.network(photo, fit: BoxFit.cover)
                            : Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                      ),
                      
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    d["title"] ?? "No Title",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: type == 'lost' ? Colors.red.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Text(
                                    type.toUpperCase(),
                                    style: TextStyle(
                                      color: type == 'lost' ? Colors.red : Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              d["description"] ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[600], height: 1.5),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(d["location"] ?? "Unknown", 
                                    style: TextStyle(color: Colors.grey[700]),
                                    maxLines: 1, overflow: TextOverflow.ellipsis
                                  ),
                                ),
                                Text("View Details >", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}