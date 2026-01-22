import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth.dart';
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

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              secondary: Colors.purple,
              background: Color(0xFFF5F7FB),
              surface: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F7FB),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(
              primary: Colors.indigoAccent,
              secondary: Colors.purpleAccent,
              background: Color(0xFF0E1117),
              surface: Color(0xFF161B22),
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
              return AuthScreen();
            },
          ),
        );
      },
    );
  }
}