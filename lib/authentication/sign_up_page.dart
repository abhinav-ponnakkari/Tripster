import 'package:Tripster/main_pages/home_page.dart';
import 'package:Tripster/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Tripster/authentication/authentication_service.dart';
import 'package:Tripster/providers/user_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _authenticationService = AuthenticationService(FirebaseAuth.instance);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.White,
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
                _buildSignUpFields(),
                const SizedBox(height: 20.0),
                _buildContinueButton(context),
                const SizedBox(height: 20.0),
                _buildSignInLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png', // Replace with your logo image path
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

  Widget _buildSignUpFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sign Up',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w900,
            fontSize: 22.0,
          ),
        ),
        const SizedBox(height: 30.0),
        const Text(
          'Create an account to start exploring',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.normal,
            fontSize: 14.0,
          ),
        ),
        const SizedBox(height: 20.0),
        _buildFormField(
            'Username', TextInputType.text, TextEditingController()),
        const SizedBox(height: 10.0),
        _buildFormField('Email', TextInputType.emailAddress, _emailController),
        const SizedBox(height: 10.0),
        _buildFormField(
            'Password', TextInputType.visiblePassword, _passwordController),
        const SizedBox(height: 10.0),
        _buildTermsCheckbox(),
      ],
    );
  }

  Widget _buildFormField(
      String label, TextInputType inputType, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter your $label',
        border: const UnderlineInputBorder(),
      ),
      keyboardType: inputType,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.w400,
        fontSize: 12.0,
      ),
    );
  }

  Widget _buildTextField({required String label, required bool isPassword}) {
    return TextField(
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

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: false, // You can add state management for this checkbox
          onChanged: (value) {
            // Handle checkbox state change
          },
        ),
        const Text(
          'I accept the terms and conditions',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w100,
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
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
          final result = await _authenticationService.signUp(
              email: email, password: password, username: username);
          Navigator.of(context).pop(); // Dismiss the loading indicator

          if (result == 'Signed up') {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final name = user.displayName ??
                  ''; // Get the user's display name, or use an empty string if null
              context.read<UserProvider>().setUser(name, email, username);
              final userId = user.uid;

              // Create the user document in Firestore
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .set({
                'name': name,
                'email': email,
                'username': username,
                'phone': '',
                'dob': '',
                'gender': '',
                'bio': '',
                'interests': '',
                'location': '',
              });

              context.read<UserProvider>().fetchUserData(userId);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            }
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text(result!),
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
          side: const BorderSide(
            color: AppColors.primaryColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            fontSize: 24.0,
            color: AppColors.Black,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Have an account? ',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to sign in page
          },
          child: const Text(
            'Sign in',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> authenticatewithgoogle({required BuildContext context}) async {
  try {
    await AuthenticationService.signInWithGoogle();
  } catch (e) {
    if (!context.mounted) return;
    showAboutDialog(
      context: context,
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SignUpPage(),
  ));
}
