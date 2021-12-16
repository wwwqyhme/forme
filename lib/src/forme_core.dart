import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../forme.dart';
import 'forme_field_scope.dart';
import 'forme_value_listenable.dart';

/// form key is a global key , also used to manage form
class FormeKey extends LabeledGlobalKey<State> implements FormeController {
  FormeKey({String? debugLabel}) : super(debugLabel);

  /// whether formKey is initialized
  bool get initialized {
    final State? state = currentState;
    if (state == null || state is! _FormeState) {
      return false;
    }
    return true;
  }

  /// get form controller , throw an error if there's no form controller
  FormeController get _currentController {
    final State? currentState = super.currentState;
    if (currentState == null) {
      throw Exception('current state is null,did you put this key on Forme?');
    }
    if (currentState is! _FormeState) {
      throw Exception(
          'current state is not a state of Forme , did you put this key on Forme?');
    }
    return currentState.controller;
  }

  @override
  Map<String, dynamic> get data => _currentController.data;

  @override
  bool get readOnly => _currentController.readOnly;

  @override
  FormeValidation get validation => _currentController.validation;

  @override
  T field<T extends FormeFieldController<dynamic>>(String name) =>
      _currentController.field<T>(name);

  @override
  bool hasField(String name) => _currentController.hasField(name);

  @override
  Future<FormeValidateSnapshot> validate({
    bool quietly = false,
    Set<String> names = const {},
    bool clearError = false,
    bool validateByOrder = false,
  }) =>
      _currentController.validate(
        quietly: quietly,
        names: names,
        validateByOrder: validateByOrder,
        clearError: clearError,
      );

  @override
  void reset() => _currentController.reset();

  @override
  void save() => _currentController.save();

  @override
  set data(Map<String, dynamic> data) => _currentController.data = data;

  @override
  set readOnly(bool readOnly) => _currentController.readOnly = readOnly;

  static FormeController? of(BuildContext context) {
    return _FormeScope.of(context)?.controller;
  }

  @override
  bool get quietlyValidate => _currentController.quietlyValidate;

  @override
  set quietlyValidate(bool quietlyValidate) =>
      _currentController.quietlyValidate = quietlyValidate;

  @override
  bool get isValueChanged => _currentController.isValueChanged;

  @override
  List<FormeFieldController> get controllers => _currentController.controllers;

  @override
  ValueListenable<FormeFieldController<T>?> fieldListenable<T>(String name) =>
      _currentController.fieldListenable<T>(name);

  @override
  ValueListenable<FormeValidation> get validationListenable =>
      _currentController.validationListenable;

  @override
  ValueListenable<Map<String, FormeFieldController?>> get fieldsListenable =>
      _currentController.fieldsListenable;
}

/// build your form !
class Forme extends StatefulWidget {
  /// whether form should be readOnly;
  ///
  /// default false
  final bool readOnly;

  /// listen form value changed
  ///
  /// this listener will be always triggered when field value changed
  final FormeValueChanged? onValueChanged;

  /// listen form focus changed
  final FormeFocusChanged? onFocusChanged;

  /// form content
  final Widget child;

  /// map initial value
  ///
  /// **this property can be overwritten by field's initialValue**
  final Map<String, dynamic> initialValue;

  /// used to listen field's validation changed
  final FormeFieldValidationChanged? onFieldValidationChanged;

  final WillPopCallback? onWillPop;

  /// if this flag is true , will not display default error when perform a validate
  final bool quietlyValidate;

  /// autovalidateMode
  ///
  /// if mode is [AutovalidateMode.onUserInteraction] , will validate and rebuild all fields which has a validator
  /// after field was interacted by user
  ///
  /// if mode is [AutovalidateMode.always] , will revalidated all value fields after called reset
  final AutovalidateMode autovalidateMode;

  /// validated by field order , only one field will be validated at a time.
  ///
  /// will not continue if any field validation is not passed
  final bool autovalidateByOrder;

  /// listen field registered|unregistered
  final void Function(String name, FormeFieldController? field)?
      onFieldsChanged;

