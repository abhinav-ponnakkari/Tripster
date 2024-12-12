import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Tripster/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuideInformationPage extends StatefulWidget {
  const GuideInformationPage({super.key});

  @override
  _GuideInformationPageState createState() => _GuideInformationPageState();
}

class _GuideInformationPageState extends State<GuideInformationPage> {
  final _placeNameController = TextEditingController();
  final _certificatesController = TextEditingController();
  final _ratingsController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _placeNameController.dispose();
    _certificatesController.dispose();
    _ratingsController.dispose();
    super.dispose();
  }

  Future<void> _saveGuideInfo(BuildContext context) async {
    setState(() {
      _isSaving = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final guideData = {
        'placeName': _placeNameController.text,
        'certificates': _certificatesController.text,
        'ratings': double.tryParse(_ratingsController.text) ?? 0.0,
      };

      try {
        // Update the guide information in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'guideInfo': guideData});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guide information saved successfully')),
        );
      } catch (e) {
        print('Error saving guide information: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save guide information')),
        );
      }
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guide Information',
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
              TextField(
                controller: _placeNameController,
                decoration: const InputDecoration(
                  labelText: 'Place Name',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _certificatesController,
                decoration: const InputDecoration(
                  labelText: 'Certificates',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _ratingsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ratings (0-5)',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveGuideInfo(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.White,
                    backgroundColor: AppColors.primaryColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    minimumSize: const Size(140, 45),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSaving)
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      const SizedBox(width: 8),
                      const Text(
                        'Save Guide Info',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
