import 'package:flutter/material.dart';
import 'event_service.dart';

class AdminCalendar extends StatefulWidget {
  const AdminCalendar({super.key});

  @override
  State<AdminCalendar> createState() => _AdminCalendarState();
}

class _AdminCalendarState extends State<AdminCalendar> {
  final name = TextEditingController();
  final date = TextEditingController();
  final time = TextEditingController();
  final venue = TextEditingController();

  Future submit() async {
    await EventService.addEvent({
      "name": name.text,
      "date": date.text,
      "time": time.text,
      "venue": venue.text,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Event")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: date, decoration: const InputDecoration(labelText: "Date yyyy-mm-dd")),
            TextField(controller: time, decoration: const InputDecoration(labelText: "Time")),
            TextField(controller: venue, decoration: const InputDecoration(labelText: "Venue")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: submit, child: const Text("Post"))
          ],
        ),
      ),
    );
  }
}