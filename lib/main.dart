import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled/LoginScreen.dart';
import 'package:untitled/SuccessScreen.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized

  Platform.isAndroid
      ? await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyBqWVtEitIYL6K1XQdKqh5ynBOdAvFuU9k',
          appId: '1:431131194011:android:c34cb5ab99dd518bfd0c3e',
          messagingSenderId: '431131194011',
          projectId: 'example1-9c07b'))
      : await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context)
  {
    final Brightness brightnessValue = MediaQuery.of(context).platformBrightness;
    final bool isDark = brightnessValue == Brightness.dark;
    return MaterialApp(
      title: 'TaskMaster',
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: FutureBuilder(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.hasData) {
              return const SuccessScreen(); // If user is authenticated, go to SuccessScreen
            } else {
              return const LoginScreen(); // If user is not authenticated, go to AuthScreen
            }
          }
        },
      ),
    );
  }
}
