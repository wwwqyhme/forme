import 'package:flutter/material.dart';
import 'package:forme/forme.dart';
import 'package:forme_searchable/src/forme_searchable_controller.dart';

import '../../forme_searchable_field.dart';
import '../../forme_searchable_result.dart';

typedef FormeSearchableOptionDisplayWidgetBuilder<T extends Object> = Widget
    Function(BuildContext context, T option, ValueChanged<T>? onDelete);

class FormeSearchableBaseField<T extends Object>
    extends FormeSearchableField<T> {
  final AutocompleteOptionToString<T> displayStringForOption;
  final FormeSearchableOptionDisplayWidgetBuilder<T>? displayOptionBuilder;
  final double? searchInputStepWidth;
  final double searchInputMinWidth;
  final InputDecoration? decoration;
  final InputDecoration? searchFieldDecoration;
  final String name;
  const FormeSearchableBaseField({
    Key? key,
    this.decoration = const InputDecoration(),
    this.searchFieldDecoration,
    this.displayOptionBuilder,
    this.searchInputStepWidth,
    this.searchInputMinWidth = 50,
    this.name = 'query',
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
  }) : super(key: key);

  @override
  FormeSearchableFieldState<T> createState() =>
      _FormeSearchableBaseFieldState<T>();
}

class _FormeSearchableBaseFieldState<T extends Object>
    extends FormeSearchableFieldState<T> {
  @override
  FormeSearchableBaseField<T> get widget =>
      super.widget as FormeSearchableBaseField<T>;

  final TextEditingController textEditingController = TextEditingController();

  void _search() {
    final Map<String, Object?> condition = {
      widget.name: textEditingController.value
    };
    controller.value = SearchCondition(condition, 1);
  }

  void _delete(T option) {
    final List<T> value = List.of(status.value)
      ..removeWhere((element) => element == option);
    super.value = value;
  }

  @override
  Widget build(BuildContext context) {
    final TextField textfield = TextField(
      decoration: widget.searchFieldDecoration,
      focusNode: focusNode,
      controller: textEditingController,
      enabled: status.enabled,
      readOnly: status.readOnly,
      onSubmitted: status.readOnly
          ? null
          : (v) {
              _search();
            },
    );

    final Wrap wrap = Wrap(
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
              child: textfield,
            ),
          ),
        ),
    );

    final FormeFieldDecorator<List<T>> decorator = FormeInputDecoratorBuilder(
        decoration: widget.decoration?.copyWith(
            suffixIcon: isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : null,
            suffixIconConstraints:
                isProcessing ? const BoxConstraints.tightFor() : null),
        emptyChecker: (value, state) {
          return state.value.isEmpty && textEditingController.text.isEmpty;
        });

    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
      },
      child: decorator.build(context, wrap),
    );
  }

  void onDelete(T option) {
    final List<T> newValue = List.of(status.value)
      ..removeWhere((element) => element == option);
    if (newValue.length != status.value.length) {
      value = newValue;
    }
  }

  @override
  void onData(int page, Map<String, Object?> condition,
      FormeSearchablePageResult<T> result) {
    setState(() {});
  }

  @override
  void onProcessing(int page, Map<String, Object?> condition) {
    setState(() {});
  }

  @override
  void onError(int page, Map<String, Object?> condition, Object error,
      StackTrace stackTrace) {
    debugPrint(error.toString());
    setState(() {});
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}
