import 'package:Tripster/main_pages/chat_interface.dart';
import 'package:Tripster/recommendation_system/preference_screen.dart';
import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:Tripster/main_pages/home_page.dart'; // Import the home page
import 'package:Tripster/main_pages/profile_page.dart'; // Import the profile page

class ItineraryPlanning extends StatefulWidget {
  const ItineraryPlanning({super.key});

  @override
  _ItineraryPlanningState createState() => _ItineraryPlanningState();
}

class _ItineraryPlanningState extends State<ItineraryPlanning> {
  DateTime? _selectedDay; // Define _selectedDay as nullable DateTime
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedStartDay; // Define _selectedStartDay as nullable DateTime
  DateTime? _selectedEndDay; // Define _selectedEndDay as nullable DateTime

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
          title: const Text(
            'Itinerary Planning',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          centerTitle: true,
          // Add any actions if needed
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Select Your Start Date'),
              _buildCalendarWidget(), // Add the calendar widget here
              const SizedBox(height: 20.0),
              _buildSectionTitle('Suggested Tourist Spots'),
              _buildSuggestedTouristSpots(),
              const SizedBox(height: 20.0),
              _buildSectionTitle('Drag the places you want to visit here'),
              _buildDragAndDropSection(),
              const SizedBox(height: 20.0),
              _buildSpotDetails(),
              const SizedBox(height: 20.0),
              _buildTimelineOverview(),
              const SizedBox(height: 20.0),
              _buildGenerateItineraryButton(),
              const SizedBox(height: 20.0),
              _buildEditingOptions(),
              const SizedBox(height: 20.0),
              _buildSaveAndShare(),
              const SizedBox(height: 20.0),
              _buildMapIntegration(),
              const SizedBox(height: 20.0),
              _buildWeatherInformation(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20.0),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
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
            // Stay on current page
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

  // Widget implementations for various features

  Widget _buildCalendarWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TableCalendar(
        // Define calendar range and initial focused day
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,

        // Define calendar format and callback for format change
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },

        // Define selection properties and callback methods
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        rangeStartDay: _selectedStartDay,
        rangeEndDay: _selectedEndDay,
        rangeSelectionMode: RangeSelectionMode.toggledOn,
        onDaySelected: (selectedDay, focusedDay) {
          if (selectedDay.isBefore(DateTime.now())) {
            // Ignore selection or show an error message
            return;
          }
          // Existing logic for selecting start and end dates
          // ...
        },
        onRangeSelected: (start, end, focusedDay) {
          if (start != null && start.isBefore(DateTime.now())) {
            // Ignore selection or show an error message
            return;
          }
          setState(() {
            _selectedStartDay = start;
            _selectedEndDay = end;
            _focusedDay = focusedDay;
          });
        },

        // Other properties and callback methods can be added here
      ),
    );
  }

  Widget _buildSuggestedTouristSpots() {
    return SizedBox(
      height:
          300, // Set a fixed height or use MediaQuery to calculate dynamically
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            height: 240.0, // Fixed height for the ListView
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: touristSpots.length,
              itemBuilder: (context, index) {
                return DraggableTouristSpot(
                  spot: touristSpots[index],
                  onDragCompleted: () {
                    // Handle what happens after a card is dragged
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragAndDropSection() {
    return DragTarget<TouristSpot>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) {
        // Handle the accepted data (TouristSpot)
        // You can add it to a list or perform other actions
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 200.0,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.Grey),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Center(
            child: Text(
              'Drag Here',
              style: TextStyle(color: AppColors.Grey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpotDetails() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spot Details',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        SizedBox(height: 10.0),
        // Implement the spot details panel here
        Text('Implement spot details panel here'),
      ],
    );
  }

  Widget _buildTimelineOverview() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline Overview',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        SizedBox(height: 10.0),
        // Implement the timeline overview here
        Text('Implement timeline overview here'),
      ],
    );
  }

  Widget _buildGenerateItineraryButton() {
    return ElevatedButton(
      onPressed: () {
        // Implement generate itinerary functionality
      },
      child: const Text(
        'Generate Itinerary',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }

  Widget _buildEditingOptions() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editing Options',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        SizedBox(height: 10.0),
        // Implement the editing options here
        Text('Implement editing options here'),
      ],
    );
  }

  Widget _buildSaveAndShare() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Save and Share',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        SizedBox(height: 10.0),
        // Implement the save and share options here
        Text('Implement save and share options here'),
      ],
    );
  }

  Widget _buildMapIntegration() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Map Integration',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        SizedBox(height: 10.0),
        // Implement the map integration here
        Text('Implement map integration here'),
      ],
    );
  }

  Widget _buildWeatherInformation() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weather Information',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        SizedBox(height: 10.0),
        // Implement the weather information here
        Text('Implement weather information here'),
      ],
    );
  }
}

// Define a class for draggable tourist spot cards
class DraggableTouristSpot extends StatelessWidget {
  final TouristSpot spot;
  final VoidCallback onDragCompleted;

  const DraggableTouristSpot(
      {super.key, required this.spot, required this.onDragCompleted});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<TouristSpot>(
      data: spot,
      feedback: Material(
        elevation: 4.0,
        child: _buildTouristSpotCard(spot),
      ),
      onDragCompleted: onDragCompleted,
      child: _buildTouristSpotCard(spot),
    );
  }
}

Widget _buildTouristSpotCard(TouristSpot spot) {
  return Container(
    width: 160.0,
    padding: const EdgeInsets.all(10.0),
    margin: const EdgeInsets.only(
        top: 10.0,
        bottom: 10.0,
        left: 8.0,
        right: 8.0), // Added top and bottom margins
    decoration: BoxDecoration(
      color: AppColors.White,
      borderRadius: BorderRadius.circular(15.0),
      boxShadow: [
        BoxShadow(
          color: AppColors.Grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset(
              spot.imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          spot.name,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          spot.description,
          style: TextStyle(
            fontSize: 14.0,
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.grey[600],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class TouristSpot {
  final String name;
  final String description;
  final String imagePath;

  TouristSpot({
    required this.name,
    required this.description,
    required this.imagePath,
  });
}

// Create a list of tourist spots
final List<TouristSpot> touristSpots = [
  TouristSpot(
    name: 'Statue of Liberty',
    description: 'Iconic American landmark located in New York City.',
    imagePath: 'assets/images/newyork.png',
  ),
  TouristSpot(
    name: 'Eiffel Tower',
    description: 'Iconic iron lattice tower located in Paris, France.',
    imagePath: 'assets/images/paris.png',
  ),
  TouristSpot(
    name: 'Eiffel Tower',
    description: 'Iconic iron lattice tower located in Paris, France.',
    imagePath: 'assets/images/london.png',
  ),
  TouristSpot(
    name: 'Eiffel Tower',
    description: 'Iconic iron lattice tower located in Paris, France.',
    imagePath: 'assets/images/rome.png',
  ),
];
