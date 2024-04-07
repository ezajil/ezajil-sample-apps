import 'package:whatsapp_clone/models/user.dart';

import 'message.dart';

class RecentChat {
  final Message message;
  final User user;
  int unreadCount;

  RecentChat({
    required this.message,
    required this.user,
    this.unreadCount = 0,
  });
}