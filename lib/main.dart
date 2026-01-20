import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:techsprint_flutter/main_home.dart';

import 'auth.dart';
import 'home.dart';
import 'main_home.dart';

final ValueNotifier<ThemeMode> appTheme = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appTheme,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // 🌤 LIGHT THEME
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            colorScheme: ColorScheme.light(
              primary: Colors.indigo,
              secondary: Colors.purple,
              background: const Color(0xFFF5F7FB),
              surface: Colors.white,
              onBackground: Colors.black,
              onSurface: Colors.black87,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F7FB),
          ),

          // 🌙 DARK THEME
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: ColorScheme.dark(
              primary: Colors.indigoAccent,
              secondary: Colors.purpleAccent,
              background: const Color(0xFF0E1117),
              surface: const Color(0xFF161B22),
              onBackground: Colors.white,
              onSurface: Colors.white70,
            ),
            scaffoldBackgroundColor: const Color(0xFF0E1117),
          ),

          themeMode: mode,

          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasData) return const MainHomePage();
              return  AuthScreen();
            },
          ),
        );
      },
    );
  }
}