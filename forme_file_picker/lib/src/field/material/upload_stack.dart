import 'package:flutter/material.dart';

import 'forme_upload_controller.dart';
import 'forme_upload_state_controller.dart';
import 'upload_progress_controller.dart';

class UploadStack extends StatefulWidget {
  final bool autoUpload;
  final FormeFileUploadController controller;
  const UploadStack({
    Key? key,
    required this.autoUpload,
    required this.controller,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<UploadStack> {
  final FormeFileUploadProgressController _progressController =
      FormeFileUploadProgressController(null);
  final FormeUploadStateController _stateController =
      FormeUploadStateController(UploadState.waiting);

  @override
  void dispose() {
    widget.controller.unbindController(_progressController, _stateController);
    _progressController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.bindController(_progressController, _stateController);
    _progressController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _stateController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    if (widget.autoUpload) {
      widget.controller.upload();
    }
  }

  @override
  void didUpdateWidget(covariant UploadStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller
          .unbindController(_progressController, _stateController);
      widget.controller.bindController(_progressController, _stateController);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.isUploading) {
      return widget.controller.progressValue ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }
    if (widget.controller.isUploadError) {
      return Center(
        child: IconButton(
          color: Theme.of(context).errorColor,
          icon: const Icon(Icons.error),
          onPressed: () {
            setState(() {
              widget.controller.retry();
            });
          },
        ),
      );
    }
    if (widget.controller.isUploadSuccess) {
      return const SizedBox.shrink();
    }
    return Center(
      child: IconButton(
        onPressed: () {
          setState(() {
            widget.controller.upload();
          });
        },
        icon: const Icon(
          Icons.upload,
          color: Colors.white,
        ),
      ),
    );
  }
}
