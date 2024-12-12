import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class User {
  final String username;
  final String userId;
  final String profileImageUrl;

  User({
    required this.username,
    required this.userId,
    required this.profileImageUrl,
  });
}

class UserProvider extends ChangeNotifier {
  String? _name;
  String? _email;
  String? _username; // Use this field for the user's username
  String? _phone;
  String? _dob;
  String? _gender;
  String? _bio;
  String? _interests;
  String? _location;
  String? _errorMessage;

  String? get name => _name;
  String? get email => _email;
  String? get username =>
      _username; // Expose this field for accessing the user's username
  String? get phone => _phone;
  String? get dob => _dob;
  String? get gender => _gender;
  String? get bio => _bio;
  String? get interests => _interests;
  String? get location => _location;
  String? get errorMessage => _errorMessage;

  String? _profileImageUrl;

  String? get profileImageUrl => _profileImageUrl;

  bool get isLoggedIn =>
      firebase_auth.FirebaseAuth.instance.currentUser !=
      null; // Check if email is not null

  String getChatDocId(String senderId, String recipientId) {
    // Sort the user IDs to ensure consistency regardless of who initiates the chat
    final chatUsers = [senderId, recipientId];
    chatUsers.sort();

    // Join the sorted user IDs with an underscore to create a unique chat ID
    final chatId = chatUsers.join('_');
    return chatId;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<User> _users = [];

  Stream<List<User>> get usersStream =>
      _firestore.collection('users').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final userData = doc.data();
          return User(
            username: userData['username'], // Use the correct key for username
            userId: doc.id,
            profileImageUrl: userData['profileImageUrl'] ?? '',
          );
        }).toList();
      });

  User getUserFromSnapshot(DocumentSnapshot doc) {
    final userData = doc.data() as Map<String, dynamic>;
    return User(
      username: userData['username'],
      userId: doc.id,
      profileImageUrl: userData['profileImageUrl'] ?? '',
    );
  }

  Future<void> fetchAllUsers() async {
    try {
      final usersQuerySnapshot = await _firestore.collection('users').get();
      _users = usersQuerySnapshot.docs.map((doc) {
        final userData = doc.data();
        return User(
          username: userData['username'], // Use the correct key for username
          userId: doc.id,
          profileImageUrl: userData['profileImageUrl'] ?? '',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  List<User> filterUsers(String query) {
    final filteredUsers = _users
        .where(
            (user) => user.username.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return filteredUsers;
  }

  void setUser(String name, String email, String username) {
    _name = name; // Set the _name property
    _email = email;
    _username = username; // Set the _username property with the username
    notifyListeners();
  }

  Future<void> updateProfileImageUrl(String imageUrl) async {
    _profileImageUrl = imageUrl;
    notifyListeners();

    try {
      // Update profile image URL in Firestore
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profileImageUrl': imageUrl});
    } catch (e) {
      print('Error updating profile image URL: $e');
    }
  }

  // Send a message to a specific user
  Future<void> sendMessage(String recipientId, String messageContent) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated.');
      }

      final senderId = currentUser.uid;
      final timestamp = Timestamp.now();

      // Create a new chat document for the sender and recipient
      final chatDocId = getChatDocId(senderId, recipientId);

      // Save the message to both sender's and recipient's chat histories
      await _firestore
          .collection('chats')
          .doc(chatDocId)
          .collection('messages')
          .add({
        'content': messageContent,
        'senderId': senderId,
        'recipientId': recipientId,
        'timestamp': timestamp,
      });

      notifyListeners();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Stream<List<Message>> getMessages(String recipientId) {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated.');
      }

      final senderId = currentUser.uid;
      final chatDocId = getChatDocId(senderId, recipientId);

      return _firestore
          .collection('chats')
          .doc(chatDocId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Message.fromSnapshot(doc)).toList());
    } catch (e) {
      print('Error getting messages: $e');
      return Stream.value([]);
    }
  }

  Future<String?> getLastMessageTime(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chats')
          .where('senderId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final lastMessage = querySnapshot.docs.first;
        final timestamp = lastMessage['timestamp'] as Timestamp;
        final lastMessageTime = timestamp.toDate();

        // Format the last message time as desired (e.g., 'HH:mm')
        final formattedTime = DateFormat.Hm().format(
            lastMessageTime); // Requires import 'package:intl/intl.dart'

        return formattedTime;
      }
    } catch (e) {
      print('Error getting last message time: $e');
    }
    return null; // Return null if no messages or error
  }

  Future<void> fetchUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        _name = userData?['name'];
        _email = userData?['email'];
        _username = userData?['username'];
        _phone = userData?['phone'];
        _dob = userData?['dob'];
        _gender = userData?['gender'];
        _bio = userData?['bio'];
        _interests = userData?['interests'];
        _location = userData?['location'];
        _profileImageUrl =
            userData?['profileImageUrl']; // Fetch profile image URL
        _errorMessage = null;
        notifyListeners();
      } else {
        _errorMessage = 'User data not found';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error fetching user data: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }

  Future<void> updateUserData(
      String userId, Map<String, dynamic> newData) async {
    try {
      await _firestore.collection('users').doc(userId).update(newData);

      // Update the corresponding fields in the UserProvider
      _phone = newData['phone'];
      _dob = newData['dob'];
      _gender = newData['gender'];
      _bio = newData['bio'];
      _interests = newData['interests'];
      _location = newData['location'];
      _username = newData['username']; // Update the _username property

      _errorMessage = null;
      await fetchUserData(userId); // Call fetchUserData to update the UI
      notifyListeners(); // Notify listeners about the data changes
    } catch (e) {
      _errorMessage = 'Error updating user data: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }
}

class Message {
  final String content;
  final String senderId;
  final String recipientId; // Ensure this is non-nullable
  final Timestamp timestamp;

  Message({
    required this.content,
    required this.senderId,
    required this.recipientId, // Ensure this is non-nullable
    required this.timestamp,
  });

  factory Message.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      content: data['content'] ?? '', // Provide a default value if null
      senderId: data['senderId'] ?? '', // Provide a default value if null
      recipientId: data['recipientId'] ?? '', // Provide a default value if null
      timestamp: data['timestamp'] ??
          Timestamp.now(), // Provide a default value if null
    );
  }
}
