import 'package:Tripster/Itinerary/trip_planner_screen.dart';
import 'package:Tripster/main_pages/chat_interface.dart';
import 'package:Tripster/main_pages/home_page.dart';
import 'package:Tripster/main_pages/profile_page.dart';
import 'package:Tripster/recommendation_system/recommendation_screen%20.dart';
import 'package:Tripster/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Tripster/recommendation_system/user_preferences.dart';

class PreferenceScreen extends StatefulWidget {
  @override
  _PreferenceScreenState createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> fetchDestinationDetails() async {
    final querySnapshot =
        await _firestore.collection('destination_details').get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Set Preferences',
          style: AppColors.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelection(userPreferences),
              _buildZoneSelection(userPreferences),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Max Budget (INR)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => userPreferences
                    .setMaxBudget(value.isNotEmpty ? int.parse(value) : null),
              ),
              _buildVisitTimeSelection(userPreferences),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Max Distance from Airport (km)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => userPreferences.setMaxDistanceFromAirport(
                    value.isNotEmpty ? int.parse(value) : null),
              ),
              _buildWeeklyOffSelection(userPreferences),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final destinationDetails = await fetchDestinationDetails();
                    final recommendations = filterRecommendations(
                        destinationDetails, userPreferences);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecommendationScreen(
                            recommendations: recommendations),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Get Recommendations',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0,
                      color: AppColors.White,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context), // Add this line
    );
  }

  Widget _buildTypeSelection(UserPreferences userPreferences) {
    final selectedTypes = userPreferences.preferredTypes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(
                'Any Type',
                selectedTypes.isEmpty,
                () {
                  userPreferences.setPreferredTypes([]);
                },
              ),
              _buildButton(
                'War Memorial',
                selectedTypes.contains('War Memorial'),
                () {
                  userPreferences.togglePreferredType('War Memorial');
                },
              ),
              _buildButton(
                'Tomb',
                selectedTypes.contains('Tomb'),
                () {
                  userPreferences.togglePreferredType('Tomb');
                },
              ),
              _buildButton(
                'Temple',
                selectedTypes.contains('Temple'),
                () {
                  userPreferences.togglePreferredType('Temple');
                },
              ),
              _buildButton(
                'Theme Park',
                selectedTypes.contains('Theme Park'),
                () {
                  userPreferences.togglePreferredType('Theme Park');
                },
              ),
              // Add more types from the dataset
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, bool selected, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0), // Add left padding of 4px
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.White,
          backgroundColor: selected ? Colors.green : AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildZoneSelection(UserPreferences userPreferences) {
    final String? selectedZone = userPreferences.preferredZone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Zone',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(
                'Any Zone',
                selectedZone == null,
                () => userPreferences.setPreferredZone(null),
              ),
              _buildButton(
                'Northern',
                selectedZone == 'Northern',
                () => userPreferences.setPreferredZone('Northern'),
              ),
              _buildButton(
                'Western',
                selectedZone == 'Western',
                () => userPreferences.setPreferredZone('Western'),
              ),
              _buildButton(
                'Southern',
                selectedZone == 'Southern',
                () => userPreferences.setPreferredZone('Southern'),
              ),
              _buildButton(
                'Eastern',
                selectedZone == 'Eastern',
                () => userPreferences.setPreferredZone('Eastern'),
              ),
              _buildButton(
                'Central',
                selectedZone == 'Central',
                () => userPreferences.setPreferredZone('Central'),
              ),
              _buildButton(
                'North Eastern',
                selectedZone == 'North Eastern',
                () => userPreferences.setPreferredZone('North Eastern'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisitTimeSelection(UserPreferences userPreferences) {
    final String? selectedVisitTime = userPreferences.preferredVisitTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Visit Time',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(
                'Any Time',
                selectedVisitTime == null,
                () => userPreferences.setPreferredVisitTime(null),
              ),
              _buildButton(
                'Morning',
                selectedVisitTime == 'Morning',
                () => userPreferences.setPreferredVisitTime('Morning'),
              ),
              _buildButton(
                'Afternoon',
                selectedVisitTime == 'Afternoon',
                () => userPreferences.setPreferredVisitTime('Afternoon'),
              ),
              _buildButton(
                'Evening',
                selectedVisitTime == 'Evening',
                () => userPreferences.setPreferredVisitTime('Evening'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyOffSelection(UserPreferences userPreferences) {
    final String? selectedWeeklyOff = userPreferences.preferredWeeklyOff;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weekly Off',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(
                'Any Day',
                selectedWeeklyOff == null,
                () => userPreferences.setPreferredWeeklyOff(null),
              ),
              _buildButton(
                'None',
                selectedWeeklyOff == 'None',
                () => userPreferences.setPreferredWeeklyOff('None'),
              ),
              _buildButton(
                'Monday',
                selectedWeeklyOff == 'Monday',
                () => userPreferences.setPreferredWeeklyOff('Monday'),
              ),
              _buildButton(
                'Tuesday',
                selectedWeeklyOff == 'Tuesday',
                () => userPreferences.setPreferredWeeklyOff('Tuesday'),
              ),
              _buildButton(
                'Wednesday',
                selectedWeeklyOff == 'Wednesday',
                () => userPreferences.setPreferredWeeklyOff('Wednesday'),
              ),
              _buildButton(
                'Thursday',
                selectedWeeklyOff == 'Thursday',
                () => userPreferences.setPreferredWeeklyOff('Thursday'),
              ),
              _buildButton(
                'Friday',
                selectedWeeklyOff == 'Friday',
                () => userPreferences.setPreferredWeeklyOff('Friday'),
              ),
              _buildButton(
                'Saturday',
                selectedWeeklyOff == 'Saturday',
                () => userPreferences.setPreferredWeeklyOff('Saturday'),
              ),
              _buildButton(
                'Sunday',
                selectedWeeklyOff == 'Sunday',
                () => userPreferences.setPreferredWeeklyOff('Sunday'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> filterRecommendations(
      List<QueryDocumentSnapshot> destinationDetails,
      UserPreferences userPreferences) {
    return destinationDetails
        .where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final preferredTypes = userPreferences.preferredTypes;
          final entranceFee = data['Entrance Fee in INR'] is int
              ? data['Entrance Fee in INR']
              : int.tryParse(data['Entrance Fee in INR']?.toString() ?? '0') ??
                  0;

          // Check if 'Best Time to visit' field is a list
          final visitTimes = data['Best Time to visit'] is List
              ? (data['Best Time to visit'] as List).cast<String>()
              : [data['Best Time to visit']?.toString() ?? ''];

          final weeklyOffs = data['Weekly Off'] is List
              ? (data['Weekly Off'] as List).cast<String>()
              : data['Weekly Off'] != null
                  ? [data['Weekly Off'].toString()]
                  : [];

          // Check if 'Airport with 50km Radius' field is a boolean
          final isWithin50kmRadius = data['Airport with 50km Radius'] is bool &&
              data['Airport with 50km Radius'];

          return (preferredTypes.isEmpty ||
                  preferredTypes.contains('Any Type') ||
                  preferredTypes.contains(data['Type'])) &&
              (userPreferences.preferredZone == null ||
                  data['Zone'] == userPreferences.preferredZone) &&
              (userPreferences.maxBudget == null ||
                  entranceFee <= userPreferences.maxBudget!) &&
              (userPreferences.preferredVisitTime == null ||
                  visitTimes.contains(userPreferences.preferredVisitTime)) &&
              (userPreferences.maxDistanceFromAirport == null ||
                  (isWithin50kmRadius &&
                      userPreferences.maxDistanceFromAirport! >= 50)) &&
              (userPreferences.preferredWeeklyOff == null ||
                  weeklyOffs.contains(userPreferences.preferredWeeklyOff));
        })
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
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
                  builder: (context) => const TripPlannerScreen()),
              (route) => false,
            );
            break;
          case 2:

            // Stay on PreferenceScreen page

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
        color: AppColors.textColor,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
