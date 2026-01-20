import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart'; // Lost & Found module
import 'calendar/calendar_home.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("FindIt AI"),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fade,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // 👋 Greeting
            Text(
              "Hello 👋",
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 6),

            Text(
              user?.email ?? "User",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // 🔍 LOST & FOUND MODULE
            _moduleCard(
              context,
              title: "Lost & Found",
              subtitle: "AI powered matching system",
              icon: Icons.search,
              colors: [Colors.indigo, Colors.purple],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),

            const SizedBox(height: 24),

            // 📅 CALENDAR MODULE
            _moduleCard(
              context,
              title: "Calendar",
              subtitle: "Campus events & schedules",
              icon: Icons.calendar_month,
              colors: [Colors.blue, Colors.lightBlue],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarHome()),
                );
              },
            ),

            const SizedBox(height: 24),

            // 🚀 Future placeholder
            _moduleCard(
              context,
              title: "More Modules",
              subtitle: "Coming soon...",
              icon: Icons.auto_awesome,
              colors: [Colors.grey, Colors.blueGrey],
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(colors: colors),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              offset: const Offset(0, 12),
              color: Colors.black.withOpacity(0.25),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [

              // ICON
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),

              const SizedBox(width: 20),

              // TEXT
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}