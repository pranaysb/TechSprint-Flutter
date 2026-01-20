import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetail extends StatelessWidget {
  final DocumentSnapshot doc;
  const EventDetail({required this.doc, super.key});

  @override
  Widget build(BuildContext context) {
    final d = doc.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text(d["name"])),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          if (d["posterUrl"] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                d["posterUrl"],
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 20),

          Text(d["description"] ?? ""),

          const SizedBox(height: 12),
          Text("📍 ${d["venue"]}"),
          Text("⏰ ${d["time"]}"),
          Text("🏫 ${d["organizer"]}"),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            icon: const Icon(Icons.map),
            label: const Text("Open in Maps"),
            onPressed: () => launchUrl(
              Uri.parse("https://www.google.com/maps/search/${d["venue"]}"),
            ),
          ),
        ],
      ),
    );
  }
}