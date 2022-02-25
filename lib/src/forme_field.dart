import 'package:flutter/cupertino.dart';
import '../forme.dart';
import 'forme_field_scope.dart';

typedef FormeValueChanged<T> = void Function(
    FormeFieldController<T>, T newValue);

typedef FormeAsyncValidator<T> = Future<String?> Function(
  FormeFieldController<T> field,
  T value,
  bool Function() isValid,
);
typedef FormeValidator<T> = String? Function(
    FormeFieldController<T> field, T value);
typedef FormeFieldValidationChanged<T> = void Function(
    FormeFieldController<T> field, FormeFieldValidation validation);
typedef FormeFieldSetter<T> = void Function(
    FormeFieldController<T> field, T value);
typedef FormeFocusChanged<T> = void Function(
    FormeFieldController<T> field, bool hasFocus);
typedef FormeFieldInitialed<T> = void Function(FormeFieldController<T> field);
typedef FormeFieldBuilder<T extends Object?> = Widget Function(
    FormeFieldState<T> state);
typedef FormeFieldValueUpdater<T extends Object?> = T Function(
    FormeField<T> oldWidget, FormeField<T> widget, T oldValue);

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

  /// whether field is enabled,
  ///
  /// if field is disabled:
  ///
  /// 1. field will lose focus and can not be focused , but you still can get focusNode from `FormeFieldController` and set `canRequestFocus` to true and require focus
  /// 2. field's validators are ignored (manually validation will  be also ignored)
  /// 3. field is readOnly
  /// 4. value will be ignored when get form data
  /// 5. value can still be changed via `FormeFieldController`
  /// 6. validation state will always be `FormeValidationState.unnecessary`
  /// 7. when get validation from `FormeController` , this field will be ignored
  final bool enabled;
  final T initialValue;

  /// used to support [Forme.autovalidateByOrder]
  ///
  /// **if not specified  , will use the order registered to [Forme]**
  final int? order;

  /// used to decorate a field
  final FormeFieldDecorator<T>? decorator;

  /// whether request focus when field value changed
  final bool requestFocusOnUserInteraction;

  /// triggered whenever field value changed.
  ///
  /// it's save to request a new frame here
  ///
  /// use [FormeFieldController.oldValue] to get previous value
  final FormeValueChanged<T>? onValueChanged;
  final FormeFocusChanged<T>? onFocusChanged;

  /// triggered whenever field read-only state changed
  ///
  /// it's save to request a new frame here
  final void Function(FormeFieldController<T> field, bool readOnly)?
      onReadonlyChanged;

  /// triggered whenever field enabled state changed
  ///
  /// it's save to request a new frame here
  final void Function(FormeFieldController<T> field, bool enable)?
      onEnabledChanged;

  /// used to listen field's validation changes
  final FormeFieldValidationChanged<T>? onValidationChanged;

  /// called after [FormeController] or [FormeFieldController] initialed
  ///
  /// valueListenable will not listen [FormeField.initialValue] , you can do
  /// that in this method
  ///
  /// **try to get another field's controller in this method will cause an error**
  final FormeFieldInitialed<T>? onInitialed;

  final FormeFieldSetter<T>? onSaved;

  /// quietlyValidate
  ///
  /// final value is [Forme.quietlyValidate] || [FormeField.quietlyValidate]
  ///
  /// false means default error text will not be displayed when validation not passed
  final bool quietlyValidate;
  final Duration? asyncValidatorDebounce;

  final FormeValidator<T>? validator;

  /// used to perform an async validate
  ///
  /// if you specific both asyncValidator and validator , asyncValidator will only worked after validator passed
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
  /// [onValueChanged] will be triggered if new value not equals with old value
  final FormeFieldValueUpdater<T>? valueUpdater;

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
    this.onValueChanged,
    this.onFocusChanged,
    this.onReadonlyChanged,
    this.onEnabledChanged,
    this.onValidationChanged,
    this.onInitialed,
    this.onSaved,
    this.quietlyValidate = false,
    this.asyncValidatorDebounce,
    this.asyncValidator,
    this.registrable = true,
    this.valueUpdater,
  })  : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled,
        super(key: key);

  @override
  FormeFieldState<T> createState() => FormeFieldState();

  static FormeFieldController<T>? of<T>(BuildContext context) {
    final FormeFieldController? controller = FormeFieldScope.of(context);
    if (controller == null) {
      return null;
    }
    return controller as FormeFieldController<T>;
  }
}
