import 'dart:async';

import 'package:forme/forme.dart';

import 'forme_searchable.dart';
import 'forme_searchable_condition.dart';
import 'forme_searchable_listener.dart';
import 'forme_searchable_result.dart';

class FormeSearchableState<T extends Object> extends FormeFieldState<List<T>>
    with FormeAsyncOperationHelper<FormeSearchablePageResult<T>> {
  Timer? _timer;

  final List<FormeSearchableListener<T>> _listeners = [];

  @override
  FormeSearchable<T> get widget => super.widget as FormeSearchable<T>;

  FormeSearchCondition? _condition;

  bool get isTimerActive => _timer != null && _timer!.isActive;

  bool _isProcessing = false;
  FormeSearchablePageResult<T>? _result;
  Object? _error;
  StackTrace? _stackTrace;

  @override
  FormeSearchableStatus<T> get status => FormeSearchableStatus._(super.status,
      widget.maximum, _isProcessing, _result, _error, _stackTrace);

  @override
  void didChange(List<T> newValue) {
    if (widget.maximum != null && newValue.length > widget.maximum!) {
      List<T> finalValue;
      if (widget.onMaximumExceed == null) {
        finalValue = newValue.sublist(newValue.length - widget.maximum!);
      } else {
        finalValue =
            widget.onMaximumExceed!(List.of(newValue), widget.maximum!);
        if (finalValue.length > widget.maximum!) {
          throw Exception(
              'length of new value which returned by onMaximumExceed should smaller or equals than maximum');
        }
      }
      super.didChange(finalValue);
      return;
    }
    super.didChange(newValue);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<List<T>> status) {
    super.onStatusChanged(status);
    _triggerListeners((listener) => listener.onStatusChanged(status));
  }

  @override
  void reset() {
    super.reset();
    cancelAllAsyncOperations();
    resetQueryStatus();
    _triggerListeners((listener) => listener.onReset());
  }

  void resetQueryStatus() {
    _isProcessing = false;
    _result = null;
    _error = null;
    _stackTrace = null;
  }

  @override
  void onAsyncStateChanged(FormeAsyncOperationState state, Object? key) {}

  @override
  void onSuccess(FormeSearchablePageResult<T> result, Object? key) {
    if (mounted && !isTimerActive) {
      _error = null;
      _stackTrace = null;
      _result = result;
      _isProcessing = false;
      _triggerListeners(
          (listener) => listener.onQuerySuccess(_condition!, result));
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (mounted && !isTimerActive) {
      _error = error;
      _stackTrace = stackTrace;
      _result = null;
      _isProcessing = false;
      _triggerListeners(
          (listener) => listener.onQueryFail(_condition!, error, stackTrace));
    }
  }

  void addListener(FormeSearchableListener<T> listener) {
    _listeners.add(listener);
  }

  void removeListener(FormeSearchableListener<T> listener) {
    _listeners.remove(listener);
  }

  void _triggerListeners(
      void Function(FormeSearchableListener<T> listener) handle) {
    for (final FormeSearchableListener<T> listener in _listeners) {
      handle(listener);
    }
  }

  void cancel() {
    cancelAllAsyncOperations();
  }

  void reload() {
    search(_condition ?? FormeSearchCondition({}, 1), false);
  }

  void goToPage(int page) {
    search(FormeSearchCondition(_condition?.condition ?? {}, page), false);
  }

  void search(FormeSearchCondition condition, [bool debounce = true]) {
    if (!mounted) {
      return;
    }
    _error = null;
    _stackTrace = null;
    _result = null;
    final bool isOnlyPageChanged = condition.condition == _condition?.condition;
    _condition = condition;
    _timer?.cancel();
    final bool cancel =
        widget.queryFilter != null && !widget.queryFilter!.call(condition);
    if (cancel) {
      cancelAllAsyncOperations();
      _isProcessing = false;
      _triggerListeners((listener) => listener.onQueryCancelled(_condition!));
      return;
    }
    if (isOnlyPageChanged) {
      _triggerListeners((listener) => listener.onPageChangeStart(condition));
    } else {
      _triggerListeners(
          (listener) => listener.onConditionChangeStart(condition));
    }
    _isProcessing = true;
    _triggerListeners((listener) => listener.onQueryProcessing(_condition!));
    if (debounce) {
      _timer = Timer(widget.debounce, () {
        if (mounted) {
          perform(widget.query(_condition!));
        }
      });
    } else {
      perform(widget.query(_condition!));
    }
  }
}

class FormeSearchableStatus<T extends Object>
    extends FormeFieldStatus<List<T>> {
  final int? maximum;
  final bool isProcessing;
  final FormeSearchablePageResult<T>? result;
  final Object? error;
  final StackTrace? stackTrace;

  bool get hasResult => result != null;
  bool get hasError => error != null;

  FormeSearchableStatus._(
    FormeFieldStatus<List<T>> parent,
    this.maximum,
    this.isProcessing,
    this.result,
    this.error,
    this.stackTrace,
  ) : super(parent);
}
