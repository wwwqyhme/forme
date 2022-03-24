import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';

import 'searchable_controller.dart';
import 'forme_searchable_controller.dart';
import 'forme_searchable_result.dart';
import 'forme_searchable_strem_event.dart';

abstract class FormeSearchableField<T extends Object> extends StatefulWidget {
  const FormeSearchableField({Key? key}) : super(key: key);

  @override
  FormeSearchableFieldState<T> createState();
}

abstract class FormeSearchableFieldState<T extends Object>
    extends State<FormeSearchableField<T>> {
  FormeSearchableController<T>? _inheritController;

  @protected
  SearchController get controller => _inheritController!.controller;

  @protected
  FormeFieldStatus<List<T>> get status => _inheritController!.status;

  @protected
  FocusNode get focusNode => _inheritController!.focusNode;

  @protected
  int? get maximum => _inheritController!.maximum;

  FormeAsyncOperationState? _state;
  FormeSearchablePageResult<T>? _result;

  FormeSearchablePageResult<T>? get result => _result;
  FormeAsyncOperationState? get state => _state;

  bool get isProcessing => state == FormeAsyncOperationState.processing;
  bool get hasError => state == FormeAsyncOperationState.error;
  bool get hasResult => _result != null;

  StreamSubscription<FormeSearchableEvent<T>>? _eventScription;
  StreamSubscription<FormeFieldChangedStatus<List<T>>>? _statusScription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final FormeSearchableController<T> current =
        FormeSearchableController.of<T>(context);

    if (_inheritController != current) {
      _eventScription?.cancel();
      _statusScription?.cancel();
      _inheritController = current;
      _eventScription = _inheritController!.eventStream.listen(_onEvent);
      _statusScription =
          _inheritController!.statusStream.listen(onStatusChanged);
    }
  }

  set value(List<T> newValue) => _inheritController?.valueUpdater(newValue);

  void onStatusChanged(FormeFieldChangedStatus<List<T>> status) {}

  void _onEvent(FormeSearchableEvent<T> event) {
    if (!mounted) {
      return;
    }

    _state = event.state;
    _result = event.result;

    if (event.hasError) {
      onError(event.page, event.condition, event.error!, event.stackTrace!);
    }

    if (event.hasResult) {
      onData(event.page, event.condition, event.result!);
    }

    if (event.isProcessing) {
      onProcessing(event.page, event.condition);
    }

    if (event.isCancel) {
      onCancel(event.page, event.condition);
    }
  }

  void onError(int page, Map<String, Object?> condition, Object error,
      StackTrace stackTrace);

  void onData(int page, Map<String, Object?> condition,
      FormeSearchablePageResult<T> result);

  void onProcessing(int page, Map<String, Object?> condition);
  void onCancel(int page, Map<String, Object?> condition);

  @override
  void dispose() {
    _statusScription?.cancel();
    _eventScription?.cancel();
    super.dispose();
  }
}
