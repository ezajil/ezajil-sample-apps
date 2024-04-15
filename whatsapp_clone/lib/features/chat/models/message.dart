import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_clone/features/chat/models/attachement.dart';

enum MessageStatus {
  notSent('NOT_SENT'),
  sent('SENT'),
  delivered('DELIVERED'),
  read('READ');

  const MessageStatus(this.value);
  final String value;

  factory MessageStatus.fromValue(String value) {
    final res = MessageStatus.values.where(
      (element) => element.value == value,
    );

    if (res.isEmpty) {
      throw 'ValueError: $value is not a valid status code';
    }

    return res.first;
  }
}

class Message {
  String chatroomId;
  String messageId;
  String author;
  String screenName;
  String content;
  Map<String, String>? mediaUrls;
  bool preview;
  int sendingDate;
  MessageStatus status;
  bool systemMessage;
  final Attachment? attachment;

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
    this.attachment,
  });

}

enum MessageAction {
  statusUpdate('STATUS_UPDATE');

  const MessageAction(this.value);
  final String value;

  factory MessageAction.fromValue(String value) {
    final res = MessageAction.values.where(
      (element) => element.value == value,
    );

    if (res.isEmpty) {
      throw 'ValueError: $value is not a valid action';
    }

    return res.first;
  }
}

class SystemMessage {
  final String targetId;
  final MessageAction action;
  final String update;

  SystemMessage({
    required this.targetId,
    required this.action,
    required this.update,
  });

  factory SystemMessage.fromMap(Map<String, dynamic> msgData) {
    return SystemMessage(
      targetId: msgData['targetId'],
      action: MessageAction.fromValue(msgData['action']),
      update: msgData['update'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetId': targetId,
      'action': action.value,
      'update': update,
    };
  }
}
