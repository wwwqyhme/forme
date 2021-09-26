import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../forme.dart';

import 'forme_mounted_value_notifier.dart';

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
  Map<FormeFieldController, String> get errors => _currentController.errors;

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
  ValueListenable<FormeFieldController?> fieldListenable(String name) =>
      _currentController.fieldListenable(name);

  static T getFieldByContext<T extends FormeFieldController<dynamic>>(
      BuildContext context) {
    return _InheritedFormeFieldController.of(context) as T;
  }
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

  /// used to listen field's validate error changed
  final FormeErrorChanged? onErrorChanged;

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

  const Forme({
    FormeKey? key,
    this.readOnly = false,
    this.onValueChanged,
    required this.child,
    this.initialValue = const <String, dynamic>{},
    this.onErrorChanged,
    this.onWillPop,
    this.quietlyValidate = false,
    this.onFocusChanged,
    AutovalidateMode? autovalidateMode,
    this.autovalidateByOrder = false,
  })  : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled,
        super(key: key);

  @override
  _FormeState createState() => _FormeState();
}

class _FormeState extends State<Forme> {
  final List<FormeFieldState> states = [];
  late final _FormeController controller;
  final Map<String, ValueNotifier<FormeFieldController?>> fieldNotifiers = {};

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
      for (final element in states) {
        element._readOnlyNotifier.value = readOnly;
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
    fieldNotifiers.forEach((key, value) {
      value.dispose();
    });
    fieldNotifiers.clear();
    super.dispose();
  }

  void reset() {
    for (final element in states) {
      element.reset();
    }
    if (widget.autovalidateMode == AutovalidateMode.always) {
      _validateForm();
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
          .where((element) => element._hasAnyValidator)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      if (valueFieldStates.isEmpty) {
        return;
      }
      _validateByOrder(valueFieldStates);
    } else {
      for (final element in states) {
        element._validate2(() {});
      }
    }
  }

  void _validateByOrder(List<FormeFieldState> states, {int index = 0}) {
    final int length = states.length;
    if (index >= length) {
      return;
    }
    final FormeFieldState state = states[index];
    state._validate2(() {
      _validateByOrder(states, index: index + 1);
    });
  }

  void save() {
    for (final element in states) {
      element.save();
    }
  }

  @override
  Widget build(BuildContext context) {
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
    bool needValidate = false;
    if (widget.autovalidateMode == AutovalidateMode.always) {
      needValidate = true;
    }
    if (widget.autovalidateMode == AutovalidateMode.onUserInteraction) {
      needValidate = states.any((element) => element._hasInteractedByUser);
    }
    if (needValidate) {
      _validateForm();
    }
  }

  void fieldErrorChange(
      FormeFieldController controller, FormeValidateError? error) {
    widget.onErrorChanged?.call(controller, error);
  }

  void fieldFocusChange(FormeFieldController controller, bool hasFocus) {
    widget.onFocusChanged?.call(controller, hasFocus);
  }

  void fieldValueChange(FormeFieldController controller, dynamic value) {
    widget.onValueChanged?.call(controller, value);
  }

  void registerField(FormeFieldState state) {
    states.add(state);
    fieldNotifiers[state.name]?.value = state.controller;
  }

