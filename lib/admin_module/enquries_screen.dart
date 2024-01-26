import 'package:flutter/material.dart';

// Model class for representing a chat
class Chat {
  final String name;
  final String lastMessage;
  final DateTime timestamp;

  Chat({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
  });
}

class EnquiriesScreen extends StatelessWidget {
  // Dummy data for the chat list
  final List<Chat> chatList = [
    Chat(
      name: "Bruce",
      lastMessage: "I am interested in any upcoming events",
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
    ),
    Chat(
      name: "Jane Smith",
      lastMessage: "How are you?",
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
    ),
    Chat(
      name: "Aifa",
      lastMessage: "I have problem regarding",
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
    ),
    Chat(
      name: "Nujel Nigs",
      lastMessage: "Hello I am unable to..",
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
    ),
    Chat(
      name: "Akshaya",
      lastMessage: "Can you please provide",
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
    ),
    Chat(
      name: "Sanju Samson",
      lastMessage: "Hi",
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
    ),
    // Add more chats as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(' ENQUIRIES'),
      ),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          // Build individual chat item
          final chat = chatList[index];
          return ListTile(
            leading: CircleAvatar(
              // You can add profile pictures here
              child: Text(chat.name[0]),
            ),
            title: Text(chat.name),
            subtitle: Text(chat.lastMessage),
            trailing: Text(
              // Format the timestamp as needed
              "${chat.timestamp.hour}:${chat.timestamp.minute}",
            ),
            onTap: () {
              // Handle tap on the chat item
              // You can navigate to the chat screen or do other actions
              print("Tapped on ${chat.name}'s chat");
            },
          );
        },
      ),
    );
  }
}
