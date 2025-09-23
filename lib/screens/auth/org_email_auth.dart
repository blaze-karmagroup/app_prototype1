import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test7/screens/home/home.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  bool _initialized = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize();
      _initialized = true;
    } catch (e) {
      print('GoogleSignIn initialize error: $e');
      // you may want to handle this
    }
  }

  Future<void> _loginWithGoogle() async {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Logged in - Org Email')));
    String email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      setState(() => _errorMessage = "Please enter your org email");
      return;
    }
    if (!email.endsWith("@karmagroup.com")) {
      setState(() => _errorMessage = "This is not an org. email");
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Logging in with Email: $email')));

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!_initialized) {
      await _initializeGoogleSignIn();
    }

    try {
      print('Attempting Google Sign-In with e-mail: $email');
      // const List<String> scopes = ['email'];

      final googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email'],
      );

      if (googleUser == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Sign-In cancelled or failed.";
        });
        return;
      }

      if (googleUser.email.toLowerCase() != email) {
        await GoogleSignIn.instance.signOut();
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Selected Google account does not match entered email.";
        });
        return;
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to get Google ID Token.";
        });
        print("Google ID Token is null.");
        return;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      print("Attempting FirebaseAuth.instance.signInWithCredential...");
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      print(
        "FirebaseAuth signInWithCredential SUCCESS. User UID: ${userCredential.user?.uid}",
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _user = userCredential.user;
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MyHomePage(title: 'Google Auth Success'),
          ),
        );
      }
    } catch (e) {
      print("Error during Firebase signInWithCredential: $e");
      if(mounted){
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _logOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
    setState(() {
      _user = null;
      _isLoading = false;
    });
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
            colors: [Colors.teal.shade900, Colors.grey.shade900],
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : _user == null
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        'Welcome!',
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
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 40),

                      // Email TextField
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: TextStyle(
                            color: Colors.tealAccent.withOpacity(0.7),
                          ),
                          hintText: 'you.example@karmagroup.com',
                          hintStyle: TextStyle(color: Colors.white38),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.tealAccent,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.tealAccent.withOpacity(0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.tealAccent.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.tealAccent,
                              width: 2,
                            ),
                          ),
                          errorStyle: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _loginWithGoogle,
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome, ${_user!.displayName}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(_user!.email ?? ""),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _logOut,
                    child: const Text("Sign Out"),
                  ),
                ],
              ),
      ),
    );
  }
}
