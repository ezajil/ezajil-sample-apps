import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/features/chat/models/attachement.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/features/chat/models/recent_chat.dart';
import 'package:whatsapp_clone/features/chat/views/chat.dart';
import 'package:whatsapp_clone/shared/data/all_users.dart';
import 'package:whatsapp_clone/features/home/views/contacts.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/theme/theme.dart';
import '../../../theme/color_theme.dart';

class HomePage extends ConsumerStatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final StreamSubscription<List<Message>> messageListener;
  late TabController _tabController;
  late List<Widget> _floatingButtons;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        // TODO connect session
        break;
      default:
        // TODO disconnect session
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    // TODO: Create and connect session

    // messageListener = firestore.getChatStream(widget.user.userId).listen(
    //   (messages) async {
    //     for (final message in messages) {
    //       message.status = MessageStatus.delivered;
    //       firestore.sendSystemMessage(
    //         message: SystemMessage(
    //           targetId: message.messageId,
    //           action: MessageAction.statusUpdate,
    //           update: MessageStatus.delivered.value,
    //         ),
    //         receiverId: message.author,
    //       );
    //
    //       if (message.attachment != null && message.attachment!.autoDownload) {
    //         DownloadService.download(
    //           taskId: message.messageId,
    //           url: message.attachment!.url,
    //           path: DeviceStorage.getMediaFilePath(
    //             message.attachment!.fileName,
    //           ),
    //           onDownloadComplete: (_) {},
    //           onDownloadError: () {},
    //         );
    //       }
    //     }
    //
    //     IsarDb.addMessages(messages);
    //   },
    // );

    // ref.read(pushNotificationsRepoProvider).init(
    //   onMessageOpenedApp: (message) async {
    //     await handleNotificationClick(message);
    //   },
    // );

    // WidgetsBinding.instance.addObserver(this);
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   final message = await FirebaseMessaging.instance.getInitialMessage();
    //   if (message == null) return;
    //
    //   await handleNotificationClick(message);
    // });

    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(handleTabIndexChange);

    _floatingButtons = [
      FloatingActionButton(
        onPressed: () async {
          if (!await hasPermission(Permission.contacts)) return;
          if (!mounted) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ContactsPage(
                user: widget.user,
              ),
            ),
          );
        },
        child: const Icon(Icons.chat),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: AppColorsDark.appBarColor,
            onPressed: () {},
            child: const Icon(Icons.edit),
          ),
          const SizedBox(
            height: 16.0,
          ),
          FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.camera_alt_rounded),
          ),
        ],
      ),
      FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_call),
      )
    ];

    super.initState();
  }

  @override
  void dispose() {
    _tabController.removeListener(handleTabIndexChange);
    _tabController.dispose();
    messageListener.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void handleTabIndexChange() {
    setState(() {});
  }

  // Future<void> handleNotificationClick(RemoteMessage message) async {
  //   final author = await ref
  //       .read(firebaseFirestoreRepositoryProvider)
  //       .getUserById(message.data['authorId']);
  //
  //   final contact = await ref
  //       .read(contactsRepositoryProvider)
  //       .getContactByPhone(author!.phone.number!);
  //
  //   if (!mounted) return;
  //   Navigator.of(context).pushAndRemoveUntil(
  //     MaterialPageRoute(
  //       builder: (context) => ChatPage(
  //         self: widget.user,
  //         other: author,
  //         otherUserContactName:
  //             contact?.displayName ?? author.phone.getFormattedNumber(),
  //       ),
  //     ),
  //     (route) => route.settings.name == "/",
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).custom.textTheme;
    final colorTheme = Theme.of(context).custom.colorTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'WhatsApp',
            style: textTheme.titleLarge.copyWith(color: colorTheme.iconColor),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.camera_alt_outlined,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert,
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelStyle: textTheme.labelLarge,
            tabs: const [
              Tab(
                text: 'CHATS',
              ),
              Tab(
                text: 'STATUS',
              ),
              Tab(
                text: 'CALLS',
              ),
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
            const Center(
              child: Text('Coming soon'),
            ),
            const Center(
              child: Text('Coming soon'),
            )
          ],
        ),
        floatingActionButton: _floatingButtons[_tabController.index],
      ),
    );
  }
}

