import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'item_list.dart';
import 'matches_tab.dart'; // We will create this next
import 'create_post.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onTheme;
  final bool isDark;
  HomeScreen({required this.onTheme, required this.isDark});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController tab;

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("FindIt", style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor)),
            Text("AI", style: TextStyle(fontWeight: FontWeight.w300)),
          ],
        ),
        bottom: TabBar(
          controller: tab,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: "Lost Items"),
            Tab(text: "Found Items"),
            Tab(text: "AI Matches"),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications_outlined), onPressed: (){}),
          SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: Column(children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
               color: Theme.of(context).primaryColor
            ),
            accountName: Text(user.displayName ?? "User", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            accountEmail: Text(user.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null ? Text(user.email![0].toUpperCase(), style: TextStyle(fontSize: 24)) : null,
            ),
          ),
          ListTile(leading: Icon(Icons.history), title: Text("My History")),
          ListTile(
            leading: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            title: Text("Dark Mode"),
            trailing: Switch(value: widget.isDark, onChanged: (_) => widget.onTheme()),
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => FirebaseAuth.instance.signOut(),
          ),
          SizedBox(height: 20),
        ]),
      ),
      body: TabBarView(controller: tab, children: [
        ItemList(type: "lost"),
        ItemList(type: "found"),
        MatchesTab(), // The new powerful tab
      ]),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text("New Post"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          final t = tab.index == 0 ? "lost" : "found";
          Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePost(defaultType: t)));
        },
      ),
    );
  }
}