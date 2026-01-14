import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailsPage extends StatelessWidget {
  final DocumentSnapshot doc;
  DetailsPage({required this.doc});

  @override
  Widget build(BuildContext context) {
    final d = doc.data() as Map<String, dynamic>;
    final me = FirebaseAuth.instance.currentUser!.uid == d["ownerUid"];
    final photo = d["photoUrl"];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(d["title"] ?? "Item Details", 
                style: TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 10)])
              ),
              background: photo != null 
                ? Image.network(photo, fit: BoxFit.cover)
                : Container(color: Colors.grey, child: Icon(Icons.image, size: 50, color: Colors.white)),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta tags
                    Row(
                      children: [
                        Chip(
                          avatar: Icon(Icons.category, size: 16),
                          label: Text(d["type"].toString().toUpperCase()),
                          backgroundColor: d["type"] == "lost" ? Colors.red.shade50 : Colors.teal.shade50,
                        ),
                        SizedBox(width: 10),
                        Chip(
                          avatar: Icon(Icons.calendar_today, size: 16),
                          label: Text("Active"),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(d["description"] ?? "No description provided.", style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800])),
                    
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),

                    Row(children: [
                      Icon(Icons.location_pin, color: Theme.of(context).primaryColor),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(d["location"] ?? "Unknown", style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    ]),

                    SizedBox(height: 30),
                    Text("Contact Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text(d["ownerName"][0])),
                      title: Text(d["ownerName"] ?? "Anonymous"),
                      subtitle: Text(d["ownerEmail"] ?? ""),
                    ),

                    SizedBox(height: 20),
                    
                    if (!me)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.mail),
                        label: Text("Contact Owner via Email"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => launchUrl(Uri.parse("mailto:${d["ownerEmail"]}?subject=Regarding ${d["title"]}")),
                      ),
                    ),

                    if (me)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.delete),
                          label: Text("Mark as Inactive / Delete"),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () {
                             doc.reference.update({"active": false});
                             Navigator.pop(context);
                          },
                        ),
                      ),
                      
                    SizedBox(height: 50),
                  ],
                ),
              )
            ]),
          )
        ],
      ),
    );
  }
}