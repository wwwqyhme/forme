import 'package:flutter/widgets.dart';

import 'forme_controller.dart';
import 'forme_core.dart';
import 'visitor/forme_visitor.dart';

/// useful when you want to create a widget depends on [Forme.isValueChanged]
///
/// will rebuild everytimes when [Forme.isValueChanged] changed
class FormeIsValueChanged extends StatefulWidget {
  final Widget Function(BuildContext context, bool isValueChanged) builder;
  const FormeIsValueChanged({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FormeIsValueChangeState();
}

class _FormeIsValueChangeState extends State<FormeIsValueChanged>
    with FormeVisitor {
  final ValueNotifier<bool> isValueChangedNotifier = ValueNotifier(false);

  late final FormeController controller;

  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _inited = true;
      controller = Forme.of(context)!;
      controller.addVisitor(this);
    }
  }

  @override
  void dispose() {
    controller.removeVisitor(this);
    isValueChangedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: isValueChangedNotifier,
        builder: (context, isValueChanged, child) {
          return widget.builder(context, isValueChanged);
        });
  }

  @override
  void onFieldsRegistered(
      FormeController form, List<FormeFieldController<Object?>> fields) {
    isValueChangedNotifier.value = form.isValueChanged;
  }

  @override
  void onFieldsStatusChanged(
      FormeController form,
      FormeFieldController<Object?> field,
      FormeFieldStatus<Object?> oldStatus,
      FormeFieldStatus<Object?> newStatus) {
    isValueChangedNotifier.value = form.isValueChanged;
  }

  @override
  void onFieldsUnregistered(FormeController form, List<String> names) {
    isValueChangedNotifier.value = form.isValueChanged;
  }
}
