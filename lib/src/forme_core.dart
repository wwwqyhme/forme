import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../forme.dart';
import 'forme_field_scope.dart';

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
  Map<String, Object?> get value => _currentController.value;

  @override
  FormeValidation get validation => _currentController.validation;

  @override
  T field<T extends FormeFieldController<Object?>>(String name) =>
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
  set value(Map<String, Object?> data) => _currentController.value = data;

  static FormeController? of(BuildContext context) {
    return _FormeScope.of(context)?.controller;
  }

  @override
  bool get quietlyValidate => _currentController.quietlyValidate;

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
  /// listen form value changed
  ///
  /// this listener will be always triggered when field value changed
  final FormeValueChanged<Object?>? onValueChanged;

  /// listen form focus changed
  final FormeFocusChanged<Object?>? onFocusChanged;

  /// form content
  final Widget child;

  /// map initial value
  ///
  /// **this property can be overwritten by field's initialValue**
  final Map<String, Object?> initialValue;

  /// used to listen field's validation changed
  final FormeFieldValidationChanged<Object?>? onFieldValidationChanged;

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
  final void Function(FormeController field, FormeValidation validation)?
      onValidationChanged;

  final void Function(FormeFieldController<Object?> field, bool readOnly)?
      onReadonlyChanged;
  final void Function(FormeFieldController<Object?> field, bool enable)?
      onEnabledChanged;

  const Forme({
    FormeKey? key,
    this.onValueChanged,
    required this.child,
    this.initialValue = const <String, Object?>{},
    this.onFieldValidationChanged,
    this.onValidationChanged,
    this.onWillPop,
    this.quietlyValidate = false,
    this.onFocusChanged,
    AutovalidateMode? autovalidateMode,
    this.autovalidateByOrder = false,
    this.onFieldsChanged,
    this.onReadonlyChanged,
    this.onEnabledChanged,
  })  : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled,
        super(key: key);

  @override
  State<Forme> createState() => _FormeState();

  static FormeController? of(BuildContext context) =>
      _FormeScope.of(context)?.controller;
}

class _FormeState extends State<Forme> {
  final List<FormeFieldState> states = [];
  late final _FormeController controller;
  final Map<String, ValueNotifier<FormeFieldController?>> fieldNotifiers = {};
  final ValueNotifier<Map<String, FormeFieldController?>> fieldsNotifier =
      FormeMountedValueNotifier({});
  final ValueNotifier<FormeValidation> validationNotifier =
      FormeMountedValueNotifier(const FormeValidation({}));

  Map<String, Object?> get initialValue => widget.initialValue;

  AutovalidateMode get autovalidateMode => widget.autovalidateMode;

  int gen = 0;

