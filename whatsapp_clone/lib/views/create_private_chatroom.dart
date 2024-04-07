import 'package:flutter/material.dart';
import 'package:whatsapp_clone/data/all_users.dart';
import 'package:whatsapp_clone/models/user.dart';
import 'package:whatsapp_clone/views/chat.dart';

class CreatePrivateChatroomPage extends StatefulWidget {
  final User currentUser;

  const CreatePrivateChatroomPage({
    super.key,
    required this.currentUser,
  });

  @override
  _CreatePrivateChatroomPageState createState() => _CreatePrivateChatroomPageState();
}

class _CreatePrivateChatroomPageState extends State<CreatePrivateChatroomPage> {
  User? selectedUser;
  String title = '';

  @override
  Widget build(BuildContext context) {
    // Filter out the current user from the user list
    List<User> otherUsers = allUsers.where((user) => user.userId != widget.currentUser.userId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create 1-to-1 chatroom'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<User>(
              hint: Text("Select user"),
              value: selectedUser,
              onChanged: (User? newValue) {
                setState(() {
                  selectedUser = newValue;
                });
              },
              items: otherUsers.map((User user) {
                return DropdownMenuItem<User>(
                  value: user,
                  child: Text(user.screenName), // Assuming 'name' is a field in your User class
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedUser != null && title.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        self: widget.currentUser,
                        other: selectedUser!,
                        otherUserScreenName: selectedUser!.screenName, // Adjust based on your User model
                      ),
                    ),
                  );
                } else {
                  // Handle the error case, maybe show a dialog or a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a user and enter a title.'),
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}