class RecentChatsBody extends ConsumerWidget {
  const RecentChatsBody({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    final chats = [];
    chats.add(RecentChat(
        message: Message(
            chatroomId: 'chatid',
            messageId: 'messageid',
            author: '1',
            screenName: 'ezajil1',
            content: 'tezst',
            mediaUrls: null,
            preview: false,
            sendingDate: 1712510485958000000,
            status: MessageStatus.read,
            systemMessage: false),
        user: User(
            userId: '2',
            screenName:
                'ezajil2'))); // TODO: Update with other user not current one
    if (chats.isEmpty) {
      return const HomePageContactsList();
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ListView.builder(
            itemCount: chats.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              RecentChat chat = chats[index];
              Message msg = chat.message;
              String msgContent = chat.message.content;
              String msgStatus = '';

              if (msg.author == user.userId) {
                msgStatus = msg.status.value;
              }
              return RecentChatWidget(
                user: user,
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

class HomePageContactsList extends StatelessWidget {
  const HomePageContactsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Builder(
      builder: (context) {
        final userCount = allUsers.length;
        if (userCount < 2) return Container();

        int avatarDisplayCount;
        if (userCount > 4) {
          avatarDisplayCount = 5;
        } else {
          avatarDisplayCount = userCount;
        }

        final descriptionList = <String>['', ''];
        if (userCount > 3) {
          descriptionList[0] = allUsers.getRange(0, 3).join(', ');
          descriptionList[1] =
              ' and ${userCount - 3} more of your contacts\n are on WhatsApp';
        } else if (userCount > 2) {
          descriptionList[0] = allUsers.getRange(0, 2).join(', ');
          descriptionList[1] = ' and ${allUsers[2]} are on WhatsApp';
        } else if (userCount > 1) {
          descriptionList[0] = allUsers.join(' and ');
          descriptionList[1] = ' are on WhatsApp';
        } else {
          descriptionList[0] = '${allUsers.first}';
          descriptionList[1] = ' is one WhatsApp.';
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 55,
              width: (avatarDisplayCount * 36) + 30,
              child: Stack(
                children: [
                  for (var i = 0; i < avatarDisplayCount; i++) ...[
                    Positioned(
                      right: (i * 36),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            width: 2,
                            color: AppColorsDark.backgroundColor,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: allUsers[i].avatarUrl != null
                              ? CachedNetworkImageProvider(
                                  allUsers[i].avatarUrl!,
                                )
                              : const AssetImage('assets/images/avatar.png')
                                  as ImageProvider,
                        ),
                      ),
                    )
                  ],
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: descriptionList[0],
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colorTheme.unselectedLabelColor
                      : colorTheme.textColor1,
                ),
                children: [
                  TextSpan(
                    text: descriptionList[1],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ],
        );
      },
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
  final String msgStatus;
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
              otherUserContactName: title,
            ),
            settings: const RouteSettings(name: 'chat'),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 28.0,
        backgroundImage: CachedNetworkImageProvider(
          chat.user.avatarUrl ??
              'https://en.gravatar.com/userimage/238463648/8cc16f6f5423605920569a634fd097eb.jpeg?size=256',
        ),
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
          if (msgStatus.isNotEmpty) ...[
            Image.asset(
              'assets/images/$msgStatus.png',
              color: msgStatus != 'READ' ? colorTheme.textColor1 : null,
              width: 15.0,
            ),
            const SizedBox(
              width: 2.0,
            )
          ],
          if (chat.message.attachment != null) ...[
            LayoutBuilder(
              builder: (context, _) {
                switch (chat.message.attachment!.type) {
                  case AttachmentType.audio:
                    return const Icon(
                      Icons.audiotrack_rounded,
                      size: 20,
                    );

                  case AttachmentType.voice:
                    return const Icon(
                      Icons.mic,
                      size: 20,
                    );

                  case AttachmentType.image:
                    return const Icon(
                      Icons.image_rounded,
                      size: 20,
                    );

                  case AttachmentType.video:
                    return const Icon(
                      Icons.videocam_rounded,
                      size: 20,
                    );

                  default:
                    return const Icon(
                      Icons.file_copy,
                      size: 20,
                    );
                }
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
                      ? chat.message.attachment!.type.value
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

  @override
  Widget build(BuildContext context) {
    return Text(
      formattedTimestamp(
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
