import 'package:flutter/material.dart';

abstract class FormeFile {
  Future<ImageProvider> get thumbnail;

  /// thumbnail cache
  ///
  /// set by picker
  ImageProvider? cache;

  bool get canbeUpload => false;

  void startUpload() {}
  void cancelUpload() {}
}
