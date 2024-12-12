import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyDetailsPage extends StatefulWidget {
  final LatLng currentLocation;

  const EmergencyDetailsPage({super.key, required this.currentLocation});

  @override
  _EmergencyDetailsPageState createState() => _EmergencyDetailsPageState();
}

class _EmergencyDetailsPageState extends State<EmergencyDetailsPage> {
  String _emergencyPlaceDetails = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchNearbyEmergencyPlace(widget.currentLocation);
  }

  Future<void> _fetchNearbyEmergencyPlace(LatLng currentLocation) async {
    try {
      String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
      String apiUrl =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${currentLocation.latitude},${currentLocation.longitude}&radius=5000&type=police|hospital&key=$apiKey';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> results = data['results'];

        if (results.isNotEmpty) {
          Map<String, dynamic> nearestPlace = results[0];
          String name = nearestPlace['name'];
          String vicinity = nearestPlace['vicinity'];
          double distance = nearestPlace['geometry']['location']['distanceFromCurrentLocation'];

          String details = 'Nearest Emergency Place:\n\n'
              'Name: $name\n'
              'Address: $vicinity\n'
              'Distance: ${distance.toStringAsFixed(2)} meters';

          setState(() {
            _emergencyPlaceDetails = details;
          });
        } else {
          setState(() {
            _emergencyPlaceDetails = 'No nearby emergency places found.';
          });
        }
      } else {
        setState(() {
          _emergencyPlaceDetails = 'Failed to fetch emergency place details.';
        });
      }
    } catch (e) {
      print('Error fetching emergency place details: $e');
      setState(() {
        _emergencyPlaceDetails = 'Error fetching emergency place details.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Place Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _emergencyPlaceDetails,
            style: const TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}