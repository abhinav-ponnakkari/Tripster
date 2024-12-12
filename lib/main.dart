import 'package:Tripster/recommendation_system/preference_screen.dart';
import 'package:Tripster/recommendation_system/user_preferences.dart';
import 'package:Tripster/sub_pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:Tripster/providers/user_provider.dart';
import 'package:Tripster/main_pages/home_page.dart';
import 'package:Tripster/authentication/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UserPreferences()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tripster',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Set initial route to '/'
      routes: {
        '/': (context) => const AuthCheck(),
        '/home': (context) => const MyHomePageWrapper(),
        '/chat': (context) => const ChatPage(
              username: '',
              profileImageUrl: '',
              bio: '',
              location: '',
              recipientId: '',
            ),
        '/preferences': (context) =>
            PreferenceScreen(), // Add route for preference screen
      },
      onUnknownRoute: (settings) {
        // Handle unknown routes here
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
      },
    );
  }
}

class MyHomePageWrapper extends StatelessWidget {
  const MyHomePageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return _handleBackPressed(context);
      },
      child: const MyHomePage(),
    );
  }

  Future<bool> _handleBackPressed(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? currentBackPressTime =
        ModalRoute.of(context)!.navigator!.userGestureInProgress == true
            ? null
            : DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  // final FirebaseAuth auth = FirebaseAuth.instance;
  // final User? user = auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<auth.User?>(
        stream: auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MyHomePageWrapper();
          } else {
            return const SignInPage();
          }
        },
      ),
    );
  }
}
