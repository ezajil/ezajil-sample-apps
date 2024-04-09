import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/user.dart';
import 'package:whatsapp_clone/theme/color_theme.dart';
import 'package:whatsapp_clone/theme/theme.dart';
import 'package:whatsapp_clone/utils/utils.dart';
import 'package:whatsapp_clone/utils/storage.dart';
import 'package:whatsapp_clone/views/widgets/attachment_renderer.dart';

class AttachmentPreview extends StatefulWidget {
  const AttachmentPreview({
    super.key,
    required this.self,
    required this.other,
    required this.message,
    required this.width,
    required this.height,
  });

  final User self;
  final User other;
  final Message message;
  final double width;
  final double height;

  @override
  State<AttachmentPreview> createState() => _AttachmentPreviewState();
}

class _AttachmentPreviewState extends State<AttachmentPreview> {
  bool _doesAttachmentExist() {
    const fileName = 'filename';
    final file = File(DeviceStorage.getMediaFilePath(fileName));

    if (file.existsSync()) {
      widget.message.file = file;
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.preview) {
      return AttachedImageVideoViewer(
          width: widget.width,
          height: widget.height,
          self: widget.self,
          other: widget.other,
          message: widget.message,
          doesAttachmentExist: _doesAttachmentExist(),
          onDownloadComplete: () => setState(() {}),
        );
    }
    return AttachedDocumentViewer(
      self: widget.self,
      message: widget.message,
      doesAttachmentExist: _doesAttachmentExist(),
      onDownloadComplete: () => setState(() {}),
    );
  }
}

class AttachedImageVideoViewer extends StatefulWidget {
  final double width;
  final double height;
  final User self;
  final User other;
  final Message message;
  final bool doesAttachmentExist;
  final VoidCallback onDownloadComplete;

  const AttachedImageVideoViewer({
    super.key,
    required this.width,
    required this.height,
    required this.self,
    required this.other,
    required this.message,
    required this.doesAttachmentExist,
    required this.onDownloadComplete,
  });

  @override
  State<AttachedImageVideoViewer> createState() =>
      _AttachedImageVideoViewerState();
}

class _AttachedImageVideoViewerState
    extends State<AttachedImageVideoViewer> {
  late final String sender;

  @override
  void initState() {
    final clientIsSender = widget.message.author == widget.self.userId;
    sender = clientIsSender ? "You" : widget.other.screenName;

    super.initState();
  }

  Future<void> navigateToViewer() async {
    final file = widget.message.file;
    // final focusNode = ref.read(chatControllerProvider).fieldFocusNode;
    // focusNode.unfocus();

    Future.delayed(
      Duration(
        milliseconds: MediaQuery.of(context).viewInsets.bottom > 0 ? 300 : 0,
      ),
          () async {
        if (!mounted || file == null) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AttachmentViewer(
              file: file,
              message: widget.message,
              sender: sender,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.message.file;
    final bool isAttachmentUploaded =
        widget.message.status == MessageStatus.SENT;

    final background = sender == "You"
        ? const Color.fromARGB(255, 0, 0, 0)
        : const Color.fromARGB(150, 0, 0, 0);

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: navigateToViewer,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: background,
                  width: widget.width,
                  height: widget.height,
                ),
                if (file != null) ...[
                  SizedBox(
                    width: widget.width,
                    height: widget.height,
                    child: Hero(
                      tag: widget.message.messageId,
                      child: AttachmentRenderer(
                        attachment: file,
                        attachmentType: widget.message.preview ? 'IMAGE' : 'DOCUMENT',
                        fit: BoxFit.cover,
                        controllable: false,
                        fadeIn: true,
                      ),
                    ),
                  )
                ],
              ],
            ),
          ),
        ),
        // if (!widget.doesAttachmentExist) ...[
        //   DownloadingAttachment(
        //     message: widget.message,
        //     onDone: widget.onDownloadComplete,
        //     showSize: true,
        //   )
        // ] else if (!isAttachmentUploaded) ...[
        //   UploadingAttachment(
        //     message: widget.message,
        //     showSize: true,
        //   )
        // ] else if (widget.message.attachment!.type == AttachmentType.video) ...[
        //   CircleAvatar(
        //     backgroundColor: const Color.fromARGB(255, 209, 208, 208),
        //     foregroundColor: Colors.black87,
        //     radius: 25,
        //     child: GestureDetector(
        //       onTap: navigateToViewer,
        //       child: const Icon(
        //         Icons.play_arrow_rounded,
        //         size: 40,
        //       ),
        //     ),
        //   )
        // ],
      ],
    );
  }
}

