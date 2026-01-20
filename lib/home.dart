import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'item_list.dart';
import 'matches_tab.dart';
import 'create_post.dart';
import 'main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tab;

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 3, vsync: this);
    tab.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("FindIt AI"),
        bottom: TabBar(
          controller: tab,
          tabs: const [
            Tab(text: "Lost"),
            Tab(text: "Found"),
            Tab(text: "Matches"),
          ],
        ),
      ),

      // 🔥 SIDEBAR FIXED
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 32,
                child: Text(user.email![0].toUpperCase()),
              ),

              const SizedBox(height: 10),

              Text(user.email!,
                  style: const TextStyle(fontWeight: FontWeight.w600)),

              const Divider(height: 40),

              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text("Dark / Light Mode"),
                trailing: Switch(
                  value: appTheme.value == ThemeMode.dark,
                  onChanged: (v) {
                    appTheme.value =
                        v ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ),

              const Spacer(),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      body: TabBarView(
        controller: tab,
        children: const [
          ItemList(type: "lost"),
          ItemList(type: "found"),
          MatchesTab(),
        ],
      ),

      floatingActionButton: tab.index == 2
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                final t = tab.index == 0 ? "lost" : "found";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePost(defaultType: t),
                  ),
                );
              },
            ),
    );
  }
}