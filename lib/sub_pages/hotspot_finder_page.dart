import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Hotspot {
  final String name;
  final String place;
  final String imageUrl;

  Hotspot({required this.name, required this.place, required this.imageUrl});
}

class HotspotFinder extends StatefulWidget {
  const HotspotFinder({Key? key}) : super(key: key);

  @override
  _HotspotFinderState createState() => _HotspotFinderState();
}

class _HotspotFinderState extends State<HotspotFinder> {
  late List<Hotspot> hotspots = [];
  bool isLoading = false;
  String searchQuery = '';

  static const _baseUrl = 'https://api.unsplash.com';
  static const String _accessKey =
      'UCmh756Dghtg3A5yrGav4ut83Y02Ze04N18P5M05L20'; // Replace with your Unsplash access key

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchData() async {
    if (searchQuery.trim().isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Uri requestUrl = Uri.parse('$_baseUrl/search/photos?'
          'query=$searchQuery&per_page=10&client_id=$_accessKey');

      final response = await http.get(requestUrl);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['results'] as List;
        print('API Response: $data'); // Print the API response

        setState(() {
          hotspots = data.map((hotspotJson) {
            final location = hotspotJson['location'] as Map<String, dynamic>?;
            return Hotspot(
              name: hotspotJson['alt_description'] ?? '',
              place: location?['city'] ?? '',
              imageUrl: hotspotJson['urls']['regular'] ?? '',
            );
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hotspot Finder',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) => updateSearchQuery(query),
              decoration: const InputDecoration(
                labelText: 'Search for Photography Hotspots',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: hotspots.length,
                    itemBuilder: (context, index) {
                      final hotspot = hotspots[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(hotspot.imageUrl),
                          ),
                          title: Text(hotspot.name),
                          subtitle: Text(hotspot.place),
                          // You can add more details or functionality to each card as needed
                        ),
                      );
                    }),
          ),
        ],
      ),
    );
  }
}
