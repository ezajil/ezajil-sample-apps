import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage.dart';

class UploadService {
  final Map<String, String> _uploadTasks = {};
  static UploadService instance = UploadService();

  static Future<void> upload({
    required String taskId,
    required File file,
    required String path,
    required void Function() onUploadDone,
    required void Function() onUploadError,
  }) async {
    final uploadTask = await ProviderContainer()
        .read(StorageRepoProvider)
        .uploadFileToFirebase(file, path);

    // instance._uploadTasks[taskId] = uploadTask;
    // uploadTask.then<void>(
    //   (snapshot) {
    //     onUploadDone();
    //     instance._uploadTasks.remove(taskId);
    //   },
    //   onError: (_) => onUploadError(),
    // );
  }

  static Future<void> cancelUpload(String taskId) async {
    // final task = instance._uploadTasks[taskId];
    // if (task == null) return;
    //
    // // await task.cancel();
    // instance._uploadTasks.remove(taskId);
    // TODO
  }

  static Stream<String>? getUploadStream(String taskId) {
    // final task = instance._uploadTasks[taskId];
    // if (task == null) return null;
    //
    // return null;
    // TODO
  }
}
