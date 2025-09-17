// lib/splash_screen.dartimport 'dart:async';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test7/screens/auth/auth_options.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the main screen after a delay
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginOptionsPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // This is the UI for your splash screen
    return Scaffold(
      body: Container(
        // Use the same gradient as your main app for a seamless transition
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade900,
              Colors.grey.shade900,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // You can add your app logo or an icon here
              Icon(Icons.hourglass_top_rounded, size: 80.0, color: Colors.white70),
              SizedBox(height: 20),
              Text(
                'Loading Attendance App',
                style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
