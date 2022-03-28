import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';

import 'field/material/forme_searchable_base_field.dart';
import 'forme_searchable_condition.dart';
import 'forme_searchable_writer.dart';
import 'forme_searchable_controller.dart';
import 'forme_searchable_result.dart';
import 'forme_searchable_reader.dart';

typedef FormeSearchableQuery<T extends Object>
    = Future<FormeSearchablePageResult<T>> Function(
        FormeSearchCondition condition);

class FormeSearchable<T extends Object> extends FormeField<List<T>> {
  final FormeSearchableQuery<T> query;
  final int? maximum;
  final List<T> Function(List<T> value, int maximum)? onMaximumExceed;
  final Duration debounce;
  FormeSearchable._({
    Key? key,
    required String name,
    required List<T> initialValue,
    required this.query,
    required Widget child,
    this.maximum,
    this.onMaximumExceed,
    required this.debounce,
  }) : super(
            key: key,
            name: name,
            valueUpdater: (oldWidget, newWidget, oldValue) {
              final int? newMaximum = (newWidget as FormeSearchable<T>).maximum;
              if (newMaximum != null && oldValue.length > newMaximum) {
                if (onMaximumExceed == null) {
                  return oldValue.sublist(oldValue.length - newMaximum);
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
                state._writer,
                state.focusNode,
                state.status,
                child: child,
              );
            },
            initialValue: initialValue);

  @override
  FormeFieldState<List<T>> createState() => _FormeSearchableState<T>();

  factory FormeSearchable.base({
    required String name,
    required FormeSearchableQuery<T> query,
    int? maximum,
    List<T> Function(List<T> value, int maximum)? onMaximumExceed,
    Duration? debounce,
  }) {
    return FormeSearchable<T>._(
      name: name,
      query: query,
      debounce: debounce ?? const Duration(milliseconds: 500),
      child: FormeSearchableBaseField<T>(),
      maximum: maximum,
      onMaximumExceed: onMaximumExceed,
      initialValue: const [],
    );
  }
}

class _FormeSearchableState<T extends Object> extends FormeFieldState<List<T>>
    with FormeAsyncOperationHelper<FormeSearchablePageResult<T>> {
  Timer? _timer;

  final List<FormeSearchableReader<T>> readers = [];

  @override
  FormeSearchable<T> get widget => super.widget as FormeSearchable<T>;

  late FormeSearchableWriter<T> _writer;

  FormeSearchCondition? _condition;
  FormeSearchCondition get condition => _condition!;

  @override
  void initStatus() {
    super.initStatus();
    _writer = FormeSearchableWriter<T>(
        onChanged: OnChanged(
      onPageChanged: (int page) {
        _condition = FormeSearchCondition(_condition?.condition ?? {}, page);
        pageChange();
      },
      onConditionChanged: (FormeSearchCondition condition) {
        _condition = condition;
        query();
      },
      onValueChanged: (List<T> newValue) {
        if (mounted) {
          didChange(newValue);
        }
      },
      onReaderAdd: (FormeSearchableReader<T> reader) {
        if (mounted) {
          addReader(reader);
        }
      },
      onReaderRemove: (FormeSearchableReader<T> reader) {
        if (mounted) {
          removeReader(reader);
        }
      },
    ));
  }

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
      for (final FormeSearchableReader<T> reader in readers) {
        reader.onFocusNodeChanged(node);
      }
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
    for (final FormeSearchableReader<T> reader in readers) {
      reader.onStatusChanged(status);
    }
  }

  void pageChange() {
    if (!mounted) {
      return;
    }
    _timer?.cancel();
    for (final FormeSearchableReader<T> reader in readers) {
      reader.onQueryProcessing(condition);
    }
    perform(widget.query(condition));
  }

  void query() {
    if (!mounted) {
      return;
    }
    _timer?.cancel();
    for (final FormeSearchableReader<T> reader in readers) {
      reader.onQueryProcessing(condition);
    }
    _timer = Timer(widget.debounce, () {
      if (mounted) {
        perform(widget.query(condition));
      }
    });
  }

  @override
  void reset() {
    super.reset();
    for (final FormeSearchableReader<T> reader in readers) {
      reader.onReset();
    }
  }

  @override
  void onAsyncStateChanged(FormeAsyncOperationState state, Object? key) {}

  @override
  void onSuccess(FormeSearchablePageResult<T> result, Object? key) {
    if (mounted) {
      for (final FormeSearchableReader<T> reader in readers) {
        reader.onQuerySuccess(condition, result);
      }
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (mounted) {
      for (final FormeSearchableReader<T> reader in readers) {
        reader.onQueryFail(condition, error, stackTrace);
      }
    }
  }

  void addReader(FormeSearchableReader<T> reader) {
    readers.add(reader);
  }

  void removeReader(FormeSearchableReader<T> reader) {
    readers.remove(reader);
  }
}
