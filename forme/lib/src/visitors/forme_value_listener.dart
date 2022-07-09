import 'package:flutter/widgets.dart';

import '../forme_core.dart';
import 'forme_visitor_state.dart';

/// used to listen form value
class FormeValueListener extends StatefulWidget {
  final Widget Function(
      BuildContext context, Map<String, dynamic> value, Widget? child) builder;
  final Widget? child;

  const FormeValueListener({
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FormeValueListenerState();
}

class _FormeValueListenerState extends FormeVisitorState<FormeValueListener> {
  late Map<String, dynamic> value;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }

  @override
  void onFieldStatusChanged(FormeState form, FormeFieldState<dynamic> field,
      FormeFieldChangedStatus<dynamic> newStatus) {
    if (newStatus.isValueChanged) {
      setState(() {
        value = form.value;
      });
    }
  }

  @override
  void onFieldsRegistered(
      FormeState form, List<FormeFieldState<dynamic>> fields) {
    setState(() {
      value = form.value;
    });
  }

  @override
  void onFieldsUnregistered(FormeState form, List<FormeFieldState> states) {
    setState(() {
      value = form.value;
    });
  }

  @override
  void onInitialed(FormeState form) {
    value = form.value;
  }
}
