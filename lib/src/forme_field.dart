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
typedef FormeFieldBuilder<T> = Widget Function(FormeFieldState<T> state);

class FormeField<T> extends StatefulWidget {
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

  /// quietlyValidate
  ///
  /// final value is [Forme.quietlyValidate] || [FormeField.quietlyValidate]
  final bool quietlyValidate;
  final Duration? asyncValidatorDebounce;
  final AutovalidateMode autovalidateMode;
  final FormeValueChanged<T>? onValueChanged;
  final FormeFocusChanged<T>? onFocusChanged;

  final void Function(FormeFieldController<T> field, bool readOnly)?
      onReadonlyChanged;
  final void Function(FormeFieldController<T> field, bool enable)?
      onEnableChanged;

  /// used to listen field's validation changes
  final FormeFieldValidationChanged<T>? onValidationChanged;

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
  final FormeFieldSetter<T>? onSaved;

  /// used to decorate a field
  final FormeFieldDecorator<T>? decorator;

  /// whether request focus when field value changed
  final bool requestFocusOnUserInteraction;

  /// whether this field can be registered to `Forme`
  ///
  /// useful when you want to create a field relies on another FormeField
  final bool registrable;

  const FormeField({
    Key? key,
    required this.name,
    this.readOnly = false,
    required this.registrable,
    required this.builder,
    this.enabled = true,
    required this.initialValue,
    this.asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    this.onValueChanged,
    this.onValidationChanged,
    this.validator,
    this.asyncValidator,
    this.order,
    this.onSaved,
    this.quietlyValidate = false,
    this.onFocusChanged,
    this.onInitialed,
    this.decorator,
    this.requestFocusOnUserInteraction = true,
    this.onEnableChanged,
    this.onReadonlyChanged,
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
