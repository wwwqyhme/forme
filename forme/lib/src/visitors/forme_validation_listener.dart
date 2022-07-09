import 'package:flutter/widgets.dart';

import '../forme_core.dart';
import '../validate/forme_validation.dart';
import 'forme_visitor_state.dart';

class FormeValidationListener extends StatefulWidget {
  final Widget Function(
      BuildContext context, FormeValidation value, Widget? child) builder;
  final Widget? child;

  const FormeValidationListener({
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FormeValidationListenerState();
}

class _FormeValidationListenerState
    extends FormeVisitorState<FormeValidationListener> {
  late FormeValidation value;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }

  @override
  void onFieldStatusChanged(FormeState form, FormeFieldState<dynamic> field,
      FormeFieldChangedStatus<dynamic> newStatus) {
    if (newStatus.isValidationChanged) {
      setState(() {
        value = form.validation;
      });
    }
  }

  @override
  void onFieldsRegistered(
      FormeState form, List<FormeFieldState<dynamic>> fields) {
    setState(() {
      value = form.validation;
    });
  }

  @override
  void onFieldsUnregistered(FormeState form, List<FormeFieldState> states) {
    setState(() {
      value = form.validation;
    });
  }

  @override
  void onInitialed(FormeState form) {
    value = form.validation;
  }
}
