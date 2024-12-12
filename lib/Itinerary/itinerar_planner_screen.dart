import 'package:Tripster/Itinerary/itinerary_schedule_screen.dart';
import 'package:Tripster/Itinerary/spot_details_screen.dart';
import 'package:Tripster/services/unsplash_service.dart';
import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'itinerary_result_screen.dart'; // Import the ItineraryResultScreen or replace with actual screen import

class ItineraryPlannerScreen extends StatefulWidget {
  final String cityName;
  final DateTime startDate;
  final DateTime endDate;

  const ItineraryPlannerScreen(
      {Key? key,
      required this.cityName,
      required this.startDate,
      required this.endDate})
      : super(key: key);

  @override
  _ItineraryPlannerScreenState createState() => _ItineraryPlannerScreenState();
}

class _ItineraryPlannerScreenState extends State<ItineraryPlannerScreen> {
  List<DocumentSnapshot> _selectedSpots = [];
  List<DocumentSnapshot> _allSpots = [];
  bool _showSelectedSpots = false;

  Future<String> _getImageUrl(String placeName) async {
    // Check if the image URL is already cached
    if (_imageUrlCache.containsKey(placeName)) {
      return _imageUrlCache[placeName]!;
    }

    try {
      // Fetch the image URL from the UnsplashService
      String imageUrl = await UnsplashService().fetchImage(placeName);

      // Cache the image URL
      _imageUrlCache[placeName] = imageUrl;

      return imageUrl;
    } catch (e) {
      // Use a fallback or placeholder image URL if the API call fails
      String fallbackImageUrl = 'https://via.placeholder.com/150';
      _imageUrlCache[placeName] = fallbackImageUrl;
      return fallbackImageUrl;
    }
  }

  final _imageUrlCache = <String, String>{};

  void _viewSpotDetails(DocumentSnapshot spot) async {
    // Extract the necessary data from the spot document
    String name = spot['Name'] ?? '';
    String city = spot['City'] ?? '';
    String googleRating = spot['Google review rating'] ?? 'N/A';
    String state = spot['State'] ?? 'N/A';
    String significance = spot['Significance'] ?? 'N/A';

    // Fetch the image URL from the UnsplashService
    String imageUrl = await _getImageUrl(name);

    // Navigate to SpotDetailsScreen with the extracted data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpotDetailsScreen(
          name: name,
          city: city,
          googleRating: googleRating,
          state: state,
          significance: significance,
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  void _addSpotToSelected(DocumentSnapshot spot) {
    if (!_selectedSpots.any((element) => element.id == spot.id)) {
      setState(() {
        _allSpots.remove(spot); // Remove the spot from _allSpots
        _selectedSpots.add(spot); // Add the spot to _selectedSpots
      });
    } else {
      // Show a snackbar or some other indication that the spot is already selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Spot is already selected'),
            duration: Duration(milliseconds: 800)),
      );
    }
  }

  void _removeSpotFromSelected(DocumentSnapshot spot) {
    setState(() {
      _selectedSpots.remove(spot);
      _allSpots.add(spot); // Add the spot back to _allSpots
    });
  }

  void _generateItinerary() {
    if (_selectedSpots.isNotEmpty) {
      List<Spot> selectedSpots = _selectedSpots.map((spot) {
        return Spot(
          name: spot['Name'] ?? '',
          timeNeeded: double.parse(spot['time needed to visit in hrs'] ?? '0'),
        );
      }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItineraryScheduleScreen(
            spots: selectedSpots,
            startDate: DateTime.now(),
            endDate: DateTime.now()
                .add(Duration(days: 1)), // Assume one-day itinerary for now
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text(
              "Please select at least one spot to generate itinerary.",
            ),
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
        title: Text(
          'Suggested Spots in, ${widget.cityName}',
          style: AppColors.titleTextStyle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showSelectedSpots = !_showSelectedSpots;
              });
            },
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('destination_details')
                  .where('City', isEqualTo: widget.cityName)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No spots found for ${widget.cityName}'),
                  );
                }

                _allSpots =
                    List.from(snapshot.data!.docs); // Initialize all spots

                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  padding: const EdgeInsets.all(10),
                  childAspectRatio: 0.75,
                  children: _allSpots.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () {
                        _viewSpotDetails(document);
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FutureBuilder<String>(
                              future: _getImageUrl(data['Name'] ?? ''),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                    child: Image.network(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                      height: 120,
                                    ),
                                  );
                                } else {
                                  return const SizedBox
                                      .shrink(); // or show a placeholder
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['Name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        ' ${data['Google review rating'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                      Text(
                                        'Time needed : ${data['time needed to visit in hrs'] ?? 'N/A'} hrs',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _addSpotToSelected(document);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: const Text(
                                          'Add',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.0,
                                            color: AppColors.White,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 180, // Set a fixed width for the button
                child: ElevatedButton(
                  onPressed: _generateItinerary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Generate Itinerary',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0,
                      color: AppColors.White,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0), // Adjust the horizontal padding
                child: SizedBox(
                  width: 180, // Set a fixed width for the button
                  child: ElevatedButton(
                    onPressed: () {
                      setState(
                        () {
                          _showSelectedSpots = !_showSelectedSpots;
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0), // Adjust the vertical padding
                      backgroundColor: AppColors.White,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: const BorderSide(
                          width: 1.0,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Show Selected Spots',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14.0,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showSelectedSpots)
            Expanded(
              child: ListView.builder(
                itemCount: _selectedSpots.length,
                itemBuilder: (context, index) {
                  final spot = _selectedSpots[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              spot['Name'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${spot['time needed to visit in hrs'] ?? 'N/A'} hrs',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          _removeSpotFromSelected(spot);
                        },
                        icon: const Icon(Icons.remove),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
