import 'package:flutter/widgets.dart';

import '../forme_core.dart';
import 'forme_visitor_state.dart';

/// useful when you want to create a widget depends on [FormeState.isValueChanged]
///
/// will rebuild everytimes when [Forme.isValueChanged] changed
///
/// **this widget must be used inside [Forme]**
class FormeIsValueChangedListener extends StatefulWidget {
  final FormeKey? formeKey;
  final Widget Function(BuildContext context, bool isValueChanged) builder;
  const FormeIsValueChangedListener({
    Key? key,
    required this.builder,
    this.formeKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FormeIsValueChangeState();
}

class _FormeIsValueChangeState
    extends FormeVisitorState<FormeIsValueChangedListener> {
  bool isValueChanged = false;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, isValueChanged);
  }

  @override
  void onFieldsRegistered(
      FormeState form, List<FormeFieldState<Object?>> fields) {
    checkIsValueChanged(form);
  }

  @override
  void onFieldStatusChanged(FormeState form, FormeFieldState<Object?> field,
      FormeFieldChangedStatus<Object?> newStatus) {
    if (newStatus.isValueChanged) {
      checkIsValueChanged(form);
    }
  }

  @override
  void onFieldsUnregistered(FormeState form, List<FormeFieldState> states) {
    checkIsValueChanged(form);
  }

  @override
  void onInitialed(FormeState form) {
    isValueChanged = form.isValueChanged;
  }

  void checkIsValueChanged(FormeState form) {
    final bool isValueChanged = form.isValueChanged;
    if (isValueChanged != this.isValueChanged) {
      setState(() {
        this.isValueChanged = isValueChanged;
      });
    }
  }
}
