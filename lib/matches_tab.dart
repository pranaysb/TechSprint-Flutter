import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gemini_service.dart';
import 'details_page.dart';

class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  bool loading = true;
  List matches = [];

  String filter = "lost"; // lost or found

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future fetchMatches() async {
    matches.clear();

    final email = FirebaseAuth.instance.currentUser!.email;

    final myPosts = await FirebaseFirestore.instance
        .collection("items")
        .where("ownerEmail", isEqualTo: email)
        .where("active", isEqualTo: true)
        .get();

    final allPosts = await FirebaseFirestore.instance
        .collection("items")
        .where("active", isEqualTo: true)
        .get();

    for (var my in myPosts.docs) {
      for (var other in allPosts.docs) {
        if (my.id == other.id) continue;
        if (my["type"] == other["type"]) continue;

        final res = await match(
          my["description"] ?? "",
          other["description"] ?? "",
        );

        final score = res["similarity_score"];

        if (score >= 0.4) {
          matches.add({
            "mine": my,
            "other": other,
            "score": score,
            "reason": res["reasoning"]
          });
        }
      }
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = matches.where((m) {
      return m["mine"]["type"] == filter;
    }).toList();

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [

        // 🔹 FILTER BAR
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text("My Lost"),
                selected: filter == "lost",
                onSelected: (_) => setState(() => filter = "lost"),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text("My Found"),
                selected: filter == "found",
                onSelected: (_) => setState(() => filter = "found"),
              ),
            ],
          ),
        ),

        // 🔹 LIST
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text("No matches found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final m = filtered[i];
                    final otherDoc = m["other"] as DocumentSnapshot;
                    final d = otherDoc.data() as Map<String, dynamic>;
                    final score = m["score"];
                    final reason = m["reason"];

                    final isHigh = score >= 0.75;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            color: Colors.black.withOpacity(0.08),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          if (d["photoUrl"] != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18)),
                              child: Image.network(
                                d["photoUrl"],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isHigh
                                            ? Colors.green.withOpacity(0.15)
                                            : Colors.orange.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isHigh
                                            ? "High Match"
                                            : "Medium Match",
                                        style: TextStyle(
                                          color: isHigh
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text("${(score * 100).toInt()}%"),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  d["title"] ?? "",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  reason,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DetailsPage(doc: otherDoc),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(22),
                                        gradient:
                                            const LinearGradient(colors: [
                                          Colors.indigo,
                                          Colors.purple
                                        ]),
                                      ),
                                      child: const Text(
                                        "View Details",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight:
                                                FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}