  void unregisterField(FormeFieldState state) {
    states.remove(state);
    fieldNotifiers[state.name]?.value = null;
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
  bool _init = false;
  FocusNode? _focusNode;
  bool? _readOnly;

  _FormeState? _formeState;

  late final FormeMountedValueNotifier<bool> _focusNotifier =
      FormeMountedValueNotifier(false, this);
  late final FormeMountedValueNotifier<bool> _readOnlyNotifier =
      FormeMountedValueNotifier(false, this);
  late final FormeFieldController<T> controller;
  late final FormeMountedValueNotifier<FormeValidateError?> _errorNotifier =
      FormeMountedValueNotifier(null, this);
  late final FormeMountedValueNotifier<T> _valueNotifier;

  int get order =>
      widget.order ??
      _formeState?.getOrder(this) ??
      (throw Exception(
          'can not get order of this field , if this field is not wrapped by Forme , you must specific an order on it'));

  String get name => widget.name;

  T? _oldValue;
  FormeValidateError? _error;
  Timer? _asyncValidatorDebounce;
  bool _ignoreValidate = false;
  bool _hasInteractedByUser = false;
  int _validateGen = 0;
  late T _value;

  T get value => _value;

  T? get oldValue => _oldValue;
  VoidCallback? _validateValidCallback;
  bool _alwaysValidateOnNextBuild = false;

  bool get _hasValidator => widget.validator != null;

  bool get _hasAsyncValidator => widget.asyncValidator != null;

  bool get _hasAnyValidator => _hasValidator || _hasAsyncValidator;

  String? get errorText =>
      (_formeState?.quietlyValidate ?? false) || widget.quietlyValidate
          ? null
          : _error?.text;

  /// get initialValue
  T get initialValue =>
      widget.initialValue ??
      _formeState?.getInitialValue(name, widget.initialValue) as T;

  AutovalidateMode get autovalidateMode => widget.autovalidateMode;

  FormeValueComparator<T> get comparator =>
      widget.comparator ??
      (a, b) {
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
      };

  bool get needValidate =>
      _hasAnyValidator &&
      widget.enabled &&
      ((autovalidateMode == AutovalidateMode.always) ||
          (autovalidateMode == AutovalidateMode.onUserInteraction &&
              _hasInteractedByUser));

  /// get current widget's focus node
  ///
  /// if there's no focus node,will create a new one
  FocusNode get focusNode {
    if (_focusNode == null) {
      _focusNode = FocusNode();
      _focusNode!.addListener(() {
        _focusNotifier.value = focusNode.hasFocus;
      });
    }
    return _focusNode ??= FocusNode();
  }

  bool get isValueChanged => !comparator(initialValue, value);

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
    _formeState?.registerField(this);
    afterInitiation();
    widget.onInitialed?.call(controller);
  }

  @protected
  FormeFieldController<T> createFormeFieldController() =>
      _FormeFieldController(this);

  @override
  void dispose() {
    _asyncValidatorDebounce?.cancel();
    _errorNotifier.dispose();
    _valueNotifier.dispose();
    _focusNotifier.dispose();
    _readOnlyNotifier.dispose();
    _focusNode?.dispose();
    _formeState?.unregisterField(this);
    super.dispose();
  }

  /// called after  FormeFieldController created
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

