import 'dart:io';

import 'package:Tripster/Itinerary/trip_planner_screen.dart';
import 'package:Tripster/main_pages/chat_interface.dart';
import 'package:Tripster/recommendation_system/preference_screen.dart';
import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:Tripster/providers/user_provider.dart';
import 'package:Tripster/authentication/sign_in_page.dart';
import 'package:Tripster/main_pages/home_page.dart';
import 'package:Tripster/sub_pages/settings_page.dart';
import 'package:Tripster/sub_pages/personal_information_page.dart'; // Import the PersonalInformationPage
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploading = false;
  ImagePicker? _picker;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final email = userProvider.email ?? '';
    final username = userProvider.username ?? '';
    final bio = userProvider.bio ?? '';
    final profileImageUrl = userProvider.profileImageUrl;

    return WillPopScope(
        onWillPop: () async {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
            (route) => false,
          );
          return false; // Return false to prevent the app from exiting
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _uploadImage(context),
                        child: _isUploading
                            ? const CircularProgressIndicator() // Show loading animation if _isUploading is true
                            : CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    profileImageUrl?.isNotEmpty ?? false
                                        ? NetworkImage(profileImageUrl!)
                                        : const AssetImage(
                                                'assets/images/profile.png')
                                            as ImageProvider,
                              ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5.0),
                            Text(
                              username,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              email,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              bio,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  _buildOptionItem(
                    context: context,
                    icon: Icons.info,
                    label: 'Personal Information',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PersonalInformationPage()),
                      );
                    },
                  ),
                  _buildOptionItem(
                    context: context,
                    icon: Icons.card_travel,
                    label: 'Trips',
                    onTap: () {
                      // Handle Trips option
                    },
                  ),
                  _buildOptionItem(
                    context: context,
                    icon: Icons.bookmark_border,
                    label: 'Saved Places',
                    onTap: () {
                      // Handle Saved Places option
                    },
                  ),
                  _buildOptionItem(
                    context: context,
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                  _buildOptionItem(
                    context: context,
                    icon: Icons.logout_outlined,
                    label: 'LogOut',
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInPage()),
                        (route) => false,
                      );
                    },
                  ),
                  // Other options
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context),
        ));
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4,
      selectedItemColor: AppColors.textColor,
      unselectedItemColor: AppColors.secondaryTextColor,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
              (route) => false,
            );
            break;
          case 1:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const TripPlannerScreen()),
              (route) => false,
            );
            break;
          case 2:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PreferenceScreen()),
              (route) => false,
            );
            break;
          case 3:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatInterface()), // Pass the context
              (route) => false,
            );
            break;

          case 4:
            // Stay on current page
            break;
          default:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
              (route) => false,
            );
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

  Future<void> _uploadImage(BuildContext context) async {
    setState(() {
      _isUploading = true; // Set the _isUploading flag to true
    });

    _picker ??= ImagePicker();

    final pickedFile = await _picker?.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = basename(file.path);
      final destination =
          'users/${FirebaseAuth.instance.currentUser!.uid}/$fileName';

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final oldProfileImageUrl = userProvider.profileImageUrl;

        final uploadTask = await firebase_storage.FirebaseStorage.instance
            .ref(destination)
            .putFile(file);

        final downloadUrl = await uploadTask.ref.getDownloadURL();

        await userProvider.updateProfileImageUrl(downloadUrl);

        if (oldProfileImageUrl != null && oldProfileImageUrl.isNotEmpty) {
          final oldProfileImageRef = firebase_storage.FirebaseStorage.instance
              .refFromURL(oldProfileImageUrl);
          await oldProfileImageRef.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully:')));
      } on firebase_storage.FirebaseException catch (e) {
        print('Error uploading image: ${e.code} - ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: ${e.message}')));
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')));
      }
    }

    setState(() {
      _isUploading = false; // Set the _isUploading flag to false
    });
  }
}
