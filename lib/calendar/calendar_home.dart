import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'month_view.dart';
import 'day_view.dart';
import 'admin_calendar.dart';

class CalendarHome extends StatelessWidget {
  const CalendarHome({super.key});

  // 🔐 Admin emails
  static const List<String> adminEmails = [
    "admin@gmail.com",
    "pranay@gmail.com",
  ];

  bool isAdmin(User? user) {
    if (user == null) return false;
    return adminEmails.contains(user.email);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final todayKey = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final todayPretty =
        DateFormat("EEEE, dd MMM yyyy").format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),

        // 🔐 ADMIN ADD BUTTON
        actions: [
          if (isAdmin(user))
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminCalendar()),
                );
              },
            ),
        ],
      ),

      body: ListView(
        children: [

          // 📅 TODAY HEADER
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today"),
                Text(
                  todayPretty,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // 📆 MONTH GRID
          const SizedBox(height: 320, child: MonthView()),

          const SizedBox(height: 20),

          // 🔴 TODAY EVENTS
          _sectionTitle("Today's Events"),
          _eventList(date: todayKey),

          const SizedBox(height: 20),

          // 🔵 UPCOMING EVENTS
          _sectionTitle("Upcoming Events"),
          _upcomingEvents(todayKey),
        ],
      ),
    );
  }

  // ---------- UI HELPERS ----------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _eventCard(Map<String, dynamic> e) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e["name"] ?? "",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text("${e["time"] ?? ""} | ${e["venue"] ?? ""}",
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ---------- TODAY EVENTS ----------

  Widget _eventList({required String date}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Events")
          .where("date", isEqualTo: date)
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          );
        }

        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text("No events today"),
          );
        }

        return Column(
          children: docs.map((d) {
            final e = d.data() as Map<String, dynamic>;
            return _eventCard(e);
          }).toList(),
        );
      },
    );
  }

  // ---------- UPCOMING EVENTS ----------

  Widget _upcomingEvents(String todayKey) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Events")
          .where("date", isGreaterThan: todayKey)
          .orderBy("date")
          .limit(5)
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          );
        }

        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text("No upcoming events"),
          );
        }

        return Column(
          children: docs.map((d) {
            final e = d.data() as Map<String, dynamic>;
            return _eventCard(e);
          }).toList(),
        );
      },
    );
  }
}