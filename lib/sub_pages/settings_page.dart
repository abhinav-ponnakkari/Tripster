import 'package:Tripster/settings/privacy_policy.dart';
import 'package:Tripster/settings/terms_of_service.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildSectionHeader('Preferences'),
          _buildOptionItem(
            icon: Icons.info,
            label: 'Personal information',
            onTap: () {
              // Handle Personal Information option
            },
          ),
          _buildOptionItem(
            icon: Icons.currency_exchange,
            label: 'Currency',
            onTap: () {
              // Handle Currency option
            },
          ),
          _buildSectionHeader('Notifications'),
          _buildOptionItem(
            icon: Icons.notifications_active,
            label: 'Push Notifications',
            onTap: () {
              // Handle Push Notifications option
            },
          ),
          _buildOptionItem(
            icon: Icons.email_outlined,
            label: 'Email Notifications',
            onTap: () {
              // Handle Email Notifications option
            },
          ),
          _buildSectionHeader('Account Management'),
          _buildOptionItem(
            icon: Icons.privacy_tip,
            label: 'Privacy Policy',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrivacyPolicyPage(),
                  ));
            },
          ),
          _buildOptionItem(
            icon: Icons.supervised_user_circle,
            label: 'Terms of Service',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TermsOfServicePage(),
                  ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22.0,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOptionItem({
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
}