  /// listen [FormeValidation] changed
  final void Function(FormeController controller, FormeValidation validation)?
      onValidationChanged;

  const Forme({
    FormeKey? key,
    this.readOnly = false,
    this.onValueChanged,
    required this.child,
    this.initialValue = const <String, dynamic>{},
    this.onFieldValidationChanged,
    this.onValidationChanged,
    this.onWillPop,
    this.quietlyValidate = false,
    this.onFocusChanged,
    AutovalidateMode? autovalidateMode,
    this.autovalidateByOrder = false,
    this.onFieldsChanged,
  })  : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled,
        super(key: key);

  @override
  _FormeState createState() => _FormeState();

  static FormeController? of(BuildContext context) =>
      _FormeScope.of(context)?.controller;
}

class _FormeState extends State<Forme> {
  final List<FormeFieldState> states = [];
  late final _FormeController controller;
  final Map<String, ValueNotifier<FormeFieldController?>> fieldNotifiers = {};
  late final ValueNotifier<Map<String, FormeFieldController?>> fieldsNotifier =
      FormeMountedValueNotifier({}, this);
  late final ValueNotifier<FormeValidation> validationNotifier =
      FormeMountedValueNotifier(const FormeValidation({}), this);

  Map<String, dynamic> get initialValue => widget.initialValue;

  AutovalidateMode get autovalidateMode => widget.autovalidateMode;

  bool? _readOnly;
  bool? _quietlyValidate;

  int gen = 0;

  bool get readOnly => _readOnly ?? widget.readOnly;

  set readOnly(bool readOnly) {
    if (_readOnly != readOnly) {
      setState(() {
        gen++;
        _readOnly = readOnly;
      });
      for (final FormeFieldState element in states) {
        element._readOnlyNotifier.value = element.readOnly;
      }
    }
  }

  bool get quietlyValidate => _quietlyValidate ?? widget.quietlyValidate;

