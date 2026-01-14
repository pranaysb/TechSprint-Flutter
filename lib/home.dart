import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'item_list.dart';
import 'matches_tab.dart';
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
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Tech", style: TextStyle(fontWeight: FontWeight.w900)),
            Text("Sprint", style: TextStyle(fontWeight: FontWeight.w300)),
          ],
        ),
        bottom: TabBar(
          controller: tab,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: [
            Tab(text: "Lost"),
            Tab(text: "Found"),
            Tab(text: "Matches"),
          ],
        ),
        actions: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[200],
            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null ? Icon(Icons.person, color: Colors.grey) : null,
          ),
          SizedBox(width: 16),
        ],
      ),
      drawer: _buildDrawer(user),
      body: TabBarView(
        controller: tab,
        children: [
          ItemList(type: "lost"),
          ItemList(type: "found"),
          MatchesTab(), // The AI Tab
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add_rounded),
        label: Text("POST ITEM"),
        elevation: 4,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () {
          // Defaults to LOST if on tab 0, FOUND if on tab 1
          final t = tab.index == 0 ? "lost" : "found"; 
          Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePost(defaultType: t)));
        },
      ),
    );
  }

  Widget _buildDrawer(User user) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            accountName: Text(user.displayName ?? "User", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null ? Text(user.email![0].toUpperCase()) : null,
            ),
          ),
          ListTile(
            leading: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            title: Text(widget.isDark ? "Light Mode" : "Dark Mode"),
            trailing: Switch(value: widget.isDark, onChanged: (_) => widget.onTheme()),
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => FirebaseAuth.instance.signOut(),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}