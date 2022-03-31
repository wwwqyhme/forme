import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import '../../forme_searchable_condition.dart';
import '../../forme_searchable_field.dart';
import '../../forme_searchable_result.dart';
import '../../page_info.dart';
import 'pagination_bar.dart';

enum FormeSearchablePaginationBarPosition {
  top,
  bottom,
}
typedef FormeSearchablePaginationBarBuilder = Widget Function(
    BuildContext context,
    int currentPage,
    int totalPage,
    ValueChanged<int>? onPageChanged);
typedef FormeSearchableSearchFieldsBuilder = Widget Function(
    BuildContext context,
    void Function({bool withDebounce})? query,
    FormeKey formeKey);
typedef FormeSearchableOptionWidgetBuilder<T extends Object> = Widget Function(
    BuildContext context, T option, bool isSelected);

class BaseFieldContent<T extends Object> extends FormeSearchableField<T> {
  /// build pagination bar
  final FormeSearchablePaginationBarBuilder? paginationBarBuilder;
  final FormeSearchablePaginationBarPosition paginationBarPosition;
  final FormePaginationConfiguration? defaultPaginationConfiguration;
  final FormeSearchableSearchFieldsBuilder? searchFieldsBuilder;
  final FormeSearchableOptionWidgetBuilder<T>? optionWidgetBuilder;
  final WidgetBuilder? processingWidgetBuilder;
  final Widget Function(BuildContext context, VoidCallback? refresh)?
      errorWidgetBuilder;
  final InputDecoration? decoration;
  final AutocompleteOptionToString<T> displayStringForOption;
  final WidgetBuilder? emptyContentWidgetBuilder;

  final bool flexiable;
  const BaseFieldContent({
    Key? key,
    required this.displayStringForOption,
    this.paginationBarBuilder,
    this.paginationBarPosition = FormeSearchablePaginationBarPosition.top,
    this.searchFieldsBuilder,
    this.defaultPaginationConfiguration,
    this.optionWidgetBuilder,
    this.processingWidgetBuilder,
    this.decoration,
    this.errorWidgetBuilder,
    this.emptyContentWidgetBuilder,
    this.flexiable = false,
  }) : super(key: key);
  @override
  FormeSearchableFieldState<T> createState() => _BaseFieldContentState<T>();
}

class _BaseFieldContentState<T extends Object>
    extends FormeSearchableFieldState<T> {
  final ValueNotifier<PageInfo?> _paginationNotifier = ValueNotifier(null);
  final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<FormeAsyncOperationState?>
      _asyncOpertionStateNotifier = ValueNotifier(null);

  final TextEditingController _controller = TextEditingController();

  final FormeKey formeKey = FormeKey();

  Map<String, Object?> get _condition =>
      formeKey.initialized ? formeKey.value : {};

  @override
  BaseFieldContent<T> get widget => super.widget as BaseFieldContent<T>;

  bool get readOnly => status.readOnly;

  @override
  void dispose() {
    cancel();
    _controller.dispose();
    _asyncOpertionStateNotifier.dispose();
    _scrollController.dispose();
    _paginationNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _search();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _createSearchFields(),
        if (widget.paginationBarPosition ==
            FormeSearchablePaginationBarPosition.top)
          _createPaginationBar(),
        _createOptionsView(),
        if (widget.paginationBarPosition ==
            FormeSearchablePaginationBarPosition.bottom)
          _createPaginationBar(),
      ],
    );
  }

  Widget _createEmptyContentWidget() {
    return widget.emptyContentWidgetBuilder?.call(context) ??
        const SizedBox.shrink();
  }

  Widget _createPaginationBar() {
    return ValueListenableBuilder<PageInfo?>(
      valueListenable: _paginationNotifier,
      builder: (context, pageInfo, child) {
        if (pageInfo == null || pageInfo.totalPage <= 1) {
          return const SizedBox.shrink();
        }
        if (widget.paginationBarBuilder != null) {
          return widget.paginationBarBuilder!(
              context, pageInfo.currentPage, pageInfo.totalPage, goToPage);
        }
        return FormeSearchablePaginationBar(
          onPageChanged: readOnly ? null : goToPage,
          configuration: widget.defaultPaginationConfiguration ??
              const FormePaginationConfiguration(),
          currentPage: pageInfo.currentPage,
          totalPage: pageInfo.totalPage,
        );
      },
    );
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

  Widget _createErrorWidget() {
    final Widget errorWidget =
        widget.errorWidgetBuilder?.call(context, readOnly ? null : reload) ??
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

  Widget _createOptionsView() {
    return ValueListenableBuilder<FormeAsyncOperationState?>(
      valueListenable: _asyncOpertionStateNotifier,
      builder: (context, state, child) {
        if (state == FormeAsyncOperationState.processing) {
          return _createProcessingWidget();
        }

        if (state == FormeAsyncOperationState.error) {
          return _createErrorWidget();
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

  void _search({bool withDebounce = true}) {
    if (readOnly) {
      return;
    }
    search(FormeSearchCondition(_condition, 1), withDebounce);
    _paginationNotifier.value = null;
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

  Widget _createSearchFields() {
    if (widget.searchFieldsBuilder != null) {
      return widget.searchFieldsBuilder!.call(
          context,
          readOnly
              ? null
              : ({bool withDebounce = true}) =>
                  _search(withDebounce: withDebounce),
          formeKey);
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Forme(
        key: formeKey,
        child: FormeField<String>(
          name: 'query',
          initialValue: '',
          onStatusChanged: (state, status) {
            if (status.isValueChanged) {
              _search();
            }
          },
          builder: (state) {
            return TextField(
              autofocus: true,
              enabled: state.enabled,
              readOnly: state.readOnly,
              controller: _controller,
              decoration:
                  (widget.decoration ?? const InputDecoration()).copyWith(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: state.readOnly
                          ? null
                          : IconButton(
                              onPressed: () {
                                _controller.text = '';
                                state.value = '';
                              },
                              icon: const Icon(Icons.clear))),
              onChanged: (String value) {
                state.value = value;
              },
              onSubmitted: (String value) {
                state.value = value;
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void onQuerySuccess(
      FormeSearchCondition condition, FormeSearchablePageResult<T> result) {
    super.onQuerySuccess(condition, result);
    _asyncOpertionStateNotifier.value = FormeAsyncOperationState.success;
    _paginationNotifier.value = PageInfo(condition.page, result.totalPage);
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
    debugPrint(error.toString());
    _asyncOpertionStateNotifier.value = FormeAsyncOperationState.error;
  }

  @override
  void onQueryCancelled(FormeSearchCondition condition) {
    super.onQueryCancelled(condition);
    _resetPagination();
    _asyncOpertionStateNotifier.value = null;
  }

  @override
  void onReset() {
    super.onReset();
    formeKey.reset();
    _asyncOpertionStateNotifier.value = null;
    _resetPagination();
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<List<T>> status) {
    super.onStatusChanged(status);

    if (status.isReadOnlyChanged && formeKey.initialized) {
      for (final FormeFieldState element in formeKey.fields) {
        element.readOnly = status.readOnly;
      }
    }
  }

  void _resetPagination() {
    _paginationNotifier.value = null;
  }
}
