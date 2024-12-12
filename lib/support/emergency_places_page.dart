import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmergencyPage extends StatefulWidget {
  @override
  _EmergencyPageState createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchCity(String city) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('destination_details')
            .where('Name', isEqualTo: city)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          querySnapshot.docs.first;
      final GeoPoint ps = documentSnapshot.get('ps');
      final List<dynamic> hospitalsList = documentSnapshot.get('hospitals');

      _markers.clear();
      _addMarker(ps, Colors.red, 'Police Station');
      _addMarkers(hospitalsList, Colors.blue, 'Hospital');

      if (_mapController != null) {
        _moveCameraToLocation(ps.latitude, ps.longitude);
      }
    }
  }

  void _moveCameraToLocation(double latitude, double longitude) {
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 12, // Adjust the zoom level as needed
        ),
      ),
    );
  }

  void _addMarker(GeoPoint location, Color color, String markerTitle) {
    final LatLng latLng = LatLng(location.latitude, location.longitude);
    final Marker marker = Marker(
      markerId: MarkerId(latLng.toString()),
      position: latLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(_colorize(color)),
      infoWindow: InfoWindow(title: markerTitle),
    );
    _markers.add(marker);
  }

  void _addMarkers(List<dynamic> locations, Color color, String markerTitle) {
    locations.forEach((location) {
      final GeoPoint geoPoint = location;
      final LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
      final Marker marker = Marker(
        markerId: MarkerId(latLng.toString()),
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(_colorize(color)),
        infoWindow: InfoWindow(title: markerTitle),
      );
      _markers.add(marker);
    });
    if (mounted) {
      setState(() {});
    }
  }

  double _colorize(Color color) =>
      ((color.value & 0x00FFFFFF) | 0x88000000) % 360.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Map'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search City',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final String city = _searchController.text.trim();
                    _searchCity(city);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(0.0, 0.0),
                zoom: 10,
              ),
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }
}
