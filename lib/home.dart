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