  bool get quietlyValidate => widget.quietlyValidate;

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
        fieldNotifiers.putIfAbsent(
            name, () => FormeMountedValueNotifier(getFieldController(name)));
  }

  FormeFieldController? getFieldController(String name) {
    final List<FormeFieldController> controllers = states
        .where((element) => element.name == name)
        .map((e) => e.controller)
        .toList();
    return controllers.isEmpty ? null : controllers.first;
  }

  Future<FormeValidation> _validateForm() async {
    if (widget.autovalidateByOrder) {
      final List<FormeFieldState> valueFieldStates = states
          .where((element) => element._hasAnyValidator && element.enabled)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      if (valueFieldStates.isEmpty) {
        return const FormeValidation({});
      }
      return _validateByOrder(valueFieldStates);
    } else {
      final Map<String, FormeFieldValidation> validations = {};
      await Future.wait(states
          .where((element) => element.enabled)
          .map((e) => e._validate2().then((value) {
                validations[e.name] = value;
                return value;
              })));
      return FormeValidation(validations);
    }
  }

  Future<FormeValidation> _validateByOrder(List<FormeFieldState> states,
      {int index = 0,
      Map<String, FormeFieldValidation> collector = const {}}) async {
    final int length = states.length;
    if (index >= length) {
      return FormeValidation(collector);
    }
    final FormeFieldState state = states[index];
    //clear errors after this field
    for (int i = index + 1; i < length; i++) {
      if (!states[i]._model.validation.isValid) {
        states[i]._clearError();
      }
    }
    final FormeFieldValidation validation = await state._validate2();
    collector[state.name] = validation;
    if (validation.isUnnecessary || validation.isValid) {
      return await _validateByOrder(states,
          index: index + 1, collector: collector);
    }
    return FormeValidation(collector);
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

  Object? getInitialValue(String name, Object? value) {
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
        .map((key, value) => MapEntry(value.name, value._model.validation)));
    widget.onValidationChanged?.call(controller, validation);
    validationNotifier.value = validation;
  }

  void fieldValidationChange(
      FormeFieldState state, FormeFieldValidation validation) {
    if (!states.contains(state)) {
      return;
    }
    updateValidation();
    widget.onFieldValidationChanged?.call(state.controller, validation);
  }

  void fieldFocusChange(FormeFieldState state, bool hasFocus) {
    if (!states.contains(state)) {
      return;
    }
    widget.onFocusChanged?.call(state.controller, hasFocus);
  }

  void fieldValueChange(FormeFieldState state, Object? value) {
    if (!states.contains(state)) {
      return;
    }
    widget.onValueChanged?.call(state.controller, value);
  }

  void fieldReadonlyChange(FormeFieldState state, bool enabled) {
    if (!states.contains(state)) {
      return;
    }
    widget.onEnabledChanged?.call(state.controller, enabled);
  }

  void fieldEnabledChange(FormeFieldState state, bool readOnly) {
    if (!states.contains(state)) {
      return;
    }
    widget.onReadonlyChanged?.call(state.controller, readOnly);
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

class FormeFieldState<T extends Object?> extends State<FormeField<T>> {
  final Duration _defaultAsyncValidatorDebounce =
      const Duration(milliseconds: 500);

  ValueNotifier<T>? _valueNotifier;
  ValueNotifier<bool>? _focusNotifier;
  ValueNotifier<FormeFieldValidation>? _validationNotifier;
  ValueNotifier<bool>? _readOnlyNotifier;
  ValueNotifier<bool>? _enabledNotifier;

  ValueListenable<T> get _valueListenable => FormeValueListenableDelegate(
      _valueNotifier ??= FormeMountedValueNotifier(_model.value));
  ValueListenable<bool> get _focusListenable => _focusNotifier ??=
      FormeMountedValueNotifier(_focusNode?.hasFocus ?? false);
  ValueListenable<FormeFieldValidation> get _validationListenable =>
      _validationNotifier ??= FormeMountedValueNotifier(_model.validation);
  ValueListenable<bool> get _readOnlyListenable =>
      _readOnlyNotifier ??= FormeMountedValueNotifier(_model.readOnly);
  ValueListenable<bool> get _enabledListenable =>
      _enabledNotifier ??= FormeMountedValueNotifier(_model.enabled);

  FocusNode? _focusNode;
  Timer? _asyncValidatorTimer;
  bool _ignoreValidate = false;
  bool _hasInteractedByUser = false;
  int _validateGen = 0;

  late _Model<T> _model;
  T? _oldValue;
  _FormeState? _formeState;

  FormeFieldController<T>? _controller;

  FormeFieldController<T> get controller =>
      _controller ??= createFormeFieldController();

  T? get oldValue => _oldValue;

  int get order =>
      widget.order ??
      _formeState?.getOrder(this) ??
      (throw Exception(
          'can not get order of this field , if this field is not wrapped by Forme , you must specific an order on it'));

  String get name => widget.name;
  T get value => _model.value;

  bool get _hasValidator => widget.validator != null;
  bool get _hasAsyncValidator => widget.asyncValidator != null;
  bool get _hasAnyValidator => _hasValidator || _hasAsyncValidator;

  bool get readOnly => _model.readOnly;
  bool get enabled => _model.enabled;

  bool? _readOnly;
  bool? _enabled;

  bool get _isReadOnly => (_readOnly ?? widget.readOnly) || !_isEnabled;
  bool get _isEnabled => _enabled ?? widget.enabled;
  FormeFieldValidation get _validation {
    if (!_isEnabled || !_hasAnyValidator) {
      return FormeFieldValidation.unnecessary;
    }
    if (_hasAnyValidator &&
        _model.validation == FormeFieldValidation.unnecessary) {
      return FormeFieldValidation.waiting;
    }
    return _model.validation;
  }

  /// set field readonly or not
  set readOnly(bool readOnly) {
    _readOnly = readOnly;
    if (_isReadOnly != _model.readOnly) {
      setState(() {
        _model = _model.copyWith(readOnly: _Optional(_isReadOnly));
      });
    }
  }

  /// set field enable or not
  ///
  /// if field is disabled
  ///
  /// 1. field can not be focused
  /// 2. field's validation is unnecessary
  /// 3. field is readOnly
  /// 4. trigger [onReadonlyChanged] if readonly state changed
  /// 5. trigger onValidationChanged if validation changed
  /// 6. trigger onEnabledChanged
  set enabled(bool enabled) {
    _enabled = enabled;
    setState(() {
      _validateGen++;
      if (!_isEnabled) {
        _hasInteractedByUser = false;
      }
      _model = _model.copyWith(
        enabled: _Optional(_isEnabled),
        readOnly: _Optional(_isReadOnly),
        validation: _Optional(_validation),
      );
    });
  }

  FormeFieldValidation get _initialValidation => _hasAnyValidator && enabled
      ? FormeFieldValidation.waiting
      : FormeFieldValidation.unnecessary;

  String? get errorText => !enabled ||
          (_formeState?.quietlyValidate ?? false) ||
          widget.quietlyValidate
      ? null
      : _model.validation.error;

  /// get initialValue
  T get initialValue =>
      _formeState?.getInitialValue(name, widget.initialValue) as T ??
      widget.initialValue;

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
    _focusNode!.addListener(_onFocusChangedListener);
  }

  void _onFocusChangedListener() {
    final _Model<T> old = _model;
    _model = _model.copyWith(
      hasFocus: _Optional(_focusNode?.hasFocus ?? false),
    );
    _onModelChanged(old, _model);
  }

  bool get isValueChanged => !compareValue(initialValue, value);

  void _register() {
    if (widget.registrable) {
      _formeState?.registerField(this);
    }
  }

  bool _inited = false;

  /// if you want to init some resources relies on [initialValue] or [readOnly] or [enabled]
  ///
  /// use [initModel] instead
  @override
  void initState() {
    super.initState();

    if (widget.onInitialed != null) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        widget.onInitialed?.call(controller);
      });
    }
  }

  @override
  void didUpdateWidget(covariant FormeField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.registrable) {
      _formeState?.registerField(this);
    } else {
      _formeState?.unregisterField(this);
    }

    final _Model<T> old = _model;
    _model = _model.copyWith(
      readOnly: _Optional(_isReadOnly),
      enabled: _Optional(_isEnabled),
      validation: _Optional(_validation),
    );

    if (widget.valueUpdater != null) {
      final bool needUpdateValue = didUpdateValue(oldWidget);
      if (needUpdateValue) {
        T newValue = widget.valueUpdater!(oldWidget, widget, value);
        _model = _model.copyWith(
          value: _Optional(newValue),
        );
      }
    }

    if (old.validation != _model.validation) {
      _validateGen++;
    }

    _onModelChanged(old, _model, true);
  }

  /// this method is used to determine whether  value  need update or not after widget updated
  /// eg: Dropdown value is '2',children values are ['1','2','3'] , after widget updated,
  /// children values are ['1','3','4'] . in this case Dropdown will be crashed due to value '2' is no longer in children values,
  ///
  /// override this method to tell user : **you should update this field's value, otherwise something unexpected will happen**
  ///
  /// if true , [widget.valueUpdater] will be called to get a new value
  @protected
  bool didUpdateValue(covariant FormeField<T> oldWidget) {
    return false;
  }

  @override
  void setState(VoidCallback fn) {
    final _Model<T> old = _model;
    super.setState(fn);
    _onModelChanged(old, _model);
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formeState = _FormeScope.of(context);

    if (!_inited) {
      _inited = true;

      initModel();
    } else {
      final _Model<T> old = _model;
      _model = _model.copyWith(
        readOnly: _Optional(_isReadOnly),
      );
      _onModelChanged(old, _model, true);
    }
  }

  /// this method will be called only once in state's lifecircle,immediately  called after [initState]
  ///
  /// recommend to init your resources in this method rather than [initState]
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method
  @protected
  @mustCallSuper
  void initModel() {
    _model = _Model<T>(
      enabled: widget.enabled,
      readOnly: widget.readOnly || !widget.enabled,
      validation: _hasAnyValidator && widget.enabled
          ? FormeFieldValidation.waiting
          : FormeFieldValidation.unnecessary,
      value: initialValue,
      hasFocus: _focusNode?.hasFocus ?? false,
    );
  }

  /// create [FormeFieldController] , this method will only called once in field's lifecycle
  ///
  /// if you want to override this method, use [FormeFieldControllerDelegate] to wrap parent's controller
  @protected
  FormeFieldController<T> createFormeFieldController() =>
      _FormeFieldController(this);

  @override
  void deactivate() {
    _formeState?.unregisterField(this);
    super.deactivate();
  }

  @override
  void dispose() {
    _valueNotifier?.dispose();
    _focusNotifier?.dispose();
    _validationNotifier?.dispose();
    _readOnlyNotifier?.dispose();
    _enabledNotifier?.dispose();
    _asyncValidatorTimer?.cancel();
    _focusNode?.removeListener(_onFocusChangedListener);
    if (_focusNode is _DisposeRequiredFocusNode) {
      _focusNode?.dispose();
    }
    super.dispose();
  }

  @mustCallSuper
  void didChange(T newValue) {
    if (!compareValue(_model.value, newValue)) {
      setState(() {
        _hasInteractedByUser = true;
        _model = _model.copyWith(value: _Optional(newValue));
      });
      _fieldChange();
    }
  }

  @mustCallSuper
  void reset() {
    setState(() {
      _validateGen++;
      _hasInteractedByUser = false;
      _ignoreValidate = false;
      _model = _model.copyWith(
          validation: _Optional(_initialValidation),
          value: _Optional(initialValue));
    });
    _fieldChange();
  }

  set value(T value) => didChange(value);

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

    _register();
    return FormeFieldScope(controller, child);
  }

  void _onModelChanged(_Model<T> oldModel, _Model<T> newModel,
      [bool onlyAfterFrameCompleted = false]) {
    void _perform(VoidCallback fn) {
      if (onlyAfterFrameCompleted) {
        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
          fn();
        });
      } else {
        fn();
      }
    }

    if (oldModel.enabled != newModel.enabled) {
      _focusNode?.canRequestFocus = newModel.enabled;
      _perform(() {
        widget.onEnabledChanged?.call(controller, newModel.enabled);
        _formeState?.fieldEnabledChange(this, newModel.enabled);
        _enabledNotifier?.value = newModel.enabled;
        onEnabledChanged(newModel.enabled);
      });
    }
    if (oldModel.readOnly != newModel.readOnly) {
      _perform(() {
        widget.onReadonlyChanged?.call(controller, newModel.readOnly);
        _formeState?.fieldReadonlyChange(this, newModel.readOnly);
        _readOnlyNotifier?.value = newModel.readOnly;
        onReadonlyChanged(newModel.readOnly);
      });
    }
    if (oldModel.validation != newModel.validation) {
      _perform(() {
        widget.onValidationChanged?.call(controller, newModel.validation);
        _formeState?.fieldValidationChange(this, newModel.validation);
        _validationNotifier?.value = newModel.validation;
        onValidationChanged(newModel.validation);
      });
    }
    if (!compareValue(oldModel.value, newModel.value)) {
      _oldValue = oldModel.value;
      _ignoreValidate = false;
      _perform(() {
        widget.onValueChanged?.call(controller, newModel.value);
        _formeState?.fieldValueChange(this, newModel.value);
        _valueNotifier?.value = newModel.value;
        onValueChanged(newModel.value);
      });
    }

    if (oldModel.hasFocus != newModel.hasFocus) {
      widget.onFocusChanged?.call(controller, newModel.hasFocus);
      _formeState?.fieldFocusChange(this, newModel.hasFocus);
      _focusNotifier?.value = newModel.hasFocus;
      onFocusChanged(newModel.hasFocus);
    }
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

  /// override this method if you want to listen readonly-state change
  @protected
  void onReadonlyChanged(bool readOnly) {}

  /// override this method if you want to listen enable-state change
  @protected
  void onEnabledChanged(bool enable) {}

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
    if (_model.validation != _initialValidation) {
      setState(() {
        _validateGen++;
        _model = _model.copyWith(validation: _Optional(_initialValidation));
      });
    }
  }

  /// this method should be only called in [_FormeState.build]
  Future<FormeFieldValidation> _validate2() async {
    void notifyValidation(FormeFieldValidation validation) {
      if (validation != _model.validation) {
        setState(() {
          _model = _model.copyWith(validation: _Optional(validation));
        });
      }
    }

    if (_ignoreValidate || !_hasAnyValidator) {
      if (!_hasAnyValidator) {
        notifyValidation(FormeFieldValidation.unnecessary);
      }
    }

    final int gen = ++_validateGen;
    if (_hasValidator) {
      final String? errorText = widget.validator!(controller, value);
      if (errorText != null || !_hasAsyncValidator) {
        notifyValidation(_createFormeFieldValidation(errorText));
      }
    }

    if (_hasAsyncValidator) {
      notifyValidation(FormeFieldValidation.validating);
      await _performAsyncValidate(gen);
    }
    return _model.validation;
  }

  /// this method should  be only called in [FormeFieldState.build]
  void _validate() {
    void notifyValidation(FormeFieldValidation validation) {
      if (_model.validation != validation) {
        final _Model<T> oldModel = _model;
        _model = _model.copyWith(validation: _Optional(validation));
        _onModelChanged(oldModel, _model, true);
      }
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
    _asyncValidatorTimer =
        Timer(widget.asyncValidatorDebounce ?? _defaultAsyncValidatorDebounce,
            () async {
      final bool isValid = await _performAsyncValidate(gen);
      if (isValid) {
        onCompleted?.call();
      }
    });
  }

  Future<bool> _performAsyncValidate(int gen) async {
    bool isValid() {
      return mounted && gen == _validateGen;
    }

    FormeFieldValidation validation;

    try {
      final String? errorText =
          await widget.asyncValidator!(controller, value, isValid);
      validation = _createFormeFieldValidation(errorText);
    } catch (e, stackTrace) {
      validation = FormeFieldValidation.fail(e, stackTrace);
    }

    if (isValid()) {
      setState(() {
        _ignoreValidate = true;
        _model = _model.copyWith(validation: _Optional(validation));
      });
      return true;
    }
    return false;
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
      return FormeFieldValidateSnapshot(
          value, FormeFieldValidation.unnecessary, controller, false, false);
    }
    final int gen = quietly ? _validateGen : ++_validateGen;

    bool isValid() {
      return mounted && gen == _validateGen;
    }

    bool needNotify() {
      return !quietly && isValid();
    }

    void notify(FormeFieldValidation validation) {
      if (needNotify() && _model.validation != validation) {
        setState(() {
          _model = _model.copyWith(validation: _Optional(validation));
        });
      }
    }

    if (_hasValidator) {
      final String? errorText = widget.validator!(controller, value);
      if (errorText != null || !_hasAsyncValidator) {
        final FormeFieldValidation validation =
            _createFormeFieldValidation(errorText);
        notify(validation);
        return FormeFieldValidateSnapshot(
            value, validation, controller, false, false);
      }
    }

    notify(FormeFieldValidation.validating);

    FormeFieldValidation validation;
    try {
      final String? errorText =
          await widget.asyncValidator!(controller, value, isValid);
      validation = _createFormeFieldValidation(errorText);
    } catch (e, stackTrace) {
      validation = FormeFieldValidation.fail(e, stackTrace);
    }

    notify(validation);
    return FormeFieldValidateSnapshot(value, validation, controller,
        !compareValue(value, this.value), !compareValue(value, initialValue));
  }

  void _markNeedsBuild() {
    setState(() {});
  }
}

