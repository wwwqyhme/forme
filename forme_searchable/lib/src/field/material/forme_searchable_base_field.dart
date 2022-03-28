import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forme/forme.dart';

import '../../forme_searchable_condition.dart';
import '../../forme_searchable_field.dart';
import '../../forme_searchable_result.dart';
import '../../page_info.dart';
import 'pagination_bar.dart';

typedef FormeSearchableOptionDisplayWidgetBuilder<T extends Object> = Widget
    Function(BuildContext context, T option, ValueChanged<T>? onDelete);
typedef FormeSearchableOptionWidgetBuilder<T extends Object> = Widget Function(
    BuildContext context, T option, bool isSelected, bool isHighlight);
typedef FormeSearchablePaginationBarBuilder = Widget Function(
    BuildContext context,
    ValueListenable<PageInfo> listenable,
    ValueChanged<int>? onPageChanged);

class FormeSearchableBaseField<T extends Object>
    extends FormeSearchableField<T> {
  final AutocompleteOptionToString<T> displayStringForOption;
  final FormeSearchableOptionDisplayWidgetBuilder<T>? displayOptionBuilder;
  final double? searchInputStepWidth;
  final double searchInputMinWidth;
  final InputDecoration? decoration;
  final InputDecoration? searchFieldDecoration;
  final String name;

  /// will not work on web
  final bool searchWhenComposing;

  final double? maxOptionsHeight;

  final bool enableHighlight;
  final FormeSearchableOptionWidgetBuilder<T>? optionWidgetBuilder;
  final bool enablePaginationBarWhenProcessing;
  final FormeSearchablePaginationBarBuilder? paginationBarBuilder;
  const FormeSearchableBaseField({
    Key? key,
    this.decoration = const InputDecoration(),
    this.searchFieldDecoration,
    this.displayOptionBuilder,
    this.searchInputStepWidth,
    this.searchInputMinWidth = 50,
    this.name = 'query',
    this.searchWhenComposing = false,
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
    this.maxOptionsHeight = 300,
    this.enableHighlight = true,
    this.optionWidgetBuilder,
    this.enablePaginationBarWhenProcessing = false,
    this.paginationBarBuilder,
  }) : super(key: key);

  @override
  FormeSearchableFieldState<T> createState() =>
      _FormeSearchableBaseFieldState<T>();
}

