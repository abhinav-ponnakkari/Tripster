/* import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'package:geocoding/geocoding.dart';

class ItineraryResultScreen extends StatefulWidget {
  final List<Destination> selectedSpots;

  ItineraryResultScreen({Key? key, required this.selectedSpots})
      : super(key: key);

  @override
  _ItineraryResultScreenState createState() => _ItineraryResultScreenState();
}

class _ItineraryResultScreenState extends State<ItineraryResultScreen> {
  static const double AVERAGE_TRAVEL_SPEED_KM_PER_HOUR =
      50.0; // Adjust as needed

  late List<ScheduledSpot> itinerary;

  @override
  void initState() {
    super.initState();
    itinerary = generateOptimizedItinerary(widget.selectedSpots);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Itinerary Result',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              saveItinerary();
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              shareItinerary();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: itinerary.length,
        itemBuilder: (context, index) {
          final spot = itinerary[index];
          return ListTile(
            title: Text(spot.destination.name),
            subtitle: Text(
              'Arrival: ${spot.arrivalTime} - Departure: ${spot.departureTime}',
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                editSpot(index);
              },
            ),
          );
        },
      ),
    );
  }

  List<ScheduledSpot> generateOptimizedItinerary(List<Destination> spots) {
    List<ScheduledSpot> itinerary = [];
    List<Destination> unvisitedSpots = List.from(spots);

    // Start from a random spot
    Destination currentSpot = unvisitedSpots.removeAt(0);
    DateTime currentTime = DateTime.now();
    itinerary.add(ScheduledSpot(
      destination: currentSpot,
      arrivalTime: formatTime(currentTime),
      departureTime: formatTime(currentTime
          .add(Duration(hours: double.parse(currentSpot.timeNeeded).ceil()))),
    ));

    while (unvisitedSpots.isNotEmpty) {
      // Find the nearest unvisited spot using the Nearest Neighbor heuristic
      Destination nearestSpot =
          findNearestNeighbor(currentSpot, unvisitedSpots);

      // Calculate travel distance and time needed for the next spot
      double distance = calculateDistance(currentSpot, nearestSpot);
      double travelTimeInHours = distance / AVERAGE_TRAVEL_SPEED_KM_PER_HOUR;

      // Calculate arrival and departure times
      DateTime arrivalTime =
          currentTime.add(Duration(hours: travelTimeInHours.ceil()));
      DateTime departureTime = arrivalTime
          .add(Duration(hours: double.parse(nearestSpot.timeNeeded).ceil()));

      itinerary.add(ScheduledSpot(
        destination: nearestSpot,
        arrivalTime: formatTime(arrivalTime),
        departureTime: formatTime(departureTime),
      ));

      // Update current spot and remove from unvisited spots
      currentSpot = nearestSpot;
      unvisitedSpots.remove(nearestSpot);
      currentTime = departureTime;
    }

    return itinerary;
  }

  Destination findNearestNeighbor(
      Destination currentSpot, List<Destination> unvisitedSpots) {
    return unvisitedSpots.reduce((nearest, spot) {
      double currentDistance = calculateDistance(currentSpot, spot);
      double nearestDistance = calculateDistance(currentSpot, nearest);
      return currentDistance < nearestDistance ? spot : nearest;
    });
  }

  double calculateDistance(Destination spot1, Destination spot2) {
    // Implement distance calculation based on coordinates or other criteria
    return 0; // Placeholder, replace with actual calculation
  }

  String formatTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void saveItinerary() async {
    try {
      final pdfLib.Document pdf = pdfLib.Document();

      pdf.addPage(
        pdfLib.Page(
          build: (context) {
            return pdfLib.Column(
              children: [
                pdfLib.Text('Itinerary',
                    style: pdfLib.TextStyle(
                        fontSize: 20, fontWeight: pdfLib.FontWeight.bold)),
                pdfLib.SizedBox(height: 20),
                for (final spot in itinerary)
                  pdfLib.Text(
                    '${spot.destination.name} - Arrival: ${spot.arrivalTime} - Departure: ${spot.departureTime}',
                    style: pdfLib.TextStyle(fontSize: 16),
                  ),
              ],
            );
          },
        ),
      );

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      final File pdfFile = File('$appDocPath/itinerary.pdf');
      await pdfFile.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Itinerary saved as PDF.'),
        ),
      );

      // Log the file path for debugging
      print('PDF saved to: ${pdfFile.path}');
    } catch (e) {
      print('Error saving PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving itinerary as PDF.'),
        ),
      );
    }
  }

  void shareItinerary() {
    String sharedText = 'Itinerary:\n';
    itinerary.forEach((spot) {
      sharedText +=
          '${spot.destination.name} - Arrival: ${spot.arrivalTime} - Departure: ${spot.departureTime}\n';
    });
    Share.share(sharedText);
  }

  void editSpot(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit spot function not implemented.'),
      ),
    );
  }
}

class ScheduledSpot {
  final Destination destination;
  final String arrivalTime;
  final String departureTime;

  ScheduledSpot({
    required this.destination,
    required this.arrivalTime,
    required this.departureTime,
  });

  factory ScheduledSpot.fromMap(Map<String, dynamic> map) {
    return ScheduledSpot(
      destination: Destination.fromMap(map['destination']),
      arrivalTime: map['arrivalTime'] ?? '',
      departureTime: map['departureTime'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'destination': destination.toMap(),
      'arrivalTime': arrivalTime,
      'departureTime': departureTime,
    };
  }
}

class Destination {
  final String id;
  final String name;
  final String city;
  final String timeNeeded;

  Destination({
    required this.id,
    required this.name,
    required this.city,
    required this.timeNeeded,
  });

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      city: map['city'] ?? '',
      timeNeeded: map['time needed to visit in hrs'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'timeNeeded': timeNeeded,
    };
  }
}
 */