  set quietlyValidate(bool quietlyValidate) {
    if (_quietlyValidate != quietlyValidate) {
      setState(() {
        gen++;
        _quietlyValidate = quietlyValidate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controller = _FormeController(this);
  }

  @override
  void dispose() {
    fieldsNotifier.dispose();
    validationNotifier.dispose();
    fieldNotifiers.forEach((key, value) {
      value.dispose();
    });
    fieldNotifiers.clear();
    super.dispose();
  }

  void reset() {
    for (final FormeFieldState element in states) {
      element.reset();
    }
    if (widget.autovalidateMode == AutovalidateMode.always) {
      setState(() {
        ++gen;
      });
    }
  }

  ValueNotifier<FormeFieldController?> fieldListenable(String name) {
    return fieldNotifiers[name] ??
        fieldNotifiers.putIfAbsent(name,
            () => FormeMountedValueNotifier(getFieldController(name), this));
  }

  FormeFieldController? getFieldController(String name) {
    final List<FormeFieldController> controllers = states
        .where((element) => element.name == name)
        .map((e) => e.controller)
        .toList();
    return controllers.isEmpty ? null : controllers.first;
  }

  void _validateForm() {
    if (widget.autovalidateByOrder) {
      final List<FormeFieldState> valueFieldStates = states
          .where((element) => element._hasAnyValidator && element.enabled)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      if (valueFieldStates.isEmpty) {
        return;
      }
      _validateByOrder(valueFieldStates);
    } else {
      for (final FormeFieldState element in states) {
        if (element.enabled) {
          element._validate2();
        }
      }
    }
  }

  void _validateByOrder(List<FormeFieldState> states, {int index = 0}) {
    final int length = states.length;
    if (index >= length) {
      return;
    }
    final FormeFieldState state = states[index];
    //clear errors after this field
    for (int i = index + 1; i < length; i++) {
      if (!states[i]._validation.isValid) {
        states[i]._clearError();
      }
    }
    state._validate2(onValid: () {
      _validateByOrder(states, index: index + 1);
    });
  }

  void save() {
    for (final FormeFieldState element in states) {
      element.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (needValidate) {
      _validateForm();
    }
    return WillPopScope(
      onWillPop: widget.onWillPop,
      child: _FormeScope(
        gen: gen,
        state: this,
        child: widget.child,
      ),
    );
  }

  dynamic getInitialValue(String name, dynamic value) {
    if (widget.initialValue.containsKey(name)) {
      return widget.initialValue[name];
    }
    return value;
  }

  bool get needValidate {
    if (autovalidateMode == AutovalidateMode.always) {
      return true;
    }
    if (autovalidateMode == AutovalidateMode.onUserInteraction) {
      return states.any((element) => element._hasInteractedByUser);
    }
    return false;
  }

  void fieldDidChange() {
    if (needValidate) {
      setState(() {
        ++gen;
      });
    }
  }

  void updateValidation() {
    final FormeValidation validation = FormeValidation(states
        .asMap()
        .map((key, value) => MapEntry(value.name, value._validation)));
    widget.onValidationChanged?.call(controller, validation);
    validationNotifier.value = validation;
  }

  void fieldValidationChange(
      FormeFieldController controller, FormeFieldValidation validation) {
    updateValidation();
    widget.onFieldValidationChanged?.call(controller, validation);
  }

  void fieldFocusChange(FormeFieldController controller, bool hasFocus) {
    widget.onFocusChanged?.call(controller, hasFocus);
  }

  void fieldValueChange(FormeFieldController controller, dynamic value) {
    widget.onValueChanged?.call(controller, value);
  }

  void registerField(FormeFieldState state) {
    if (!states.contains(state)) {
      states.add(state);
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        widget.onFieldsChanged?.call(state.name, state.controller);
        fieldNotifiers[state.name]?.value = state.controller;
        fieldsNotifier.value = {state.name: state.controller};
        updateValidation();
      });
    }
  }

  void unregisterField(FormeFieldState state) {
    if (states.remove(state)) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        widget.onFieldsChanged?.call(state.name, null);
        fieldNotifiers[state.name]?.value = null;
        fieldsNotifier.value = {state.name: null};
        updateValidation();
      });
    }
  }

  bool get isValueChanged => states.any((element) => element.isValueChanged);

  int getOrder(FormeFieldState formeFieldState) {
    return states.indexOf(formeFieldState);
  }
}

class _FormeScope extends InheritedWidget {
  final int gen;
  final _FormeState state;

  const _FormeScope({
    required this.gen,
    required this.state,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant _FormeScope oldWidget) {
    return gen != oldWidget.gen;
  }

  static _FormeState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FormeScope>()?.state;
  }
}

class FormeFieldState<T> extends State<FormeField<T>> {
  final Duration _defaultAsyncValidatorDebounce =
      const Duration(milliseconds: 500);

  bool _init = false;
  FocusNode? _focusNode;
  bool? _readOnly;
  bool? _enabled;
  T? _oldValue;
  late FormeFieldValidation _validation;
  Timer? _asyncValidatorTimer;
  bool _ignoreValidate = false;
  bool _hasInteractedByUser = false;
  int _validateGen = 0;
  late T _value;

  _FormeState? _formeState;

  late final ValueNotifier<bool> _focusNotifier =
      FormeMountedValueNotifier(false, this);
  late final ValueNotifier<bool> _readOnlyNotifier;
  late final ValueNotifier<bool> _enabledNotifier;
  late final ValueNotifier<FormeFieldValidation> _validationNotifier;
  late final _ValueMountedNotifier<T> _valueNotifier;
  late final FormeFieldController<T> controller;

  int get order =>
      widget.order ??
      _formeState?.getOrder(this) ??
      (throw Exception(
          'can not get order of this field , if this field is not wrapped by Forme , you must specific an order on it'));

  String get name => widget.name;
  T get value => _value;
  T? get oldValue => _oldValue;

  bool get _hasValidator => widget.validator != null;
  bool get _hasAsyncValidator => widget.asyncValidator != null;
  bool get _hasAnyValidator => _hasValidator || _hasAsyncValidator;

  bool get readOnly =>
      (_formeState?.readOnly ?? false) ||
      (_readOnly ?? widget.readOnly) ||
      !(_enabled ?? widget.enabled);

