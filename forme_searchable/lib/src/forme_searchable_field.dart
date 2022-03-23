import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';

import 'forme_searchable_controller.dart';
import 'forme_searchable_inherit_controller.dart';
import 'forme_searchable_result.dart';
import 'forme_searchable_strem_event.dart';

abstract class FormeSearchableField<T extends Object> extends StatefulWidget {
  const FormeSearchableField({Key? key}) : super(key: key);

  @override
  FormeSearchableFieldState<T> createState();
}

abstract class FormeSearchableFieldState<T extends Object>
    extends State<FormeSearchableField<T>> {
  FormeSearchableInheritController<T>? _inheritController;

  @protected
  FormeSearchableController get controller => _inheritController!.controller;

  @protected
  FormeFieldStatus<List<T>> get status => _inheritController!.status;

  @protected
  FocusNode get focusNode => _inheritController!.focusNode;

  @protected
  int? get maximum => _inheritController!.maximum;

  FormeAsyncOperationState? _state;

  FormeAsyncOperationState? get state => _state;

  bool get isProcessing => state == FormeAsyncOperationState.processing;
  bool get hasError => state == FormeAsyncOperationState.error;
  bool get hasResult => state == FormeAsyncOperationState.success;

  StreamSubscription<FormeSearchableEvent<T>>? _scription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final FormeSearchableInheritController<T> current =
        FormeSearchableInheritController.of<T>(context);

    if (_inheritController != current) {
      _scription?.cancel();
      _inheritController = current;
      _scription = _inheritController!.stream.listen(_onEvent);
    }
  }

  set value(List<T> newValue) => _inheritController?.valueUpdater(newValue);

  void _onEvent(FormeSearchableEvent<T> event) {
    if (!mounted) {
      return;
    }

    _state = event.state;

    if (event.hasError) {
      onError(event.page, event.condition, event.error!, event.stackTrace!);
    }

    if (event.hasResult) {
      onData(event.page, event.condition, event.result!);
    }

    if (event.isProcessing) {
      onProcessing(event.page, event.condition);
    }
  }

  void onError(int page, Map<String, Object?> condition, Object error,
      StackTrace stackTrace);

  void onData(int page, Map<String, Object?> condition,
      FormeSearchablePageResult<T> result);

  void onProcessing(int page, Map<String, Object?> condition);

  @override
  void dispose() {
    _scription?.cancel();
    super.dispose();
  }
}
