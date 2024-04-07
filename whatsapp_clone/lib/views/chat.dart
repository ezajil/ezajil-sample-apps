
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user.dart';

class ChatPage extends StatefulWidget {
  final User self;
  final User other;
  final String otherUserScreenName;

  const ChatPage({
    Key? key,
    required this.self,
    required this.other,
    required this.otherUserScreenName,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    // Initialize any necessary data or states here
  }

  @override
  Widget build(BuildContext context) {
    // Simplified build method without Provider or Firebase logic
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: _buildAppBarTitle(context),
        leadingWidth: 36.0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, size: 24),
        ),
        actions: _buildAppBarActions(),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    // User's avatar and name in the AppBar
    return Row(
      children: [
        CircleAvatar(
          maxRadius: 18,
          backgroundImage: NetworkImage(widget.other.avatarUrl ?? 'https://en.gravatar.com/userimage/238463648/8cc16f6f5423605920569a634fd097eb.jpeg?size=256'),
        ),
        const SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserScreenName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            // Placeholder for user activity status
            Text(
              'Online', // Replace with actual status
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    // App bar actions like video call, call, and more options
    return [
      IconButton(
        onPressed: () {}, // Define functionality
        icon: const Icon(Icons.videocam_rounded, size: 28),
      ),
      IconButton(
        onPressed: () {}, // Define functionality
        icon: const Icon(Icons.call, size: 24),
      ),
      IconButton(
        onPressed: () {}, // Define functionality
        icon: const Icon(Icons.more_vert, size: 26),
      ),
    ];
  }

  Widget _buildBody(BuildContext context) {
    // Main chat page body
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/chat_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                SystemChannels.textInput.invokeMethod("TextInput.hide");
              },
              child: const Text('Chat messages will appear here'), // Replace with actual chat messages widget
            ),
          ),
          const SizedBox(
            height: 4.0,
          ),
          const Text('Chat input container will go here'), // Replace with actual chat input widget
        ],
      ),
    );
  }
}
