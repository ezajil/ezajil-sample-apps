import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage.dart';

class DownloadService {
  final Map<String, String> _downloadTasks = {};
  static DownloadService instance = DownloadService();

  static Future<void> download({
    required String taskId,
    required String url,
    required String path,
    required void Function() onDownloadComplete,
    required void Function() onDownloadError,
  }) async {
    final downloadTask = await ProviderContainer()
        .read(StorageRepoProvider)
        .downloadFileFromFirebase(url, path);

    // instance._downloadTasks[taskId] = downloadTask;
    // downloadTask.then<void>(
    //   (snapshot) {
    //     onDownloadComplete();
    //     instance._downloadTasks.remove(taskId);
    //   },
    //   onError: (_) => onDownloadError(),
    // );
  }

  static Future<void> cancelDownload(String taskId) async {
    // final task = instance._downloadTasks[taskId];
    // if (task == null) return;
    //
    // await task.cancel();
    // instance._downloadTasks.remove(taskId);
    // TODO
  }

  static Stream<String>? getDownloadStream(String taskId) {
    // final task = instance._downloadTasks[taskId];
    // if (task == null) return null;
    //
    // return task.snapshotEvents;
    // TODO
  }
}
