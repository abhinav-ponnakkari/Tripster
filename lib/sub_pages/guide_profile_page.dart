import 'package:flutter/material.dart';
import 'package:Tripster/guide.dart';

class GuideProfilePage extends StatefulWidget {
  final Guide guide; // Assuming you have a Guide data model

  const GuideProfilePage({Key? key, required this.guide}) : super(key: key);

  @override
  _GuideProfilePageState createState() => _GuideProfilePageState();
}

class _GuideProfilePageState extends State<GuideProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage(widget.guide.profileImageUrl),
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.guide.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Age: ${widget.guide.age}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Gender: ${widget.guide.gender}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Location: ${widget.guide.location}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Languages Spoken: ${widget.guide.languagesSpoken.join(', ')}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            _buildRatingSection(),
            const SizedBox(height: 16.0),
            _buildReviewsSection(),
            // Add more sections as needed
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        SizedBox(height: 8.0),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            Icon(Icons.star, color: Colors.amber),
            Icon(Icons.star, color: Colors.amber),
            Icon(Icons.star, color: Colors.amber),
            Icon(Icons.star_border, color: Colors.amber),
            SizedBox(width: 8.0),
            Text(
              '4.0', // Replace with actual rating value
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        const SizedBox(height: 8.0),
        _buildReviewItem(
          reviewerName: 'Alice',
          reviewText: 'Great guide! Highly recommended.',
        ),
        _buildReviewItem(
          reviewerName: 'Bob',
          reviewText: 'Knowledgeable and friendly.',
        ),
        // Add more review items as needed
      ],
    );
  }

  Widget _buildReviewItem(
      {required String reviewerName, required String reviewText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reviewerName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            reviewText,
            style: const TextStyle(fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}
