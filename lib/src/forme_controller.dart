import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../forme.dart';

/// base form controller
///
/// you can access a form controller by [FormeKey] or [FormeKey.of]
abstract class FormeController {
  /// whether form has a name field
  bool hasField(String name);

  /// whether form is readonly
  bool get readOnly;

  /// set form readOnly|editable
  set readOnly(bool readOnly);

  /// find [FormeFieldController] by name
  T field<T extends FormeFieldController<dynamic>>(String name);

  /// get form data
  Map<String, dynamic> get data;

  /// get validation of Form
  FormeValidation get validation;

  /// perform a validate
  ///
  /// if [Forme.quietlyValidate] is true, this method will not display default error
  ///
  /// if [quietly] is true , this method will not update and display error though [Forme.quietlyValidate] is false
  ///
  /// if [clearError] is true, will clear field's error before validate
  ///
  /// if [validateByOrder] is true, only one field will be validated at a time ! will not continue validate if any field validation not passed or failed
  ///
  /// **this method is depends on [Future.wait] and eagerError is true**
  ///
  /// if [names] is not empty , will only validate these fields
  Future<FormeValidateSnapshot> validate({
    bool quietly = false,
    Set<String> names,
    bool clearError = false,
    bool validateByOrder = false,
  });

  /// set forme data
  set data(Map<String, dynamic> data);

  /// reset form
  ///
  /// **only reset all value fields**
  void reset();

  /// save all form fields
  ///
  /// form field's onSaved will be  called
  void save();

  /// whether validate is quietly
  bool get quietlyValidate;

  /// set validate quietly
  ///
  /// **call this method (if Forme's quietlyValidate is false) if you want to display error by a custom way**
  set quietlyValidate(bool quietlyValidate);

  /// whether form' value changed after initialized
  ///
  /// this method is relay on [FormeField.initialValue] and [Forme.initialValue]
  ///
  /// value is compared by [FormeFieldState.compareValue]
  bool get isValueChanged;

  /// get all registered controllers
  List<FormeFieldController> get controllers;

  /// listen when field initialed or disposed
  ///
  /// if [FormeFieldController] is null , means field is not initialed or has been disposed, otherwise means field is initialed
  ///
  ///  ```
  ///   Forme(
  ///     Builder((context){
  ///       FormeKey.of(context).valueField('username') //will cause an error
  ///     });
  ///     ValueListenable<FormeFieldController?>(
  ///       listenable:FormeKey.of(context).fieldListenable('username'),
  ///       builder:(context,field,child) {
  ///         if(field != null) // ok
  ///       }
  ///     )
  ///     FormeTextField(name:'username')
  ///   )
  ///   ```
  ValueListenable<FormeFieldController<T>?> fieldListenable<T>(String name);

  /// used to listen any form field's validation changes
  ///
  /// will also triggered when field registered to forme or unregistered
  ValueListenable<FormeValidation> get validationListenable;
}

abstract class FormeFieldController<T> {
  /// get forme controller
  FormeController? get formeController;

  ///get field's name
  String get name;

  /// whether field is readOnly;
  bool get readOnly;

  /// set readOnly
  set readOnly(bool readOnly);

  /// get focus node
  ///
  /// maybe null if field does not request a focusNode yet
  ///
  /// **don't dispose it by yourself!**
  FocusNode? get focusNode;

  /// get context
  BuildContext get context;

  /// focus listenable
  ValueListenable<bool> get focusListenable;

  /// readOnly listenable
  ///
  /// useful update children items when readOnly state changes,
  ///  eg [FormeCupertinoSegmentedControl]
  ///
  /// will trigger when [Forme] or field's readOnly state changed
  ValueListenable<bool> get readOnlyListenable;

  /// enabled listenable
  ///
  ///
  /// will trigger when [Forme] or field's readOnly state changed
  ValueListenable<bool> get enabledListenable;

  /// get current value of field
  T get value;

  /// set field value
  set value(T value);

  /// validate field
  ///
  /// if [quietly] ,will not rebuild field and update and display error Text
  Future<FormeFieldValidateSnapshot<T>> validate({bool quietly = false});

  /// reset field
  ///
  /// 1. set field value to initialValue
  /// 2. reset validation
  void reset();

