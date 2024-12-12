import 'package:Tripster/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Tripster/services/unsplash_service.dart'; // Import the UnsplashService

class RecommendationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;

  const RecommendationScreen({Key? key, required this.recommendations})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recommendations',
          style: AppColors.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = recommendations[index];
          final name = recommendation['Name'] ?? '';
          final city = recommendation['City'] ?? '';
          final reviewRating = recommendation['Google review rating'] ?? 0.0;

          return RecommendationCard(
            name: name,
            city: city,
            reviewRating: reviewRating,
          );
        },
      ),
    );
  }
}

class RecommendationCard extends StatefulWidget {
  final String name;
  final String city;
  final String reviewRating; // Change the type to String

  const RecommendationCard({
    Key? key,
    required this.name,
    required this.city,
    required this.reviewRating, // Change the type to String
  }) : super(key: key);

  @override
  _RecommendationCardState createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchImageUrl();
  }

  Future<void> _fetchImageUrl() async {
    try {
      final unsplashService = UnsplashService();
      final imageUrl = await unsplashService.fetchImage(widget.name);
      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      print('Error fetching image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double reviewRatingValue =
        double.tryParse(widget.reviewRating) ?? 0.0; // Convert to double

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: _imageUrl.isEmpty ? Colors.grey : null,
              child: _imageUrl.isNotEmpty
                  ? CachedNetworkImage(imageUrl: _imageUrl)
                  : const SizedBox.shrink(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(widget.city),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4.0),
                    Text(
                        '$reviewRatingValue'), // Use the converted double value
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