  set readOnly(bool readOnly) {
    if (readOnly != this.readOnly) {
      setState(() {
        _readOnly = readOnly;
      });
      _readOnlyNotifier.value = this.readOnly;
    }
  }

  set enabled(bool enabled) {
    if (enabled != this.enabled) {
      setState(() {
        _enabled = enabled;
        _validateGen++;
        _validation = _initialValidation;
        _hasInteractedByUser = false;
        if (!enabled) {
          _focusNode?.canRequestFocus = false;
        }
      });
      _readOnlyNotifier.value = readOnly;
      _validationNotifier.value = _validation;
      _enabledNotifier.value = enabled;
    }
  }

  bool get enabled => _enabled ?? widget.enabled;

  FormeFieldValidation get _initialValidation => _hasAnyValidator && enabled
      ? FormeFieldValidation.waiting
      : FormeFieldValidation.unnecessary;

  String? get errorText => !enabled ||
          (_formeState?.quietlyValidate ?? false) ||
          widget.quietlyValidate
      ? null
      : _validation.error;

  /// get initialValue
  T get initialValue =>
      widget.initialValue ??
      _formeState?.getInitialValue(name, widget.initialValue) as T;

  /// get current widget's focus node
  ///
  /// if there's no focus node,will create a new one
  FocusNode get focusNode {
    if (_focusNode == null) {
      focusNode = _DisposeRequiredFocusNode();
      focusNode.canRequestFocus = enabled;
    }
    return _focusNode!;
  }

  /// **this method should be called by subclass only!**
  ///
  /// if current focusNode is not null ,dispose current node & set new focusNode
  ///
  /// you need to dispose node you set before before you set another node
  @protected
  set focusNode(FocusNode focusNode) {
    if (_focusNode == focusNode) {
      return;
    }
    if (_focusNode is _DisposeRequiredFocusNode) {
      _focusNode!.dispose();
    }
    _focusNode = focusNode;
    if (!enabled) {
      _focusNode!.canRequestFocus = false;
    }
    _focusNode!.addListener(() {
      _focusNotifier.value = focusNode.hasFocus;
    });
  }