    _errorNotifier.addListener(() {
      onErrorChanged(_errorNotifier.value);
      widget.onErrorChanged?.call(controller, _errorNotifier.value);
      _formeState?.fieldErrorChange(controller, _errorNotifier.value);
    });
  }

  @mustCallSuper
  void didChange(T newValue) {
    final T oldValue = _value;
    if (!comparator(oldValue, newValue)) {
      setState(() {
        _hasInteractedByUser = true;
        _value = newValue;
        _oldValue = oldValue;
      });
      _fieldChange();
      _valueNotifier.value = newValue;
    }
  }

  @override
  void didUpdateWidget(FormeField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final T oldValue = _value;
    updateFieldValueInDidUpdateWidget(oldWidget);
    if (!comparator(oldValue, _value)) {
      _oldValue = oldValue;
      _valueNotifier.value = _value;
    }
  }

  /// when you want to update value in [didUpdateWidget] , you should override this method rather than override [didUpdateWidget]
  @protected
  void updateFieldValueInDidUpdateWidget(FormeField<T> oldWidget) {}

  @mustCallSuper
  void reset() {
    final T oldValue = _value;
    setState(() {
      _validateGen++;
      _error = null;
      _hasInteractedByUser = false;
      _ignoreValidate = false;
      _oldValue = oldValue;
      _value = initialValue;
      _validateValidCallback = null;
      _alwaysValidateOnNextBuild = false;
    });
    _fieldChange();
    if (!comparator(oldValue, initialValue)) {
      _valueNotifier.value = initialValue;
    }
    _errorNotifier.value = null;
  }

  @protected
  void setValue(T value) {
    _value = value;
  }

  /// called before  FormeFieldController created
  ///
  /// this method is called in didChangeDependencies and will only called once in state's lifecycle
  ///
  /// **init your resource in this method**
  @protected
  @mustCallSuper
  void beforeInitiation() {
    _readOnlyNotifier.value = readOnly;
    _value = initialValue;
    _valueNotifier = FormeMountedValueNotifier(initialValue, this);
  }

  /// override this method if you want to listen focus changed
  @protected
  void onFocusChanged(bool hasFocus) {}

  bool get readOnly =>
      (_formeState?.readOnly ?? false) || (_readOnly ?? widget.readOnly);

  set readOnly(bool readOnly) {
    if (readOnly != _readOnly) {
      setState(() {
        _readOnly = readOnly;
      });
      _readOnlyNotifier.value = readOnly;
    }
  }

  void requestFocusOnUserInteraction() {
    if (_hasInteractedByUser && widget.requestFocusOnUserInteraction) {
      _focusNode?.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_alwaysValidateOnNextBuild || needValidate) {
      _alwaysValidateOnNextBuild = false;
      _validate();
    }

    Widget child = widget.builder(this);

    if (widget.decorator != null) {
      child = widget.decorator!.build(
        controller,
        child,
      );
    }

    return _InheritedFormeFieldController(controller, child);
  }

  void _clearError() {
    _validateGen++;
    setState(() {
      _error = null;
    });
    _errorNotifier.value = null;
  }

  void _validate2(VoidCallback onValid) {
    _asyncValidatorDebounce?.cancel();
    if (_ignoreValidate) {
      if (_error?.valid ?? false) {
        onValid();
      }
      return;
    }
    if (!_hasAnyValidator) {
      return;
    }
    setState(() {
      _alwaysValidateOnNextBuild = true;
      final int gen = _validateGen + 1;
      _validateValidCallback = () {
        if (gen == _validateGen) {
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            onValid();
          });
        }
      };
    });
  }

  void _validate() {
    _asyncValidatorDebounce?.cancel();
    if (_ignoreValidate || !_hasAnyValidator) {
      return;
    }
    final int gen = ++_validateGen;

    void afterUpdateError() {
      if (_error!.valid) {
        _validateValidCallback?.call();
      }
      if (!_error!.validating) {
        _validateValidCallback = null;
      }
    }

    void notifyError(FormeValidateError error) {
      _error = error;
      afterUpdateError();
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        _errorNotifier.value = _error;
      });
    }

    if (_hasValidator) {
      final String? errorText = widget.validator!(controller, value);
      if (errorText != null || !_hasAsyncValidator) {
        notifyError(FormeValidateError(
            errorText,
            errorText == null
                ? FormeValidateState.valid
                : FormeValidateState.invalid));
        return;
      }
    }
    if (_hasAsyncValidator) {
      notifyError(
          const FormeValidateError(null, FormeValidateState.validating));
      _asyncValidatorDebounce = Timer(
          widget.asyncValidatorDebounce ?? const Duration(milliseconds: 500),
          () {
        FormeValidateError? error;
        widget.asyncValidator!(controller, value).then((text) {
          error = FormeValidateError(
              text,
              text == null
                  ? FormeValidateState.valid
                  : FormeValidateState.invalid);
        }).whenComplete(() {
          if (mounted && gen == _validateGen) {
            setState(() {
              _error = error ??
                  const FormeValidateError(null, FormeValidateState.fail);
              _ignoreValidate = true;
            });
            afterUpdateError();
            _errorNotifier.value = _error;
          }
        });
      });
    }
  }

  void _fieldChange() {
    if (_formeState != null) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        _formeState!.fieldDidChange();
      });
    }
  }

  Future<FormeFieldValidateSnapshot<T>> _performValidate(
      {bool quietly = false}) {
    final T value = this.value;
    if (!_hasAnyValidator) {
      return Future.delayed(
          Duration.zero,
          () => FormeFieldValidateSnapshot(
              value, null, order, controller, false, false));
    }
    final int gen = quietly ? _validateGen : ++_validateGen;

    bool needNotify() {
      return !quietly && gen == _validateGen && mounted;
    }

    void notify(FormeValidateError error) {
      if (needNotify()) {
        setState(() {
          _error = error;
        });
        _errorNotifier.value = _error;
      }
    }

    if (_hasValidator) {
      final String? errorText = widget.validator!(controller, value);
      if (errorText != null || !_hasAsyncValidator) {
        final FormeValidateError error = FormeValidateError(
            errorText,
            errorText == null
                ? FormeValidateState.valid
                : FormeValidateState.invalid);
        notify(error);
        return Future.delayed(
            Duration.zero,
            () => FormeFieldValidateSnapshot(
                  value,
                  error,
                  order,
                  controller,
                  false,
                  false,
                ));
      }
    }

    if (_hasAsyncValidator) {
      if (!quietly) {
        notify(const FormeValidateError(null, FormeValidateState.validating));
      }

      FormeValidateError? error;
      return widget.asyncValidator!(controller, value).then((text) {
        error = FormeValidateError(
            text,
            text == null
                ? FormeValidateState.valid
                : FormeValidateState.invalid);
        return FormeFieldValidateSnapshot(value, error, order, controller,
            comparator(value, this.value), comparator(value, initialValue));
      }).whenComplete(() {
        error ??= const FormeValidateError(null, FormeValidateState.fail);
        notify(error!);
      });
    }

    throw Exception('should not go here');
  }

  void save() {
    widget.onSaved?.call(controller, value);
  }

  /// override this method if you want to listen value changed
  @protected
  void onValueChanged(T value) {}

  /// override this method if you want to listen error changed
  @protected
  void onErrorChanged(FormeValidateError? error) {}
}

