import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailsPage extends StatelessWidget {
  final DocumentSnapshot doc;
  DetailsPage({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final isMe = FirebaseAuth.instance.currentUser?.uid == data["ownerUid"];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.indigo,
            flexibleSpace: FlexibleSpaceBar(
              background: data["photoUrl"] != null
                  ? Image.network(data["photoUrl"], fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[300],
                      child: Center(child: Icon(Icons.image, size: 80, color: Colors.white)),
                    ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                transform: Matrix4.translationValues(0, -20, 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: data["type"] == "lost" ? Colors.red[50] : Colors.teal[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data["type"].toString().toUpperCase(),
                            style: TextStyle(
                              color: data["type"] == "lost" ? Colors.red : Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Spacer(),
                        Text("Active", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    Text(
                      data["title"] ?? "No Title",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 18, color: Colors.indigo),
                        SizedBox(width: 5),
                        Text(data["location"] ?? "Unknown", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      ],
                    ),

                    SizedBox(height: 24),
                    Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      data["description"] ?? "",
                      style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800]),
                    ),

                    SizedBox(height: 32),
                    Divider(),
                    SizedBox(height: 16),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade100,
                        child: Text(data["ownerName"]?[0] ?? "U", style: TextStyle(color: Colors.indigo)),
                      ),
                      title: Text(data["ownerName"] ?? "Anonymous"),
                      subtitle: Text("Owner"),
                    ),

                    SizedBox(height: 24),

                    if (!isMe)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.email),
                          label: Text("CONTACT OWNER"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: data["ownerEmail"],
                              query: 'subject=Regarding ${data["title"]}',
                            );
                            launchUrl(emailLaunchUri);
                          },
                        ),
                      ),
                      
                    if (isMe)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.delete_outline),
                          label: Text("MARK AS INACTIVE"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red.shade200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                             doc.reference.update({"active": false});
                             Navigator.pop(context);
                          },
                        ),
                      ),
                    
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}