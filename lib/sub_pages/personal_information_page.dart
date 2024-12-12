import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Tripster/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:country_code_picker/country_code_picker.dart'; // Import the country_code_picker package

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  _PersonalInformationPageState createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  bool _isEditing = false;
  bool _isSaving = false;

  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedGender = 'Male';
  String? _username;
  final _bioController = TextEditingController();
  final _interestsController = TextEditingController();
  final _locationController = TextEditingController();
  final _usernameController = TextEditingController();

  final List<List<String>> _interestOptions = [
    ['War Memorial', 'Monument', 'Historical'],
    ['Tomb', 'Fort', 'Palace'],
    [
      'Temple',
      'Religious Shrine',
      'Gurudwara',
      'Religious',
      'Spiritual Center'
    ],
    ['Theme Park', 'Amusement Park', 'Entertainment', 'Race Track'],
    ['Observatory', 'Museum', 'Science', 'Educational'],
    ['Market', 'Mall', 'Shopping', 'Food'],
    ['Stepwell', 'Landmark', 'Architectural', 'Government Building'],
    [
      'Park',
      'Botanical Garden',
      'Nature',
      'Beach',
      'Lake',
      'Valley',
      'Waterfall',
      'National Park',
      'Wildlife Sanctuary',
      'Bird Sanctuary',
      'Hill',
      'Sunrise Point',
      'Recreational',
      'Scenic',
      'Natural Feature',
      'Trekking',
      'Adventure Sport'
    ],
  ];

  final Set<String> _selectedInterests = {};

  @override
  void initState() {
    super.initState();
    // Fetch user data and populate text fields
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        setState(() {
          _phoneController.text = userData['phone'] ?? '';
          _dobController.text = userData['dob'] ?? '';
          _selectedGender = ['Male', 'Female', 'Other']
                  .contains(userData['gender'])
              ? userData['gender']
              : 'Male'; // Set default to 'Male' if gender is not in the list
          _bioController.text = userData['bio'] ?? '';
          _interestsController.text = userData['interests'] ?? '';
          _locationController.text = userData['location'] ?? '';
          _username = userData['username'] ?? '';
          _usernameController.text = _username ?? '';

          // Populate selected interests based on user data
          final savedInterests = userData['interests'] ?? '';
          if (savedInterests.isNotEmpty) {
            _selectedInterests.addAll(savedInterests.split(', '));
          }
        });
      }
    }
  }

  Future<void> _saveProfile(BuildContext context) async {
    setState(() {
      _isSaving = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newUsername = _usernameController.text.trim();

      // Check if the new username is already taken
      final usernameExists = await _checkUsernameExists(newUsername);
      if (usernameExists) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Username $newUsername is already taken. Please choose a different one.')),
        );
        return;
      }

      final userData = {
        'phone': _phoneController.text,
        'dob': _dobController.text,
        'gender': _selectedGender,
        'bio': _bioController.text,
        'interests': _selectedInterests.join(', '),
        'location': _locationController.text,
        'username': newUsername, // Include the new username
      };

      await context.read<UserProvider>().updateUserData(user.uid, userData);

      setState(() {
        _isEditing = false;
        _isSaving = false;
        _username = newUsername;
      });

      // Fetch updated user data
      await _fetchUserData();
    }
  }

  Future<bool> _checkUsernameExists(String newUsername) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: newUsername)
            .where('uid',
                isNotEqualTo:
                    currentUser.uid) // Exclude the current user's username
            .get();
        return querySnapshot.docs.isNotEmpty;
      }
      return false; // If the current user is null, return false
    } catch (e) {
      print('Error checking username existence: $e');
      return false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dobController.text) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Information',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_username != null &&
                  _username!
                      .isNotEmpty) // Check if username is not null and not empty
                _buildInformationTile('Username:', _username!),
              const SizedBox(height: 10.0),
              if (userProvider.email != null)
                _buildInformationTile('Email', userProvider.email!),
              if (userProvider.phone != null)
                _buildInformationTile('Phone', userProvider.phone!),
              if (userProvider.dob != null)
                _buildInformationTile('Date of Birth', userProvider.dob!),
              if (userProvider.gender != null)
                _buildInformationTile('Gender', userProvider.gender!),
              if (userProvider.bio != null)
                _buildInformationTile('Bio', userProvider.bio!),
              if (userProvider.interests != null)
                _buildInformationTile('Interests', userProvider.interests!),
              if (userProvider.location != null)
                _buildInformationTile('Location', userProvider.location!),
              if (_isEditing) // Display username editing field when editing
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors
                              .primaryColor, // Change border color to blue when focused
                        ),
                      ),
                    ),
                  ),
                ),
              if (_isEditing) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppColors
                                .primaryColor), // Change border color to blue when focused
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                        ), // Change border color to blue when focused
                      ),
                    ),
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                    items: <String>['Male', 'Female', 'Other']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                        ), // Change border color to blue when focused
                      ),
                    ),
                    validator: (value) {
                      if (!['Male', 'Female', 'Other'].contains(value)) {
                        return 'Please select a valid gender option';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                        ), // Change border color to blue when focused
                      ),
                    ),
                    maxLines: 3,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Interests',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      for (final interestGroup in _interestOptions)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: interestGroup.map((interest) {
                              return ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (_selectedInterests.contains(interest)) {
                                      _selectedInterests.remove(interest);
                                    } else {
                                      _selectedInterests.add(interest);
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor:
                                      _selectedInterests.contains(interest)
                                          ? AppColors.White
                                          : AppColors.primaryColor,
                                  backgroundColor:
                                      _selectedInterests.contains(interest)
                                          ? AppColors.primaryColor
                                          : const Color.fromARGB(
                                              255, 255, 248, 248),
                                ),
                                child: Text(
                                  interest,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      CountryCodePicker(
                        onChanged: (value) {
                          setState(() {
                            _locationController.text = value.name!;
                          });
                        },
                        initialSelection: 'US',
                        showCountryOnly: true,
                        showOnlyCountryWhenClosed: true,
                        alignLeft: false,
                        textStyle: const TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ],
              Container(
                margin: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isEditing = !_isEditing),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.White,
                      backgroundColor:
                          AppColors.primaryColor, // Change text color to white
                      elevation: 4, // Add elevation for drop shadow
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16.0), // Set button radius
                      ),
                      minimumSize:
                          const Size(140, 45), // Set a minimum button size
                    ),
                    child: Text(
                      _isEditing ? 'Cancel' : 'Edit Profile',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                      ), // Increase text size to 18
                    ),
                  ),
                ),
              ),
              if (_isEditing)
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _saveProfile(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.White,
                        backgroundColor: AppColors
                            .primaryColor, // Change text color to white
                        elevation: 4, // Add elevation for drop shadow
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16.0), // Set button radius
                        ),
                        minimumSize:
                            const Size(140, 45), // Set a minimum button size
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSaving)
                            const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue)),
                          const SizedBox(width: 8),
                          const Text(
                            'Save Profile',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                            ), // Increase text size to 18
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
