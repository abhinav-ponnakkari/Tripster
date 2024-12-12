import 'package:Tripster/sub_pages/support_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'EmergencyDetailsPage.dart';

class MapScreen extends StatefulWidget {
  final String? searchQuery; // Added searchQuery parameter

  const MapScreen({Key? key, this.searchQuery}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  TextEditingController _searchController =
      TextEditingController(); // Remove 'final' keyword
  bool isLocationEnabled = false;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _searchController.text = widget.searchQuery!;
      _searchLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchLocation,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (isLocationEnabled) {
                _getCurrentLocation();
              } else {
                _requestLocationService();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              if (_currentLocation != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmergencyDetailsPage(
                        currentLocation: _currentLocation!),
                  ),
                );
              } else {
                print('Current location not available');
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 12.0,
            ),
            onTap: (LatLng latLng) {
              if (isLocationEnabled) {
                _getCurrentLocation();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Location",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
              ),
              onSubmitted: (value) => _searchLocation(),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  Future<void> _searchLocation() async {
    String placeName = _searchController.text;
    LatLng? location = await getLocationFromPlaceName(placeName);
    if (location != null) {
      _goToPlace(location);
    } else {
      print('Location not found for place: $placeName');
    }
  }

  Future<LatLng?> getLocationFromPlaceName(String placeName) async {
    try {
      List<Location> locations = await locationFromAddress(placeName);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      return null;
    } catch (e) {
      print('Error getting location for place: $placeName, Error: $e');
      return null;
    }
  }

  void _goToPlace(LatLng location) {
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 15.0,
        ),
      ));
    }
  }

  void _navigateToSupportPage() {
    if (_currentLocation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupportPage(
            currentLocation: _currentLocation!,
          ),
        ),
      );
    } else {
      print('Current location not available');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      _goToPlace(currentLocation);
      setState(() {
        _currentLocation = currentLocation;
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _requestLocationService() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Location Service Disabled"),
              content: const Text(
                  "Please enable location services to use this feature."),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Location Permission Denied"),
              content: const Text(
                  "Please grant location permission to use this feature."),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }

    setState(() {
      isLocationEnabled = true;
    });

    _getCurrentLocation();
  }
}
