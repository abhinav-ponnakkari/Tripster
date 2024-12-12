import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  final String email = 'tripster@gmail.com';
  final String phone = '+91 8589941032';
  final String address = 'Mananthavady, Wayanad, Kerala';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactInfo('Email', email),
            const SizedBox(height: 20.0),
            _buildContactInfo('Phone', phone),
            const SizedBox(height: 20.0),
            _buildContactInfo('Address', address),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18.0,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5.0),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16.0,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
