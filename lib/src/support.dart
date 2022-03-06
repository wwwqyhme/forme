import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';

/// useful when you want to create a widget depends on [Forme.isValueChanged]
///
/// will rebuild everytimes when [Forme.isValueChanged] changed
class FormeIsValueChangedListener extends StatefulWidget {
  final Widget Function(BuildContext context, bool isValueChanged) builder;
  const FormeIsValueChangedListener({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FormeIsValueChangeState();
}

class _FormeIsValueChangeState
    extends _FormeVisitorState<FormeIsValueChangedListener> {
  bool isValueChanged = false;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, isValueChanged);
  }

  @override
  void onFieldsRegistered(
      FormeController form, List<FormeFieldController<Object?>> fields) {
    checkIsValueChanged(form);
  }

  @override
  void onFieldStatusChanged(
      FormeController form,
      FormeFieldController<Object?> field,
      FormeFieldStatus<Object?> oldStatus,
      FormeFieldStatus<Object?> newStatus) {
    if (oldStatus.value != newStatus.value) {
      checkIsValueChanged(form);
    }
  }

  @override
  void onFieldsUnregistered(FormeController form, List<String> names) {
    checkIsValueChanged(form);
  }

  void checkIsValueChanged(FormeController form) {
    final bool isValueChanged = form.isValueChanged;
    if (isValueChanged != this.isValueChanged) {
      setState(() {
        this.isValueChanged = isValueChanged;
      });
    }
  }
}

/// this widget used to listen forme field value change
///
/// eg:
/// ``` Dart
/// FormeFieldValueListener<String>(
///   name: 'fieldName',
///   builder: (context, field, value) {
///     if (field == null) {
///       return const SizedBox.shrink();
///     }
///     return Text(value!);
///   }),
/// ```
/// no need to care about order of fields
///
/// **this widget must used inside in  [Forme] or [FormeField]**
class FormeFieldValueListener<T extends Object?> extends StatelessWidget {
  final String name;
  final Widget? child;

  /// if field is null ,means field is not created or has been disposed...
  final Widget Function(
    BuildContext context,
    FormeFieldController<T>? field,
    T? value,
  ) builder;

  const FormeFieldValueListener({
    Key? key,
    required this.name,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FormeFieldController<T>? fieldController = FormeField.of(context);

    if (fieldController != null && fieldController.name == name) {
      return ValueListenableBuilder<T>(
          child: child,
          valueListenable: fieldController.valueListenable,
          builder: (context, value, child) {
            return builder(context, fieldController, value);
          });
    }

    final FormeController controller = Forme.of(context)!;
    return ValueListenableBuilder<FormeFieldController<T>?>(
        valueListenable: controller.fieldListenable<T>(name),
        builder: (context, field, child) {
          if (field == null) {
            return builder(context, field, null);
          }
          return ValueListenableBuilder<T>(
              valueListenable: field.valueListenable,
              child: child,
              builder: (context, value, child) {
                return builder(context, field, value);
              });
        });
  }
}

/// used to listen form value
class FormeValueListener extends StatefulWidget {
  final Widget Function(BuildContext context, Map<String, Object?>? value)
      builder;

  const FormeValueListener({
    Key? key,
    required this.builder,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FormeValueListenerState();
}

class _FormeValueListenerState extends _FormeVisitorState<FormeValueListener> {
  Map<String, Object?>? value;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value == null ? null : Map.from(value!));
  }

  @override
  void onFieldStatusChanged(
      FormeController form,
      FormeFieldController<Object?> field,
      FormeFieldStatus<Object?> oldStatus,
      FormeFieldStatus<Object?> newStatus) {
    if (oldStatus.value != newStatus.value) {
      setState(() {
        value = form.value;
      });
    }
  }

  @override
  void onFieldsRegistered(
      FormeController form, List<FormeFieldController<Object?>> fields) {
    setState(() {
      value = form.value;
    });
  }

  @override
  void onFieldsUnregistered(FormeController form, List<String> names) {
    setState(() {
      value = form.value;
    });
  }
}

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
    extends _FormeVisitorState<FormeFieldsValidationListener> {
  FormeValidation? _validation;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _validation);
  }

  @override
  void onFieldStatusChanged(
      FormeController form,
      FormeFieldController<Object?> field,
      FormeFieldStatus<Object?> oldStatus,
      FormeFieldStatus<Object?> newStatus) {
    if (widget.names.contains(field.name) &&
        oldStatus.validation != newStatus.validation) {
      updateValidation(form);
    }
  }

  @override
  void onFieldsRegistered(
      FormeController form, List<FormeFieldController<Object?>> fields) {
    if (fields.any((element) => widget.names.contains(element.name))) {
      updateValidation(form);
    }
  }

  @override
  void onFieldsUnregistered(FormeController form, List<String> names) {
    if (names.any((element) => widget.names.contains(element))) {
      updateValidation(form);
    }
  }

  void updateValidation(FormeController form) {
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
}

abstract class _FormeVisitorState<T extends StatefulWidget> extends State<T>
    with FormeVisitor {
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
    super.dispose();
  }
}
