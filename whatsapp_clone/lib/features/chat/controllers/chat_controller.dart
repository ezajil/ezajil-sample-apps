import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/compression_service.dart';
import 'package:whatsapp_clone/shared/repositories/upload_service.dart';
import 'package:whatsapp_clone/shared/utils/attachment_utils.dart';
import 'package:whatsapp_clone/shared/utils/storage_paths.dart';
import 'package:whatsapp_clone/shared/widgets/camera.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../shared/repositories/download_service.dart';
import '../../../shared/repositories/push_notifications.dart';
import '../../../shared/utils/abc.dart';
import '../../../shared/widgets/gallery.dart';
import '../models/attachement.dart';
import '../views/attachment_sender.dart';

final chatControllerProvider =
    StateNotifierProvider.autoDispose<ChatStateNotifier, ChatState>(
  (ref) => ChatStateNotifier(ref: ref),
);

enum RecordingState {
  notRecording,
  recording,
  recordingLocked,
  paused,
}

class ChatState {
  ChatState({
    this.hideElements = false,
    this.recordingState = RecordingState.notRecording,
    this.showScrollBtn = false,
    this.unreadCount = 0,
    this.showEmojiPicker = false,
    required this.recordingSamples,
    required this.soundRecorder,
    required this.messageController,
    required this.fieldFocusNode,
  });

  final bool hideElements;
  final RecordingState recordingState;
  final TextEditingController messageController;
  final FocusNode fieldFocusNode;
  final FlutterSoundRecorder soundRecorder;
  final bool showScrollBtn;
  final int unreadCount;
  final List<RecordingDisposition> recordingSamples;
  final bool showEmojiPicker;

  void dispose() {
    fieldFocusNode.dispose();
    messageController.dispose();
    soundRecorder.closeRecorder();
  }

  ChatState copyWith({
    bool? hideElements,
    RecordingState? recordingState,
    bool? showScrollBtn,
    int? unreadCount,
    bool? showEmojiPicker,
    List<RecordingDisposition>? recordingSamples,
  }) {
    return ChatState(
      hideElements: hideElements ?? this.hideElements,
      recordingState: recordingState ?? this.recordingState,
      showScrollBtn: showScrollBtn ?? this.showScrollBtn,
      unreadCount: unreadCount ?? this.unreadCount,
      showEmojiPicker: showEmojiPicker ?? this.showEmojiPicker,
      messageController: messageController,
      fieldFocusNode: fieldFocusNode,
      soundRecorder: soundRecorder,
      recordingSamples: recordingSamples ?? this.recordingSamples,
    );
  }
}

class ChatStateNotifier extends StateNotifier<ChatState> {
  ChatStateNotifier({required this.ref})
      : super(
          ChatState(
            messageController: TextEditingController(),
            fieldFocusNode: FocusNode(),
            soundRecorder: FlutterSoundRecorder(logLevel: Level.error),
            recordingSamples: [],
          ),
        );

  final AutoDisposeStateNotifierProviderRef ref;
  late User self;
  late User other;
  late String otherUserContactName;
  StreamSubscription<RecordingDisposition>? recordingStream;

  void initUsers(User self, User other, String otherUserContactName) {
    this.self = self;
    this.other = other;
    this.otherUserContactName = otherUserContactName;
  }

