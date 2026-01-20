import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatelessWidget {
  final DocumentSnapshot doc;
  const DetailsPage({required this.doc, super.key});

  @override
  Widget build(BuildContext context) {
    final d = doc.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text(d["title"] ?? "")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (d["photoUrl"] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(d["photoUrl"],
                  height: 220, fit: BoxFit.cover),
            ),
          const SizedBox(height: 16),
          Text(d["description"] ?? ""),
          const SizedBox(height: 10),
          Text(d["location"] ?? ""),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.mail),
            label: const Text("Contact"),
            onPressed: () => launchUrl(Uri.parse(
                "mailto:${d["ownerEmail"]}?subject=Regarding ${d["title"]}")),
          )
        ],
      ),
    );
  }
}