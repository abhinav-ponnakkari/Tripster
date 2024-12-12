import 'package:Tripster/Itinerary/spot_details_screen.dart';
import 'package:Tripster/Itinerary/trip_planner_screen.dart';
import 'package:Tripster/main_pages/chat_interface.dart';
import 'package:Tripster/recommendation_system/preference_screen.dart';
import 'package:Tripster/review/review_page.dart';
import 'package:Tripster/services/unsplash_service.dart';
import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Tripster/providers/user_provider.dart';
import 'package:Tripster/sub_pages/weather_page.dart';
import 'package:Tripster/main_pages/profile_page.dart';
import 'package:Tripster/sub_pages/support_page.dart';
import 'package:Tripster/sub_pages/settings_page.dart';
import 'package:Tripster/sub_pages/assistant_page.dart';
import 'package:Tripster/main_pages/itinerary_planner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

var userNameDisplay = "";

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    // Fetch user information from UserProvider
    final userProvider = context.watch<UserProvider>();
    final username =
        userProvider.username ?? ""; // Use empty string if username is null
    userNameDisplay = username;
    final email = userProvider.email ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: AppColors.titleTextStyle,
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(userProvider.username ?? ''),
              accountEmail: Text(userProvider.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: userProvider.profileImageUrl != null
                    ? NetworkImage(userProvider.profileImageUrl!)
                    : const AssetImage('assets/images/profile.png')
                        as ImageProvider,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
              ),
            ),
            ListTile(
              title: const Text(
                'Settings',
                style: AppColors.subtitleTextStyle,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Support',
                style: AppColors.subtitleTextStyle,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPopularDestinations(context),
            _buildQuickAccess(context),
            _buildWeatherUpdates(context),
            // _buildTravelSuggestions(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildPopularDestinations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding:
              EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
          child: Text('Popular destinations', style: AppColors.titleTextStyle),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchDestinationDetails().then(filterPopularDestinations),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200.0,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              return const SizedBox(
                height: 200.0,
                child: Center(
                  child: Text('Error loading popular destinations'),
                ),
              );
            } else {
              final popularDestinations = snapshot.data!;
              return SizedBox(
                height: 200.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularDestinations.length,
                  itemBuilder: (context, index) {
                    final destination = popularDestinations[index];
                    final imageUrl = destination['ImageURL'] ?? '';
                    final name = destination['Name'] ?? '';
                    final city = destination['City'] ?? '';
                    final reviewRatingString =
                        destination['Google review rating']?.toString() ??
                            '0.0';
                    final reviewRating =
                        double.tryParse(reviewRatingString) ?? 0.0;

                    return DestinationCard(
                      name: name,
                      city: city,
                      reviewRating: reviewRating,
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding:
              EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
          child: Text('Quick access', style: AppColors.titleTextStyle),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ItineraryPage()),
            );
          },
          child: const ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text(
              'Itinerary Planning',
              style: AppColors.subtitleTextStyle,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.keyboard_arrow_right_outlined),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AssistantPage()),
            );
          },
          child: const ListTile(
            leading: Icon(Icons.assistant_outlined),
            title: Text(
              'Assistants',
              style: AppColors.subtitleTextStyle,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.keyboard_arrow_right_outlined),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PreferenceScreen(),
                ));
          },
          child: const ListTile(
            leading: Icon(Icons.chat),
            title: Text(
              'View Recommendations',
              style: AppColors.subtitleTextStyle,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.keyboard_arrow_right_outlined),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Reviews(),
                ));
          },
          child: const ListTile(
            leading: Icon(Icons.reviews_outlined),
            title: Text(
              'Reviews',
              style: AppColors.subtitleTextStyle,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.keyboard_arrow_right_outlined),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherUpdates(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Weather Updates', style: AppColors.titleTextStyle),
        ),
        WeatherCard(
          image: 'assets/images/river.png',
          temperature: '25°C',
          condition: 'Sunny',
          suggestion: 'Enjoy the sunny weather!',
        )
      ],
    );
  }

  Widget _buildTravelSuggestions(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Travel Suggestions',
            style: TextStyle(
              fontSize: 22.0,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TravelSuggestionCard(
          image: 'assets/images/ramen.png',
          title: 'Local cuisine',
          subtitle: 'Try the delicious ramen in Tokyo   ',
        ),
        TravelSuggestionCard(
          image: 'assets/images/rome.png',
          title: 'Off the beaten path',
          subtitle: 'Explore the hidden alleys of Rome',
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.Black,
      unselectedItemColor: AppColors.secondaryTextColor,
      onTap: (index) {
        switch (index) {
          case 0:
            // Stay on MyHomePage
            break;
          case 1:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const TripPlannerScreen()),
              (route) => false,
            );
            break;
          case 2:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PreferenceScreen()),
              (route) => false,
            );
            break;
          case 3:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ChatInterface()),
              (route) => false,
            );
            break;
          case 4:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
              (route) => false,
            );
            break;
          default:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
            );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Itinerary',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flight_outlined),
          label: 'Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mail_outline),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.bold,
        fontSize: 10.0,
        color: AppColors.primaryColor,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<List<QueryDocumentSnapshot>> fetchDestinationDetails() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('destination_details')
        .get();
    return querySnapshot.docs;
  }

  List<Map<String, dynamic>> filterPopularDestinations(
    List<QueryDocumentSnapshot> destinationDetails,
  ) {
    // Shuffle the destination list to randomize the order
    final random = Random();
    destinationDetails.shuffle(random);

    // Take a random subset of destinations (e.g., top 4)
    final randomDestinations = destinationDetails
        .take(6)
        .map((doc) => (doc.data() as Map<String, dynamic>))
        .toList();

    return randomDestinations;
  }
}

