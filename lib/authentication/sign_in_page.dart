import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Tripster/providers/user_provider.dart';
import 'package:Tripster/authentication/authentication_service.dart';
import 'package:Tripster/authentication/sign_up_page.dart';
import 'package:Tripster/authentication/reset_password_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _authenticationService = AuthenticationService(FirebaseAuth.instance);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Set to true to avoid overflow issues
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 10.0),
                _buildTagline(),
                const SizedBox(height: 30.0),
                _buildEmailPasswordFields(),
                const SizedBox(height: 20.0),
                _buildSignInButton(context),
                const SizedBox(height: 20.0),
                _buildAlternativeSignInOptions(),
                const SizedBox(height: 20.0),
                _buildFooterButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 80.0,
    );
  }

  Widget _buildTagline() {
    return const Text(
      'Explore the world with us',
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.w600,
        fontSize: 12.0,
      ),
    );
  }

  Widget _buildEmailPasswordFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sign In',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w900,
            fontSize: 22.0,
          ),
        ),
        const SizedBox(height: 30.0),
        const Text(
          'Hi, Nice to see you again',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.normal,
            fontSize: 14.0,
          ),
        ),
        const SizedBox(height: 20.0),
        _buildTextField(
            label: 'Email', isPassword: false, controller: _emailController),
        const SizedBox(height: 20.0),
        _buildTextField(
            label: 'Password',
            isPassword: true,
            controller: _passwordController),
        const SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildTextField(
      {required String label,
      required bool isPassword,
      required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        hintText: 'Enter your $label',
        labelText: label,
      ),
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.w400,
        fontSize: 12.0,
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return SizedBox(
      width: 340.0,
      height: 50.0,
      child: OutlinedButton(
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );

          final email = _emailController.text;
          final password = _passwordController.text;
          final username = _usernameController.text;
          final result = await _authenticationService.signIn(
            email: email,
            password: password,
            username: username,
          );
          Navigator.of(context).pop(); // Dismiss the loading indicator

          if (result == 'Signed in') {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final name = user.displayName ?? '';
              context.read<UserProvider>().setUser(name, email, username);
              final userId = user.uid;
              context.read<UserProvider>().fetchUserData(userId);
              Navigator.pushReplacementNamed(context, '/home');
            }
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text(result ?? 'Unknown error occurred'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF1A80E5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: const Text(
          'Sign in',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            fontSize: 24.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeSignInOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialSignInButton('assets/icons/google.png', () {
          // Implement Google sign in functionality
        }),
        const SizedBox(width: 20.0),
        _buildSocialSignInButton('assets/icons/apple.png', () {
          // Implement Apple sign in functionality
        }),
        const SizedBox(width: 20.0),
        _buildSocialSignInButton('assets/icons/facebook.png', () {
          // Implement Facebook sign in functionality
        }),
      ],
    );
  }

  Widget _buildSocialSignInButton(String iconPath, VoidCallback onPressed) {
    return GestureDetector(
      onTap: () async {
        if (iconPath == 'assets/icons/google.png') {
          try {
            await AuthenticationService.signInWithGoogle();
            // Handle successful sign-in
          } catch (e) {
            // Handle sign-in error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to sign in with Google: $e'),
              ),
            );
          }
        } else {
          // Handle other sign-in options
        }
      },
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
          color: const Color(0xFF1A80E5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: 30.0,
            height: 30.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ResetPasswordPage()),
            );
          },
          child: const Text(
            'Forgot password?',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.normal,
              color: Color(0xFF0D141C),
            ),
          ),
        ),
        const SizedBox(width: 20.0),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpPage()),
            );
          },
          child: const Text(
            'Sign up',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFF1A80E5),
            ),
          ),
        ),
      ],
    );
  }
}
