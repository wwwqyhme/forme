import 'package:flutter/material.dart';
import 'package:forme/forme.dart';
import 'package:forme_searchable/src/forme_searchable_state.dart';

class BaseDisplayWidget<T extends Object> extends StatelessWidget {
  final ValueChanged<T>? delete;
  final FocusNode focusNode;
  final AutocompleteOptionToString<T> displayStringForOption;
  final FormeSearchableStatus<T> status;
  final InputDecoration? decoration;

  const BaseDisplayWidget({
    Key? key,
    required this.status,
    required this.delete,
    required this.focusNode,
    required this.displayStringForOption,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Wrap wrap = Wrap(
      spacing: 10,
      children: status.value.map<Widget>((e) {
        return InputChip(
          label: Text(displayStringForOption(e)),
          onDeleted: delete == null ? null : () => delete!(e),
        );
      }).toList(),
    );
    final FormeFieldDecorator<List<T>> decorator = FormeInputDecoratorBuilder(
        decoration: decoration ??
            InputDecoration(
                errorText: status.validation.error,
                suffixIcon: const Icon(Icons.search)),
        maxLength: status.maximum,
        counter: (value) => value.length,
        emptyChecker: (value, state) {
          return state.value.isEmpty;
        });
    return decorator.build(context, wrap);
  }
}