  bool get isValueChanged => !compareValue(initialValue, value);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formeState = _FormeScope.of(context);
    if (_init) {
      return;
    }
    _init = true;
    beforeInitiation();
    controller = createFormeFieldController();
    if (widget.registrable) {
      _formeState?.registerField(this);
    }
    afterInitiation();
    widget.onInitialed?.call(controller);
  }

  /// called before [FormeFieldController] created
  ///
  /// this method is called in didChangeDependencies and will only called once in state's lifecycle
  ///
  /// **init your resource in this method**
  @protected
  @mustCallSuper
  void beforeInitiation() {
    _readOnlyNotifier = FormeMountedValueNotifier(readOnly, this);
    _enabledNotifier = FormeMountedValueNotifier(enabled, this);
    _value = initialValue;
    _valueNotifier = _ValueMountedNotifier(initialValue, this);
    _validation = _initialValidation;
    _validationNotifier = FormeMountedValueNotifier(_validation, this);
  }

  /// called after  [FormeFieldController] created
  ///
  /// this method is called in didChangeDependencies and will only called once in state's lifecycle
  @protected
  @mustCallSuper
  void afterInitiation() {
    _focusNotifier.addListener(() {
      onFocusChanged(focusNode.hasFocus);
      widget.onFocusChanged?.call(controller, focusNode.hasFocus);
      _formeState?.fieldFocusChange(controller, focusNode.hasFocus);
    });
    _valueNotifier.addListener(() {
      _ignoreValidate = false;
      onValueChanged(_valueNotifier.value);
      widget.onValueChanged?.call(controller, _valueNotifier.value);
      _formeState?.fieldValueChange(controller, _valueNotifier.value);
    });

    _validationNotifier.addListener(() {
      onValidationChanged(_validationNotifier.value);
      widget.onValidationChanged?.call(controller, _validationNotifier.value);
      _formeState?.fieldValidationChange(controller, _validationNotifier.value);
    });
  }

  /// create [FormeFieldController] , this method will only called once in field's lifecycle
  ///
  /// if you want to override this method, use [FormeFieldControllerDelegate] to wrap parent's controller
  @protected
  FormeFieldController<T> createFormeFieldController() =>
      _FormeFieldController(this);

  @override
  void dispose() {
    _asyncValidatorTimer?.cancel();
    _validationNotifier.dispose();
    _valueNotifier.dispose();
    _focusNotifier.dispose();
    _enabledNotifier.dispose();
    _readOnlyNotifier.dispose();
    if (_focusNode is _DisposeRequiredFocusNode) {
      _focusNode?.dispose();
    }
    _formeState?.unregisterField(this);
    super.dispose();
  }

  @mustCallSuper
  void didChange(T newValue) {
    if (!compareValue(_value, newValue)) {
      setState(() {
        _hasInteractedByUser = true;
        _value = newValue;
      });
      _valueNotifier.value = newValue;
      _fieldChange();
    }
  }

  @override
  void didUpdateWidget(FormeField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.registrable && !widget.registrable) {
      _formeState?.unregisterField(this);
    }

    if (!oldWidget.registrable && widget.registrable) {
      _formeState?.registerField(this);
    }

    if (_enabledNotifier.value != enabled) {
      _hasInteractedByUser = false;
      if (!enabled) {
        _focusNode?.canRequestFocus = false;
      }
      _validateGen++;
      _validation = _initialValidation;
      _validationNotifier.value = _validation;
    }

    _enabledNotifier.value = enabled;
    _readOnlyNotifier.value = readOnly;

    // has no validators
    if (!_hasAnyValidator) {
      _validateGen++;
      _validation = FormeFieldValidation.unnecessary;
      _validationNotifier.value = _validation;
    } else {
      //has validators and  enabled
      if (enabled && _validation == FormeFieldValidation.unnecessary) {
        _validateGen++;
        _validation = FormeFieldValidation.waiting;
        _validationNotifier.value = _validation;
      }
    }

    updateFieldValueInDidUpdateWidget(oldWidget);
    _valueNotifier.value = _value;
  }

  /// when you want to update value in [didUpdateWidget] , you should override this method rather than override [didUpdateWidget]
  ///
  /// use [setValue] rather than  [didChange]
  @protected
  void updateFieldValueInDidUpdateWidget(FormeField<T> oldWidget) {}

  @mustCallSuper
  void reset() {
    setState(() {
      _validateGen++;
      _validation = _initialValidation;
      _hasInteractedByUser = false;
      _ignoreValidate = false;
      _value = initialValue;
    });
    _valueNotifier.value = initialValue;
    _validationNotifier.value = _validation;
    _fieldChange();
  }

  set value(T value) => didChange(value);

  @protected
  void setValue(T value) {
    _value = value;
  }

  @override
  Widget build(BuildContext context) {
    final bool needValidate = _hasAnyValidator &&
        enabled &&
        ((widget.autovalidateMode == AutovalidateMode.always) ||
            (widget.autovalidateMode == AutovalidateMode.onUserInteraction &&
                _hasInteractedByUser));
    if (needValidate) {
      _validate();
    }

    Widget child = widget.builder(this);

    if (widget.decorator != null) {
      child = widget.decorator!.build(
        controller,
        child,
      );
    }

    return FormeFieldScope(controller, child);
  }

  /// override this method if you want to listen value changed
  @protected
  void onValueChanged(T value) {}

  /// override this method if you want to listen validation changed
  @protected
  void onValidationChanged(FormeFieldValidation validation) {}

  /// override this method if you want to listen focus changed
  @protected
  void onFocusChanged(bool hasFocus) {}

  void requestFocusOnUserInteraction() {
    if (_hasInteractedByUser && widget.requestFocusOnUserInteraction) {
      _focusNode?.requestFocus();
    }
  }

  /// override this method if default compare can not meet your needs
  bool compareValue(T a, T b) {
    if (a == b) {
      return true;
    }
    if (a is List && b is List) {
      return listEquals<dynamic>(a, b);
    }
    if (a is Set && b is Set) {
      return setEquals<dynamic>(a, b);
    }
    if (a is Map && b is Map) {
      return mapEquals<dynamic, dynamic>(a, b);
    }
    return false;
  }

  void save() {
    widget.onSaved?.call(controller, value);
  }

  void _clearError() {
    if (_validation == _initialValidation) {
      return;
    }
    setState(() {
      _validateGen++;
      _validation = _initialValidation;
    });
    _validationNotifier.value = _validation;
  }

  /// this method should be only called in [_FormeState.build]
  void _validate2({VoidCallback? onValid}) {
    void notifyOnValid() {
      if (_validation.isUnnecessary || _validation.isValid) {
        onValid?.call();
      }
    }

    void notifyValidation(FormeFieldValidation validation) {
      setState(() {
        _validation = validation;
      });
      _validationNotifier.value = _validation;
      notifyOnValid();
    }

    if (_ignoreValidate || !_hasAnyValidator) {
      if (!_hasAnyValidator) {
        notifyValidation(FormeFieldValidation.unnecessary);
      } else {
        notifyOnValid();
      }
      return;
    }

    final int gen = ++_validateGen;
    if (_hasValidator) {
      final String? errorText = widget.validator!(controller, value);
      if (errorText != null || !_hasAsyncValidator) {
        notifyValidation(_createFormeFieldValidation(errorText));
        return;
      }
    }

    if (_hasAsyncValidator) {
      notifyValidation(FormeFieldValidation.validating);
      _asyncValidate(gen, onCompleted: notifyOnValid);
    }
  }

  /// this method should  be only called in [FormeFieldState.build]
  void _validate() {
    void notifyValidation(FormeFieldValidation validation) {
      _validation = validation;
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        _validationNotifier.value = _validation;
      });
    }

    if (_ignoreValidate || !_hasAnyValidator) {
      if (!_hasAnyValidator) {
        notifyValidation(FormeFieldValidation.unnecessary);
      }
      return;
    }

    final int gen = ++_validateGen;

    if (_hasValidator) {
      final String? errorText = widget.validator!(controller, value);
      if (errorText != null || !_hasAsyncValidator) {
        notifyValidation(_createFormeFieldValidation(errorText));
        return;
      }
    }
    if (_hasAsyncValidator) {
      notifyValidation(FormeFieldValidation.validating);
      _asyncValidate(gen);
    }
  }

  void _asyncValidate(
    int gen, {
    VoidCallback? onCompleted,
  }) {
    _asyncValidatorTimer?.cancel();
    _asyncValidatorTimer = Timer(
        widget.asyncValidatorDebounce ?? _defaultAsyncValidatorDebounce, () {
      _performAsyncValidate(gen, onCompleted: onCompleted);
    });
  }

  Future _performAsyncValidate(
    int gen, {
    VoidCallback? onCompleted,
  }) async {
    bool isValid() {
      return mounted && gen == _validateGen;
    }

    FormeFieldValidation validation;

    try {
      final String? errorText =
          await widget.asyncValidator!(controller, value, isValid);
      validation = _createFormeFieldValidation(errorText);
    } catch (e) {
      validation = FormeFieldValidation.fail(e);
    }

    if (isValid()) {
      setState(() {
        _validation = validation;
        _ignoreValidate = true;
      });
      _validationNotifier.value = _validation;
      onCompleted?.call();
    }
  }

  void _fieldChange() {
    _formeState?.fieldDidChange();
  }

  FormeFieldValidation _createFormeFieldValidation(String? errorText) {
    if (errorText == null) {
      return FormeFieldValidation.valid;
    }
    return FormeFieldValidation.invalid(errorText);
  }

  /// this method is used to manually validate
  Future<FormeFieldValidateSnapshot<T>> _performValidate(
      {bool quietly = false}) async {
    final T value = this.value;
    if (!_hasAnyValidator || !enabled) {
      return FormeFieldValidateSnapshot(value, FormeFieldValidation.unnecessary,
          order, controller, false, false);
    }
    final int gen = quietly ? _validateGen : ++_validateGen;

    bool isValid() {
      return mounted && gen == _validateGen;
    }

    bool needNotify() {
      return !quietly && isValid();
    }

    void notify(FormeFieldValidation validation) {
      if (needNotify()) {
        setState(() {
          _validation = validation;
        });
        _validationNotifier.value = _validation;
      }
    }

    if (_hasValidator) {
      final String? errorText = widget.validator!(controller, value);
      if (errorText != null || !_hasAsyncValidator) {
        final FormeFieldValidation validation =
            _createFormeFieldValidation(errorText);
        notify(validation);
        return FormeFieldValidateSnapshot(
            value, validation, order, controller, false, false);
      }
    }

    notify(FormeFieldValidation.validating);

    FormeFieldValidation validation;
    try {
      final String? errorText =
          await widget.asyncValidator!(controller, value, isValid);
      validation = _createFormeFieldValidation(errorText);
    } catch (e) {
      validation = FormeFieldValidation.fail(e);
    }

    notify(validation);
    return FormeFieldValidateSnapshot(value, validation, order, controller,
        !compareValue(value, this.value), !compareValue(value, initialValue));
  }
}