class _FormeController extends FormeController {
  final _FormeState state;
  @override
  final ValueListenable<Map<String, FormeFieldController?>> fieldsListenable;

  _FormeController(this.state)
      : fieldsListenable = FormeValueListenableDelegate(state.fieldsNotifier);

  @override
  Map<String, Object?> get value {
    final Map<String, Object?> map = <String, Object?>{};
    for (final FormeFieldState element in state.states) {
      if (!element.enabled) {
        continue;
      }
      final String name = element.name;
      final Object? value = element.value;
      map[name] = value;
    }
    return map;
  }

  @override
  bool get quietlyValidate => state.quietlyValidate;

  @override
  FormeValidation get validation => FormeValidation(state.states
      .where((element) => element.enabled)
      .toList()
      .asMap()
      .map((key, value) => MapEntry(value.name, value._model.validation)));

  @override
  T field<T extends FormeFieldController<Object?>>(String name) {
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
    final List<FormeFieldValidateSnapshot<Object?>> value = await Future.wait(
        states.map((state) => state._performValidate(quietly: quietly)),
        eagerError: true);
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
  set value(Map<String, Object?> data) => data.forEach((key, Object? value) {
        field(key).value = value;
      });

  T? findFormeFieldController<T extends FormeFieldController<Object?>>(
      String name) {
    for (final FormeFieldState state in state.states) {
      if (state.name == name) {
        return state.controller as T;
      }
    }
    return null;
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

class _FormeFieldController<T extends Object?> extends FormeFieldController<T> {
  final FormeFieldState<T> _state;

  @override
  ValueListenable<FormeFieldValidation> get validationListenable =>
      _state._validationListenable;
  @override
  ValueListenable<T> get valueListenable => _state._valueListenable;
  @override
  ValueListenable<bool> get focusListenable => _state._focusListenable;
  @override
  ValueListenable<bool> get readOnlyListenable => _state._readOnlyListenable;
  @override
  ValueListenable<bool> get enabledListenable => _state._enabledListenable;

  _FormeFieldController(this._state);

  @override
  bool get readOnly => _state.readOnly;

  @override
  FormeController? get formeController => Forme.of(_state.context);

  @override
  FocusNode? get focusNode => _state._focusNode;

  @override
  String get name => _state.name;

  @override
  set readOnly(bool readOnly) => _state.readOnly = readOnly;

  @override
  T get value => _state.value;

  @override
  FormeFieldValidation get validation => _state._model.validation;

  @override
  void reset() => _state.reset();

  @override
  Future<FormeFieldValidateSnapshot<T>> validate({bool quietly = false}) =>
      _state._performValidate(quietly: quietly);

  @override
  set value(T value) => _state.value = value;

  @override
  T? get oldValue => _state.oldValue;

  @override
  bool get isValueChanged => _state.isValueChanged;

  @override
  BuildContext get context => _state.context;

  @override
  bool get enabled => _state.enabled;

  @override
  set enabled(bool enabled) => _state.enabled = enabled;

  @override
  bool get mounted => _state.mounted;

  @override
  void markNeedsBuild() => _state._markNeedsBuild();
}

/// a focusnode created by FormeField itself rather than set by subclass ,
/// so it's our responsibility to dispose it
class _DisposeRequiredFocusNode extends FocusNode {}

class _Model<T> {
  final bool enabled;
  final bool readOnly;
  final FormeFieldValidation validation;
  final T value;
  final bool hasFocus;

  _Model({
    required this.enabled,
    required this.readOnly,
    required this.validation,
    required this.value,
    required this.hasFocus,
  });

  _Model<T> copyWith({
    _Optional<bool>? enabled,
    _Optional<bool>? readOnly,
    _Optional<FormeFieldValidation>? validation,
    _Optional<T>? value,
    _Optional<bool>? hasFocus,
  }) {
    return _Model<T>(
      enabled: enabled == null ? this.enabled : enabled.value,
      readOnly: readOnly == null ? this.readOnly : readOnly.value,
      validation: validation == null ? this.validation : validation.value,
      value: value == null ? this.value : value.value,
      hasFocus: hasFocus == null ? this.hasFocus : hasFocus.value,
    );
  }
}

class _Optional<T> {
  final T value;
  _Optional(this.value);
}
