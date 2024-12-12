import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return EmergencyPage();
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class EmergencyPage extends StatelessWidget {
  final TextEditingController _placeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _placeController,
                decoration: const InputDecoration(
                  labelText: 'Enter Place',
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _retrieveEmergencyDetails(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Get Details",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0,
                    color: AppColors.White,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _retrieveEmergencyDetails(BuildContext context) async {
    String placeName = _placeController.text.trim();

    // Get a reference to the Firestore service
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Query Firestore for all documents in the 'Emergency_details' collection
      QuerySnapshot snapshot =
          await firestore.collection('Emergency_details').get();

      // Create a Fuzzy instance with the list of document IDs as options
      final List<String> options = snapshot.docs.map((doc) => doc.id).toList();
      final Fuzzy<String> fuzzy = Fuzzy(options);

      // Find the closest match to the entered place name
      final List<Result<String>> results = fuzzy.search(placeName);
      if (results.isNotEmpty) {
        // Retrieve emergency details for the closest match
        String closestMatch = results.first.item;
        DocumentSnapshot docSnapshot = await firestore
            .collection('Emergency_details')
            .doc(closestMatch)
            .get();

        String policeNumber = docSnapshot['police'].toString();
        String hospitalNumber = docSnapshot['hospital'].toString();

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Emergency Details for $closestMatch'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Police: $policeNumber'),
                  Text('Hospital: $hospitalNumber'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // No matches found
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('No Emergency Details Found'),
              content: Text('No emergency details found for $placeName.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error retrieving emergency details: $e');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while retrieving data.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
