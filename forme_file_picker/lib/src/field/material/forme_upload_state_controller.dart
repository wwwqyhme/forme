import 'package:flutter/cupertino.dart';

class FormeUploadStateController extends ValueNotifier<UploadState> {
  FormeUploadStateController(UploadState value) : super(value);
}

enum UploadState {
  success,
  error,
  uploading,
  waiting,
}
