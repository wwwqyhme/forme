import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import '../../forme_searchable_condition.dart';
import '../../forme_searchable_field.dart';
import '../../forme_searchable_result.dart';

typedef FormeSearchableOptionWidgetBuilder<T extends Object> = Widget Function(
    BuildContext context, T option, bool isSelected);
typedef FormeSearchableErrorWidgetBuilder = Widget Function(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
    VoidCallback? refresh);

class BaseFieldContent<T extends Object> extends FormeSearchableField<T> {
  /// build pagination bar
  final FormeSearchableOptionWidgetBuilder<T>? optionWidgetBuilder;
  final WidgetBuilder? processingWidgetBuilder;
  final FormeSearchableErrorWidgetBuilder? errorWidgetBuilder;
  final AutocompleteOptionToString<T> displayStringForOption;
  final WidgetBuilder? emptyContentWidgetBuilder;

  final bool flexiable;
  const BaseFieldContent({
    Key? key,
    required this.displayStringForOption,
    this.optionWidgetBuilder,
    this.processingWidgetBuilder,
    this.errorWidgetBuilder,
    this.emptyContentWidgetBuilder,
    this.flexiable = false,
  }) : super(key: key);
  @override
  FormeSearchableFieldState<T> createState() => _BaseFieldContentState<T>();
}

class _BaseFieldContentState<T extends Object>
    extends FormeSearchableFieldState<T> {
  final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<FormeAsyncOperationState?>
      _asyncOpertionStateNotifier = ValueNotifier(null);

  @override
  BaseFieldContent<T> get widget => super.widget as BaseFieldContent<T>;

  bool get readOnly => status.readOnly;

  @override
  void dispose() {
    _asyncOpertionStateNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FormeAsyncOperationState?>(
      valueListenable: _asyncOpertionStateNotifier,
      builder: (context, state, child) {
        if (state == FormeAsyncOperationState.processing) {
          return _createProcessingWidget();
        }

        if (state == FormeAsyncOperationState.error) {
          return _createErrorWidget(error!, stackTrace!);
        }

        if (state == FormeAsyncOperationState.success) {
          if (result!.datas.isEmpty) {
            return _createEmptyContentWidget();
          }
          return Flexible(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: result!.datas.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final T option = result!.datas[index];
                final bool isSelected = status.value.contains(option);
                Widget optionWidget;
                if (widget.optionWidgetBuilder != null) {
                  optionWidget =
                      widget.optionWidgetBuilder!(context, option, isSelected);
                } else {
                  optionWidget = ListTile(
                    leading: isSelected ? const Icon(Icons.check_circle) : null,
                    title: Text(widget.displayStringForOption(option)),
                  );
                }
                return InkWell(
                  onTap: readOnly
                      ? null
                      : () {
                          _toggle(index);
                        },
                  child: optionWidget,
                );
              },
            ),
          );
        }
        return Container(
          width: double.maxFinite,
        );
      },
    );
  }

  Widget _createEmptyContentWidget() {
    return widget.emptyContentWidgetBuilder?.call(context) ??
        const SizedBox.shrink();
  }

  Widget _createProcessingWidget() {
    final Widget processingWidget =
        widget.processingWidgetBuilder?.call(context) ??
            const SizedBox(
              width: double.maxFinite,
              child: Center(
                  child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )),
            );

    return widget.flexiable
        ? Flexible(child: processingWidget)
        : processingWidget;
  }

  Widget _createErrorWidget(Object error, StackTrace stackTrace) {
    final Widget errorWidget = widget.errorWidgetBuilder
            ?.call(context, error, stackTrace, readOnly ? null : reload) ??
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                Icons.error,
                size: 36,
                color: Theme.of(context).errorColor,
              ),
              IconButton(
                  onPressed: readOnly ? null : reload,
                  icon: Icon(
                    Icons.refresh,
                    color: Theme.of(context).primaryColor,
                  )),
            ]),
          ),
        );
    return widget.flexiable ? Flexible(child: errorWidget) : errorWidget;
  }

  void _toggle(int index) {
    if (readOnly) {
      return;
    }
    final T highlight = result!.datas[index];
    final List<T> value = List.of(status.value);
    if (value.remove(highlight)) {
      super.value = value;
    } else {
      super.value = value..add(highlight);
    }
  }

  @override
  void onQuerySuccess(
      FormeSearchCondition condition, FormeSearchablePageResult<T> result) {
    super.onQuerySuccess(condition, result);
    _asyncOpertionStateNotifier.value = FormeAsyncOperationState.success;
  }

  @override
  void onQueryProcessing(FormeSearchCondition condition) {
    super.onQueryProcessing(condition);
    _asyncOpertionStateNotifier.value = FormeAsyncOperationState.processing;
  }

  @override
  void onQueryFail(
      FormeSearchCondition condition, Object error, StackTrace trace) {
    super.onQueryFail(condition, error, trace);
    _asyncOpertionStateNotifier.value = FormeAsyncOperationState.error;
  }

  @override
  void onQueryCancelled(FormeSearchCondition condition) {
    super.onQueryCancelled(condition);
    _asyncOpertionStateNotifier.value = null;
  }

  @override
  void onReset() {
    super.onReset();
    _asyncOpertionStateNotifier.value = null;
  }
}
