import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

/// if dropdown is changing to a new value , this function is used to check whether new value can be changed or not
///
/// [isValid] whether current checking is valid or not.
/// in some cases , if widget is disposed before  checking completed
/// [FormeFieldState.didChange] will never be called , some logic in
/// [FormeField.onStatusChanged] or [Forme.onFieldStatusChanged] will never
/// be executed , to prevent these , we need to do our logic in checking
/// eg:
///
/// ``` Dart
///  FormeDropdownButton(
///     onValueChanged:(f,v) {
///       logic(f,v);
///     },
///     beforeValueChanged:(f,v,isValid) async{
///       final bool change = await check(f,v);
///       if(change) {
///         //checking is valid but field is disposed..
///         if(isValid() && !f.controller.mounted){
///           logic(f,v);
///         }
///       }
///       return change
///     }
///   )
///
///  Future void logic(FormeFieldController field,dynamic value) async{
///
///   }
/// ```
typedef BeforeValueChanged<T> = Future<bool> Function(
    FormeFieldState<T> field, T value, bool Function() isValid);

class FormeDropdownButton<T extends Object> extends FormeField<T?> {
  final List<DropdownMenuItem<T>> items;

  /// if dropdown is changing to a new value , this param is used to check whether new value can be changed or not
  final BeforeValueChanged<T?>? beforeValueChanged;

  /// whether used a temp value during checking whether value can be changed
  ///
  /// if true , a temp value will be displayed during checking ,after checking completed,
  /// new value or old value(not allowed to change) will be displayed and temp value will be set to null
  ///
  /// recommend to set this param to true if  beforeValueChanged will take some time to complete
  ///
  /// default is true
  final bool useTempValueDuringBeforeValueChangedChecking;
  FormeDropdownButton({
    required this.items,
    T? initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<T?>? onStatusChanged,
    FormeFieldInitialed<T?>? onInitialed,
    FormeFieldSetter<T?>? onSaved,
    FormeValidator<T?>? validator,
    FormeAsyncValidator<T?>? asyncValidator,
    DropdownButtonBuilder? selectedItemBuilder,
    VoidCallback? onTap,
    bool autofocus = false,
    Widget? hint,
    Widget? disabledHint,
    int elevation = 8,
    TextStyle? style,
    bool isDense = true,
    bool isExpanded = true,
    double itemHeight = kMinInteractiveDimension,
    Color? focusColor,
    Color? dropdownColor,
    double iconSize = 24,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    InputDecoration? decoration,
    FormeFieldDecorator<T?>? decorator,
    bool requestFocusOnUserInteraction = true,
    bool registrable = true,
    bool enabled = true,
    Widget? underline,
    double? menuMaxHeight,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    BorderRadius? borderRadius,
    this.beforeValueChanged,
    this.useTempValueDuringBeforeValueChangedChecking = true,
    FormeFieldValueUpdater<T?>? valueUpdater,
    FormeFieldValidationFilter<T?>? validationFilter,
  }) : super(
          validationFilter: validationFilter,
          valueUpdater: valueUpdater,
          enabled: enabled,
          registrable: registrable,
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
          order: order,
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          autovalidateMode: autovalidateMode,
          onStatusChanged: onStatusChanged,
          onInitialed: onInitialed,
          onSaved: onSaved,
          validator: validator,
          asyncValidator: asyncValidator,
          key: key,
          readOnly: readOnly,
          name: name,
          initialValue: initialValue,
          decorator: decorator ??
              (decoration == null
                  ? null
                  : FormeInputDecoratorBuilder<T?>(
                      decoration: decoration.copyWith(focusColor: focusColor),
                      emptyChecker: (value, controller) =>
                          value == null &&
                          (controller as _FormDropdownButtonState)._tempValue ==
                              null,
                      wrapper: (child, controller) {
                        return DropdownButtonHideUnderline(child: child);
                      })),
          builder: (genericState) {
            final _FormDropdownButtonState<T> state =
                genericState as _FormDropdownButtonState<T>;
            final bool readOnly = state.readOnly;
            final DropdownButton<T> dropdownButton = DropdownButton<T>(
              borderRadius: borderRadius,
              underline: underline,
              focusNode: state.focusNode,
              autofocus: autofocus,
              selectedItemBuilder: selectedItemBuilder,
              value: state._tempValue ?? state.value,
              items: items,
              onTap: onTap,
              icon: icon,
              iconSize: iconSize,
              iconEnabledColor: iconEnabledColor,
              iconDisabledColor: iconDisabledColor,
              hint: hint,
              disabledHint: disabledHint,
              elevation: elevation,
              style: style,
              isDense: isDense,
              isExpanded: isExpanded,
              itemHeight: itemHeight,
              focusColor: focusColor,
              dropdownColor: dropdownColor,
              menuMaxHeight: menuMaxHeight,
              enableFeedback: enableFeedback,
              alignment: alignment ?? AlignmentDirectional.centerStart,
              onChanged: readOnly ? null : state._didChange,
            );

            return dropdownButton;
          },
        );

  @override
  _FormDropdownButtonState<T> createState() => _FormDropdownButtonState();
}

class _FormDropdownButtonState<T extends Object> extends FormeFieldState<T?> {
  int _gen = 0;
  T? _tempValue;

  @override
  FormeDropdownButton<T> get widget => super.widget as FormeDropdownButton<T>;

  Future _didChange(T? newValue) async {
    final int gen = ++_gen;
    bool change = true;
    final bool useTempValue =
        widget.useTempValueDuringBeforeValueChangedChecking;
    if (widget.beforeValueChanged != null) {
      if (useTempValue) {
        setState(() {
          _tempValue = newValue;
        });
      }
      try {
        change = await widget.beforeValueChanged!(this, newValue, () {
          return gen == _gen;
        });
      } catch (e) {
        change = false;
      }
    }
    if (!mounted || gen != _gen) {
      return;
    }
    _tempValue = null;
    if (change) {
      didChange(newValue);
      requestFocusOnUserInteraction();
    } else {
      if (useTempValue) {
        setState(() {});
      }
    }
  }
}
