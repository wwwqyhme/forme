import 'package:flutter/cupertino.dart';

import 'forme_upload_state_controller.dart';
import 'upload_progress_controller.dart';

class FormeFileUploadController {
  final Future<Object?> Function() _upload;
  final VoidCallback _cancel;
  final void Function(Object? result)? _onUploadSuccess;
  final void Function(Object error, StackTrace? trace)? _onUploadFail;

  FormeFileUploadController(
      this._upload, this._cancel, this._onUploadSuccess, this._onUploadFail);

  Object? error;
  StackTrace? stackTrace;

  bool get isUploadError => error != null;
  bool get isUploadSuccess => _uploadSuccess;
  bool get isUploadComplete => isUploadSuccess || isUploadError;
  Object? get uploadResult => _result;
  bool get isUploading => _uploading;
  Widget? get progressValue => _progressValue;

  void progress(Widget? value) {
    _progressValue = value;
    _progressController?.value = value;
  }

  void bindController(
    FormeFileUploadProgressController controller,
    FormeUploadStateController stateController,
  ) {
    _progressController = controller;
    _stateController = stateController;
  }

  void unbindController(
    FormeFileUploadProgressController controller,
    FormeUploadStateController stateController,
  ) {
    if (_progressController == controller) {
      _progressController = null;
    }
    if (_stateController == stateController) {
      _stateController = null;
    }
  }

  Future upload() async {
    if (_uploadFuture != null) {
      return;
    }
    _stateController?.value = UploadState.uploading;
    _uploading = true;
    try {
      _result = await (_uploadFuture ??= _upload());
      _uploadSuccess = true;
      _uploading = false;
      _stateController?.value = UploadState.success;
      _onUploadSuccess?.call(_result);
    } catch (e, trace) {
      debugPrintStack(stackTrace: trace);
      _uploading = false;
      error = e;
      stackTrace = trace;
      _stateController?.value = UploadState.error;
      _onUploadFail?.call(e, trace);
    }
  }

  void retry() {
    if (!isUploadError) {
      return;
    }
    _reset();
    upload();
  }

  /// cancel upload
  void cancel() {
    if (isUploading) {
      _reset();
      _cancel();
    }
  }

  void _reset() {
    _result = null;
    _progressController?.value = null;
    _stateController?.value = UploadState.waiting;
    _uploading = false;
    _progressValue = null;
    _uploadSuccess = false;
    _uploadFuture = null;
    error = null;
    stackTrace = null;
  }

  Object? _result;
  FormeFileUploadProgressController? _progressController;
  FormeUploadStateController? _stateController;
  bool _uploading = false;
  Widget? _progressValue;
  bool _uploadSuccess = false;
  Future<Object?>? _uploadFuture;
}
