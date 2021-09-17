import 'package:flutter/material.dart';

import '../../forme_field.dart';

class FormeCheckbox extends FormeField<bool> {
  FormeCheckbox({
    bool initialValue = false,
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<bool>? onValueChanged,
    FormeFocusChanged<bool>? onFocusChanged,
    FormeErrorChanged<bool>? onErrorChanged,
    FormeFieldInitialed<bool>? onInitialed,
    FormeFieldSetter<bool>? onSaved,
    FormeValidator<bool>? validator,
    FormeAsyncValidator<bool>? asyncValidator,
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
    Color? tileColor,
    Color? selectedTileColor,
    ShapeBorder? shape,
  }) : super(
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          autovalidateMode: autovalidateMode,
          onValueChanged: onValueChanged,
          onFocusChanged: onFocusChanged,
          onErrorChanged: onErrorChanged,
          onInitialed: onInitialed,
          onSaved: onSaved,
          validator: validator,
          asyncValidator: asyncValidator,
          key: key,
          readOnly: readOnly,
          name: name,
          initialValue: initialValue,
          builder: (state) {
            bool readOnly = state.readOnly;
            bool value = state.value;
            return Checkbox(
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
                  : (_) {
                      state.didChange(!value);
                      state.requestFocus();
                    },
            );
          },
        );
}
