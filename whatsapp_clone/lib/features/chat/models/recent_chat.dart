import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/models/user.dart';

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
