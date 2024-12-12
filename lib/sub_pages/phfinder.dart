import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotspotMapScreen extends StatefulWidget {
  @override
  _HotspotMapScreenState createState() => _HotspotMapScreenState();
}

class _HotspotMapScreenState extends State<HotspotMapScreen> {
  GoogleMapController? mapController;
  List<Marker> markers = [];
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotspot Map'),
      ),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Enter City Name',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _searchHotspots(searchController.text.trim());
                },
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(0.0, 0.0), // Initial camera position
                zoom: 10.0,
              ),
              markers: Set<Marker>.of(markers),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchHotspots(String city) async {
    // Clear previous markers
    setState(() {
      markers.clear();
    });

    // Query Firestore for hotspots in the specified city
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('destination_details')
        .where('City', isEqualTo: city)
        .get();

    // Add markers for each hotspot to the map
    querySnapshot.docs.forEach((doc) {
      List<dynamic> hotspots = doc['ph']; // Updated array name to 'ph'
      hotspots.forEach((hotspot) {
        GeoPoint geoPoint = hotspot;
        setState(() {
          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(geoPoint.latitude, geoPoint.longitude),
              infoWindow: InfoWindow(title: doc['Name']),
            ),
          );
        });
      });
    });

    // Zoom the map to fit all markers
    _zoomToFitMarkers();
  }

  void _zoomToFitMarkers() {
    if (markers.isEmpty || mapController == null) return;

    double minLat = markers[0].position.latitude;
    double maxLat = markers[0].position.latitude;
    double minLng = markers[0].position.longitude;
    double maxLng = markers[0].position.longitude;

    for (Marker marker in markers) {
      double lat = marker.position.latitude;
      double lng = marker.position.longitude;

      minLat = lat < minLat ? lat : minLat;
      maxLat = lat > maxLat ? lat : maxLat;
      minLng = lng < minLng ? lng : minLng;
      maxLng = lng > maxLng ? lng : maxLng;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
}
