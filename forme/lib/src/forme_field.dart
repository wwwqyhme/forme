import 'package:flutter/widgets.dart';

import '../forme.dart';
import 'forme_field_scope.dart';

typedef FormeFieldStatusChanged<T> = void Function(
    FormeFieldState<T>, FormeFieldChangedStatus<T> status);

typedef FormeAsyncValidator<T> = Future<String?> Function(
  FormeFieldState<T> field,
  T value,
  bool Function() isValid,
);
typedef FormeValidator<T> = String? Function(FormeFieldState<T> field, T value);
typedef FormeFieldSetter<T> = void Function(FormeFieldState<T> field, T value);
typedef FormeFieldInitialed<T> = void Function(FormeFieldState<T> field);
typedef FormeFieldBuilder<T extends Object?> = Widget Function(
    FormeFieldState<T> state);
typedef FormeFieldValueUpdater<T extends Object?> = T Function(
    FormeField<T> oldWidget, FormeField<T> widget, T oldValue);
typedef FormeValueComparator<T extends Object?> = bool Function(
    T oldValue, T newValue);
typedef FormeFieldValidationFilter<T extends Object?> = bool Function(
    FormeFieldValidationContext<T> context);

@immutable
class FormeFieldType extends Type {
  final Type fieldType;
  final String name;

  FormeFieldType._(this.fieldType, this.name);

  @override
  int get hashCode => Object.hash(fieldType, name);

  @override
  bool operator ==(Object other) {
    return other is FormeFieldType &&
        other.fieldType == fieldType &&
        other.name == name;
  }

  @override
  String toString() {
    return '$fieldType[$name]';
  }
}

class FormeField<T extends Object?> extends StatefulWidget {
  final String name;
  final bool readOnly;
  final FormeFieldBuilder<T> builder;

  /// used to compare two value
  ///
  /// default:
  ///
  /// ``` Dart
  /// bool _defaultComparator(T oldValue, T newValue) {
  ///      if (oldValue is List && newValue is List) {
  ///        return listEquals(oldValue, newValue);
  ///     }
  ///
  ///      if (oldValue is Set && newValue is Set) {
  ///        return setEquals(oldValue, newValue);
  ///     }
  ///
  ///     if (oldValue is Map && newValue is Map) {
  ///      return mapEquals(oldValue, newValue);
  ///   }
  ///
  ///    return oldValue == newValue;
  ///  }
  /// ```
  final FormeValueComparator<T>? comparator;

  /// whether field is enabled,
  ///
  /// if field is disabled:
  ///
  /// 1. field will lose focus and can not be focused , but you still can get focusNode from `FormeFieldState` and set `canRequestFocus` to true and require focus
  /// 2. field's validators are ignored (manually validation will  be also ignored)
  /// 3. field is readOnly
  /// 4. value will be ignored when get form data
  /// 5. value can still be changed via `FormeFieldState`
  /// 6. validation state will always be `FormeValidationState.unnecessary`
  /// 7. when get validation from `FormeState` , this field will be ignored
  final bool enabled;

  /// initial value
  ///
  /// **[Forme.initialValue] has higher priority than field's initialValue**
  final T initialValue;

  /// used to support [Forme.autovalidateByOrder]
  ///
  /// **if not specified  , will use the order registered to [Forme]**
  final int? order;

  /// used to decorate a field
  final FormeFieldDecorator<T>? decorator;

  /// whether request focus when field value changed
  final bool requestFocusOnUserInteraction;

  /// listen field status change
  final FormeFieldStatusChanged<T>? onStatusChanged;

  /// called immediately after [FormeFieldState.initStatus]
  ///
  /// typically used to add visitors
  ///
  /// **DO NOT** request a new frame here
  final FormeFieldInitialed<T>? onInitialed;

  final FormeFieldSetter<T>? onSaved;

  /// quietlyValidate
  ///
  /// final value is [Forme.quietlyValidate] || [FormeField.quietlyValidate]
  ///
  /// false means default error text will not be displayed when validation not passed
  final bool quietlyValidate;
  final Duration? asyncValidatorDebounce;

  /// sync validator
  final FormeValidator<T>? validator;

  /// used to perform an async validation
  ///
  /// if you specify both asyncValidator and validator , asyncValidator will only worked after validator passed
  ///
  /// `isValid` is used to check whether this validation is valid or not
  /// if you want to update ui before you return validation result , you should call `isValid()` first
  ///
  /// eg:
  ///
  /// ```
  /// asyncValidator:(controller,value,isValid) {
  ///   return Future.delayed(const Duration(millseconds:500),(){
  ///     if(isValid()) {
  ///       updateUI();
  ///     }
  ///     return validationResult;
  ///   });
  /// }
  /// ```
  ///
  /// if `isValid()` is false, it means widget is unmounted or another async validation is performed
  /// or reset is called
  final FormeAsyncValidator<T>? asyncValidator;

  final AutovalidateMode autovalidateMode;

  /// whether is registrable
  ///
  /// if false ,[Forme] will not hold this field state , listeners will not be triggered
  final bool registrable;

  /// this method is used to update value when didUpdateWidget called
  /// eg: Dropdown's value is ['2'] , children values are ['1','2','3']
  /// after widget updated , children values are ['1','3','4'] , in this case
  /// Dropdown will be crashsed. use [valueUpdater] to avoid this
  ///
  /// [onStatusChanged] will be triggered if new value not equals with old value
  final FormeFieldValueUpdater<T>? valueUpdater;

  /// used to determine whether perform a validation
  ///
  /// will not work when validate manually
  ///
  ///
  /// default :
  ///
  /// ``` Dart
  ///    bool _defaultValidationFilter(FormeFieldValidationContext<T> context) {
  ///   final FormeFieldValidation validation = context.validation;
  ///
  ///   if (validation.isWaiting || validation.isFail) {
  ///     return true;
  ///   }
  ///
  ///   if (validation.isValidating) {
  ///    if (context.comparator(
  ///        context.validatingValue as T, context.currentValidateValue)) {
  ///      return false;
  ///    }
  ///    return true;
  ///   }
  ///
  ///   return !context.comparator(context.latestSuccessfulValidationValue as T,
  ///     context.currentValidateValue);
  ///}
  /// ```
  final FormeFieldValidationFilter<T>? validationFilter;
  final FocusNode? focusNode;

  Type get fieldType => super.runtimeType;

  @override
  FormeFieldType get runtimeType => FormeFieldType._(fieldType, name);

  const FormeField({
    Key? key,
    this.validator,
    required this.name,
    this.readOnly = false,
    required this.builder,
    this.enabled = true,
    required this.initialValue,
    AutovalidateMode? autovalidateMode,
    this.order,
    this.decorator,
    this.requestFocusOnUserInteraction = true,
    this.onStatusChanged,
    this.onInitialed,
    this.onSaved,
    this.quietlyValidate = false,
    this.asyncValidatorDebounce,
    this.asyncValidator,
    this.registrable = true,
    this.valueUpdater,
    this.comparator,
    this.validationFilter,
    this.focusNode,
  })  : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled,
        super(key: key);

  @override
  FormeFieldState<T> createState() => FormeFieldState();

  static FormeFieldState<T>? of<T>(BuildContext context) {
    final FormeFieldState? controller = FormeFieldScope.of(context);
    if (controller == null) {
      return null;
    }
    return controller as FormeFieldState<T>;
  }
}
