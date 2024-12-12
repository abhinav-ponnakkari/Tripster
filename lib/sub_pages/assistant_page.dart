import 'package:Tripster/sub_pages/hotspot_page.dart';
import 'package:Tripster/sub_pages/phfinder.dart';
import 'package:Tripster/support/emergency.dart';
import 'package:flutter/material.dart';
import 'package:Tripster/main_pages/home_page.dart';
import 'package:Tripster/sub_pages/translator_page.dart';
import 'package:Tripster/sub_pages/hotspot_finder_page.dart';

class AssistantPage extends StatelessWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Assistants',
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
            const SizedBox(height: 20.0),
            _buildOptionItem(
              icon: Icons.translate_outlined,
              label: 'Translator',
              onTap: () => _navigateToTranslator(context),
            ),
            _buildOptionItem(
              icon: Icons.contact_emergency_outlined,
              label: 'Emergency Services',
              onTap: () => _navigateToEmergencyPage(context),
            ),
            _buildOptionItem(
              icon: Icons.photo_camera_outlined,
              label: 'Hotspot Finder',
              onTap: () => _navigateToHotspotFinder(context),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTranslator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TranslationScreen(),
      ),
    );
  }

  void _navigateToEmergencyPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyPage(),
      ),
    );
  }

  void _navigateToHotspotFinder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotspotFinderPage(),
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
