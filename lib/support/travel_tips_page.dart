import 'package:flutter/material.dart';

class TravelTipsPage extends StatelessWidget {
  TravelTipsPage({Key? key}) : super(key: key);

  final List<String> travelTips = [
    'Pack light to avoid excess baggage fees.',
    'Research local customs and etiquette before traveling.',
    'Always carry a reusable water bottle to stay hydrated.',
    'Keep copies of important documents like passports and visas.',
    'Use the in app navigation, translation,chat and other services.',
    'Try local cuisines and explore off-the-beaten-path attractions.',
    'Stay aware of your surroundings and be cautious with valuables.',
    'Keep a travel journal to capture memories and experiences.',
    'Respect nature and cultural heritage sites during your travels.',
    'Connect with locals for insider tips and recommendations.'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Travel Tips',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: travelTips.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text(
              travelTips[index],
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}