class _FormeController extends FormeController {
  final _FormeState state;
  @override
  final ValueListenable<Map<String, FormeFieldController?>> fieldsListenable;

  _FormeController(this.state)
      : fieldsListenable = FormeValueListenableDelegate(state.fieldsNotifier);

  @override
  Map<String, dynamic> get data {
    final Map<String, dynamic> map = <String, dynamic>{};
    for (final FormeFieldState element in state.states) {
      if (!element.enabled) {
        continue;
      }
      final String name = element.name;
      final dynamic value = element.value;
      map[name] = value;
    }
    return map;
  }

  @override
  bool get quietlyValidate => state.quietlyValidate;

  @override
  bool get readOnly => state.readOnly;

  @override
  FormeValidation get validation => FormeValidation(state.states
      .where((element) => element.enabled)
      .toList()
      .asMap()
      .map((key, value) => MapEntry(value.name, value._validation)));

  @override
  T field<T extends FormeFieldController<dynamic>>(String name) {
    final T? field = findFormeFieldController(name);
    if (field == null) {
      throw Exception('no field can be found by name :$name');
    }
    return field;
  }

  @override
  bool hasField(String name) =>
      state.states.any((element) => element.name == name);

  @override
  Future<FormeValidateSnapshot> validate({
    bool quietly = false,
    Set<String> names = const {},
    bool clearError = false,
    bool validateByOrder = false,
  }) async {
    final List<FormeFieldState> states = (state.states
            .where((element) =>
                element._hasAnyValidator &&
                element.enabled &&
                (names.isEmpty || names.contains(element.name)))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order)))
        .toList();
    if (states.isEmpty) {
      return FormeValidateSnapshot([]);
    }
    if (clearError) {
      for (final FormeFieldState element in states) {
        element._clearError();
      }
    }
    if (validateByOrder) {
      return _validateByOrder(states, quietly);
    }
    final List<FormeFieldValidateSnapshot<dynamic>> value = await Future.wait(
        states.map((state) => state._performValidate(quietly: quietly)),
        eagerError: true);
    value.sort((a, b) => a.order.compareTo(b.order));
    return FormeValidateSnapshot(value);
  }

  Future<FormeValidateSnapshot> _validateByOrder(
      List<FormeFieldState> states, bool quietly,
      {int index = 0, List<FormeFieldValidateSnapshot> list = const []}) async {
    final int length = controllers.length;
    final List<FormeFieldValidateSnapshot> copyList = List.of(list);
    final FormeFieldValidateSnapshot snapshot =
        await states[index]._performValidate(quietly: quietly);
    copyList.add(snapshot);
    if (!snapshot.isValid || index == length - 1) {
      return FormeValidateSnapshot(copyList);
    }
    return _validateByOrder(states, quietly, index: index + 1, list: copyList);
  }

  @override
  void reset() => state.reset();

  @override
  void save() => state.save();

  @override
  set data(Map<String, dynamic> data) => data.forEach((key, dynamic value) {
        field(key).value = value;
      });

  @override
  set quietlyValidate(bool quietlyValidate) =>
      state.quietlyValidate = quietlyValidate;

  @override
  set readOnly(bool readOnly) => state.readOnly = readOnly;

  T? findFormeFieldController<T extends FormeFieldController<dynamic>>(
      String name) {
    for (final FormeFieldState state in state.states) {
      if (state.name == name) {
        return state.controller as T;
      }
    }
  }

  @override
  bool get isValueChanged => state.isValueChanged;

  @override
  List<FormeFieldController> get controllers =>
      state.states.map((e) => e.controller).toList();

  @override
  ValueListenable<FormeFieldController<T>?> fieldListenable<T>(String name) =>
      _FormeFieldControllerListenable<T>(state.fieldListenable(name));

  @override
  ValueListenable<FormeValidation> get validationListenable =>
      FormeValueListenableDelegate(state.validationNotifier);
}

