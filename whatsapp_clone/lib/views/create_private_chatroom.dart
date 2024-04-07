import 'package:flutter/material.dart';
import 'package:whatsapp_clone/data/all_users.dart';
import 'package:whatsapp_clone/models/user.dart';
import 'package:whatsapp_clone/theme/theme.dart';
import 'package:whatsapp_clone/views/chat.dart';

class CreatePrivateChatroomPage extends StatefulWidget {
  final User currentUser;

  const CreatePrivateChatroomPage({
    super.key,
    required this.currentUser,
  });

  @override
  _CreatePrivateChatroomPageState createState() =>
      _CreatePrivateChatroomPageState();
}

class _CreatePrivateChatroomPageState extends State<CreatePrivateChatroomPage> {
  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    List<User> otherUsers = allUsers
        .where((user) => user.userId != widget.currentUser.userId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Contact'),
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorTheme.greenColor,
                    child: const Icon(
                      Icons.people,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 18.0,
                  ),
                  Text(
                    'New group',
                    style: Theme.of(context).custom.textTheme.bold,
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: otherUsers.length,
              itemBuilder: (context, index) {
                User user = otherUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl != null
                        ? user.avatarUrl!
                        : 'https://en.gravatar.com/userimage/238463648/8cc16f6f5423605920569a634fd097eb.jpeg?size=256'),
                    // Replace with your image provider
                    backgroundColor: Colors.grey, // Fallback color
                  ),
                  title: Text(user.screenName),
                  // Assuming 'name' is a field in your User class
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          self: widget.currentUser,
                          other: user,
                          otherUserScreenName: user.screenName, // Adjust based on your User model
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