class AttachedDocumentViewer extends StatefulWidget {
  final User self;
  final Message message;
  final bool doesAttachmentExist;
  final VoidCallback onDownloadComplete;

  const AttachedDocumentViewer({
    super.key,
    required this.self,
    required this.message,
    required this.doesAttachmentExist,
    required this.onDownloadComplete,
  });

  @override
  State<AttachedDocumentViewer> createState() =>
      _AttachedDocumentViewerState();
}

class _AttachedDocumentViewerState
    extends State<AttachedDocumentViewer> {
  late final bool clientIsSender;

  @override
  void initState() {
    clientIsSender = widget.message.author == widget.self.userId;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.message.file;
    final bool isAttachmentUploaded =
        widget.message.status == MessageStatus.SENT;
    const ext = 'pdf';

    Widget? trailing;
    // if (!widget.doesAttachmentExist) {
    //   trailing = DownloadingAttachment(
    //     message: widget.message,
    //     onDone: widget.onDownloadComplete,
    //   );
    // } else if (!isAttachmentUploaded) {
    //   trailing = UploadingAttachment(
    //     message: widget.message,
    //   );
    // }

    final backgroundColor = clientIsSender
        ? Theme.of(context).custom.colorTheme.outgoingEmbedColor
        : Theme.of(context).custom.colorTheme.incomingEmbedColor;

    String fileName = 'test';
    final len = fileName.length;
    if (fileName.length > 20) {
      fileName =
      "${fileName.substring(0, 15)}....${fileName.substring(len - 6, len)}";
    }

    return GestureDetector(
      onTap: () async {
        if (!widget.doesAttachmentExist) return;
        await OpenFile.open(file!.path);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColorsLight.incomingMessageBubbleColor,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(blurRadius: 1, color: Color.fromARGB(80, 0, 0, 0))
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Center(
                child: Text(
                  ext.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    "${strFormattedSize(100000)} · $ext",
                    style:
                    const TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
            if (widget.message.content.length > 10) ...[
              const Spacer(),
            ],
            trailing ?? const Text('')
          ],
        ),
      ),
    );
  }
}

class AttachmentViewer extends StatefulWidget {
  const AttachmentViewer({
    super.key,
    required this.file,
    required this.message,
    required this.sender,
  });
  final File file;
  final Message message;
  final String sender;

  @override
  State<AttachmentViewer> createState() => _AttachmentViewerState();
}

