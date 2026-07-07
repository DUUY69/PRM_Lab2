// StorageService
// Upload PDF lên Firebase Storage

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static Future<String> uploadPdf(
      File file,
      ) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child(
      'reports/${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }
}