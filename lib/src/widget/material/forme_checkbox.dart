import 'package:flutter/material.dart';

import '../../../forme.dart';

class FormeCheckbox extends FormeField<bool?> {
  final bool tristate;
  FormeCheckbox({
    bool? initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<bool?>? onValueChanged,
    FormeFocusChanged<bool?>? onFocusChanged,
    FormeFieldValidationChanged<bool?>? onValidationChanged,
    FormeFieldInitialed<bool?>? onInitialed,
    FormeFieldSetter<bool?>? onSaved,
    FormeValidator<bool?>? validator,
    FormeAsyncValidator<bool?>? asyncValidator,
    Color? activeColor,
    MouseCursor? mouseCursor,
    MaterialStateProperty<Color?>? fillColor,
    Color? checkColor,
    Color? focusColor,
    Color? hoverColor,
    MaterialStateProperty<Color?>? overlayColor,
    double? splashRadius,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? materialTapTargetSize,
    OutlinedBorder? shape,
    bool autofocus = false,
    BorderSide? side,
    this.tristate = false,
    bool requestFocusOnUserInteraction = true,
    FormeFieldDecorator<bool>? decorator,
  }) : super(
          decorator: decorator,
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
          order: order,
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          autovalidateMode: autovalidateMode,
          onValueChanged: onValueChanged,
          onFocusChanged: onFocusChanged,
          onValidationChanged: onValidationChanged,
          onInitialed: onInitialed,
          onSaved: onSaved,
          validator: validator,
          asyncValidator: asyncValidator,
          key: key,
          readOnly: readOnly,
          name: name,
          initialValue: tristate ? initialValue : initialValue ?? false,
          builder: (state) {
            final bool readOnly = state.readOnly;
            final bool? value = state.value;
            return Checkbox(
              autofocus: autofocus,
              focusNode: state.focusNode,
              side: side,
              tristate: tristate,
              mouseCursor: mouseCursor,
              shape: shape,
              activeColor: activeColor,
              fillColor: fillColor,
              checkColor: checkColor,
              materialTapTargetSize: materialTapTargetSize,
              focusColor: focusColor,
              hoverColor: hoverColor,
              overlayColor: overlayColor,
              splashRadius: splashRadius,
              visualDensity: visualDensity,
              value: value,
              onChanged: readOnly
                  ? null
                  : (value) {
                      state.didChange(value);
                      state.requestFocusOnUserInteraction();
                    },
            );
          },
        );

  @override
  FormeFieldState<bool?> createState() => _FormeCheckboxState();
}

class _FormeCheckboxState extends FormeFieldState<bool?> {
  @override
  FormeCheckbox get widget => super.widget as FormeCheckbox;

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<bool?> oldWidget) {
    super.updateFieldValueInDidUpdateWidget(oldWidget);
    final FormeCheckbox old = oldWidget as FormeCheckbox;
    if (old.tristate && !widget.tristate && value == null) {
      setValue(false);
    }
  }

  @override
  void didChange(bool? newValue) {
    if (newValue == null && !widget.tristate) {
      throw Exception(
          'current value can not be null, set tristate to true if you want to support nullable');
    }
    super.didChange(newValue);
  }
}
