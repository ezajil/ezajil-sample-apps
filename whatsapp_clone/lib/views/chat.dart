import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/theme/theme.dart';
import 'package:whatsapp_clone/utils/utils.dart';
import 'package:whatsapp_clone/views/widgets/chat_date.dart';
import 'package:whatsapp_clone/views/widgets/message_card.dart';
import 'package:whatsapp_clone/views/widgets/scroll_btn.dart';
import 'package:whatsapp_clone/views/widgets/unread_banner.dart';

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
    // TODO: Fetch messages
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
          backgroundImage: NetworkImage(widget.other.avatarUrl ??
              'https://en.gravatar.com/userimage/238463648/8cc16f6f5423605920569a634fd097eb.jpeg?size=256'),
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
              'Online', // TODO: Replace with actual status
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
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                SystemChannels.textInput.invokeMethod("TextInput.hide");
              },
              child: Container(
                color: Colors.transparent,
                // Ensuring the GestureDetector fills the space
                child: ChatStream(self: widget.self, other: widget.other),
              ),
            ),
          ),
          const SizedBox(
            height: 4.0,
          ),
          const Text('Chat input container will go here'),
          // Replace with actual chat input widget
        ],
      ),
    );
  }
}

class ChatStream extends StatefulWidget {
  final User self;
  final User other;

  const ChatStream({
    Key? key,
    required this.self,
    required this.other,
  }) : super(key: key);

  @override
  State<ChatStream> createState() => _ChatStreamState();
}

class _ChatStreamState extends State<ChatStream> {
  late final String chatroomId;
  late final ScrollController scrollController;
  late Stream<List<Message>> messageStream;

  bool isInitialRender = true;
  int unreadCount = 0;
  int prevMsgCount = 0;
  final GlobalKey bannerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    chatroomId = 'chatroom1';
    messageStream = Stream.value([
      Message(
        chatroomId: 'hatroom1',
        messageId: 'msg1',
        author: widget.self.userId,
        screenName: widget.self.userId,
        content: 'First Message.',
        mediaUrls: null,
        preview: false,
        sendingDate: 1712673231451000000,
        status: MessageStatus.READ,
        systemMessage: false,
      ),
      Message(
        chatroomId: 'chatroom1',
        messageId: 'msg2',
        author: widget.other.userId,
        screenName: widget.other.userId,
        content: 'Second Message.',
        mediaUrls: null,
        preview: false,
        sendingDate: 1712673231455000000,
        status: MessageStatus.DELIVERED,
        systemMessage: false,
      ),
      Message(
        chatroomId: 'chatroom1',
        messageId: 'msg3',
        author: widget.self.userId,
        screenName: widget.self.userId,
        content: 'Third Message.',
        mediaUrls: null,
        preview: false,
        sendingDate: 1712673231460000000,
        status: MessageStatus.DELIVERED,
        systemMessage: false,
      ),
      // Add more messages as needed
    ]); //TODO: fetch messages of chatroom
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = customTheme.colorTheme;

    return StreamBuilder<List<Message>>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final messages = snapshot.data!;
        final unreadMsgCount = updateUnreadCount(messages);

        if (isInitialRender) {
          handleInitialData(unreadMsgCount);
        } else if (messages.length - prevMsgCount > 0) {
          handleNewMessage(messages.first);
        }

        prevMsgCount = messages.length;
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(color: Colors.transparent),
            CustomScrollView(
              shrinkWrap: true,
              reverse: true,
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                if (unreadCount > 0) ...[
                  SliverList.builder(
                    itemCount: unreadCount,
                    itemBuilder: (context, index) {
                      return buildMessageCard(index, messages);
                    },
                    findChildIndexCallback: (key) {
                      return getMessageIndexByKey(key, messages);
                    },
                  ),
                  SliverToBoxAdapter(
                    key: bannerKey,
                    child: UnreadMessagesBanner(
                      unreadCount: unreadCount,
                    ),
                  ),
                ],
                SliverList.builder(
                  itemCount: messages.length - unreadCount,
                  itemBuilder: (context, index) {
                    index = index + unreadCount;
                    return buildMessageCard(index, messages);
                  },
                  findChildIndexCallback: (key) {
                    return getMessageIndexByKey(key, messages);
                  },
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDarkTheme
                            ? const Color.fromARGB(200, 24, 34, 40)
                            : const Color.fromARGB(148, 248, 236, 130),
                      ),
                      child: Text(
                        '🔒Messages and calls are end-to-end encrypted. No one outside this chat, not even WhatsApp, can read or listen to them. Tap to learn more.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkTheme
                              ? colorTheme.yellowColor
                              : colorTheme.textColor1,
                        ),
                        softWrap: true,
                        textWidthBasis: TextWidthBasis.longestLine,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ChatDate(
                      date: messages.isEmpty
                          ? 'Today'
                          : formatSendingDate(messages.last.sendingDate),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ScrollButton(
                scrollController: scrollController,
                unreadCount: unreadCount,
              ),
            )
          ],
        );
      },
    );
  }

  Widget buildMessageCard(int index, List<Message> messages) {
    final message = messages[index];
    final isFirstMsg = index == messages.length - 1;
    final isSpecial =
        isFirstMsg || messages[index].author != messages[index + 1].author;
    final currMsgDate = formatSendingDate(messages[index].sendingDate);
    final showDate = isFirstMsg ||
        currMsgDate != formatSendingDate(messages[index + 1].sendingDate);

    return Column(
      key: ValueKey(message.messageId),
      children: [
        if (!isFirstMsg && showDate) ...[
          ChatDate(date: currMsgDate),
        ],
        VisibilityDetector(
          key: ValueKey('${message.messageId}_vd'),
          onVisibilityChanged: (info) {
            if (info.visibleFraction < 0.1) return;
            markAsRead(message);
          },
          child: MessageCard(
            self: widget.self,
            other: widget.other,
            message: message,
            currentUserId: widget.self.userId,
            special: isSpecial,
          ),
        ),
      ],
    );
  }

  void handleInitialData(int unreadMsgCount) {
    isInitialRender = false;
    unreadCount = unreadMsgCount;

    if (unreadCount > 0) {
      scrollToUnreadBanner();
    }
  }

  void handleNewMessage(Message message) {
    if (message.author == widget.self.userId) {
      unreadCount = 0;
      if (message.status == MessageStatus.NOT_SENT) {
        scrollToBottom();
      }
    } else {
      unreadCount = unreadCount > 0 ? unreadCount + 1 : 0;
    }
  }

  int updateUnreadCount(List<Message> messages) {
    int unreadCount = 0;

    for (final message in messages) {
      if (message.author == widget.self.userId) break;
      if (message.status == MessageStatus.READ) break;
      unreadCount++;
    }
    return unreadCount;
  }

  void scrollToUnreadBanner() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Scrollable.ensureVisible(
        bannerKey.currentContext!,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void markAsRead(Message message) {
    if (message.author == widget.self.userId) return;
    if (message.status == MessageStatus.READ) return;
    //TODO mark as READ
  }

  int getMessageIndexByKey(Key key, List<Message> messages) {
    final messageKey = key as ValueKey;
    return messages.indexWhere((msg) => msg.messageId == messageKey.value);
  }
}
