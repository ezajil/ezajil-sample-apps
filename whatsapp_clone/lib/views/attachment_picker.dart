import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatsapp_clone/models/attachment.dart';
import 'package:whatsapp_clone/models/user.dart';
import 'package:whatsapp_clone/theme/theme.dart';
import 'package:whatsapp_clone/views/widgets/buttons.dart';

class AttachmentPicker extends StatefulWidget {
  final User self;
  final User other;
  final Future<List<Attachment>?> Function(BuildContext context,
      {bool returnAttachments}) pickDocuments;
  final Future<List<Attachment>?> Function(BuildContext context,
      {bool returnAttachments}) pickAttachmentsFromGallery;
  final Future<void> Function(BuildContext context) pickAudioFiles;
  final Future<void> Function(BuildContext context) navigateToCameraView;

  const AttachmentPicker({
    super.key,
    required this.self,
    required this.other,
    required this.pickDocuments,
    required this.pickAttachmentsFromGallery,
    required this.pickAudioFiles,
    required this.navigateToCameraView,
  });

  @override
  State<AttachmentPicker> createState() => _AttachmentPickerState();
}

class _AttachmentPickerState extends State<AttachmentPicker> {
  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Theme.of(context).brightness == Brightness.dark
              ? colorTheme.appBarColor
              : colorTheme.backgroundColor,
        ),
        child: GridView.count(
          crossAxisCount: 3,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            LabelledButton(
              onTap: () async {
                widget.pickDocuments(context);
              },
              backgroundColor: Colors.deepPurpleAccent,
              label: 'Document',
              child: const Icon(
                Icons.insert_page_break,
                size: 28,
                color: Colors.white,
              ),
            ),
            LabelledButton(
              onTap: () async {
                widget.navigateToCameraView(context);
              },
              label: 'Camera',
              backgroundColor: Colors.redAccent[400],
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
            LabelledButton(
              onTap: () async {
                widget.pickAttachmentsFromGallery(context);
              },
              label: 'Gallery',
              backgroundColor: Colors.purple[400],
              child: const Icon(
                Icons.photo_size_select_actual_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
            if (Platform.isAndroid) ...[
              LabelledButton(
                onTap: () async {
                  widget.pickAudioFiles(context);
                },
                label: 'Audio',
                backgroundColor: Colors.orange[900],
                child: const Icon(
                  Icons.headphones_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              )
            ],
            LabelledButton(
              onTap: () {
                if (!mounted) return;
                Navigator.pop(context);
              },
              label: 'Location',
              backgroundColor: Colors.green[600],
              child: const Icon(
                Icons.location_on,
                size: 28,
                color: Colors.white,
              ),
            ),
            LabelledButton(
              onTap: () {
                if (!mounted) return;
                Navigator.pop(context);
              },
              label: 'Payment',
              backgroundColor: Colors.teal[600],
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.currency_rupee_rounded,
                  size: 18,
                  color: Colors.teal[600],
                ),
              ),
            ),
            LabelledButton(
              onTap: () async {
                if (!mounted) return;
                Navigator.pop(context);
              },
              label: 'Contact',
              backgroundColor: Colors.blue[600],
              child: const Icon(
                Icons.person,
                size: 28,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
