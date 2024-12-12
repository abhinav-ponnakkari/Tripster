import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Tripster/providers/user_provider.dart';

class ChatPage extends StatefulWidget {
  final String recipientId;
  final String username;
  final String profileImageUrl;
  final String bio;
  final String location;

  const ChatPage({
    Key? key,
    required this.recipientId,
    required this.username,
    required this.profileImageUrl,
    required this.bio,
    required this.location,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final UserProvider _userProvider = UserProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat with ${widget.username}',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuideInfo(widget.bio, widget.location),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(getChatId())
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs
                    .map((doc) => Message.fromSnapshot(doc))
                    .where((message) =>
                        message.senderId == _auth.currentUser!.uid ||
                        message.recipientId == _auth.currentUser!.uid)
                    .toList();
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSentByUser =
                        message.senderId == _auth.currentUser!.uid;
                    return _buildMessageBubble(
                      message: message.content,
                      isSentByUser: isSentByUser,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildGuideInfo(String bio, String location) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32.0,
            backgroundColor: Colors.grey[300],
            backgroundImage: NetworkImage(widget.profileImageUrl),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  bio,
                  style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.normal,
                      fontSize: 12.0,
                      color: AppColors.Grey),
                ),
                const SizedBox(height: 4.0),
                Text(
                  location,
                  style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                      color: AppColors.Grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isSentByUser,
  }) {
    return Row(
      mainAxisAlignment:
          isSentByUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isSentByUser ? Colors.blue[400] : Colors.grey[300],
            borderRadius: isSentByUser
                ? const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: isSentByUser ? AppColors.White : AppColors.Black,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInputField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                hintStyle: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  String getChatId() {
    final currentUserId = _auth.currentUser!.uid;
    final recipientId = widget.recipientId;
    final chatId = _userProvider.getChatDocId(currentUserId, recipientId);
    return chatId;
  }

  void _sendMessage() {
    final String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      final chatId = getChatId();
      _firestore.collection('chats').doc(chatId).collection('messages').add({
        'content': messageText,
        'senderId': _auth.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((value) {
        // Clear the message input field after sending
        _messageController.clear();
      }).catchError((error) {
        print('Error sending message: $error');
      });
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
