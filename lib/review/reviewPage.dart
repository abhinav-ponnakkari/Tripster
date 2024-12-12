import 'package:Tripster/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewPage extends StatefulWidget {
  final String username;

  const ReviewPage({
    Key? key,
    required this.username,
  }) : super(key: key);
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  double _rating = 0.0;
  String _selectedPlace = '';

  Future<void> _addReview() async {
    if (_selectedPlace.isNotEmpty) {
      await FirebaseFirestore.instance.collection('reviews').add({
        'place': _selectedPlace,
        'review': _reviewController.text,
        'rating': _rating,
        'name': widget.username.toString()
      });
      _reviewController.clear();
      _rating = 0.0;
      _selectedPlace = '';
    }
  }

  void _searchPlaces(String query) {
    FirebaseFirestore.instance
        .collection('destination_details')
        .where('Name', isGreaterThanOrEqualTo: query)
        .where('Name', isLessThan: query + 'z')
        .get()
        .then((querySnapshot) {
      setState(() {
        _searchResults = querySnapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Reviews',
          style: AppColors.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a place',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchPlaces(_searchController.text),
                ),
              ),
              style: AppColors.subtitleTextStyle, // Apply the text style here
            ),
          ),
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final place = _searchResults[index];
                      return ListTile(
                        title: Text(place['City']),
                        subtitle: Text(place['Type']),
                        onTap: () {
                          setState(() {
                            _selectedPlace = _searchController.text;
                          });
                        },
                      );
                    },
                  )
                : Center(
                    child: Text('No places found'),
                  ),
          ),
          if (_selectedPlace.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review for $_selectedPlace',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    controller: _reviewController,
                    decoration: InputDecoration(
                      hintText: 'Enter your review',
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _addReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      "Submit Review",
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
        ],
      ),
    );
  }
}
