import 'package:flutter/material.dart';
import 'package:test7/screens/home/home.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginUser() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Logged in - Org Email')));
    if (_formKey.currentState?.validate() ?? false) {
      // Form is valid, proceed with login
      String email = _emailController.text;
      String password = _passwordController.text;

      // TODO: Implement your actual email/password login logic here
      // e.g., call an authentication service
      print('Email: $email, Password: $password');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logging in with Email: $email')),
      );

      // Example: After successful login, navigate to the main app screen
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => YourMainAppScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with Email'),
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
          child: SingleChildScrollView( // To prevent overflow if keyboard appears
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Optional: App Logo
                  // Image.asset('assets/app_logo.png', height: 80),
                  // const SizedBox(height: 32),

                  const Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Enter your credentials to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email TextField
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: TextStyle(color: Colors.tealAccent.withOpacity(0.7)),
                      hintText: 'you@example.com',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.tealAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.tealAccent.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.tealAccent.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
                      ),
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password TextField
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.tealAccent.withOpacity(0.7)),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.tealAccent),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.tealAccent.withOpacity(0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.tealAccent.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.tealAccent.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
                      ),
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  // Optional: Forgot Password
                  /*
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to Forgot Password Page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Forgot Password Tapped')),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.tealAccent, fontSize: 14),
                      ),
                    ),
                  ),*/
                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _loginUser,
                    child: const Text('Login', style: TextStyle(color: Colors.black87)),
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