  /// get validation
  ///
  /// 1. [FormeFieldValidation.state] is `valid` , means field passed validation
  /// 2. [FormeFieldValidation.state] is `invalid` , means field not passed validation , [FormeFieldValidation.error] is not null
  /// 3. [FormeFieldValidation.state] is `validating` , means an async validation is in progress
  /// 4. [FormeFieldValidation.state] is `fail` , means an error is occurred when performing an async validation , but [Form ValidateError] will not include this error , you must handle it by yourself
  /// 5. [FormeFieldValidation.state] is `waiting` means field has not validated yet or reset after validate
  /// 6. [FormeFieldValidation.state] is `unnecessary` means field has no validators
  ///
  /// **you can still get error text even though [Forme.quietlyValidate] is true**
  ///
  /// **value notifier is always be trigger before errorNotifier , so  when you want to get error in onValueChanged , you should call this method in [WidgetsBinding.instance.addPostFrameCallback]**
  FormeFieldValidation get validation;

  /// get validation listenable
  ///
  /// it's useful when you want to display error by your custom way!
  ///
  /// this notifier is used for [ValueListenableBuilder]
  ValueListenable<FormeFieldValidation> get validationListenable;

  /// get value listenable
  ///
  /// same as widget's onChanged , but it is more useful
  /// when you want to build a widget relies on field's value change
  ///
  /// eg: if you want to build a clear icon on textField , but don't want to display it
  /// when textField's value is empty ,you can do like this :
  ///
  /// ``` dart
  ///  return ValueListenableBuilder<String?>(
  ///         valueListenable:formeKey.valueField(name).valueListenable,
  ///         builder: (context, a, b) {
  ///           return a == null || a.length == 0
  ///               ? SizedBox()
  ///               : IconButton(icon:Icon(Icons.clear),onPressed:(){
  ///                 formeKey.valueField(name).value = '';
  ///               });
  ///         });
  /// ```
  ///
  /// this notifier is used for [ValueListenableBuilder]
  ValueListenable<T> get valueListenable;

  /// get old field value
  ///
  /// **after field's value changed , you can use this method to get old value**
  T? get oldValue;

  /// whether field's value changed after initialized
  ///
  /// this method is relay on [FormeField.initialValue] and [Forme.initialValue]
  ///
  /// value is compared by [FormeFieldState.compareValue]
  bool get isValueChanged;

  /// whether field is enabled
  bool get enabled;

  /// enable|disable field
  ///
  /// if field is disabled
  ///
  /// 1. field will lose focus and can not be focused
  /// 2. field's validators are ignored (manually validation will  be also ignored)
  /// 3. field is readOnly
  /// 4. value will be ignored when get form data
  /// 5. value can still be changed via `FormeFieldController`
  /// 6. validation state will be set to `unnecessary` and will always be `FormeValidationState.unnecessary`
  /// 7. when get validation from `FormeController` , this field will be ignored
  set enabled(bool enabled);

  bool get mounted;
}

class FormeFieldControllerDelegate<T> extends FormeFieldController<T> {
  FormeFieldControllerDelegate(this._delegate);
  final FormeFieldController<T> _delegate;

  @override
  bool get readOnly => _delegate.readOnly;

  @override
  set readOnly(bool readOnly) => _delegate.readOnly = readOnly;

  @override
  T get value => _delegate.value;

  @override
  set value(T value) => _delegate.value = value;

  @override
  FormeFieldValidation get validation => _delegate.validation;

  @override
  ValueListenable<FormeFieldValidation> get validationListenable =>
      _delegate.validationListenable;

  @override
  ValueListenable<bool> get focusListenable => _delegate.focusListenable;

  @override
  FocusNode? get focusNode => _delegate.focusNode;

  @override
  FormeController? get formeController => _delegate.formeController;

  @override
  bool get isValueChanged => _delegate.isValueChanged;

  @override
  String get name => _delegate.name;

  @override
  T? get oldValue => _delegate.oldValue;

  @override
  ValueListenable<bool> get readOnlyListenable => _delegate.readOnlyListenable;

  @override
  ValueListenable<bool> get enabledListenable => _delegate.enabledListenable;

  @override
  void reset() => _delegate.reset();

  @override
  Future<FormeFieldValidateSnapshot<T>> validate({bool quietly = false}) =>
      _delegate.validate(quietly: quietly);

  @override
  ValueListenable<T> get valueListenable => _delegate.valueListenable;

  @override
  BuildContext get context => _delegate.context;

  @override
  bool get enabled => _delegate.enabled;

  @override
  set enabled(bool enabled) => _delegate.enabled = enabled;

  @override
  bool get mounted => _delegate.mounted;
}
