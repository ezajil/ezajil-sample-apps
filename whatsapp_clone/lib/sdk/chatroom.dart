import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/sdk/session.dart';
import 'package:whatsapp_clone/sdk/token_manager.dart';
import 'package:whatsapp_clone/sdk/transport.dart';
import 'package:whatsapp_clone/sdk/utils/http.dart';
import 'package:whatsapp_clone/shared/models/user.dart';

class Chatroom {
  final Transport transport;
  final User currentUser;
  final TokenManager tokenManager = TokenManager();
  final String apiEndpoint;
  final String chatroomId;
  final String name;
  final String latestMessage;
  final DateTime creationDate;
  final String creatorId;
  final bool single;
  final List<String> participantIds;
  final Map<String, dynamic> metadata;
  final DateTime lastJoined;
  final StreamController<dynamic> _eventController =
      StreamController.broadcast();

  Chatroom({
    required Session session,
    required this.chatroomId,
    required this.name,
    required this.latestMessage,
    required this.creationDate,
    required this.creatorId,
    required this.single,
    required this.participantIds,
    required this.metadata,
    required this.lastJoined,
  })  : transport = session.transport,
        currentUser = session.currentUser,
        apiEndpoint = session.apiEndpoint;

  factory Chatroom.fromJson(Session session, Map<String, dynamic> json) {
    return Chatroom(
      // Assuming these are provided or set later since they typically do not come from JSON
      session: session,
      chatroomId: json['chatroomId'] as String,
      name: json['name'] as String,
      latestMessage: json['latestMessage'] as String,
      creationDate: DateTime.parse(json['creationDate']),
      creatorId: json['creatorId'] as String,
      single: json['single'] as bool,
      participantIds: List<String>.from(json['participantIds']),
      metadata: Map<String, dynamic>.from(json['metadata']),
      lastJoined: DateTime.parse(json['lastJoined']),
    );
  }

  void open() {
    // Listen to different types of messages from the transport
    transport.on('payload-delivery-error:$chatroomId').listen((message) {
      print('payload-delivery-error: ${message.toString()}');
      _eventController.add({'type': 'payload-delivery-error', ...message});
    });

    transport.on('chat-message:$chatroomId').listen((message) {
      print('chat-message: ${message.toString()}');
      _eventController.add({'type': 'chat-message', ...message});
    });

    transport.on('message-sent:$chatroomId').listen((message) {
      print('message-sent: ${message.toString()}');
      _eventController.add({'type': 'message-sent', ...message});
    });

    transport.on('user-typing:$chatroomId').listen((message) {
      print('user-typing: ${message.toString()}');
      _eventController.add({'type': 'user-typing', ...message});
    });

    transport.on('messages-delivered:$chatroomId').listen((message) {
      print('messages-delivered: ${message.toString()}');
      _eventController.add({'type': 'messages-delivered', ...message});
    });

    transport.on('messages-read:$chatroomId').listen((message) {
      print('messages-read: ${message.toString()}');
      _eventController.add({'type': 'messages-read', ...message});
    });
  }

  void close() {
    _eventController.close();
  }

  Stream<dynamic> on(String event) => _eventController.stream
      .where((e) => e['event'] == event)
      .map((e) => e['data']);

  Future<List<Message>> getMessages({String? pagingState, int? limit}) async {
    var queryParams = {'pagingState': pagingState, 'limit': limit?.toString()};
    final response = await httpGet(
        '$apiEndpoint/api/v1/chatrooms/$chatroomId/messages',
        tokenManager.get,
        queryParams);
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Message.fromJson(json)).toList();
  }

  Future<List<User>> getUsers() async {
    final responseData = await httpGet(
        '$apiEndpoint/api/v1/chatrooms/$chatroomId/users', tokenManager.get);
    List<dynamic> data = jsonDecode(responseData.body);
    return data.map((json) => User.fromJson(json)).toList();
  }

  Future<void> join() async {
    final url = '$apiEndpoint/api/v1/chatrooms/$chatroomId/join';
    await httpPost(url, tokenManager.get, {});
  }

  void sendChatMessage(String textMessage) {
    if (textMessage.isNotEmpty) {
      var message = {
        'chatroomId': chatroomId,
        'messageId': const Uuid().v4(),
        'author': currentUser.userId,
        'screenName': currentUser.screenName,
        'content': textMessage,
        'users': participantIds,
        'sendingDate': DateTime.now().microsecondsSinceEpoch * 1000,
      };
      _sendTextMessage(message);
    }
  }

  void _sendTextMessage(Map<String, dynamic> message) {
    transport.send(jsonEncode({'event': 'chat-message', 'payload': message}));
  }

  Future<Map<String, dynamic>> uploadAttachment(File file) async {
    final sizeInMB = file.lengthSync() / (1024 * 1024);
    if (sizeInMB > 20) {
      throw Exception('The maximum upload size is 20MB');
    }

    final messageId = const Uuid().v4();
    final formData = {
      'chatroomId': chatroomId,
      'author': currentUser.userId,
      'messageId': messageId,
      'file': file
    };

    final response =
        await uploadFile('$apiEndpoint/dam/upload', tokenManager.get, formData);
    final uploadResult = jsonDecode(response.body);
    final message = {
      'chatroomId': chatroomId,
      'messageId': messageId,
      'author': currentUser.userId,
      'mediaUrls': uploadResult['links'],
      'preview': uploadResult['preview'],
      'screenName': currentUser.screenName,
      'users': participantIds,
      'sendingDate': uploadResult['sendingDate'],
    };

    _sendTextMessage(message);
    return message;
  }

  void fireUserTyping() {
    transport.send({
      'event': 'user-typing',
      'payload': {
        'chatroomId': chatroomId,
        ...currentUser.toJson() // Ensure User has a toJson method
      }
    });
  }

  void markMessageAsDelivered(int latestMessageDelivered) {
    transport.send({
      'event': 'messages-delivered',
      'payload': {
        'chatroomId': chatroomId,
        'latestMessageDelivered': latestMessageDelivered
      }
    });
  }

  void markMessageAsRead(int latestMessage) {
    transport.send({
      'event': 'messages-read',
      'payload': {'chatroomId': chatroomId, 'latestMessageRead': latestMessage}
    });
  }
}
