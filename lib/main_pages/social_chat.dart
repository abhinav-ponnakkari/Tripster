import 'package:Tripster/recommendation_system/preference_screen.dart';
import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:Tripster/sub_pages/chat_page.dart';
import 'package:Tripster/codes/Itinerary_planning.dart';
import 'package:Tripster/main_pages/profile_page.dart';
import 'package:Tripster/main_pages/home_page.dart';
import 'package:Tripster/providers/user_provider.dart'; // Import UserProvider

class SocialChat extends StatefulWidget {
  final BuildContext? parentContext; // Add this line

  const SocialChat({Key? key, this.parentContext})
      : super(key: key); // Modify constructor

  @override
  _SocialChatState createState() => _SocialChatState();
}

class _SocialChatState extends State<SocialChat> {
  bool _isSearching = false;
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');

  final UserProvider _userProvider =
      UserProvider(); // Create instance of UserProvider

  @override
  void initState() {
    super.initState();
    _userProvider
        .fetchAllUsers(); // Fetch all users when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
          (route) => false,
        );
        return false;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching ? _buildSearchField() : _buildTitle(),
            centerTitle: true,
            actions: _buildAppBarActions(),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Friends'),
                Tab(text: 'Guides'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildFriendsSection(),
              _buildGuideSection(),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Chat',
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
      ),
    );
  }

  Widget _buildSearchField() {
    return ValueListenableBuilder<String>(
      valueListenable: _searchQueryNotifier,
      builder: (context, value, child) {
        return TextField(
          onChanged: (newValue) {
            _searchQueryNotifier.value = newValue;
          },
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
            color: AppColors.Black,
          ),
        );
      },
    );
  }

  List<Widget> _buildAppBarActions() {
    return _isSearching
        ? [
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQueryNotifier.value = ''; // Clear the search query
                  _userProvider.fetchAllUsers(); // Reset user list
                });
              },
            ),
          ]
        : [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                  _searchQueryNotifier.value = ''; // Clear the search query
                });
              },
            ),
          ];
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      selectedItemColor: AppColors.textColor,
      unselectedItemColor: AppColors.secondaryTextColor,
      onTap: (index) {
        switch (index) {
          case 0:
            _navigateTo(context, const MyHomePage());
            break;
          case 1:
            _navigateTo(context, const ItineraryPlanning());
            break;
          case 2:
            _navigateTo(context, PreferenceScreen());
            break;
          case 4:
            _navigateTo(context, const ProfilePage());
            break;
          default:
            _navigateTo(context, const MyHomePage());
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

  Widget _buildFriendsSection() {
    return ValueListenableBuilder<String>(
      valueListenable: _searchQueryNotifier,
      builder: (context, searchQuery, child) {
        return StreamBuilder<List<User>>(
          stream: _userProvider.usersStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final users = snapshot.data!;
              final currentUsername = _userProvider.username ?? '';

              // Filter out the current user and based on search query
              final filteredUsers = users
                  .where((user) =>
                      user.username !=
                          currentUsername && // <-- Add this condition
                      user.username
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                  .toList();

              return ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 22.0,
                      backgroundImage: user.profileImageUrl.isNotEmpty
                          ? NetworkImage(user.profileImageUrl)
                          : const AssetImage('assets/images/profile.png')
                              as ImageProvider<Object>,
                    ),
                    title: Text(user.username),
                    onTap: () async {
                      // Fetch user data
                      await _userProvider.fetchUserData(user.userId);

                      // Navigate to ChatPage with user data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            username: _userProvider.username ?? '',
                            profileImageUrl:
                                _userProvider.profileImageUrl ?? '',
                            bio: _userProvider.bio ?? '',
                            location: _userProvider.location ?? '',
                            recipientId: '',
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  Widget _buildGuideSection() {
    // Implement Guide section UI here
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildGuideProfile(
          name: 'John Doe',
          age: 30,
          gender: 'Male',
          rating: 4.5,
          reviews: 20,
          ratingDistribution: {
            '5 Stars': 15,
            '4 Stars': 5,
            '3 Stars': 0,
            '2 Stars': 0,
            '1 Star': 0
          },
        ),
        _buildGuideProfile(
          name: 'John Doe',
          age: 30,
          gender: 'Male',
          rating: 4.5,
          reviews: 20,
          ratingDistribution: {
            '5 Stars': 15,
            '4 Stars': 5,
            '3 Stars': 0,
            '2 Stars': 0,
            '1 Star': 0
          },
        ),
      ],
    );
  }

  Widget _buildGuideProfile({
    required String name,
    required int age,
    required String gender,
    required double rating,
    required int reviews,
    required Map<String, int> ratingDistribution,
  }) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 32.0,
                      backgroundImage: AssetImage('assets/images/profile.png'),
                    ),
                    const SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 16.0,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20.0),
                            const SizedBox(width: 5.0),
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(width: 2.0),
                            Text(
                              '(${reviews.toString()} reviews)',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const Row(
                  children: [
                    // Add buttons here
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              'Age: $age',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 5.0),
            Text(
              'Gender: $gender',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w100,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Ratings:',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 5.0),
            _buildRatingDistributionChart(ratingDistribution),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 150.0,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatPage(
                                  username: '',
                                  bio: '',
                                  location: '',
                                  profileImageUrl: '',
                                  recipientId: '',
                                )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A80E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Message',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: AppColors.White,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 150.0,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle book functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8EEF2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Book',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: AppColors.Black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistributionChart(Map<String, int> ratingDistribution) {
    int maxRating = ratingDistribution.values
        .reduce((value, element) => value > element ? value : element);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ratingDistribution.entries.map((entry) {
        double widthFactor = entry.value / maxRating;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12.0,
                ),
              ),
              const SizedBox(width: 5.0),
              Expanded(
                child: Container(
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widthFactor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }
}
