import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool loading = false;
  String error = "";

  Future<void> submitEmail() async {
    setState(() { error = ""; loading = true; });
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }
    } catch (e) {
      setState(() => error = e.toString().split(']').last.trim());
    } finally {
      if(mounted) setState(() => loading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() { error = ""; loading = true; });
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => loading = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(cred);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if(mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade400, Colors.purple.shade900],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar, size: 60, color: Colors.indigo),
                    SizedBox(height: 16),
                    Text(
                      isLogin ? "Welcome Back" : "Join FindIt AI",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 24),
                    if (loading) CircularProgressIndicator()
                    else SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: submitEmail,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        child: Text(isLogin ? "Login" : "Register", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(isLogin ? "Create new account" : "Already have account? Login"),
                    ),
                    Divider(height: 30),
                    OutlinedButton.icon(
                      icon: Icon(Icons.g_mobiledata, size: 28),
                      label: Text("Continue with Google"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      onPressed: signInWithGoogle,
                    ),
                    if (error.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(error, style: TextStyle(color: Colors.red, fontSize: 13), textAlign: TextAlign.center),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}