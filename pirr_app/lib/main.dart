import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pirr_app/login_screen.dart';
import 'package:pirr_app/entries_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 👉 Use Firestore Emulator in local development
  if (Platform.isAndroid) {
    // Android emulator can't reach "localhost" directly
    FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
  } else {
    // macOS / iOS simulator can use localhost
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pirr Mini',
      // Use Material 3 defaults if available; keep theme minimal for the mini app
      // theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Guard against null user explicitly for readability
          if (snapshot.hasData) {
            return const EntriesScreen();
          }
          return LoginScreen(onLogin: () {});
        },
      ),
    );
  }
}
