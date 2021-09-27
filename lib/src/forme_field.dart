import 'package:flutter/cupertino.dart';
import '../forme.dart';
import 'forme_field_scope.dart';

typedef FormeValueChanged<T> = void Function(
    FormeFieldController<T>, T newValue);
typedef FormeAsyncValidator<T> = Future<String?> Function(
    FormeFieldController<T> field, T value);
typedef FormeValidator<T> = String? Function(
    FormeFieldController<T> field, T value);
typedef FormeFieldValidationInfoChanged<T> = void Function(
    FormeFieldController<T> field, FormeFieldValidationInfo info);
typedef FormeFieldSetter<T> = void Function(
    FormeFieldController<T> field, T value);
typedef FormeValueComparator<T> = bool Function(T oldValue, T newValue);
typedef FormeFocusChanged<T> = void Function(
    FormeFieldController<T> field, bool hasFocus);
typedef FormeFieldInitialed<T> = void Function(FormeFieldController<T> field);
typedef FormeFieldBuilder<T> = Widget Function(FormeFieldState<T> state);

class FormeField<T> extends StatefulWidget {
  final String name;
  final bool readOnly;
  final FormeFieldBuilder<T> builder;
  final bool enabled;
  final T initialValue;

  /// comparator is used to check whether value changed
  final FormeValueComparator<T>? comparator;

  /// used to support [Forme.autovalidateByOrder]
  ///
  /// **if not specified  , will use the order registered to [Forme]**
  final int? order;

  /// quietlyValidate
  ///
  /// final value is [Forme.quietlyValidate] || [FormeField.quietlyValidate]
  final bool quietlyValidate;
  final Duration? asyncValidatorDebounce;
  final AutovalidateMode autovalidateMode;
  final FormeValueChanged<T>? onValueChanged;
  final FormeFocusChanged<T>? onFocusChanged;

  /// used to listen field's validate errorText changed
  ///
  /// triggered when:
  ///
  /// 1. if autovalidateMode is not disabled, **in this case, will triggered after current frame completed**
  /// 2. after called [FormeFieldController.validate] method
  ///
  /// **errorText will be null if field's errorText from nonnull to null**
  final FormeFieldValidationInfoChanged<T>? onValidationInfoChanged;

  /// called after [FormeController] or [FormeFieldController] initialed
  ///
  /// valueListenable will not listen [FormeField.initialValue] , you can do
  /// that in this method
  ///
  /// **try to get another field's controller in this method will cause an error**
  final FormeFieldInitialed<T>? onInitialed;

  final FormeValidator<T>? validator;

  /// used to perform an async validate
  ///
  /// if you specific both asyncValidator and validator , asyncValidator will only worked after validator passed
  final FormeAsyncValidator<T>? asyncValidator;
  final FormeFieldSetter<T>? onSaved;

  /// used to decorate a field
  final FormeFieldDecorator<T>? decorator;

  /// whether request focus when field value changed
  final bool requestFocusOnUserInteraction;

  const FormeField({
    Key? key,
    required this.name,
    this.readOnly = false,
    required this.builder,
    this.enabled = true,
    required this.initialValue,
    this.asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    this.onValueChanged,
    this.onValidationInfoChanged,
    this.validator,
    this.asyncValidator,
    this.order,
    this.onSaved,
    this.quietlyValidate = false,
    this.comparator,
    this.onFocusChanged,
    this.onInitialed,
    this.decorator,
    this.requestFocusOnUserInteraction = true,
  })  : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled,
        super(key: key);

  @override
  FormeFieldState<T> createState() => FormeFieldState();

  static FormeFieldController<dynamic>? of(BuildContext context) {
    return FormeFieldScope.of(context);
  }
}