class _FormeSearchableBaseFieldState<T extends Object>
    extends FormeSearchableFieldState<T> {
  late final ValueNotifier<bool> _paginationEnableNotifier =
      ValueNotifier(true);
  late final ValueNotifier<FormeAsyncOperationState?>
      _asyncOpertionStateNotifier = ValueNotifier(null);
  late final ValueNotifier<int> _indexNotifier;
  late final Map<Type, Action<Intent>> _actionMap;
  late final CallbackAction<AutocompletePreviousOptionIntent>
      _previousOptionAction;
  late final CallbackAction<AutocompleteNextOptionIntent> _nextOptionAction;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  final ValueNotifier<PageInfo> _paginationNotifier =
      ValueNotifier(PageInfo(1, 1));

  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowUp):
        AutocompletePreviousOptionIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown):
        AutocompleteNextOptionIntent(),
  };

  @override
  void initState() {
    super.initState();
    _indexNotifier = ValueNotifier(widget.enableHighlight ? 0 : -1);
    _previousOptionAction = CallbackAction<AutocompletePreviousOptionIntent>(
        onInvoke: _highlightPreviousOption);
    _nextOptionAction = CallbackAction<AutocompleteNextOptionIntent>(
        onInvoke: _highlightNextOption);
    _actionMap = <Type, Action<Intent>>{
      AutocompletePreviousOptionIntent: _previousOptionAction,
      AutocompleteNextOptionIntent: _nextOptionAction,
    };
  }

  @override
  FormeSearchableBaseField<T> get widget =>
      super.widget as FormeSearchableBaseField<T>;

  Widget createPaginationBar() {
    if (widget.enablePaginationBarWhenProcessing) {
      if (widget.paginationBarBuilder == null) {
        return defaultPaginationBar(true);
      }
      return widget.paginationBarBuilder!(
          context, _paginationNotifier, (int page) => super.page = page);
    }
    return ValueListenableBuilder<bool>(
        valueListenable: _paginationEnableNotifier,
        builder: (context, enabled, child) {
          if (widget.paginationBarBuilder == null) {
            return defaultPaginationBar(enabled);
          }
          return widget.paginationBarBuilder!(context, _paginationNotifier,
              enabled ? (int page) => super.page = page : null);
        });
  }

  Widget defaultPaginationBar(bool enabled) {
    return FormeSearchablePaginationBar(
        onPageChanged: !enabled
            ? null
            : (int page) {
                super.page = page;
              },
        configuration: const FormePaginationConfiguration(),
        notifier: _paginationNotifier);
  }

  @override
  Widget build(BuildContext context) {
    final TextField textfield = TextField(
      onChanged: (String v) {
        _search(1);
      },
      decoration: widget.searchFieldDecoration,
      focusNode: focusNode,
      controller: _textEditingController,
      enabled: status.enabled,
      readOnly: status.readOnly,
      onSubmitted: status.readOnly
          ? null
          : (v) {
              WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                focusNode.requestFocus();
              });
              if (!hasResult || result!.datas.isEmpty) {
                return;
              }
              final int highlighIndex = _indexNotifier.value;
              if (highlighIndex == -1 ||
                  highlighIndex >= result!.datas.length) {
                return;
              }
              _toggle(highlighIndex);
            },
    );

    final Wrap wrap = Wrap(
      spacing: 10,
      children: status.value.map<Widget>((e) {
        if (widget.displayOptionBuilder != null) {
          return widget.displayOptionBuilder!(
              context, e, status.readOnly ? null : _delete);
        }

        return InputChip(
          label: Text(widget.displayStringForOption(e)),
          onDeleted: status.readOnly
              ? null
              : () {
                  _delete(e);
                },
        );
      }).toList()
        ..add(
          IntrinsicWidth(
            stepWidth: widget.searchInputStepWidth,
            child: Container(
              constraints: BoxConstraints(minWidth: widget.searchInputMinWidth),
              child: Shortcuts(
                shortcuts: widget.enableHighlight && !status.readOnly
                    ? _shortcuts
                    : {},
                child: Actions(
                  actions: widget.enableHighlight && !status.readOnly
                      ? _actionMap
                      : {},
                  child: textfield,
                ),
              ),
            ),
          ),
        ),
    );

    final FormeFieldDecorator<List<T>> decorator = FormeInputDecoratorBuilder(
        decoration: widget.decoration,
        emptyChecker: (value, state) {
          return state.value.isEmpty && _textEditingController.text.isEmpty;
        });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            focusNode.requestFocus();
          },
          child: decorator.build(context, wrap),
        ),
        ValueListenableBuilder<FormeAsyncOperationState?>(
          valueListenable: _asyncOpertionStateNotifier,
          builder: (context, state, child) {
            if (state == null) {
              return const SizedBox.shrink();
            }
            return Material(
              elevation: 4,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: widget.maxOptionsHeight ?? double.infinity),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lastNonnullResult != null &&
                          lastNonnullResult!.totalPage > 1)
                        createPaginationBar(),
                      if (isProcessing)
                        const SizedBox(
                          width: double.maxFinite,
                          child: Center(
                              child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          )),
                        ),
                      if (hasResult)
                        AutocompleteHighlightedOption(
                          highlightIndexNotifier: _indexNotifier,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: result!.datas.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final T option = result!.datas[index];
                              final bool highlight =
                                  AutocompleteHighlightedOption.of(context) ==
                                      index;
                              if (highlight) {
                                WidgetsBinding.instance!
                                    .addPostFrameCallback((timeStamp) {
                                  _scrollController.position.ensureVisible(
                                    context.findRenderObject()!,
                                    alignment: 0.5,
                                  );
                                });
                              }
                              final bool isSelected =
                                  status.value.contains(option);
                              Widget optionWidget;
                              if (widget.optionWidgetBuilder != null) {
                                optionWidget = widget.optionWidgetBuilder!(
                                    context, option, isSelected, highlight);
                              } else {
                                optionWidget = Container(
                                  color: highlight
                                      ? Theme.of(context).focusColor
                                      : null,
                                  child: ListTile(
                                    leading: isSelected
                                        ? const Icon(Icons.check_circle)
                                        : null,
                                    title: Text('$option'),
                                  ),
                                );
                              }
                              return InkWell(
                                onTap: status.readOnly
                                    ? null
                                    : () {
                                        _toggle(index);
                                      },
                                child: optionWidget,
                              );
                            },
                          ),
                        )
                    ]),
              ),
            );
          },
        ),
      ],
    );
  }

  void _search([int? page]) {
    if (_textEditingController.value.composing != TextRange.empty &&
        !widget.searchWhenComposing) {
      return;
    }
    super.condition = FormeSearchCondition(
        {widget.name: _textEditingController.text}, page ?? 1);
  }

  void _toggle(int index) {
    final T highlight = result!.datas[index];
    final List<T> value = List.of(status.value);
    if (value.remove(highlight)) {
      super.value = value;
    } else {
      super.value = value..add(highlight);
    }
  }

  void _updateHighlight(int newIndex) {
    _indexNotifier.value = newIndex;
  }

  void _highlightPreviousOption(AutocompletePreviousOptionIntent intent) {
    if (_indexNotifier.value == 0) {
      return;
    }
    _updateHighlight(_indexNotifier.value - 1);
  }

  void _highlightNextOption(AutocompleteNextOptionIntent intent) {
    final int? dataLength = result?.datas.length;
    if (dataLength == null || _indexNotifier.value == dataLength - 1) {
      return;
    }
    _updateHighlight(_indexNotifier.value + 1);
  }

  void _delete(T option) {
    final List<T> newValue = List.of(status.value)
      ..removeWhere((element) => element == option);
    if (newValue.length != status.value.length) {
      value = newValue;
    }
  }

  @override
  void onQuerySuccess(
      FormeSearchCondition condition, FormeSearchablePageResult<T> result) {
    super.onQuerySuccess(condition, result);
    _indexNotifier.value = result.datas.isNotEmpty ? 0 : -1;
    _asyncOpertionStateNotifier.value = FormeAsyncOperationState.success;
    _paginationEnableNotifier.value = true;
  }

  @override
  void onQueryProcessing(FormeSearchCondition condition) {
    super.onQueryProcessing(condition);
    _indexNotifier.value = -1;
    _asyncOpertionStateNotifier.value = FormeAsyncOperationState.processing;
    _paginationEnableNotifier.value = false;
  }

  @override
  void onQueryFail(
      FormeSearchCondition condition, Object error, StackTrace trace) {
    super.onQueryFail(condition, error, trace);
    debugPrint(error.toString());
    _indexNotifier.value = -1;
    _asyncOpertionStateNotifier.value = FormeAsyncOperationState.error;
    _paginationEnableNotifier.value = true;
  }

  // @override
  // void onCancel(FormeSearchCondition condition) {
  //   _indexNotifier.value = -1;
  //   _asyncOpertionStateNotifier.value = null;
  //   _paginationEnableNotifier.value = true;
  // }

  @override
  void onQueryComplete(FormeSearchCondition condition) {
    super.onQueryComplete(condition);
    if (lastNonnullResult != null) {
      _paginationNotifier.value =
          PageInfo(condition.page, lastNonnullResult!.totalPage);
    }
    final String query = condition.getCondition(widget.name) ?? '';
    if (_textEditingController.text != query) {
      _textEditingController.text = query;
    }
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<List<T>> status) {
    super.onStatusChanged(status);
    if (status.isFocusChanged && status.hasFocus) {
      _search();
    }
  }

  @override
  void dispose() {
    _paginationEnableNotifier.dispose();
    _paginationNotifier.dispose();
    _scrollController.dispose();
    _textEditingController.dispose();
    _asyncOpertionStateNotifier.dispose();
    super.dispose();
  }

  @override
  void onReset() {
    _textEditingController.text = '';
  }
}
