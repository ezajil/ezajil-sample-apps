import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/theme/theme.dart';
import 'package:whatsapp_clone/views/chat.dart';

import '../models/message.dart';
import '../models/recent_chat.dart';
import '../models/user.dart';
import '../theme/color_theme.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Widget> _floatingButtons;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabIndexChange);

    _floatingButtons = [
      FloatingActionButton(
        onPressed: () {
          // Implement your action
        },
        child: const Icon(Icons.chat),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Implement your action
            },
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 16.0),
          FloatingActionButton(
            onPressed: () {
              // Implement your action
            },
            child: const Icon(Icons.camera_alt_rounded),
          ),
        ],
      ),
      FloatingActionButton(
        onPressed: () {
          // Implement your action
        },
        child: const Icon(Icons.add_call),
      ),
    ];
  }

  void _handleTabIndexChange() {
    if (!mounted) return;
    setState(() {
      // This will trigger a rebuild when the tab index changes
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndexChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whatsapp'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'CHATS'),
            Tab(text: 'STATUS'),
            Tab(text: 'CALLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [
          RecentChatsBody(user: widget.user),
          const Center(child: Text('Coming soon')),
          const Center(child: Text('Coming soon')),
        ],
      ),
      floatingActionButton: _floatingButtons[_tabController.index],
    );
  }
}

class RecentChatsBody extends StatefulWidget {
  final User user;

  const RecentChatsBody({Key? key, required this.user}) : super(key: key);

  @override
  _RecentChatsBodyState createState() => _RecentChatsBodyState();
}

class _RecentChatsBodyState extends State<RecentChatsBody> {
  List<RecentChat> chats = []; // Assuming RecentChat is defined elsewhere

  @override
  void initState() {
    super.initState();
    // Initialize your chats here, could be from a local source or dummy data
    chats =
        []; // TODO: This should be replaced with actual data retrieval logic
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme; // Custom theming

    // if (chats.isEmpty) {
    //   return const HomePageContactsList(); // Replace with actual empty state widget
    // }
    chats.add(RecentChat(
        message: Message(
            chatroomId: 'chatid',
            messageId: 'messageid',
            author: '2',
            screenName: 'ezajil2',
            content: 'tezst',
            mediaUrls: null,
            preview: false,
            sendingDate: 1712510485958000000,
            status: MessageStatus.READ,
            systemMessage: false),
        user: widget.user));
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ListView.builder(
            itemCount: chats.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              RecentChat chat = chats[index];
              Message msg =
                  chat.message; // Assuming Message is defined elsewhere
              String msgContent = chat.message.content;
              MessageStatus? msgStatus;

              if (msg.author == widget.user.userId) {
                msgStatus = msg.status;
              }

              return RecentChatWidget(
                user: widget.user,
                chat: chat,
                colorTheme: colorTheme,
                title: chat.user.screenName,
                msgStatus: msgStatus,
                msgContent: msgContent,
              );
            },
          ),
        ),
        if (chats.isNotEmpty) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: 18,
                  color: Theme.of(context).brightness == Brightness.light
                      ? colorTheme.greyColor
                      : colorTheme.iconColor,
                ),
                const SizedBox(width: 4),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall,
                    children: [
                      TextSpan(
                        text: 'Your personal messages are ',
                        style: TextStyle(color: colorTheme.greyColor),
                      ),
                      TextSpan(
                        text: 'end-to-end encrypted',
                        style: TextStyle(color: colorTheme.greenColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }
}

class RecentChatWidget extends StatelessWidget {
  const RecentChatWidget({
    super.key,
    required this.user,
    required this.chat,
    required this.colorTheme,
    required this.title,
    required this.msgStatus,
    required this.msgContent,
  });

  final User user;
  final RecentChat chat;
  final ColorTheme colorTheme;
  final String title;
  final MessageStatus? msgStatus;
  final String msgContent;

  @override
  Widget build(BuildContext context) {
    final trailingChildren = [
      RecentChatTime(chat: chat, colorTheme: colorTheme),
      if (chat.unreadCount > 0) ...[
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorTheme.greenColor,
          ),
          margin: const EdgeInsets.only(left: 4.0),
          padding: const EdgeInsets.all(6.0),
          child: Text(
            chat.unreadCount.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    ];

    return ListTile(
      onTap: () {
        chat.unreadCount = 0;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              self: user,
              other: chat.user,
              otherUserScreenName: title,
            ),
            settings: const RouteSettings(name: 'chat'),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 28.0,
        backgroundImage: NetworkImage(chat.user.avatarUrl != null
            ? chat.user.avatarUrl!
            : 'https://en.gravatar.com/userimage/238463648/8cc16f6f5423605920569a634fd097eb.jpeg?size=256'),
      ),
      title: Text(
        title,
        style: Theme.of(context)
            .custom
            .textTheme
            .titleMedium
            .copyWith(color: colorTheme.textColor1),
      ),
      subtitle: Row(
        children: [
          if (msgStatus != null) ...[
            Image.asset(
              'assets/images/$msgStatus.png',
              color: msgStatus != 'SEEN' ? colorTheme.textColor1 : null,
              width: 15.0,
            ),
            const SizedBox(
              width: 2.0,
            )
          ],
          if (chat.message.preview) ...[
            LayoutBuilder(
              builder: (context, _) {
                return const Icon(
                  Icons.file_copy,
                  size: 20,
                );
              },
            ),
            const SizedBox(
              width: 2.0,
            )
          ],
          Text(
              msgContent.length > 30
                  ? '${msgContent.substring(0, 30)}...'
                  : msgContent == "\u00A0" || msgContent.isEmpty
                      ? 'IMAGE'
                      : msgContent,
              style: Theme.of(context).custom.textTheme.subtitle2)
        ],
      ),
      trailing: chat.unreadCount > 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: trailingChildren,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: trailingChildren,
            ),
    );
  }
}

class RecentChatTime extends StatefulWidget {
  const RecentChatTime({
    super.key,
    required this.chat,
    required this.colorTheme,
  });

  final RecentChat chat;
  final ColorTheme colorTheme;

  @override
  State<RecentChatTime> createState() => _RecentChatTimeState();
}

class _RecentChatTimeState extends State<RecentChatTime> {
  late final Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String formatDate(int nanosecondsSinceEpoch,
      [bool timeOnly = false, bool meridiem = false]) {
    // Convert nanoseconds to microseconds since DateTime supports up to microseconds.
    int microsecondsSinceEpoch = nanosecondsSinceEpoch ~/ 1000;

    DateTime now = DateTime.now();
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);

    if (timeOnly || datesHaveSameDay(now, date)) {
      return meridiem
          ? DateFormat('hh:mm a').format(date)
          : DateFormat('HH:mm').format(date);
    }

    if (isYesterday(date)) {
      return 'Yesterday';
    }

    return DateFormat.yMd().format(date);
  }

  bool datesHaveSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isYesterday(DateTime date) {
    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDate(
        widget.chat.message.sendingDate,
      ),
      style: Theme.of(context).custom.textTheme.caption.copyWith(
            color: widget.chat.unreadCount > 0
                ? widget.colorTheme.greenColor
                : Theme.of(context).custom.colorTheme.greyColor,
          ),
    );
  }
}
