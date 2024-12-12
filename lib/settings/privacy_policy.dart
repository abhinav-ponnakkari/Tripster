import 'package:flutter/material.dart';
import 'package:Tripster/utils/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy', style: AppColors.titleTextStyle),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Privacy Policy', style: AppColors.titleTextStyle),
              SizedBox(height: 20.0),
              Text(
                'At Tripster, we are committed to protecting your privacy. This Privacy Policy outlines how we collect, use, and safeguard your personal information when you use our app.',
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Information Collection: We collect information such as your name, email address, location data, and usage statistics to provide you with personalized services.',
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              // Add more privacy policy details here
            ],
          ),
        ),
      ),
    );
  }
}
