import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/utils/shared_pref.dart';

import '../../features/chat/models/message.dart';

final pushNotificationsRepoProvider = Provider(
  (ref) => PushNotificationsRepo(FirebaseMessaging.instance, ref),
);

class PushNotificationsRepo {
  final FirebaseMessaging instance;
  final ProviderRef ref;

  PushNotificationsRepo(this.instance, this.ref);

  Future<void> init({
    required Future<void> Function(RemoteMessage) onMessageOpenedApp,
  }) async {
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
    instance.onTokenRefresh.listen((token) => handleTokenRefresh(token, ref));
  }

  Future<void> sendPushNotification(Message message) async {
    // final token = 'some token';
    //
    // const String url =
    //     'https://wa_notifications-1-q2097095.deta.app/new_message';
    // final Map<String, String> headers = {"Content-Type": "application/json"};
    //
    // String messageContent = message.content;
    // if (message.attachment != null) {
    //   messageContent = "Sent an attachment";
    // }
    //
    // final user = getCurrentUser()!;
    // final String messageJson = jsonEncode(
    //   {
    //     'token': token,
    //     'messageId': message.messageId,
    //     'messageContent': messageContent,
    //     'authorId': user.userId,
    //     'authorName': user.screenName,
    //   },
    // );
    //
    // await post(
    //   Uri.parse(url),
    //   headers: headers,
    //   body: messageJson,
    // );
  }
}

Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  final data = message.data;

  //TODO
}

void handleTokenRefresh(String newToken, ProviderRef ref) {
  final oldToken = SharedPref.instance.getString('fcmToken');
  if (newToken == oldToken) return;

  SharedPref.instance.setString('fcmToken', newToken);
}
