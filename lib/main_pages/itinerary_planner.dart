import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class Destination {
  final String id;
  final String name;
  final String city;
  final String timeNeeded;
  double lat;
  double lng;

  Destination({
    required this.id,
    required this.name,
    required this.city,
    required this.timeNeeded,
    this.lat = 0.0, // Default values
    this.lng = 0.0,
  });

  factory Destination.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Destination(
      id: snapshot.id,
      name: data['Name'] ?? '',
      city: data['City'] ?? '',
      timeNeeded: data['time needed to visit in hrs'] ?? '0',
    );
  }
}

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({Key? key}) : super(key: key);

  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  List<Destination> _destinations = [];
  List<Destination> _selectedDestinations = [];
  final List<Destination> _itineraryDestinations = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDestinations();
  }

  Future<void> _fetchDestinations() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('destination_details')
          .get();

      List<Destination> destinations = [];
      await Future.forEach(querySnapshot.docs, (doc) async {
        Destination destination = Destination.fromSnapshot(doc);
        print(destination);
        // fetchCoordinates(destination);
        destinations.add(destination);
      });

      setState(() {
        _destinations = destinations;
      });
    } catch (e) {
      print('Error fetching destinations: $e');
    }
  }

  Future<void> fetchCoordinates(
      List<Destination> _itineraryDestinations) async {
    // Encode the city name for URL usage
    Destination destination;
    for (destination in _itineraryDestinations) {
      final encodedCity = Uri.encodeComponent(destination.city);
      const apiKey = '60cd7c0d0f2949ea9773253d5fbf3abc';

// Build the OpenCage API URL
      final url = Uri.parse(
          'https://api.opencagedata.com/geocode/v1/json?q=$encodedCity&key=$apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

// Check if results are present
        if (data['results'] != null && data['results'].isNotEmpty) {
// Assuming the first result is the best match
          final firstResult = data['results'][0];
          if (firstResult['geometry'] != null) {
            destination.lat = firstResult['geometry']['lat'];
            destination.lng = firstResult['geometry']['lng'];
          } else {
            showPopup(
                context, 'Geometry data not found for ${destination.city}');
          }
        } else {
          showPopup(context, 'No results found for ${destination.city}');
        }
      } else {
// Handle API errors
        showPopup(
            context, 'Error fetching coordinates: ${response.statusCode}');
      }
    }
    Navigator.pop(context);

    _generateItinerary(_itineraryDestinations);
  }

  void showPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _searchCity(String cityName) {
    String searchValue = cityName.toLowerCase();
    List<Destination> filteredDestinations = _destinations
        .where((destination) =>
            destination.city.toLowerCase().contains(searchValue))
        .toList();

    setState(() {
      _selectedDestinations = filteredDestinations;
    });
  }

  Future<void> _toggleSelection(Destination destination) async {
    try {
      if (_itineraryDestinations.isNotEmpty) {
        // Check if the destination has coordinates
        if (destination.lat == 0.0 && destination.lng == 0.0) {
          setState(() {
            if (_selectedDestinations.contains(destination)) {
              _selectedDestinations.remove(destination);
              _itineraryDestinations.add(destination);
            } else {
              _selectedDestinations.add(destination);
              _itineraryDestinations.add(destination);
            }
          });
          return; // Skip the travel time calculation
        }
      } else {
        setState(() {
          _selectedDestinations.remove(destination);
          _itineraryDestinations.add(destination);
        });
      }
    } catch (e) {
      print(_selectedDestinations);
      print(_itineraryDestinations);
      print('Error: $e');
      // Handle the error gracefully, e.g., display a message or log it
    }
  }

  // Future<double> getTravelTime(double originLat, double originLng,
  //     double destLat, double destLng) async {
  //   const apiKey = 'AIzaSyAEysQmIOwATg41m3Qv8UrLOgWMFLLkEo0';
  //   final apiUrl =
  //       'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$originLat,$originLng&destinations=$destLat,$destLng&key=$apiKey';

  //   final response = await http.get(Uri.parse(apiUrl));

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);

  //     if (data['rows'] != null && data['rows'].isNotEmpty) {
  //       final elements = data['rows'][0]['elements'];

  //       if (elements != null && elements.isNotEmpty) {
  //         final duration = elements[0]['duration'];

  //         if (duration != null &&
  //             duration is Map &&
  //             duration['value'] != null &&
  //             duration['value'] is int) {
  //           final travelTimeSeconds = duration['value'];
  //           final double travelTimeInHours = travelTimeSeconds / 3600;
  //           return travelTimeInHours;
  //         } else {
  //           throw Exception('Invalid duration data or missing value');
  //         }
  //       } else {
  //         throw Exception('Empty elements list');
  //       }
  //     } else {
  //       throw Exception('Empty rows list');
  //     }
  //   } else {
  //     throw Exception('Failed to load travel time: ${response.statusCode}');
  //   }
  // }

  Future<double?> getTravelTime(double originLat, double originLng,
      double destLat, double destLng) async {
    final apiKey =
        'AIzaSyAEysQmIOwATg41m3Qv8UrLOgWMFLLkEo0'; // Replace with your actual API key
    final baseUrl =
        'https://maps.googleapis.com/maps/api/directions/json'; // Replace with your geocoding service's base URL

    final uri = Uri.https(baseUrl, '', {
      'origin': '$originLat,$originLng',
      'destination': '$destLat,$destLng',
      'key': apiKey,
      'mode':
          'driving', // Replace with desired travel mode (e.g., 'transit', 'bicycling')
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['routes'].isNotEmpty) {
        final travelTimeSeconds =
            data['routes'][0]['legs'][0]['duration']['value'];
        return travelTimeSeconds / 3600.0; // Convert seconds to hours
      } else {
        print('No routes found between origin and destination.');
        return null;
      }
    } else {
      print('Error fetching travel time: ${response.statusCode}');
      return null;
    }
  }

  List<int> _findRoute(List<List<double>> distance) {
    List<int> schedule = [];

    final numCities = distance.length;
    final visited = List<bool>.filled(numCities, false);

    // Start from any node (here, we start from node 0)
    int currentCity = 0;
    visited[currentCity] = true;
    schedule.add(currentCity);

    // Visit all remaining nodes
    for (var i = 1; i < numCities; i++) {
      int nearestCity = -1;
      double minDistance = double.infinity;

      // Find the nearest unvisited city
      for (var j = 0; j < numCities; j++) {
        if (!visited[j] && distance[currentCity][j] < minDistance) {
          minDistance = distance[currentCity][j];
          nearestCity = j;
        }
      }

      // Update route and visited list
      if (nearestCity != -1) {
        visited[nearestCity] = true;
        schedule.add(nearestCity);
        currentCity = nearestCity;
      }
    }

    // Return to starting node to complete the route
    schedule.add(0);

    return schedule;
  }

  void _generateItinerary(List<Destination> itineraryDestinations) {
    List<List<double?>> distance = [];
    List<Destination> itinerarySchedule = [];

    if (itineraryDestinations.isNotEmpty) {
      for (int i = 0; i < itineraryDestinations.length; i++) {
        for (int j = 0; j < itineraryDestinations.length; j++) {
          distance[i][j] = getTravelTime(
              itineraryDestinations[i].lat,
              itineraryDestinations[i].lng,
              itineraryDestinations[j].lat,
              itineraryDestinations[j].lng) as double?;
        }
      }

      List<int> schedule = _findRoute(distance.cast<List<double>>());

      for (int i = 0; i < schedule.length; i++) {
        itinerarySchedule[i] = itineraryDestinations[schedule[i]];
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ScheduleScreen(selectedDestinations: itinerarySchedule),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "Please select at least one destination to generate itinerary."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _searchCity(_searchController.text);
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          const Text(
            'Destinations in the city:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedDestinations.length,
              itemBuilder: (context, index) {
                final destination = _selectedDestinations[index];
                return ListTile(
                  title: Text(destination.name),
                  subtitle: Text(destination.city),
                  onTap: () => _toggleSelection(destination),
                  selected: _selectedDestinations.contains(destination),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => DestinationListPage(destinations: _itineraryDestinations),
              //   ),
              // );
              showDialog(
                context: context,
                barrierDismissible:
                    false, // Prevent dismissal by tapping outside
                builder: (context) =>
                    Center(child: CircularProgressIndicator()),
              );
              fetchCoordinates(_itineraryDestinations);
            },
            child: const Text('Generate Itinerary'),
          ),
        ],
      ),
    );
  }
}

