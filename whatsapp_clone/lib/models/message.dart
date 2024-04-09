
import 'dart:io';

class Message {
  String chatroomId;
  String messageId;
  String author;
  String screenName;
  String content;
  Map<String, String>? mediaUrls;
  File? file;
  bool preview;
  int sendingDate;
  MessageStatus status;
  bool systemMessage;

  Message({
    required this.chatroomId,
    required this.messageId,
    required this.author,
    required this.screenName,
    required this.content,
    required this.mediaUrls,
    required this.preview,
    required this.sendingDate,
    required this.status,
    required this.systemMessage,
  });

}

enum MessageStatus { NOT_SENT, SENT, DELIVERED, READ }
