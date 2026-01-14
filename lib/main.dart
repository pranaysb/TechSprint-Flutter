import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(AppRoot());
}

class AppRoot extends StatefulWidget {
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool dark = false;

  void toggleTheme() {
    setState(() {
      dark = !dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FindIt AI",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: TextStyle(
              color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: Color(0xFF121212),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Color(0xFF1E1E1E),
        ),
      ),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
             return Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData) return AuthScreen();
          return HomeScreen(onTheme: toggleTheme, isDark: dark);
        },
      ),
    );
  }
}