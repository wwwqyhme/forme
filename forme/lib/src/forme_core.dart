import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'forme_field.dart';
import 'forme_field_scope.dart';
import 'forme_visitor.dart';
import 'validate/forme_field_validate_snapshot.dart';
import 'validate/forme_field_validation_context.dart';
import 'validate/forme_validation.dart';

/// form key is a global key , also used to manage form
class FormeKey extends LabeledGlobalKey<FormeState> {
  FormeKey({String? debugLabel}) : super(debugLabel);

  /// whether formKey is initialized
  bool get initialized {
    final State? state = currentState;
    if (state == null) {
      return false;
    }
    return true;
  }

  FormeState get _state =>
      currentState ??
      (throw Exception(
          'current state is null , did you put this key on Forme?'));

  Map<String, Object?> get value => _state.value;

  FormeValidation get validation => _state.validation;

  T field<T extends FormeFieldState<Object?>>(String name) =>
      _state.field<T>(name);

  bool hasField(String name) => _state.hasField(name);

  Future<FormeValidateSnapshot> validate({
    bool quietly = false,
    Set<String> names = const {},
    bool clearError = false,
    bool validateByOrder = false,
  }) =>
      _state.validate(
        quietly: quietly,
        names: names,
        validateByOrder: validateByOrder,
        clearError: clearError,
      );

  void reset() => _state.reset();

  void save() => _state.save();

  set value(Map<String, Object?> data) => _state.value = data;

  bool get quietlyValidate => _state.quietlyValidate;

  bool get isValueChanged => _state.isValueChanged;

  List<FormeFieldState> get fields => _state.fields;

  bool addVisitor(FormeVisitor visitor) => _state.addVisitor(visitor);

  bool removeVisitor(FormeVisitor visitor) => _state.removeVisitor(visitor);
}

/// build your form !
class Forme extends StatefulWidget {
  /// listen form focus changed
  final FormeFieldStatusChanged<Object?>? onFieldStatusChanged;

  /// form content
  final Widget child;

  /// map initial value
  final Map<String, Object?> initialValue;

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

  /// listen fields registered in this frame
  final void Function(List<FormeFieldState> fields)? onFieldsRegistered;
  final void Function(List<FormeFieldState> fields)? onFieldsUnregistered;

  /// called in [FormeState.initState]
  ///
  /// typically used to add visitors
  ///
  /// **DO NOT** get any field or request a new frame here
  final void Function(FormeState form)? onInitialed;

  const Forme({
    FormeKey? key,
    this.onFieldStatusChanged,
    required this.child,
    this.initialValue = const <String, Object?>{},
    this.onWillPop,
    this.quietlyValidate = false,
    AutovalidateMode? autovalidateMode,
    this.autovalidateByOrder = false,
    this.onFieldsRegistered,
    this.onFieldsUnregistered,
    this.onInitialed,
  })  : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled,
        super(key: key);

  @override
  State<Forme> createState() => FormeState();

  static FormeState? of(BuildContext context) => _FormeScope.of(context);
}

class FormeState extends State<Forme> {
  final List<FormeFieldState> _states = [];
  final List<FormeFieldState> _newRegisteredStates = [];
  final List<FormeFieldState> _newUnregisteredStates = [];
  final List<FormeVisitor> _visitors = [];

  /// get initialValue
  Map<String, Object?> get initialValue => widget.initialValue;
  AutovalidateMode get autovalidateMode => widget.autovalidateMode;

  int _gen = 0;

  /// whether current form is quietlyValidate or not
  bool get quietlyValidate => widget.quietlyValidate;

  /// get form validation
  FormeValidation get validation => FormeValidation(_states
      .where((element) => element.enabled)
      .toList()
      .asMap()
      .map((key, value) => MapEntry(value.name, value._status.validation)));

