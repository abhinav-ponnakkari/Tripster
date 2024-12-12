import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotspot Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return HotspotFinderPage();
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class HotspotFinderPage extends StatefulWidget {
  @override
  _HotspotFinderPageState createState() => _HotspotFinderPageState();
}

class _HotspotFinderPageState extends State<HotspotFinderPage> {
  final TextEditingController _locationController = TextEditingController();
  List<Hotspot> _hotspots = [];

  Future<void> _findHotspots(String location) async {
    // Get a reference to the Firestore service
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Get document for the entered location
      DocumentSnapshot snapshot =
          await firestore.collection('hotspot_finder').doc(location).get();

      if (snapshot.exists) {
        // Extract hotspot data
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        _hotspots = data.entries
            .map((entry) => Hotspot(name: entry.key, imageUrl: entry.value))
            .toList();
      } else {
        _hotspots = []; // Clear existing list if location not found
      }
      setState(() {}); // Update UI with retrieved data
    } catch (e) {
      print('Error retrieving hotspots: $e');
      // Handle errors (e.g., network issues)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotspot Finder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Enter Location',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _findHotspots(_locationController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4,
              ),
              child: const Text(
                "Find Hotspots",
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0,
                  color: AppColors.White,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: _hotspots.isEmpty
                  ? const Center(child: Text('No hotspots found.'))
                  : GridView.count(
                      crossAxisCount: 2, // Adjust for number of columns
                      mainAxisSpacing: 10.0, // Spacing between tiles
                      crossAxisSpacing: 10.0,
                      children: _hotspots
                          .map((hotspot) => _buildHotspotTile(hotspot))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotspotTile(Hotspot hotspot) {
    return Column(
      children: [
        Expanded(
          child: CachedNetworkImage(
            imageUrl: hotspot.imageUrl,
            fit: BoxFit.cover, // Cover the entire container
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            hotspot.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class Hotspot {
  final String name;
  final String imageUrl;

  Hotspot({required this.name, required this.imageUrl});
}
