import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../forme.dart';

/// base form controller
///
/// you can access a form controller by [FormeKey] or [FormeKey.of]
abstract class FormeController {
  /// whether form has a name field
  bool hasField(String name);

  /// find [FormeFieldController] by name
  T field<T extends FormeFieldController<Object?>>(String name);

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

  /// save all form fields
  ///
  /// form field's onSaved will be  called
  void save();

  /// whether validate is quietly
  bool get quietlyValidate;

  /// get all registered controllers
  List<FormeFieldController> get controllers;

  /// get form data
  Map<String, Object?> get value;

  /// set forme value
  set value(Map<String, Object?> value);

  /// whether form' value changed after initialized
  bool get isValueChanged;

  /// reset form
  void reset();

  /// listen when field registered or unregistered
  ///
  /// if [FormeFieldController] is null , means field is not initialed or has been disposed, otherwise means field is initialed
  ///
  ///  ```
  ///   Forme(
  ///     Builder((context){
  ///       FormeKey.of(context).valueField('username') //will cause an error
  ///     });
  ///     ValueListenableBuilder<FormeFieldController?>(
  ///       listenable:FormeKey.of(context).fieldListenable('username'),
  ///       builder:(context,field,child) {
  ///         if(field != null) // ok
  ///       }
  ///     )
  ///     FormeTextField(name:'username')
  ///   )
  ///   ```
  ValueListenable<FormeFieldController<T>?> fieldListenable<T>(String name);

  /// listen  fields registered or unregistered
  ///
  /// will only be triggered once in a frame
  ///
  /// value contains all registered|unregistered fields in this frame,
  /// key is name of field , if value is null , means field unregistered ,otherwise registered
  ValueListenable<Map<String, FormeFieldController?>> get fieldsListenable;

  /// used to listen any form field's validation changes
  ///
  /// will also triggered when field registered to forme or unregistered
  ValueListenable<FormeValidation> get validationListenable;

  /// add forme visitor
  ///
  /// return false if exists
  bool addVisitor(FormeVisitor visitor);

  /// remove visitor
  bool removeVisitor(FormeVisitor visitor);
}

abstract class FormeFieldController<T extends Object?> {
  /// used to listen field's status
  ///
  /// if [FormeFieldStatus.disposed] is true ,means field is disposed ,
  /// you should release resources on this controller to avoid preventing
  /// recycle [FormeFieldState]
  ///
  /// this notifier can  also be listened by [ValueListenableBuilder],
  /// but [valueListenable] and others are better choice because of less build
  ValueNotifier<FormeFieldStatus<T>> get statusNotifier;

  /// name of field
  String get name;

  /// whether controller is disposed or not
  ///
  /// if controller is disposed , you should break reference to this controller to avoid memory leak
  bool get isDisposed => statusNotifier.value.disposed;

  /// get forme controller
  ///
  /// null if field is not wrapped by [Forme]
  FormeController? get formeController => Forme.of(context);

  /// whether field is readOnly;
  bool get readOnly => statusNotifier.value.readOnly;

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

  /// get current value of field
  T get value => statusNotifier.value.value;

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
  FormeFieldValidation get validation => statusNotifier.value.validation;

  /// get old field value
  ///
  /// **after field's value changed , you can use this method to get old value**
  T? get oldValue;

  /// whether field's value changed after initialized
  bool get isValueChanged;

  /// whether field is enabled
  bool get enabled => statusNotifier.value.enabled;

  /// enable|disable field
  ///
  /// if field is disabled
  ///
  /// 1. field will lose focus and can not be focused
  /// 2. field's validation will be always [FormeFieldValidation.unnecessary]
  /// 3. field is readOnly
  /// 4. value will be ignored when get form data
  /// 5. value can still be changed via [FormeFieldController]
  /// 6. when get validation from [FormeController] , this field will be ignored
  set enabled(bool enabled);

  /// get generic type
  Type get type => T;

  /// whether value can be nullable or not
  bool get isNullable => null is T;

  /// mark this field needs rebuild
  void markNeedsBuild();

  /// focus listenable
  ValueListenable<bool> get focusListenable;

  /// readOnly listenable
  ///
  /// useful update children items when readOnly state changes
  ///
  /// will trigger when [Forme] or field's readOnly state changed
  ValueListenable<bool> get readOnlyListenable;

  /// enabled listenable
  ///
  ///
  /// will trigger when [Forme] or field's readOnly state changed
  ValueListenable<bool> get enabledListenable;

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

  /// get validation listenable
  ///
  /// it's useful when you want to display error by your custom way!
  ///
  /// this notifier is used for [ValueListenableBuilder]
  ValueListenable<FormeFieldValidation> get validationListenable;

  /// clear validation error
  ///
  /// [validation] will be [FormeFieldValidation.unnecessary]
  /// or [FormeFieldValidation.waiting] after cleared
  void clearError();

  /// get order of field , typically used for [Forme.autovalidateByOrder]
  ///
  /// null if field is not wrapped by [Forme]
  /// and not specific an order on [FormeField]
  int? get order;
}

class FormeFieldControllerDelegate<T> implements FormeFieldController<T> {
  FormeFieldControllerDelegate(this._delegate) {
    _delegate.statusNotifier.addListener(() {
      final FormeFieldStatus<T> status = _delegate.statusNotifier.value;
      if (status.disposed) {
        dispose();
      }
    });
  }
  final FormeFieldController<T> _delegate;

  @override
  set readOnly(bool readOnly) => _delegate.readOnly = readOnly;

  @override
  set value(T value) => _delegate.value = value;

  @override
  FormeFieldValidation get validation => _delegate.validation;

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
  void reset() => _delegate.reset();

  @override
  Future<FormeFieldValidateSnapshot<T>> validate({bool quietly = false}) =>
      _delegate.validate(quietly: quietly);

  @override
  BuildContext get context => _delegate.context;

  @override
  set enabled(bool enabled) => _delegate.enabled = enabled;

  @override
  void markNeedsBuild() => _delegate.markNeedsBuild();

  @override
  bool get enabled => _delegate.enabled;

  @override
  ValueListenable<bool> get enabledListenable => _delegate.enabledListenable;

  @override
  ValueListenable<bool> get focusListenable => _delegate.focusListenable;

  @override
  bool get isNullable => _delegate.isNullable;

  @override
  bool get readOnly => _delegate.readOnly;

  @override
  ValueListenable<bool> get readOnlyListenable => _delegate.readOnlyListenable;

  @override
  ValueNotifier<FormeFieldStatus<T>> get statusNotifier =>
      _delegate.statusNotifier;

  @override
  Type get type => _delegate.type;

  @override
  ValueListenable<FormeFieldValidation> get validationListenable =>
      _delegate.validationListenable;

  @override
  T get value => _delegate.value;

  @override
  ValueListenable<T> get valueListenable => _delegate.valueListenable;

  @override
  bool get isDisposed => _delegate.isDisposed;

  @override
  void clearError() => _delegate.clearError();

  @override
  int? get order => _delegate.order;

  @protected
  void dispose() {}
}