class _AttachmentViewerState extends State<AttachmentViewer> {
  bool showControls = true;
  SystemUiOverlayStyle currentStyle = const SystemUiOverlayStyle(
    statusBarColor: Color.fromARGB(206, 0, 0, 0),
    systemNavigationBarColor: Colors.black,
    systemNavigationBarDividerColor: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    String title = widget.sender;
    String formattedTime = formatSendingDate(widget.message.sendingDate);

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: Theme.of(context).iconTheme.copyWith(
          color: Colors.white,
        ),
      ),
      child: AnnotatedRegion(
        value: currentStyle,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => setState(() {
              showControls = !showControls;
            }),
            child: Stack(
              children: [
                InteractiveViewer(
                  child: Align(
                    child: Hero(
                      tag: widget.message.messageId,
                      child: AttachmentRenderer(
                        attachment: widget.file,
                        attachmentType: widget.message.preview ? 'IMAGE' : 'DOCUMENT',
                        fit: BoxFit.contain,
                        controllable: true,
                      ),
                    ),
                  ),
                ),
                if (showControls) ...[
                  SafeArea(
                    child: Container(
                      height: 60,
                      color: const Color.fromARGB(206, 0, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: Theme.of(context)
                                          .custom
                                          .textTheme
                                          .titleLarge
                                          .copyWith(color: Colors.white),
                                    ),
                                    Text(
                                      formattedTime,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.star_border_outlined),
                                Icon(Icons.turn_slight_right),
                                Icon(Icons.more_vert),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class DownloadingAttachment extends StatefulWidget {
//   const DownloadingAttachment({
//     super.key,
//     required this.self,
//     required this.message,
//     required this.onDone,
//     this.showSize = false,
//   });
//   final User self;
//   final Message message;
//   final VoidCallback onDone;
//   final bool showSize;
//
//   @override
//   State<DownloadingAttachment> createState() =>
//       _DownloadingAttachmentState();
// }
//
// class _DownloadingAttachmentState extends State<DownloadingAttachment> {
//   late bool isDownloading;
//   late bool clientIsSender;
//   Stream<TaskSnapshot>? downloadStream;
//
//   @override
//   void initState() {
//     isDownloading = false;
//     if (isDownloading) {
//       final downloadStream =
//       DownloadService.getDownloadStream(widget.message.messageId);
//       if (downloadStream == null) {
//         download();
//       }
//     }
//
//     clientIsSender = widget.self.userId == widget.message.author;
//
//     super.initState();
//   }
//
//   Future<void> download() async {
//     await ref.read(chatControllerProvider.notifier).downloadAttachment(
//       widget.message,
//           (_) {
//         widget.onDone();
//       },
//           () {
//         if (!mounted) return;
//         setState(() => isDownloading = false);
//       },
//     );
//
//     downloadStream = DownloadService.getDownloadStream(widget.message.messageId)!;
//     setState(() => isDownloading = true);
//   }
//
//   Future<void> cancel() async {
//     await ref
//         .read(chatControllerProvider.notifier)
//         .cancelDownload(widget.message);
//     setState(() => isDownloading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (downloadStream == null && isDownloading) {
//       return const SizedBox(width: 10, height: 10);
//     }
//
//     const overlayColor = Color.fromARGB(150, 0, 0, 0);
//
//     if (!isDownloading) {
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           InkWell(
//             onTap: download,
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: widget.showSize ? overlayColor : Colors.transparent,
//                 border: Border.all(
//                   width: 2,
//                   color: Theme.of(context).custom.colorTheme.greenColor,
//                 ),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.download_rounded,
//                 color: Theme.of(context).custom.colorTheme.greenColor,
//               ),
//             ),
//           ),
//           if (widget.showSize) ...[
//             const SizedBox(height: 4.0),
//             Container(
//               decoration: BoxDecoration(
//                 color: overlayColor,
//                 borderRadius: BorderRadius.circular(100),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   strFormattedSize(100000),
//                   style: TextStyle(
//                     color: Theme.of(context).custom.colorTheme.greenColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ),
//           ]
//         ],
//       );
//     }
//
//     final noProgressIndicator = ProgressCancelBtn(
//       onTap: cancel,
//       overlayColor: widget.showSize ? overlayColor : Colors.transparent,
//     );
//
//     return StreamBuilder(
//       stream: downloadStream,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return noProgressIndicator;
//         }
//
//         final snapData = snapshot.data!;
//
//         switch (snapData.state) {
//           case TaskState.running:
//             return ProgressCancelBtn(
//               onTap: cancel,
//               progressValue: snapData.bytesTransferred / snapData.totalBytes,
//               overlayColor: widget.showSize ? overlayColor : Colors.transparent,
//             );
//           case TaskState.success:
//             return const CircularProgressIndicator(
//               strokeWidth: 3.0,
//             );
//           case TaskState.error:
//             return const CircularProgressIndicator(
//               strokeWidth: 3.0,
//             );
//           default:
//             return noProgressIndicator;
//         }
//       },
//     );
//   }
// }
//
// class UploadingAttachment extends ConsumerStatefulWidget {
//   final Message message;
//   final bool showSize;
//
//   const UploadingAttachment({
//     super.key,
//     required this.message,
//     this.showSize = false,
//   });
//
//   @override
//   ConsumerState<UploadingAttachment> createState() =>
//       _UploadingAttachmentState();
// }
//
// class _UploadingAttachmentState extends ConsumerState<UploadingAttachment> {
//   late bool isUploading;
//   late Stream<TaskSnapshot> uploadStream;
//   late bool clientIsSender;
//
//   @override
//   void initState() {
//     isUploading =
//         widget.message.attachment!.uploadStatus == UploadStatus.uploading;
//     if (isUploading) {
//       final stream = UploadService.getUploadStream(widget.message.id);
//       if (stream != null) {
//         uploadStream = stream;
//       }
//     }
//
//     clientIsSender = ref.read(chatControllerProvider.notifier).self.id ==
//         widget.message.senderId;
//
//     super.initState();
//   }
//
//   @override
//   void didUpdateWidget(covariant UploadingAttachment oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     isUploading =
//         widget.message.attachment!.uploadStatus == UploadStatus.uploading;
//
//     if (isUploading) {
//       uploadStream = UploadService.getUploadStream(widget.message.id)!;
//     }
//   }
//
//   Future<void> upload() async {
//     await ref
//         .read(chatControllerProvider.notifier)
//         .uploadAttachment(widget.message);
//
//     uploadStream = UploadService.getUploadStream(widget.message.id)!;
//     setState(() => isUploading = true);
//   }
//
//   Future<void> stopUpload() async {
//     await ref.read(chatControllerProvider.notifier).stopUpload(widget.message);
//     setState(() => isUploading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.message.attachment!.uploadStatus == UploadStatus.preparing) {
//       return const SizedBox(width: 10, height: 10);
//     }
//
//     const overlayColor = Color.fromARGB(150, 0, 0, 0);
//
//     if (!isUploading) {
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           InkWell(
//             onTap: upload,
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: widget.showSize ? overlayColor : Colors.transparent,
//                 border: Border.all(
//                   width: 2,
//                   color: Theme.of(context).custom.colorTheme.greenColor,
//                 ),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.upload_rounded,
//                 color: Theme.of(context).custom.colorTheme.greenColor,
//               ),
//             ),
//           ),
//           if (widget.showSize) ...[
//             const SizedBox(height: 4.0),
//             Container(
//               decoration: BoxDecoration(
//                 color: overlayColor,
//                 borderRadius: BorderRadius.circular(100),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   strFormattedSize(widget.message.attachment!.fileSize),
//                   style: TextStyle(
//                     color: Theme.of(context).custom.colorTheme.greenColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ),
//           ]
//         ],
//       );
//     }
//
//     final noProgressIndicator = ProgressCancelBtn(
//       onTap: stopUpload,
//       overlayColor: widget.showSize ? overlayColor : Colors.transparent,
//     );
//
//     return StreamBuilder(
//       stream: uploadStream,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return noProgressIndicator;
//         }
//
//         final snapData = snapshot.data!;
//
//         switch (snapData.state) {
//           case TaskState.running:
//             return ProgressCancelBtn(
//               onTap: stopUpload,
//               overlayColor: widget.showSize ? overlayColor : Colors.transparent,
//               progressValue: snapData.bytesTransferred / snapData.totalBytes,
//             );
//           case TaskState.success:
//             return const CircularProgressIndicator(
//               strokeWidth: 3.0,
//             );
//           case TaskState.error:
//             WidgetsBinding.instance.addPostFrameCallback((_) async {
//               if (!mounted) return;
//               setState(() => isUploading = false);
//             });
//             return const CircularProgressIndicator(
//               strokeWidth: 3.0,
//             );
//           default:
//             return noProgressIndicator;
//         }
//       },
//     );
//   }
// }