  Future<void> initRecorder() async {
    await state.soundRecorder.openRecorder();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    state.soundRecorder.setSubscriptionDuration(
      const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  void navigateToHome(BuildContext context) {
    Navigator.pop(context);
  }

  void setRecordingState(RecordingState recordingState) {
    state = state.copyWith(recordingState: recordingState);
  }

  Future<void> pauseRecording() async {
    await state.soundRecorder.pauseRecorder();
    setRecordingState(RecordingState.paused);
  }

  Future<void> resumeRecording() async {
    await state.soundRecorder.resumeRecorder();
    setRecordingState(RecordingState.recordingLocked);
  }

  Future<void> cancelRecording() async {
    await state.soundRecorder.stopRecorder();
    recordingStream?.cancel();
    recordingStream = null;
    state = state.copyWith(
      recordingSamples: [],
      recordingState: RecordingState.notRecording,
    );
  }

  Future<void> startRecording() async {
    if (!await hasPermission(Permission.microphone)) return;
    await state.soundRecorder.startRecorder(
      codec: Codec.aacADTS,
      sampleRate: 44100,
      bitRate: 48000,
      toFile: "voice.aac",
    );

    recordingStream = state.soundRecorder.onProgress!.listen(
      recordingListener,
    );
    setRecordingState(RecordingState.recording);
  }

  void recordingListener(RecordingDisposition data) {
    state = state.copyWith(
      recordingSamples: state.recordingSamples..add(data),
    );
  }

  Future<void> onMicDragLeft(double dx, double deviceWidth) async {
    if (dx > deviceWidth * 0.6) return;

    await state.soundRecorder.stopRecorder();
    setRecordingState(RecordingState.notRecording);
  }

  Future<void> onMicDragUp(double dy, double deviceHeight) async {
    if (dy > deviceHeight - 100 ||
        state.recordingState == RecordingState.recordingLocked) return;

    setRecordingState(RecordingState.recordingLocked);
  }

  Future<void> onRecordingDone() async {
    final path = await state.soundRecorder.stopRecorder();
    recordingStream?.cancel();
    recordingStream = null;

    final samples = state.recordingSamples.map((e) => e.decibels ?? 0).toList();

    state = state.copyWith(
      recordingSamples: [],
      recordingState: RecordingState.notRecording,
    );

    final recordedFile = File(path!);
    final messageId = const Uuid().v4();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final ext = path.split(".").last;
    final fileName = "AUD_$timestamp.$ext";

    await recordedFile.copy(
      DeviceStorage.getMediaFilePath(fileName),
    );

    final senderId = ref.read(chatControllerProvider.notifier).self.userId;
    final receiverId = ref.read(chatControllerProvider.notifier).other.userId;

    ref.read(chatControllerProvider.notifier).sendMessageWithAttachments(
          Message(
            chatroomId: 'chatroomId',
            messageId: messageId,
            author: senderId,
            screenName: receiverId,
            content: 'First Message.',
            mediaUrls: null,
            preview: false,
            sendingDate: 1712673231451000000,
            status: MessageStatus.read,
            systemMessage: false,
            attachment: Attachment(
              type: AttachmentType.voice,
              url: "",
              fileName: fileName,
              fileSize: recordedFile.lengthSync(),
              fileExtension: ext,
              uploadStatus: UploadStatus.uploading,
              autoDownload: true,
              file: recordedFile,
              samples: samples,
            ),
          ),
        );
  }

  void onTextChanged(String value) {
    if (value.isEmpty) {
      state = state.copyWith(hideElements: false);
    } else if (value != ' ') {
      state = state.copyWith(hideElements: true);
    } else {
      state.messageController.text = "";
    }
  }

  void toggleScrollBtnVisibility() {
    state = state.copyWith(showScrollBtn: !state.showScrollBtn);
  }

  void setUnreadCount(int count) {
    if (state.unreadCount == count) return;
    state = state.copyWith(unreadCount: count);
  }

  void setShowEmojiPicker(bool shouldShowEmojiPicker) {
    print('Change emoji picker state');
    state = state.copyWith(showEmojiPicker: shouldShowEmojiPicker);
  }

  void onSendBtnPressed(WidgetRef ref, User sender, User receiver) async {
    sendMessageNoAttachments(
      Message(
        chatroomId: 'chatroomId',
        messageId: 'msg1',
        author: sender.userId,
        screenName: receiver.userId,
        content: 'First Message.',
        mediaUrls: null,
        preview: false,
        sendingDate: 1712673231451000000,
        status: MessageStatus.read,
        systemMessage: false,
      ),
    );

    state.messageController.text = "";
    state = state.copyWith(
      hideElements: false,
    );
  }

  Future<void> sendMessageNoAttachments(Message message) async {
    // TODO
  }

  void sendMessageWithAttachments(Message message) async {
    // TODO
  }

  Future<void> uploadAttachment(Message message) async {
    // TODO
  }

  Future<void> uploadCompleteHandler(
    // TaskSnapshot snapshot,
    Message message,
  ) async {
    // TODO
    ref.read(pushNotificationsRepoProvider).sendPushNotification(message);
  }

  Future<void> stopUpload(Message message) async {
    if (message.attachment!.uploadStatus == UploadStatus.notUploading) {
      return;
    }

    await UploadService.cancelUpload(message.messageId);
    // TODO
  }

  Future<void> downloadAttachment(
    Message message,
    void Function() onComplete,
    void Function() onError,
  ) async {
    await DownloadService.download(
      taskId: message.messageId,
      url: message.attachment!.url,
      path: DeviceStorage.getMediaFilePath(message.attachment!.fileName),
      onDownloadComplete: onComplete,
      onDownloadError: onError,
    );
  }

  Future<void> cancelDownload(Message message) async {
    await DownloadService.cancelDownload(message.messageId);
  }

  Future<void> compressAttachment(Message message) async {
    final compressedFile = await CompressionService.compressImage(
      message.attachment!.file!,
    );

    await compressedFile.copy(
      DeviceStorage.getMediaFilePath(
        message.attachment!.fileName,
      ),
    );

    message.attachment!.file = compressedFile;
    message.attachment!.fileSize = await compressedFile.length();
    message.attachment!.fileExtension = compressedFile.path.split('.').last;
  }

  Future<void> markMessageAsSeen(Message message) async {
    // TODO
  }

  Future<void> navigateToCameraView(BuildContext context) async {
    final cameras = await availableCameras();
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CameraView(cameras: cameras)),
    );
  }

