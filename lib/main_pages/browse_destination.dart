import 'package:Tripster/main_pages/chat_interface.dart';
import 'package:Tripster/services/map.dart';
import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:Tripster/codes/Itinerary_planning.dart';
import 'package:Tripster/main_pages/profile_page.dart';
import 'package:Tripster/main_pages/home_page.dart';

class BrowseDestination extends StatefulWidget {
  const BrowseDestination({super.key});

  @override
  _BrowseDestinationState createState() => _BrowseDestinationState();
}

class _BrowseDestinationState extends State<BrowseDestination> {
  RangeValues _currentRangeValues = const RangeValues(1000, 50000);
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching ? _buildSearchField() : _buildTitle(),
          centerTitle: true,
          actions: _buildAppBarActions(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Explore by region'),
              _buildRegionButtons(),
              _buildSectionTitle('Interests'),
              _buildInterestButtons(),
              _buildSectionTitle('Budget'),
              _buildSectionSubTitle('Price range'),
              _buildBudgetSlider(),
              _buildSectionTitle('Featured Destinations'),
              _buildFeaturedDestinations(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Where to go',
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.normal,
          fontSize: 16.0,
        ),
        border: InputBorder.none,
      ),
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
        color: AppColors.textColor,
      ),
      onSubmitted: (value) {
        // Navigate to MapScreen with the search query
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(searchQuery: value),
          ),
        );
      },
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () {
            // setState(() {
            //   _isSearching = false;
            // });
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MapScreen()));
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ];
    }
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20.0),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22.0,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  Widget _buildSectionSubTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8.0),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16.0,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildRegionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton('Asia'),
          _buildButton('Europe'),
          _buildButton('North America'),
          _buildButton('South America'),
          _buildButton('Middle East'),
          _buildButton('Artic'),
        ],
      ),
    );
  }

  Widget _buildInterestButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton('Beach'),
          _buildButton('City'),
          _buildButton('Mountains'),
          _buildButton('Desert'),
          _buildButton('Tropical Forest'),
          _buildButton('Villages'),
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            const Color(0xFFE8EDF2),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14.0,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSlider() {
    return RangeSlider(
      values: _currentRangeValues,
      min: 1000,
      max: 50000,
      divisions: 100,
      activeColor: AppColors.primaryColor,
      inactiveColor: const Color(0xFFD1DBE8),
      onChanged: (RangeValues values) {
        setState(() {
          _currentRangeValues = values;
        });
      },
      labels: RangeLabels(
        '\u20B9${_currentRangeValues.start.toStringAsFixed(0)}',
        '\u20B9${_currentRangeValues.end.toStringAsFixed(0)}',
      ),
    );
  }

  Widget _buildFeaturedDestinations() {
    return SizedBox(
      height: 200.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFeaturedDestination(
              'assets/images/beach.png', 'Beach Paradise', 'India'),
          _buildFeaturedDestination(
              'assets/images/buildings.png', 'Cityscape Adventure', 'Dubai'),
          _buildFeaturedDestination(
              'assets/images/mountains.png', 'Mountain Retreat', 'Brazil'),
          _buildFeaturedDestination(
              'assets/images/dessert.png', 'Desert Expedition', 'Saudi Arabia'),
        ],
      ),
    );
  }

  Widget _buildFeaturedDestination(
      String imagePath, String name, String country) {
    return Container(
      width: 240.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset(
              imagePath,
              height: 135.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14.0,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            country,
            style: const TextStyle(
              fontSize: 14.0,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: AppColors.textColor,
      unselectedItemColor: AppColors.secondaryTextColor,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
              (route) => false,
            );
            break;
          case 1:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const ItineraryPlanning()),
              (route) => false,
            );
            break;
          case 2:

            // Stay on BrowseDestination page

            break;
          case 3:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatInterface()), // Pass the context
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
              (route) => false,
            );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          label: 'Wishlists',
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
        color: AppColors.textColor,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