class _FormeFieldControllerListenable<T>
    extends ValueListenable<FormeFieldController<T>?> {
  final ValueNotifier<FormeFieldController?> delegate;

  const _FormeFieldControllerListenable(this.delegate);

  @override
  void addListener(VoidCallback listener) => delegate.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      delegate.removeListener(listener);

  @override
  FormeFieldController<T>? get value => delegate.value == null
      ? null
      : delegate.value! as FormeFieldController<T>;
}

class _FormeFieldController<T> extends FormeFieldController<T> {
  final FormeFieldState<T> state;
  @override
  final ValueListenable<FormeFieldValidation> validationListenable;
  @override
  final ValueListenable<T> valueListenable;
  @override
  final ValueListenable<bool> focusListenable;
  @override
  final ValueListenable<bool> readOnlyListenable;
  @override
  final ValueListenable<bool> enabledListenable;

  _FormeFieldController(this.state)
      : focusListenable = FormeValueListenableDelegate(state._focusNotifier),
        readOnlyListenable =
            FormeValueListenableDelegate(state._readOnlyNotifier),
        enabledListenable =
            FormeValueListenableDelegate(state._enabledNotifier),
        validationListenable =
            FormeValueListenableDelegate(state._validationNotifier),
        valueListenable = FormeValueListenableDelegate<T>(state._valueNotifier);