  /// reset all registered fields
  void reset() {
    for (final FormeFieldState element in _states) {
      element.reset();
    }
    if (widget.autovalidateMode == AutovalidateMode.always) {
      setState(() {});
    }
  }

  /// whether value is changed or not
  bool get isValueChanged => _states.any((element) => element.isValueChanged);

  /// get form value
  ///
  /// will not contains value of disabled fields
  Map<String, Object?> get value {
    final Map<String, Object?> map = <String, Object?>{};
    for (final FormeFieldState element in _states) {
      if (!element.enabled) {
        continue;
      }
      final String name = element.name;
      final Object? value = element.value;
      map[name] = value;
    }
    return map;
  }

  /// get field by name
  ///
  /// throw an exception if field not found
  T field<T extends FormeFieldState<Object?>>(String name) {
    final T? field = _findField(name);
    if (field == null) {
      throw Exception('no field can be found by name :$name');
    }
    return field;
  }

  /// whether field is registered
  bool hasField(String name) => _states.any((element) => element.name == name);

  /// validate form manually
  ///
  /// if [names] is not empty , will only validate these fields
  /// if [clearError] is true, will clear error first before validate
  /// if [validateByOrder] is true, will validate field by order , only one field will be validated at once
  Future<FormeValidateSnapshot> validate({
    bool quietly = false,
    Set<String> names = const {},
    bool clearError = false,
    bool validateByOrder = false,
  }) async {
    final List<FormeFieldState> states = (_states
            .where((element) =>
                element._hasAnyValidator &&
                element.enabled &&
                (names.isEmpty || names.contains(element.name)))
            .toList()
          ..sort((a, b) => a.order!.compareTo(b.order!)))
        .toList();
    if (states.isEmpty) {
      return FormeValidateSnapshot([]);
    }
    if (clearError) {
      for (final FormeFieldState element in states) {
        element.errorText = null;
      }
    }
    if (validateByOrder) {
      return _validateByOrderManually(states, quietly);
    }
    final List<FormeFieldValidateSnapshot<Object?>> value = await Future.wait(
        states.map((state) => state.validate(quietly: quietly)),
        eagerError: true);
    return FormeValidateSnapshot(value);
  }

  /// set form value
  set value(Map<String, Object?> data) => data.forEach((key, Object? value) {
        field(key).value = value;
      });

  /// get all regsitered  fields
  List<FormeFieldState> get fields => List.of(_states);

  /// add visitor
  ///
  /// return true if visitor is not exists
  bool addVisitor(FormeVisitor visitor) {
    if (!_visitors.contains(visitor)) {
      _visitors.add(visitor);
      return true;
    }
    return false;
  }

  /// remove visitor
  ///
  /// return true if visitor removed
  bool removeVisitor(FormeVisitor visitor) {
    return _visitors.remove(visitor);
  }

  /// save all registered fields
  void save() {
    for (final FormeFieldState element in _states) {
      element.save();
    }
  }

  /// rebuild all widgets of form
  void rebuildForm() {
    setState(() {
      ++_gen;
    });
  }

