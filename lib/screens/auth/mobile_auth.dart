// lib/auth/mobile_login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test7/screens/auth/org_email_auth.dart';
import 'package:test7/screens/home/home.dart';

class MobileLoginPage extends StatefulWidget {
  const MobileLoginPage({super.key});

  @override
  State<MobileLoginPage> createState() => _MobileLoginPageState();
}

class _MobileLoginPageState extends State<MobileLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _submitMobileNumber() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Logged in - Mobile no')));
    if (_formKey.currentState?.validate() ?? false) {
      String mobileNumber = _mobileController.text;

      // TODO: Implement your actual mobile number submission logic here
      // e.g., send OTP, verify number with backend
      print('Mobile Number: $mobileNumber');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing Mobile Number: $mobileNumber')),
      );

      // Example: After successfully sending OTP, navigate to OTP verification screen
      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => OtpVerificationPage(mobileNumber: mobileNumber)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with Mobile'),
        backgroundColor: Colors.transparent, // Or Colors.teal.shade800
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true, // If using transparent AppBar
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Optional: App Logo or relevant icon
                  // Icon(Icons.phone_android_outlined, size: 80, color: Colors.tealAccent),
                  // const SizedBox(height: 32),

                  const Text(
                    'Enter Your Mobile Number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "We'll send a verification code to this number.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Mobile Number TextField
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      labelStyle:
                          TextStyle(color: Colors.tealAccent.withOpacity(0.7)),
                      hintText: 'e.g., 9876543210',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(Icons.phone_android_outlined,
                            color: Colors.tealAccent),
                      ),
                      // Optional: Add a country code prefix text or a dropdown for country codes
                      // prefixText: '+91 ',
                      // prefixStyle: TextStyle(color: Colors.white70, fontSize: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.tealAccent.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.tealAccent.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.tealAccent, width: 2),
                      ),
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Allow only digits
                      LengthLimitingTextInputFormatter(
                          10), // Example: Limit to 10 digits for Indian numbers
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.length < 10) {
                        // Adjust length check as per your needs
                        return 'Mobile number must be at least 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Submit Button (e.g., "Send OTP" or "Continue")
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _submitMobileNumber,
                    child: const Text('Send OTP',
                        style: TextStyle(color: Colors.black87)),
                  ),
                  const SizedBox(height: 20),

                  // Optional: Link to login with Email instead
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Prefer to use email?",
                          style: TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EmailLoginPage()));
                        },
                        child: const Text(
                          'Login with Email',
                          style: TextStyle(
                              color: Colors.tealAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
