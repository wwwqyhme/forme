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

  /// get error msg after validated
  ///
  /// this method can get error even though  [Forme.quietlyValidate] is true
  Map<FormeFieldController, String> get errors;

  /// perform a validate
  ///
  /// if [Forme.quietlyValidate] is true, this method will not display default error
  ///
  /// if [quietly] is true , this method will not update and display error though [Forme.quietlyValidate] is false
  ///
  /// if [clearError] is true, will clear field's error before validate
  ///
  /// if [validateByOrder] is true, only one field will be validated at a time ! will not continue validate if any field validation not password or failed
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
  /// **comparator from [FormeField.comparator] is used to compare two values **
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
  ValueListenable<FormeFieldController?> fieldListenable(String name);
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
  /// 2. clear error message
  void reset();

  /// get error
  ///
  /// error is null means this field has not validated yet
  ///
  /// 1. [FormeValidateError.state] is `valid` , means field passed validation
  /// 2. [FormeValidateError.state] is `invalid` , means field not passed validation , [FormeValidateError.text] is not null
  /// 3. [FormeValidateError.state] is `validating` , means an async validation is in progress
  /// 4. [FormeValidateError.state] is `fail` , means an error is occurred when performing an async validation , but [Form ValidateError] will not include this error , you must handle it by yourself
  ///
  /// **you can still get error text even though [Forme.quietlyValidate] is true**
  ///
  /// **value notifier is always be trigger before errorNotifier , so  when you want to get error in onValueChanged , you should call this method in [WidgetsBinding.instance.addPostFrameCallback]**
  FormeValidateError? get error;

  /// get error listenable
  ///
  /// it's useful when you want to display error by your custom way!
  ///
  /// this notifier is used for [ValueListenableBuilder]
  ValueListenable<FormeValidateError?> get errorTextListenable;

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
  ValueListenable<T?> get valueListenable;

  /// get old field value
  ///
  /// **after field's value changed , you can use this method to get old value**
  T? get oldValue;

  /// whether field's value changed after initialized
  ///
  /// this method is relay on [FormeField.initialValue] and [Forme.initialValue]
  ///
  /// the `comparator` from [FormeField.comparator] is used to compare value
  bool get isValueChanged;
}

class FormeFieldControllerDelegate<T> implements FormeFieldController<T> {
  const FormeFieldControllerDelegate(this.delegate);
  final FormeFieldController<T> delegate;

  @override
  bool get readOnly => delegate.readOnly;

  @override
  set readOnly(bool readOnly) => delegate.readOnly = readOnly;

  @override
  T get value => delegate.value;

  @override
  set value(T value) => delegate.value = value;

  @override
  FormeValidateError? get error => delegate.error;

  @override
  ValueListenable<FormeValidateError?> get errorTextListenable =>
      delegate.errorTextListenable;

  @override
  ValueListenable<bool> get focusListenable => delegate.focusListenable;

  @override
  FocusNode? get focusNode => delegate.focusNode;

  @override
  FormeController? get formeController => delegate.formeController;

  @override
  bool get isValueChanged => delegate.isValueChanged;

  @override
  String get name => delegate.name;

  @override
  T? get oldValue => delegate.oldValue;

  @override
  ValueListenable<bool> get readOnlyListenable => delegate.readOnlyListenable;

  @override
  void reset() => delegate.reset();

  @override
  Future<FormeFieldValidateSnapshot<T>> validate({bool quietly = false}) =>
      delegate.validate(quietly: quietly);

  @override
  ValueListenable<T?> get valueListenable => delegate.valueListenable;

  @override
  BuildContext get context => delegate.context;
}
