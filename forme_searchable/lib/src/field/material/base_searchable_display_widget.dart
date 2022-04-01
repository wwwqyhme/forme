import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import '../../forme_searchable_condition.dart';
import '../../forme_searchable_field.dart';

class BaseSearchableDisplayWidget<T extends Object>
    extends FormeSearchableField<T> {
  final InputDecoration? decoration;
  final InputDecoration? searchFieldDecoration;
  final AutocompleteOptionToString<T> displayStringForOption;
  final double? searchInputStepWidth;
  final double searchInputMinWidth;
  const BaseSearchableDisplayWidget({
    Key? key,
    this.decoration = const InputDecoration(),
    this.searchFieldDecoration,
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
    this.searchInputMinWidth = 50,
    this.searchInputStepWidth,
  }) : super(key: key);
  @override
  FormeSearchableFieldState<T> createState() =>
      _BaseSearchableDisplayWidgetState<T>();
}

class _BaseSearchableDisplayWidgetState<T extends Object>
    extends FormeSearchableFieldState<T> {
  final TextEditingController _controller = TextEditingController();

  @override
  BaseSearchableDisplayWidget<T> get widget =>
      super.widget as BaseSearchableDisplayWidget<T>;
  final FormeKey formeKey = FormeKey();
  Map<String, Object?> get _condition =>
      formeKey.initialized ? formeKey.value : {};

  @override
  void initState() {
    super.initState();
    // if (widget.performSearchAfterInitState) {
    //   WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
    //     _search();
    //   });
    // }
  }

  @override
  void dispose() {
    cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextField textfield = TextField(
      onChanged: (String v) {
        _search();
      },
      decoration: widget.searchFieldDecoration,
      focusNode: focusNode,
      controller: _controller,
      enabled: status.enabled,
      readOnly: status.readOnly,
      onSubmitted: status.readOnly
          ? null
          : (v) {
              _search();
            },
    );

    final Wrap wrap = Wrap(
      spacing: 10,
      children: status.value.map<Widget>((e) {
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
              child: textfield,
            ),
          ),
        ),
    );

    final FormeFieldDecorator<List<T>> decorator = FormeInputDecoratorBuilder(
        decoration: widget.decoration,
        emptyChecker: (value, state) {
          return state.value.isEmpty && _controller.text.isEmpty;
        });
    return decorator.build(context, wrap);
  }

  @override
  void onQueryFail(
      FormeSearchCondition condition, Object error, StackTrace trace) {
    super.onQueryFail(condition, error, trace);
    debugPrint('$error');
    debugPrintStack(stackTrace: trace);
  }

  @override
  void onReset() {
    super.onReset();
    _controller.text = '';
  }

  void _search() {
    if (status.readOnly) {
      return;
    }
    search(FormeSearchCondition(_condition, 1));
  }

  void _delete(T option) {
    final List<T> newValue = List.of(status.value)
      ..removeWhere((element) => element == option);
    if (newValue.length != status.value.length) {
      value = newValue;
    }
  }
}
