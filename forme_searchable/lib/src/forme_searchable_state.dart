import 'dart:async';

import 'package:flutter/widgets.dart';
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
  set focusNode(FocusNode node) {
    final FocusNode? current = hasFocusNode ? focusNode : null;
    super.focusNode = node;
    if (current != focusNode) {
      _triggerListeners((listener) => listener.onFocusNodeChanged(node));
    }
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
    _triggerListeners((listener) => listener.onReset());
  }

  @override
  void onAsyncStateChanged(FormeAsyncOperationState state, Object? key) {}

  @override
  void onSuccess(FormeSearchablePageResult<T> result, Object? key) {
    if (mounted) {
      _triggerListeners(
          (listener) => listener.onQuerySuccess(_condition!, result));
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (mounted) {
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

  void goToPage(int page) {
    search(FormeSearchCondition(_condition?.condition ?? {}, page), false);
  }

  void search(FormeSearchCondition condition, [bool debounce = true]) {
    if (!mounted) {
      return;
    }
    _condition = condition;
    _timer?.cancel();
    final bool cancel =
        widget.queryFilter != null && !widget.queryFilter!.call(condition);
    if (cancel) {
      cancelAllAsyncOperations();
      _triggerListeners((listener) => listener.onQueryCancelled(_condition!));
      return;
    }
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