class DestinationCard extends StatefulWidget {
  final String name;
  final String city;
  final double reviewRating;

  const DestinationCard({
    Key? key,
    required this.name,
    required this.city,
    required this.reviewRating,
  }) : super(key: key);

  @override
  _DestinationCardState createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
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

  void _showSpotDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpotDetailsScreen(
          name: widget.name,
          city: widget.city,
          googleRating: widget.reviewRating.toString(),
          state: '', // Set the state value if available, or leave it empty
          significance:
              '', // Set the significance value if available, or leave it empty
          imageUrl: _imageUrl.isNotEmpty
              ? _imageUrl
              : 'https://craftsnippets.com/articles_images/placeholder/placeholder.jpg',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSpotDetails,
      child: Container(
        width: 300.0,
        margin: const EdgeInsets.only(
            left: 16.0, right: 0.0, top: 24.0, bottom: 24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: _imageUrl.isEmpty ? Colors.grey : null,
          image: _imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(_imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  color: AppColors.White,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 18.0,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(1, 1),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
              Text(
                widget.city,
                style: const TextStyle(
                  color: AppColors.White,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(1, 1),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '${widget.reviewRating}',
                    style: const TextStyle(
                      color: AppColors.White,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final String image;
  final String temperature;
  final String condition;
  final String suggestion;

  const WeatherCard({
    Key? key,
    required this.image,
    required this.temperature,
    required this.condition,
    required this.suggestion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherPage(
              // temperature: temperature,
              // condition: condition,
              suggestion: suggestion,
            ),
          ),
        );
      },
      child: Container(
        width: 400,
        height: 135.0,
        margin: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    temperature,
                    style: const TextStyle(
                      color: AppColors.White,
                      fontSize: 32.0,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    condition,
                    style: const TextStyle(
                      color: AppColors.White,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 24.0,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                suggestion,
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                  fontSize: 16.0,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(1, 1),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TravelSuggestionCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const TravelSuggestionCard({
    Key? key,
    required this.image,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 135.0,
      margin:
          const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.White,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w900,
                fontSize: 16.0,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.White,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