/// share FormFieldController in sub tree
class _InheritedFormeFieldController extends InheritedWidget {
  final FormeFieldController controller;

  const _InheritedFormeFieldController(this.controller, Widget child)
      : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static FormeFieldController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedFormeFieldController>()!
        .controller;
  }
}

class _FormeController extends FormeController {
  final _FormeState state;

  _FormeController(this.state);

  @override
  Map<String, dynamic> get data {
    final Map<String, dynamic> map = <String, dynamic>{};
    for (final element in state.states) {
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
  Map<FormeFieldController, String> get errors {
    final Map<FormeFieldController, String> errorMap = {};
    for (final FormeFieldState state in state.states) {
      final FormeFieldController controller = state.controller;
      final String? errorText = controller.error?.text;
      if (errorText == null) {
        continue;
      }
      errorMap[controller] = errorText;
    }
    return errorMap;
  }

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
  }) {
    final List<FormeFieldState> states = (state.states
            .where((element) =>
                element._hasAnyValidator &&
                (names.isEmpty || names.contains(element.name)))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order)))
        .toList();
    if (states.isEmpty) {
      return Future.delayed(Duration.zero, () => FormeValidateSnapshot([]));
    }
    if (clearError) {
      for (final element in states) {
        element._clearError();
      }
    }
    if (validateByOrder) {
      return _validateByOrder(states, quietly);
    }
    return Future.wait(
            states.map((state) => state._performValidate(quietly: quietly)),
            eagerError: true)
        .then((value) {
      value.sort((a, b) => a.order.compareTo(b.order));
      return FormeValidateSnapshot(value);
    });
  }

  Future<FormeValidateSnapshot> _validateByOrder(
      List<FormeFieldState> states, bool quietly,
      {int index = 0, List<FormeFieldValidateSnapshot> list = const []}) {
    final int length = controllers.length;
    final List<FormeFieldValidateSnapshot> copyList = List.of(list);
    return states[index]._performValidate(quietly: quietly).then((value) {
      copyList.add(value);
      if (value.invalid || index == length - 1) {
        return FormeValidateSnapshot(copyList);
      }
      return _validateByOrder(states, quietly,
          index: index + 1, list: copyList);
    });
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
  ValueListenable<FormeFieldController?> fieldListenable(String name) =>
      _ValueListenable(state.fieldListenable(name));
}

class _ValueListenable<T> extends ValueListenable<T> {
  final ValueNotifier<T> delegate;

  const _ValueListenable(this.delegate);

  @override
  void addListener(VoidCallback listener) => delegate.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      delegate.removeListener(listener);

  @override
  T get value => delegate.value;
}

class _FormeFieldController<T> implements FormeFieldController<T> {
  final FormeFieldState<T> state;
  @override
  final ValueListenable<FormeValidateError?> errorTextListenable;
  @override
  final ValueListenable<T> valueListenable;
  @override
  final ValueListenable<bool> focusListenable;
  @override
  final ValueListenable<bool> readOnlyListenable;

  _FormeFieldController(this.state)
      : focusListenable = _ValueListenable(state._focusNotifier),
        readOnlyListenable = _ValueListenable(state._readOnlyNotifier),
        errorTextListenable = _ValueListenable(state._errorNotifier),
        valueListenable = _ValueListenable<T>(state._valueNotifier);

  @override
  bool get readOnly => state.readOnly;

  @override
  FormeController? get formeController => FormeKey.of(state.context);

  @override
  FocusNode? get focusNode => state._focusNode;

  @override
  String get name => state.name;

  @override
  set readOnly(bool readOnly) => state.readOnly = readOnly;

  @override
  T get value => state.value;

  @override
  FormeValidateError? get error => state._error;

  @override
  void reset() => state.reset();

  @override
  Future<FormeFieldValidateSnapshot<T>> validate({bool quietly = false}) =>
      state._performValidate(quietly: quietly);

  @override
  set value(T value) => state.didChange(value);

  @override
  T? get oldValue => state.oldValue;

  @override
  bool get isValueChanged => state.isValueChanged;

  @override
  BuildContext get context => state.context;

  @override
  bool get hasValidator => state._hasAnyValidator;
}