  @override
  bool get readOnly => state.readOnly;

  @override
  FormeController? get formeController => Forme.of(state.context);

  @override
  FocusNode? get focusNode => state._focusNode;

  @override
  String get name => state.name;

  @override
  set readOnly(bool readOnly) => state.readOnly = readOnly;

  @override
  T get value => state.value;

  @override
  FormeFieldValidation get validation => state._validation;

  @override
  void reset() => state.reset();

  @override
  Future<FormeFieldValidateSnapshot<T>> validate({bool quietly = false}) =>
      state._performValidate(quietly: quietly);

  @override
  set value(T value) => state.value = value;

  @override
  T? get oldValue => state.oldValue;

  @override
  bool get isValueChanged => state.isValueChanged;

  @override
  BuildContext get context => state.context;

  @override
  bool get enabled => state.enabled;

  @override
  set enabled(bool enabled) => state.enabled = enabled;

  @override
  bool get mounted => state.mounted;
}

/// a focusnode created by FormeField itself rather than set by subclass ,
/// so it's our responsibility to dispose it
class _DisposeRequiredFocusNode extends FocusNode {}

class _ValueMountedNotifier<T> extends ChangeNotifier
    implements ValueListenable<T> {
  final FormeFieldState<T> state;
  _ValueMountedNotifier(this._value, this.state);
  @override
  T get value => _value;
  T _value;
  set value(T newValue) {
    if (!state.mounted) {
      return;
    }
    if (state.compareValue(_value, newValue)) {
      return;
    }
    state._oldValue = _value;
    _value = newValue;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    if (state.mounted) {
      super.addListener(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    if (state.mounted) {
      super.removeListener(listener);
    }
  }
}
