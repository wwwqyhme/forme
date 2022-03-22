import 'package:flutter/widgets.dart';

import '../forme_core.dart';
import '../validate/forme_validation.dart';
import 'forme_visitor_state.dart';

/// used to listen multi field validation change
///
///
/// eg:
///
/// ``` Dart
/// FormeFieldsValidationListener(
///       names: const {'password', 'confirm'},
///       builder: (context, validation) {
///         if (validation == null) {
///           return const SizedBox();
///         }
///         if (validation.isInvalid) {
///           return Padding(
///             padding: const EdgeInsets.only(left: 24),
///             child: Text(
///               validation.validations.values
///                   .where((element) => element.isInvalid)
///                   .first
///                   .error!,
///               style: _getErrorStyle(),
///             ),
///           );
///         }
///         return const SizedBox.shrink();
///       },
///     ),
/// ```
class FormeFieldsValidationListener extends StatefulWidget {
  final Set<String> names;
  final Widget Function(BuildContext context, FormeValidation? validation)
      builder;

  const FormeFieldsValidationListener({
    Key? key,
    required this.names,
    required this.builder,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FormeFieldsValidationListenerState();
}

class _FormeFieldsValidationListenerState
    extends FormeVisitorState<FormeFieldsValidationListener> {
  FormeValidation? _validation;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _validation);
  }

  @override
  void onFieldStatusChanged(FormeState form, FormeFieldState<Object?> field,
      FormeFieldChangedStatus<Object?> newStatus) {
    if (widget.names.contains(field.name) && newStatus.isValidationChanged) {
      updateValidation(form);
    }
  }

  @override
  void onFieldsRegistered(
      FormeState form, List<FormeFieldState<Object?>> fields) {
    if (fields.any((element) => widget.names.contains(element.name))) {
      updateValidation(form);
    }
  }

  @override
  void onFieldsUnregistered(FormeState form, List<FormeFieldState> states) {
    if (states
        .map((e) => e.name)
        .any((element) => widget.names.contains(element))) {
      updateValidation(form);
    }
  }

  void updateValidation(FormeState form) {
    final Map<String, FormeFieldValidation> validationMap = {};
    for (final String name in widget.names) {
      if (form.hasField(name)) {
        validationMap[name] = form.field(name).validation;
      }
    }
    setState(() {
      _validation = FormeValidation(validationMap);
    });
  }

  @override
  void onInitialed(FormeState form) {
    _validation = form.validation;
  }
}
