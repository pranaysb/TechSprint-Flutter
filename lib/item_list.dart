import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'details_page.dart';

class ItemList extends StatefulWidget {
  final String type;
  const ItemList({required this.type, super.key});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  bool onlyMine = false;

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser!.email;

    Query query = FirebaseFirestore.instance
        .collection("items")
        .where("type", isEqualTo: widget.type)
        .where("active", isEqualTo: true);

    if (onlyMine) {
      query = query.where("ownerEmail", isEqualTo: email);
    }

    return Column(
      children: [

        // 🔹 MY POSTS FILTER (only here)
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(
                widget.type == "lost" ? "My Lost" : "My Found",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Switch(
                value: onlyMine,
                onChanged: (v) {
                  setState(() => onlyMine = v);
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (_, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snap.data!.docs;

              if (docs.isEmpty) {
                return const Center(child: Text("No posts found"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final doc = docs[i];
                  final d = doc.data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailsPage(doc: doc),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.4)
                                : Colors.black.withOpacity(0.08)
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          if (d["photoUrl"] != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24)),
                              child: Image.network(
                                d["photoUrl"],
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d["title"] ?? "",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  d["description"] ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16),
                                    const SizedBox(width: 6),
                                    Text(d["location"] ?? ""),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      gradient: const LinearGradient(
                                        colors: [Colors.indigo, Colors.purple],
                                      ),
                                    ),
                                    child: const Text(
                                      "View Details",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}