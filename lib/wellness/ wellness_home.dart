import 'package:flutter/material.dart';
import 'wellness_chat.dart';

class WellnessHome extends StatelessWidget {
  const WellnessHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.indigo,
            Colors.purple,
          ]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: Colors.white, size: 80),
            SizedBox(height: 20),
            Text("MindCare AI",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              "Talk freely. You are safe & anonymous.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => WellnessChat()));
              },
              child: Text("Start Chat", style: TextStyle(color: Colors.indigo)),
            )
          ],
        ),
      ),
    );
  }
}