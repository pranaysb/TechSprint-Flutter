import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'day_view.dart';

class MonthView extends StatelessWidget {
  const MonthView({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(31, (i) => DateTime(now.year, now.month, i + 1));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("Events").snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snap.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: days.length,
          itemBuilder: (_, i) {
            final d = days[i];
            final dateKey = DateFormat("yyyy-MM-dd").format(d);

            final dayEvents = events.where((e) {
              final data = e.data() as Map<String, dynamic>;
              return data["date"] == dateKey;
            }).toList();

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DayView(date: dateKey),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${d.day}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),

                    if (dayEvents.isNotEmpty)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}