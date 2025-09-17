// lib/login_options_page.dart
import 'package:flutter/material.dart';
import 'package:test7/screens/auth/mobile_auth.dart';
import 'package:test7/screens/auth/org_email_auth.dart';

class LoginOptionsPage extends StatelessWidget {
  const LoginOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: Add an AppBar if you want a title
      // appBar: AppBar(
      //   title: const Text('Login Options'),
      // ),
      body: Container(
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Optional: Add your App Logo here
                // Image.asset('assets/app_logo.png', height: 100),
                // const SizedBox(height: 48),

                const Text(
                  'Choose Your Login Method',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Option 1: Login with Organization Email ID
                ElevatedButton.icon(
                  icon: const Icon(Icons.email_outlined, color: Colors.white70),
                  label: const Text(
                    'Login with Organization Email',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EmailLoginPage()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email Login Tapped')),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Option 2: Login with Mobile Number
                ElevatedButton.icon(
                  icon: const Icon(Icons.phone_android_outlined, color: Colors.white70),
                  label: const Text(
                    'Login with Mobile Number',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MobileLoginPage()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mobile Login Tapped')),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Optional: "Or" divider
                // Row(
                //   children: <Widget>[
                //     Expanded(child: Divider(color: Colors.white54)),
                //     Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 8.0),
                //       child: Text("OR", style: TextStyle(color: Colors.white54)),
                //     ),
                //     Expanded(child: Divider(color: Colors.white54)),
                //   ],
                // ),
                // const SizedBox(height: 20),

                // Optional: Other login methods like Google, Apple, etc.
                // TextButton(
                //   onPressed: () {
                //     // Handle other login methods
                //   },
                //   child: const Text(
                //     'Login with Google',
                //     style: TextStyle(color: Colors.white70),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