  T? _findField<T extends FormeFieldState<Object?>>(String name) {
    for (final FormeFieldState state in _states) {
      if (state.name == name) {
        return state as T;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    widget.onInitialed?.call(this);
  }

  @override
  Widget build(BuildContext context) {
    if (_needValidate) {
      _validateForm();
    }
    return WillPopScope(
      onWillPop: widget.onWillPop,
      child: _FormeScope(
        gen: _gen,
        state: this,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _visitors.clear();
    _newRegisteredStates.clear();
    _newUnregisteredStates.clear();
    super.dispose();
  }

  Future<FormeValidation> _validateForm() async {
    if (widget.autovalidateByOrder) {
      final List<FormeFieldState> valueFieldStates = _states
          .where((element) => element._hasAnyValidator && element.enabled)
          .toList()
        ..sort((a, b) => a.order!.compareTo(b.order!));
      if (valueFieldStates.isEmpty) {
        return const FormeValidation({});
      }
      return _validateByOrder(valueFieldStates, collector: {});
    } else {
      final Map<String, FormeFieldValidation> validations = {};
      await Future.wait(_states
          .where((element) => element.enabled)
          .map((e) => e._validateByForm().then((value) {
                validations[e.name] = value;
                return value;
              })));
      return FormeValidation(validations);
    }
  }

  Object? _getInitialValue(String name, Object? value) {
    if (widget.initialValue.containsKey(name)) {
      return widget.initialValue[name];
    }
    return value;
  }

  bool get _needValidate {
    if (autovalidateMode == AutovalidateMode.always) {
      return true;
    }
    if (autovalidateMode == AutovalidateMode.onUserInteraction) {
      return _states.any((element) => element._hasInteractedByUser);
    }
    return false;
  }

  void _fieldDidChange() {
    if (_needValidate) {
      setState(() {
        // ++_gen;
      });
    }
  }

  void _notifyFieldsRegistered(List<FormeFieldState> states) {
    for (final FormeFieldState state in states) {
      for (FormeFieldVisitor visitor in state._visitors) {
        visitor.onRegistered(this, state);
      }
    }

    for (final FormeVisitor visitor in _visitors) {
      visitor.onFieldsRegistered(this, List.of(states));
    }

    widget.onFieldsRegistered?.call(List.of(states));
  }

  void _notifyFieldsUnregistered(List<FormeFieldState> states) {
    for (final FormeFieldState state in states) {
      for (FormeFieldVisitor visitor in state._visitors) {
        visitor.onUnregistered(this, state);
      }
    }
    for (final FormeVisitor visitor in _visitors) {
      visitor.onFieldsUnregistered(this, List.of(states));
    }
    widget.onFieldsUnregistered?.call(states);
  }

  void _notifiyFieldsStatusChanged(
    FormeFieldState state,
    FormeFieldChangedStatus status,
  ) {
    if (!_states.contains(state)) {
      return;
    }
    for (final FormeVisitor visitor in _visitors) {
      visitor.onFieldStatusChanged(this, state, status);
    }

    widget.onFieldStatusChanged?.call(state, status);
  }

  void _registerField(FormeFieldState state) {
    if (!_states.contains(state)) {
      _states.add(state);
      if (_newRegisteredStates.isEmpty) {
        SchedulerBinding.instance!.endOfFrame.then((_) {
          if (_needValidate) {
            _validateForm();
          }
          final List<FormeFieldState> states = List.of(_newRegisteredStates);
          _newRegisteredStates.clear();
          _notifyFieldsRegistered(states);
        });
      }
      _newRegisteredStates.add(state);
    }
  }

  void _unregisterField(FormeFieldState state) {
    if (_states.remove(state)) {
      if (_newUnregisteredStates.isEmpty) {
        SchedulerBinding.instance!.endOfFrame.then((_) {
          if (mounted) {
            if (_needValidate) {
              _validateForm();
            }
            final List<FormeFieldState> states =
                List.of(_newUnregisteredStates);
            _newUnregisteredStates.clear();
            _notifyFieldsUnregistered(states);
          }
        });
      }
      _newUnregisteredStates.add(state);
    }
  }

  int _getOrder(FormeFieldState formeFieldState) {
    return _states.indexOf(formeFieldState);
  }

  Future<FormeValidateSnapshot> _validateByOrderManually(
      List<FormeFieldState> states, bool quietly,
      {int index = 0, List<FormeFieldValidateSnapshot> list = const []}) async {
    final int length = states.length;
    final List<FormeFieldValidateSnapshot> copyList = List.of(list);
    final FormeFieldValidateSnapshot snapshot =
        await states[index].validate(quietly: quietly);
    copyList.add(snapshot);
    if (!snapshot.isValid || index == length - 1) {
      return FormeValidateSnapshot(copyList);
    }
    return _validateByOrderManually(states, quietly,
        index: index + 1, list: copyList);
  }

  Future<FormeValidation> _validateByOrder(List<FormeFieldState> states,
      {int index = 0,
      required Map<String, FormeFieldValidation> collector}) async {
    final int length = states.length;
    if (index >= length) {
      return FormeValidation(collector);
    }
    final FormeFieldState state = states[index];
    final FormeFieldValidation validation = await state._validateByForm();
    collector[state.name] = validation;
    if (validation.isUnnecessary || validation.isValid) {
      return await _validateByOrder(states,
          index: index + 1, collector: collector);
    }
    return FormeValidation(collector);
  }
}

class _FormeScope extends InheritedWidget {
  final int gen;
  final FormeState state;

  const _FormeScope({
    required this.gen,
    required this.state,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant _FormeScope oldWidget) {
    return gen != oldWidget.gen;
  }

  static FormeState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FormeScope>()?.state;
  }
}

class FormeFieldState<T extends Object?> extends State<FormeField<T>> {
  final List<FormeFieldVisitor<T>> _visitors = [];

  final Duration _defaultAsyncValidatorDebounce =
      const Duration(milliseconds: 500);

  FocusNode? _focusNode;
  Timer? _asyncValidatorTimer;
  bool _hasInteractedByUser = false;
  int _validateGen = 0;

  late FormeFieldStatus<T> _status;
  FormeState? _formeState;

  int? get order => widget.order ?? _formeState?._getOrder(this);

  String get name => widget.name;
  T get value => _status.value;

  T? _oldValue;
  T? _latestSuccessfulValidationValue;
  T? _validatingValue;

  bool _inited = false;

  bool get _hasValidator => widget.validator != null;
  bool get _hasAsyncValidator => widget.asyncValidator != null;
  bool get _hasAnyValidator => _hasValidator || _hasAsyncValidator;

  bool get readOnly => _status.readOnly;
  bool get enabled => _status.enabled;

  bool? _readOnly;
  bool? _enabled;

  bool get _isReadOnly => (_readOnly ?? widget.readOnly) || !_isEnabled;
  bool get _isEnabled => _enabled ?? widget.enabled;
  FormeFieldValidation get _validation {
    if (!_isEnabled || !_hasAnyValidator) {
      return FormeFieldValidation.unnecessary;
    }
    if (_hasAnyValidator &&
        _status.validation == FormeFieldValidation.unnecessary) {
      return FormeFieldValidation.waiting;
    }
    return _status.validation;
  }

  /// get generic type
  Type get type => T;

  /// whether value can be nullable or not
  bool get isNullable => null is T;

  /// get previous value
  T? get oldValue => _oldValue;

  /// get form state
  ///
  /// return null if field not wrapped by [Forme]
  FormeState? get form => _formeState;

  /// get current status
  FormeFieldStatus<T> get status => _status;

  /// whether current validation is set via [errorText]
  bool get isCustomValidation => _status.validation is _CustomValidation;

  /// set field readonly or not
  set readOnly(bool readOnly) {
    _readOnly = readOnly;
    if (_isReadOnly != _status.readOnly) {
      setState(() {
        _status = _status._copyWith(readOnly: _Optional(_isReadOnly));
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
      _status = _status._copyWith(
        enabled: _Optional(_isEnabled),
        readOnly: _Optional(_isReadOnly),
        validation: _Optional(_validation),
      );
    });
  }

  FormeFieldValidation get _initialValidation => _hasAnyValidator && enabled
      ? FormeFieldValidation.waiting
      : FormeFieldValidation.unnecessary;

  /// get current validation state
  FormeFieldValidation get validation => _status.validation;

  /// get errorText
  ///
  /// **null when field has no error or quietlyValidate**
  String? get errorText => !enabled ||
          (_formeState?.quietlyValidate ?? false) ||
          widget.quietlyValidate
      ? null
      : _status.validation.error;

  /// get initialValue
  ///
  /// **[Forme.initialValue] has higher priority than field's initialValue**
  T get initialValue {
    Object? initialValue =
        _formeState?._getInitialValue(name, widget.initialValue);
    if (initialValue != null) {
      return initialValue as T;
    }
    return widget.initialValue;
  }

  /// whether field request a focusnode or not
  bool get hasFocusNode => _focusNode != null;

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

  /// whether value is changed after initialed
  bool get isValueChanged => !isValueEquals(initialValue, value);

  @mustCallSuper
  void didChange(T newValue) {
    if (!isValueEquals(_status.value, newValue)) {
      setState(() {
        _hasInteractedByUser = true;
        _status = _status._copyWith(value: _Optional(newValue));
      });
      _fieldChange();
    }
  }

  /// equals to [FormeFieldState.didChange]
  set value(T value) => didChange(value);

  /// reset field
  ///
  /// 1. clear validation
  /// 2. set value to initialValue
  @mustCallSuper
  void reset() {
    setState(() {
      _validateGen++;
      _latestSuccessfulValidationValue = null;
      _hasInteractedByUser = false;
      _status = _status._copyWith(
          validation: _Optional(_initialValidation),
          value: _Optional(initialValue));
    });
    _fieldChange();
  }

  /// request focus if user interacted
  void requestFocusOnUserInteraction() {
    if (_hasInteractedByUser && widget.requestFocusOnUserInteraction) {
      _focusNode?.requestFocus();
    }
  }

  /// save field
  void save() {
    widget.onSaved?.call(this, value);
  }

  /// if [errorText] is null , reset validation
  /// if [errorText] not null , set custom error text even though field has no validators at all
  ///
  /// field will rebuild after this method called , a validation may be performed during building.
  /// in this case , custom validation  will be overwritten by new validation.
  ///
  /// will not worked on disabled fields
  ///
  /// see  [FormeFieldState.isCustomValidation]
  ///
  /// see  [FormeField.validateFilter]
  set errorText(String? errorText) {
    if (!enabled) {
      return;
    }
    final FormeFieldValidation validation;
    if (errorText == null) {
      validation = _initialValidation;
    } else {
      validation = _CustomValidation.invalid(errorText);
    }
    if (_status.validation != validation) {
      setState(() {
        _validateGen++;
        _status = _status._copyWith(validation: _Optional(validation));
      });
    }
  }

  /// this method is used to manually validate
  Future<FormeFieldValidateSnapshot<T>> validate({bool quietly = false}) async {
    final T value = this.value;
    if (!_hasAnyValidator || !enabled) {
      return FormeFieldValidateSnapshot(
          value, FormeFieldValidation.unnecessary, name, false, false);
    }
    final int gen = quietly ? _validateGen : ++_validateGen;

    bool isValid() {
      return mounted && gen == _validateGen;
    }

    bool needNotify() {
      return !quietly && isValid();
    }

    void notify(FormeFieldValidation validation) {
      if (needNotify() && _status.validation != validation) {
        setState(() {
          _status = _status._copyWith(validation: _Optional(validation));
        });
      }
    }

    if (_hasValidator) {
      final String? errorText = widget.validator!(this, value);
      if (errorText != null || !_hasAsyncValidator) {
        final FormeFieldValidation validation =
            _createFormeFieldValidation(errorText);
        notify(validation);
        return FormeFieldValidateSnapshot(
            value, validation, name, false, false);
      }
    }

    notify(FormeFieldValidation.validating);

    FormeFieldValidation validation;
    try {
      final String? errorText =
          await widget.asyncValidator!(this, value, isValid);
      validation = _createFormeFieldValidation(errorText);
    } catch (e, stackTrace) {
      validation = FormeFieldValidation.fail(e, stackTrace);
    }

    notify(validation);
    return FormeFieldValidateSnapshot(
        value, validation, name, value != this.value, value != initialValue);
  }

  /// add visitor
  ///
  /// true if visitor not exists
  bool addVisitor(FormeFieldVisitor<T> visitor) {
    if (!_visitors.contains(visitor)) {
      _visitors.add(visitor);
      return true;
    }
    return false;
  }

  /// remove visitor
  ///
  /// true if visitor exists
  bool removeVisitor(FormeFieldVisitor<T> visitor) {
    return _visitors.remove(visitor);
  }

  void _onFocusChangedListener() {
    final FormeFieldStatus<T> old = _status;
    _status = _status._copyWith(
      hasFocus: _Optional(_focusNode?.hasFocus ?? false),
    );
    _onStatusChanged(old, _status);
  }

  /// this method will be called only once in state's lifecircle,immediately  called after [initState]
  ///
  /// recommend to init your resources in this method rather than [initState]
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method
  @protected
  @mustCallSuper
  void initStatus() {
    _status = FormeFieldStatus<T>._(
      enabled: widget.enabled,
      readOnly: widget.readOnly || !widget.enabled,
      validation: _hasAnyValidator && widget.enabled
          ? FormeFieldValidation.waiting
          : FormeFieldValidation.unnecessary,
      value: initialValue,
      hasFocus: _focusNode?.hasFocus ?? false,
    );
  }

  @override
  void didUpdateWidget(covariant FormeField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.registrable) {
      _formeState?._registerField(this);
    } else {
      _formeState?._unregisterField(this);
    }

    final FormeFieldStatus<T> old = _status;
    _status = _status._copyWith(
      readOnly: _Optional(_isReadOnly),
      enabled: _Optional(_isEnabled),
      validation: _Optional(_validation),
    );

    if (widget.valueUpdater != null) {
      T newValue = widget.valueUpdater!(oldWidget, widget, value);
      _status = _status._copyWith(
        value: _Optional(newValue),
      );
    }

    if (old.validation != _status.validation) {
      _validateGen++;
    }

    _onStatusChanged(old, _status, true);
  }

  @override
  void setState(VoidCallback fn) {
    final FormeFieldStatus<T> old = _status;
    super.setState(fn);
    _onStatusChanged(old, _status);
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formeState = _FormeScope.of(context);

    if (!_inited) {
      _inited = true;
      initStatus();
      widget.onInitialed?.call(this);
    }
  }

  @override
  void deactivate() {
    _formeState?._unregisterField(this);
    super.deactivate();
  }

  @override
  void dispose() {
    _visitors.clear();
    _asyncValidatorTimer?.cancel();
    _focusNode?.removeListener(_onFocusChangedListener);
    if (_focusNode is _DisposeRequiredFocusNode) {
      _focusNode?.dispose();
    }
    super.dispose();
  }

  void _register() {
    if (widget.registrable) {
      _formeState?._registerField(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool needValidate = _hasAnyValidator &&
        enabled &&
        ((widget.autovalidateMode == AutovalidateMode.always) ||
            (widget.autovalidateMode == AutovalidateMode.onUserInteraction &&
                _hasInteractedByUser));
    if (needValidate) {
      _validateByField();
    }

    _register();
    return FormeFieldScope(this, Builder(
      builder: (context) {
        Widget child = widget.builder(this);

        if (widget.decorator != null) {
          child = widget.decorator!.build(
            context,
            child,
          );
        }
        return child;
      },
    ));
  }

  bool _defaultComparator(T oldValue, T newValue) {
    if (oldValue is List && newValue is List) {
      return listEquals(oldValue, newValue);
    }

    if (oldValue is Set && newValue is Set) {
      return setEquals(oldValue, newValue);
    }

    if (oldValue is Map && newValue is Map) {
      return mapEquals(oldValue, newValue);
    }

    return oldValue == newValue;
  }

  @protected
  bool isValueEquals(T oldValue, T newValue) {
    return (widget.comparator ?? _defaultComparator).call(oldValue, newValue);
  }

  void _onStatusChanged(
      FormeFieldStatus<T> oldStatus, FormeFieldStatus<T> newStatus,
      [bool onlyAfterFrameCompleted = false]) {
    final FormeFieldChangedStatus<T> status = FormeFieldChangedStatus._(
        newStatus,
        oldStatus.enabled != newStatus.enabled,
        oldStatus.hasFocus != newStatus.hasFocus,
        oldStatus.readOnly != newStatus.readOnly,
        oldStatus.validation != newStatus.validation,
        !isValueEquals(oldStatus.value, newStatus.value));

    void task() {
      for (FormeFieldVisitor<T> visitor in _visitors) {
        visitor.onStatusChanged(_formeState, this, status);
      }
      _formeState?._notifiyFieldsStatusChanged(this, status);
      onStatusChanged(status);
      widget.onStatusChanged?.call(this, status);
    }

    if (status.isValidationChanged) {
      _validatingValue = null;
      final FormeFieldValidation validation = status.validation;
      if (validation.isValid || validation.isInvalid) {
        _latestSuccessfulValidationValue = status.value;
      }
      if (validation.isValidating) {
        _validatingValue = status.value;
      }
    }

    if (status.isEnabledChanged) {
      _focusNode?.canRequestFocus = newStatus.enabled;
    }

    if (status.isValueChanged) {
      _oldValue = oldStatus.value;
    }

    if (onlyAfterFrameCompleted) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        task();
      });
    } else {
      task();
    }
  }

  /// override this method if you want to listen status changed
  @protected
  void onStatusChanged(FormeFieldChangedStatus<T> status) {}

  bool _defaultValidationFilter(FormeFieldValidationContext<T> context) {
    final FormeFieldValidation validation = context.validation;

    if (validation.isWaiting || validation.isFail) {
      return true;
    }

    if (validation.isValidating) {
      if (context.comparator(
          context.validatingValue as T, context.currentValidateValue)) {
        return false;
      }
      return true;
    }

    return !context.comparator(context.latestSuccessfulValidationValue as T,
        context.currentValidateValue);
  }

  bool get _needValidate {
    final FormeFieldValidationContext<T> context =
        FormeFieldValidationContext<T>(
            this,
            form,
            _latestSuccessfulValidationValue,
            status.value,
            _validatingValue,
            isValueEquals);
    return (widget.validationFilter ?? _defaultValidationFilter).call(context);
  }

  void _notifyValidation(
      FormeFieldValidation validation, bool requestNewFrame) {
    if (mounted && validation != _status.validation) {
      if (requestNewFrame) {
        setState(() {
          _status = _status._copyWith(validation: _Optional(validation));
        });
      } else {
        final FormeFieldStatus<T> oldStatus = _status;
        _status = _status._copyWith(validation: _Optional(validation));
        _onStatusChanged(oldStatus, _status, true);
      }
    }
  }

  /// this method should be only called in [_FormeState.build]
  Future<FormeFieldValidation> _validateByForm() async {
    if (!_needValidate) {
      return _status.validation;
    }

    if (!_hasAnyValidator) {
      _notifyValidation(FormeFieldValidation.unnecessary, true);
      return _status.validation;
    }

    final int gen = ++_validateGen;
    if (_hasValidator) {
      final String? errorText = widget.validator!(this, value);
      if (errorText != null || !_hasAsyncValidator) {
        _notifyValidation(_createFormeFieldValidation(errorText), true);
        return _status.validation;
      }
    }

    if (_hasAsyncValidator) {
      _notifyValidation(FormeFieldValidation.validating, true);
      await _performAsyncValidate(gen);
    }
    return _status.validation;
  }

  /// this method should  be only called in [FormeFieldState.build]
  void _validateByField() {
    if (!_needValidate) {
      return;
    }

    if (!_hasAnyValidator) {
      _notifyValidation(FormeFieldValidation.unnecessary, false);
      return;
    }

    final int gen = ++_validateGen;

    if (_hasValidator) {
      final String? errorText = widget.validator!(this, value);
      if (errorText != null || !_hasAsyncValidator) {
        _notifyValidation(_createFormeFieldValidation(errorText), false);
        return;
      }
    }
    if (_hasAsyncValidator) {
      _notifyValidation(FormeFieldValidation.validating, false);
      _asyncValidatorTimer?.cancel();
      _asyncValidatorTimer = Timer(
          widget.asyncValidatorDebounce ?? _defaultAsyncValidatorDebounce, () {
        _performAsyncValidate(gen);
      });
    }
  }

  Future<bool> _performAsyncValidate(int gen) async {
    bool isValid() {
      return mounted && gen == _validateGen;
    }

    FormeFieldValidation validation;

    try {
      final String? errorText =
          await widget.asyncValidator!(this, value, isValid);
      validation = _createFormeFieldValidation(errorText);
    } catch (e, stackTrace) {
      validation = FormeFieldValidation.fail(e, stackTrace);
    }

    final bool valid = isValid();

    if (valid) {
      setState(() {
        _status = _status._copyWith(validation: _Optional(validation));
      });
    }

    return valid;
  }

  void _fieldChange() {
    _formeState?._fieldDidChange();
  }

  FormeFieldValidation _createFormeFieldValidation(String? errorText) {
    if (errorText == null) {
      return FormeFieldValidation.valid;
    }
    return FormeFieldValidation.invalid(errorText);
  }
}

/// a focusnode created by FormeField itself rather than set by subclass ,
/// so it's our responsibility to dispose it
class _DisposeRequiredFocusNode extends FocusNode {}

class FormeFieldChangedStatus<T extends Object?> extends FormeFieldStatus<T> {
  FormeFieldChangedStatus._(
    FormeFieldStatus<T> newStatus,
    this.isEnabledChanged,
    this.isFocusChanged,
    this.isReadOnlyChanged,
    this.isValidationChanged,
    this.isValueChanged,
  ) : super._(
          enabled: newStatus.enabled,
          readOnly: newStatus.readOnly,
          validation: newStatus.validation,
          value: newStatus.value,
          hasFocus: newStatus.hasFocus,
        );

  FormeFieldChangedStatus(FormeFieldChangedStatus<T> parent)
      : isEnabledChanged = parent.isEnabledChanged,
        isFocusChanged = parent.isFocusChanged,
        isReadOnlyChanged = parent.isReadOnlyChanged,
        isValidationChanged = parent.isValidationChanged,
        isValueChanged = parent.isValueChanged,
        super(parent);

  final bool isEnabledChanged;
  final bool isReadOnlyChanged;
  final bool isValidationChanged;
  final bool isValueChanged;
  final bool isFocusChanged;
}

class FormeFieldStatus<T extends Object?> {
  final bool enabled;
  final bool readOnly;
  final FormeFieldValidation validation;
  final T value;
  final bool hasFocus;

  FormeFieldStatus._({
    required this.enabled,
    required this.readOnly,
    required this.validation,
    required this.value,
    required this.hasFocus,
  });

  FormeFieldStatus(FormeFieldStatus<T> parent)
      : enabled = parent.enabled,
        hasFocus = parent.hasFocus,
        readOnly = parent.readOnly,
        validation = parent.validation,
        value = parent.value;

  FormeFieldStatus<T> _copyWith({
    _Optional<bool>? enabled,
    _Optional<bool>? readOnly,
    _Optional<FormeFieldValidation>? validation,
    _Optional<T>? value,
    _Optional<bool>? hasFocus,
  }) {
    return FormeFieldStatus<T>._(
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

class _CustomValidation extends FormeFieldValidation {
  const _CustomValidation.invalid(String errorText) : super.invalid(errorText);
}