class ScheduleScreen extends StatelessWidget {
  final List<Destination> selectedDestinations;

  const ScheduleScreen({Key? key, required this.selectedDestinations})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Destination> optimalSchedule = selectedDestinations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary Schedule'),
      ),
      body: ListView.builder(
        itemCount: optimalSchedule.length,
        itemBuilder: (context, index) {
          final destination = optimalSchedule[index];
          return ListTile(
            title: Text(destination.name),
            subtitle: Text(
              'City: ${destination.city} - Time Needed: ${destination.timeNeeded} hrs',
            ),
          );
        },
      ),
    );
  }

  List<Destination> _getOptimalSchedule(List<Destination> destinations) {
    List<Destination> schedule = [];
    schedule.addAll(destinations); // Start with the selected destinations

    // Sort destinations based on time needed (ascending order)
    schedule.sort((a, b) => a.timeNeeded.compareTo(b.timeNeeded));

    return schedule;
  }
}

class DestinationListPage extends StatelessWidget {
  final List<Destination> destinations;

  const DestinationListPage({Key? key, required this.destinations})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Destination List'),
      ),
      body: ListView.builder(
        itemCount: destinations.length,
        itemBuilder: (BuildContext context, int index) {
          return DestinationCard(destination: destinations[index]);
        },
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Destination destination;

  const DestinationCard({Key? key, required this.destination})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${destination.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text('City: ${destination.city}'),
            SizedBox(height: 8.0),
            Text('Time Needed: ${destination.timeNeeded} hrs'),
            SizedBox(height: 8.0),
            Text('Latitude: ${destination.lat}'),
            SizedBox(height: 8.0),
            Text('Longitude: ${destination.lng}'),
          ],
        ),
      ),
    );
  }
}
