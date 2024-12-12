import 'package:flutter/material.dart';
import 'package:Tripster/utils/colors.dart';

class TermsOfServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Service', style: AppColors.titleTextStyle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms of Service',
                style: AppColors.titleTextStyle,
              ),
              const SizedBox(height: 20.0),
              const ListTile(
                title: Text(
                  'By using Tripster, you agree to abide by the following terms and conditions:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              _buildTermTile(
                title: 'App Usage',
                content:
                    'Our app is designed to provide travel-related information and services. You may use the app for personal, non-commercial purposes only.',
              ),
              const SizedBox(height: 20.0),
              _buildTermTile(
                title: 'User Conduct',
                content:
                    'You must not engage in any unlawful or unauthorized activities while using the app, including but not limited to spamming, hacking, or distributing malicious content.',
              ),
              const SizedBox(height: 20.0),
              _buildTermTile(
                title: 'Content Rights',
                content:
                    'All content, including text, images, and multimedia, provided in the app is owned by [Your Company Name] and protected by copyright laws.',
              ),
              const SizedBox(height: 20.0),
              _buildTermTile(
                title: 'Disclaimer',
                content:
                    'We strive to provide accurate and up-to-date information, but we cannot guarantee the completeness or reliability of the content. Users are responsible for verifying information before making decisions based on it.',
              ),
              const SizedBox(height: 20.0),
              const ListTile(
                title: Text(
                  'Please review the full Terms of Service for a comprehensive understanding of your rights and responsibilities when using our app.',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
              // Add more terms of service details here
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermTile({required String title, required String content}) {
    return ListTile(
      title: Text(
        '- $title:',
        style: const TextStyle(
          fontSize: 16.0,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        content,
        style: const TextStyle(
          fontSize: 16.0,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }
}
