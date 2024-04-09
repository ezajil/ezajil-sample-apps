import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:whatsapp_clone/theme/theme.dart';
import 'package:whatsapp_clone/utils/utils.dart';

class AttachmentRenderer extends StatelessWidget {
  const AttachmentRenderer({
    super.key,
    required this.attachmentType,
    required this.attachment,
    this.fit = BoxFit.none,
    this.controllable = false,
    this.compact = false,
    this.fadeIn = false,
  });

  final String attachmentType;
  final File attachment;
  final BoxFit fit;
  final bool controllable;
  final bool compact;
  final bool fadeIn;

  @override
  Widget build(BuildContext context) {
    switch (attachmentType) {
      case 'IMAGE':
        return ImageViewer(image: attachment, fit: fit);
      default:
        return DocumentViewer(
          document: attachment,
          compact: compact,
        );
    }
  }
}

class ImageViewer extends StatelessWidget {
  const ImageViewer({
    super.key,
    required this.image,
    required this.fit,
  });
  final File image;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      image,
      fit: fit,
    );
  }
}

class DocumentViewer extends StatelessWidget {
  const DocumentViewer({
    super.key,
    required this.document,
    this.compact = false,
  });
  final File document;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    String fileName = document.path.split("/").last;
    if (fileName.length > 20) {
      fileName = "${fileName.substring(0, 15)}...${fileName.substring(15)}";
    }
    final fileSizeStr = strFormattedSize(document.lengthSync());
    final fileExtension = fileName.split(".").last;

    final compactView = Container(
      width: 40,
      height: 50,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 233, 245, 245),
        borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Center(
        child: Text(
          fileExtension.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );

    return compact
        ? compactView
        : GestureDetector(
            onTap: () async {
              await OpenFile.open(document.path);
            },
            child: Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                compactView,
                const SizedBox(
                  height: 8,
                ),
                Text(
                  fileName,
                  style: Theme.of(context)
                      .custom
                      .textTheme
                      .titleLarge
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(fileSizeStr),
              ],
            )),
          );
  }
}
