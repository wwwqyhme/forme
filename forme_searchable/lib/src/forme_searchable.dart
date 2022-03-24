import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forme/forme.dart';
import 'package:forme_searchable/src/field/material/forme_searchable_base_field.dart';

import 'searchable_controller.dart';
import 'forme_searchable_field.dart';
import 'forme_searchable_controller.dart';
import 'forme_searchable_result.dart';
import 'forme_searchable_strem_event.dart';

typedef FormeSearchableQuery<T extends Object>
    = Future<FormeSearchablePageResult<T>> Function(
        int page, Map<String, Object?> condition);
typedef FormeSearchableSearchConditionFilter = bool Function(
    SearchCondition condition);

class FormeSearchable<T extends Object> extends FormeField<List<T>> {
  final int page;
  final Map<String, Object?> condition;
  final FormeSearchableQuery<T> query;
  final int? maximum;
  final List<T> Function(List<T> value, int maximum)? onMaximumExceed;
  final FormeSearchableSearchConditionFilter? searchConditionFilter;
  final Duration debounce;
  FormeSearchable._({
    Key? key,
    required String name,
    required List<T> initialValue,
    required this.page,
    required this.condition,
    required this.query,
    required FormeSearchableField<T> child,
    this.maximum,
    this.onMaximumExceed,
    this.searchConditionFilter,
    this.debounce = const Duration(milliseconds: 500),
  }) : super(
            key: key,
            name: name,
            valueUpdater: (oldWidget, newWidget, oldValue) {
              final int? newMaximum = (newWidget as FormeSearchable<T>).maximum;
              if (newMaximum != null && newMaximum > oldValue.length) {
                if (onMaximumExceed == null) {
                  return oldValue.sublist(0, newMaximum);
                }
                final List<T> newValue = onMaximumExceed(oldValue, newMaximum);
                if (newValue.length > newMaximum) {
                  throw Exception(
                      'length of new value which returned by onMaximumExceed should smaller or equals than maximum');
                }
                return newValue;
              }
              return oldValue;
            },
            builder: (genericState) {
              final _FormeSearchableState<T> state =
                  genericState as _FormeSearchableState<T>;
              return FormeSearchableController<T>(
                state.controller,
                state.eventStreamController.stream,
                state.statusStreamController.stream,
                state.status,
                state.didChange,
                state.focusNode,
                child: child,
                maximum: maximum,
              );
            },
            initialValue: initialValue);

  @override
  FormeFieldState<List<T>> createState() => _FormeSearchableState<T>();

  factory FormeSearchable.base({
    required String name,
    int page = 1,
    Map<String, Object?> condition = const {},
    required FormeSearchableQuery<T> query,
    int? maximum,
    List<T> Function(List<T> value, int maximum)? onMaximumExceed,
    FormeSearchableSearchConditionFilter? searchConditionFilter,
  }) {
    return FormeSearchable<T>._(
      name: name,
      query: query,
      searchConditionFilter: searchConditionFilter,
      child: FormeSearchableBaseField<T>(),
      page: page,
      condition: condition,
      maximum: maximum,
      onMaximumExceed: onMaximumExceed,
      initialValue: const [],
    );
  }
}

class _FormeSearchableState<T extends Object> extends FormeFieldState<List<T>>
    with FormeAsyncOperationHelper<FormeSearchablePageResult<T>> {
  late final SearchController controller;
  Timer? _timer;

  SearchCondition? condition;

  @override
  FormeSearchable<T> get widget => super.widget as FormeSearchable<T>;

  late final StreamController<FormeSearchableEvent<T>> eventStreamController;
  late final StreamController<FormeFieldChangedStatus<List<T>>>
      statusStreamController;

  @override
  void initStatus() {
    super.initStatus();
    controller =
        SearchController(SearchCondition(widget.condition, widget.page));
    controller.addListener(() {
      condition = controller.value;
      query();
    });
    eventStreamController = StreamController.broadcast();
    statusStreamController = StreamController.broadcast();
  }

  @override
  void didChange(List<T> newValue) {
    if (widget.maximum != null && newValue.length > widget.maximum!) {
      List<T> finalValue;
      if (widget.onMaximumExceed == null) {
        finalValue = newValue.sublist(0, widget.maximum);
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
    controller.dispose();
    statusStreamController.close();
    eventStreamController.close();
    super.dispose();
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<List<T>> status) {
    super.onStatusChanged(status);
    statusStreamController.add(status);
  }

  void query() {
    if (!mounted) {
      return;
    }
    _timer?.cancel();
    if (widget.searchConditionFilter != null &&
        !widget.searchConditionFilter!(condition!)) {
      cancelAllAsyncOperations();
      eventStreamController.add(
          FormeSearchableEvent.cancel(condition!.page, condition!.condition));
      return;
    }
    _timer = Timer(widget.debounce, () {
      if (mounted) {
        perform(widget.query(condition!.page, condition!.condition));
      }
    });
  }

  @override
  void reset() {
    super.reset();
    controller.value = SearchCondition(widget.condition, widget.page);
  }

  @override
  void onAsyncStateChanged(FormeAsyncOperationState state, Object? key) {
    if (mounted && state == FormeAsyncOperationState.processing) {
      eventStreamController.add(FormeSearchableEvent.processing(
          condition!.page, condition!.condition));
    }
  }

  @override
  void onSuccess(FormeSearchablePageResult<T> result, Object? key) {
    if (mounted) {
      eventStreamController.add(FormeSearchableEvent.success(
          result, condition!.page, condition!.condition));
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (mounted) {
      eventStreamController.add(FormeSearchableEvent.error(
          condition!.page, condition!.condition, error, stackTrace));
    }
  }
}
