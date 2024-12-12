import 'package:Tripster/support/contact_us_page.dart';
import 'package:Tripster/support/emergency.dart';
import 'package:Tripster/support/travel_tips_page.dart';
import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';

class SupportPage extends StatelessWidget {
  final LatLng? currentLocation;

  const SupportPage({super.key, this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Support',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildOptionItem(
            icon: Icons.lightbulb_outline,
            label: 'Travel Tips',
            description: 'Get helpful tips for your travels',
            onTap: () {
              _handleTravelTips(context);
            },
          ),
          _buildOptionItem(
            icon: Icons.phone_in_talk,
            label: 'Emergency Contacts',
            description: 'Find emergency contacts for assistance',
            onTap: () {
              _handleEmergencyContacts(context);
            },
          ),
          _buildOptionItem(
            icon: Icons.email_outlined,
            label: 'Contact Us',
            description: 'Reach out to our support team',
            onTap: () {
              _handleContactUs(context);
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildLiveChatButton(context),
    );
  }

  void _handleTravelTips(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => TravelTipsPage()));
  }

  void _handleEmergencyContacts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmergencyPage()),
    );
  }

  void _handleContactUs(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ContactUsPage()));
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required String description,
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
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
            color: AppColors.secondaryTextColor,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget _buildLiveChatButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: ElevatedButton.icon(
        onPressed: () {
          _handleLiveChat(context);
        },
        icon: const Icon(
          Icons.chat_bubble_outline,
          color: AppColors.textColor,
        ),
        label: const Text(
          'Live Chat',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: AppColors.textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8EEF2),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
    );
  }

  void _handleLiveChat(BuildContext context) {
    // Handle Live Chat button tap
  }
}
