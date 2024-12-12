import 'package:Tripster/Itinerary/trip_planner_screen.dart';
import 'package:Tripster/main_pages/home_page.dart';
import 'package:Tripster/main_pages/profile_page.dart';
import 'package:Tripster/recommendation_system/preference_screen.dart';
import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tripster/sub_pages/messaging_screen.dart';
import 'package:provider/provider.dart';
import 'package:Tripster/providers/user_provider.dart'; // Assuming UserProvider class is defined in this file
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class ChatInterface extends StatefulWidget {
  @override
  _ChatInterfaceState createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final firebase_auth.User? user =
      firebase_auth.FirebaseAuth.instance.currentUser;

  Future<String?> getLastMessageTime(String userId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return userProvider.getLastMessageTime(userId);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Implement search functionality here
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data!.docs
              .map((doc) => userProvider.getUserFromSnapshot(doc))
              .where((user) => user.userId != currentUserId)
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(users[index].profileImageUrl),
                  ),
                  title: Text(users[index].username),
                  subtitle: FutureBuilder<String?>(
                    future: getLastMessageTime(users[index].userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox
                            .shrink(); // Show nothing while loading
                      } else if (snapshot.hasError) {
                        return const Text(
                            'Error'); // Show error message if fetching fails
                      } else {
                        return Text(
                          snapshot.data ??
                              '', // Use snapshot.data to display the last message time
                          style: const TextStyle(fontSize: 12.0),
                        );
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessagingScreen(
                          currentUserId: currentUserId,
                          recipientUser: users[index],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      selectedItemColor: AppColors.textColor,
      unselectedItemColor: AppColors.secondaryTextColor,
      onTap: (index) {
        switch (index) {
          case 0:
            _navigateTo(context, const MyHomePage());
            break;
          case 1:
            _navigateTo(context, const TripPlannerScreen());
            break;
          case 2:
            _navigateTo(context, PreferenceScreen());
            break;
          case 3:
            break;
          case 4:
            _navigateTo(context, const ProfilePage());
            break;
          default:
            _navigateTo(context, const MyHomePage());
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Itinerary',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flight_outlined),
          label: 'Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mail_outline),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.bold,
        fontSize: 10.0,
        color: AppColors.textColor,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }
}
