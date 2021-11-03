import 'package:flutter/material.dart';

import '../../forme_field.dart';

class FormeCheckbox extends FormeField<bool?> {
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
    bool tristate = false,
    bool requestFocusOnUserInteraction = true,
  }) : super(
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
          initialValue: tristate ? initialValue : initialValue!,
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
}
