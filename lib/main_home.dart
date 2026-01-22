import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'complaint/complaint_home.dart';
import 'home.dart';
import 'calendar/calendar_home.dart';
import 'marketplace/marketplace_home.dart';
import 'main.dart';

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

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("User"),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text("Theme"),
              trailing: Switch(
                value: appTheme.value == ThemeMode.dark,
                onChanged: (v) {
                  appTheme.value = v ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),

      body: FadeTransition(
        opacity: _fade,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            Text("Hello 👋",
                style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 6),

            Text(
              user?.email ?? "User",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // LOST & FOUND
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

            // CALENDAR
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

            // 🔥 MARKETPLACE RESTORED
            _moduleCard(
              context,
              title: "Marketplace",
              subtitle: "Buy & Sell inside campus",
              icon: Icons.storefront,
              colors: [Colors.green, Colors.teal],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MarketplaceHome()),
                );
              },
            ),

            const SizedBox(height: 24),
            _moduleCard(
 context,
 title:"Smart Complaints",
 subtitle:"AI auto routed system",
 icon:Icons.report_problem,
 colors:[Colors.red,Colors.orange],
 onTap:(){
   Navigator.push(context,
     MaterialPageRoute(builder:(_)=>ComplaintHome()));
 },
),
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.white70)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}