  Future<List<Attachment>?> pickAttachmentsFromGallery(
    BuildContext context, {
    bool returnAttachments = false,
  }) async {
    if (Platform.isAndroid &&
        (!await hasPermission(Permission.storage)) &&
        (!await hasPermission(Permission.photos))) {
      return null;
    }

    if (!context.mounted) return null;

    if (Platform.isAndroid) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Gallery(
            title: 'Send to $otherUserContactName',
          ),
        ),
      );
      return null;
    }

    final key = showLoading(context);

    List<File>? files = await pickMultimedia();
    if (files == null) {
      Navigator.pop(key.currentContext!);
      return null;
    }

    final attachments = createAttachmentsFromFiles(files);
    if (returnAttachments) {
      Navigator.pop(key.currentContext!);
      return attachments;
    }

    if (!mounted) return null;
    Navigator.pop(key.currentContext!);
    navigateToAttachmentSender(context, attachments);
    return null;
  }

  Future<void> pickAudioFiles(
    BuildContext context,
  ) async {
    final key = showLoading(context);

    List<File>? files = await pickFiles(type: FileType.audio);
    if (files == null) {
      Navigator.pop(key.currentContext!);
      return;
    }

    final attachments = createAttachmentsFromFiles(files);

    if (!mounted) return;
    Navigator.pop(key.currentContext!);
    navigateToAttachmentSender(context, attachments);
  }

  Future<List<Attachment>?> pickDocuments(
    BuildContext context, {
    bool returnAttachments = false,
  }) async {
    final key = showLoading(context);

    List<File>? files = await pickFiles(type: FileType.any);
    if (files == null) {
      Navigator.pop(key.currentContext!);
      return null;
    }

    final attachments = createAttachmentsFromFiles(
      files,
      areDocuments: true,
    );

    if (returnAttachments) {
      Navigator.pop(key.currentContext!);
      return attachments;
    }

    if (!mounted) return null;
    Navigator.pop(key.currentContext!);
    navigateToAttachmentSender(context, attachments);
    return null;
  }

  GlobalKey showLoading(context) {
    final dialogKey = GlobalKey();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          key: dialogKey,
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Text(
                'Preparing media',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).custom.colorTheme.textColor2,
                ),
              ),
            ],
          ),
        );
      },
    );

    return dialogKey;
  }

  Future<List<Attachment>> createAttachmentsFromFiles(
    List<File> files, {
    bool areDocuments = false,
  }) async {
    return await Future.wait(
      files.map((file) async {
        final type = areDocuments
            ? AttachmentType.document
            : AttachmentType.fromValue(
                lookupMimeType(file.path)?.split("/")[0].toUpperCase() ??
                    'DOCUMENT',
              );

        double? width, height;
        if (type == AttachmentType.image) {
          (width, height) = await getImageDimensions(File(file.path));
        } else if (type == AttachmentType.video) {
          (width, height) = await getVideoDimensions(File(file.path));
        }

        final fileName = file.path.split("/").last;

        return Attachment(
          type: type,
          url: "",
          autoDownload:
              type == AttachmentType.image || type == AttachmentType.voice,
          fileName: fileName,
          fileSize: await file.length(),
          fileExtension: fileName.split(".").last,
          width: width,
          height: height,
          file: file,
        );
      }),
    );
  }

  void navigateToAttachmentSender(
    BuildContext context,
    Future<List<Attachment>> attachments,
  ) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AttachmentMessageSender(
          attachmentsFuture: attachments,
        ),
      ),
    );
  }
}
