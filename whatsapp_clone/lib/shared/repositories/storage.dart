import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final StorageRepoProvider =
    Provider((ref) => StorageRepo());

class StorageRepo {

  Future<void> uploadFileToFirebase(File file, String path) async {
    // TODO
  }

  Future<void> getFileMetadata(String url) async {
    // TODO
  }

  Future<void> downloadFileFromFirebase(
    String url,
    String path,
  ) async {
    // TODO
  }
}
