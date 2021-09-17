import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../forme_field.dart';

class FormeSwitch extends FormeField<bool> {
  FormeSwitch({
    bool initialValue = false,
    required String name,
    bool readOnly = false,
    Widget? label,
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
    Color? activeTrackColor,
    Color? inactiveThumbColor,
    Color? inactiveTrackColor,
    ImageProvider? activeThumbImage,
    ImageProvider? inactiveThumbImage,
    MaterialStateProperty<Color?>? thumbColor,
    MaterialStateProperty<Color?>? trackColor,
    DragStartBehavior? dragStartBehavior,
    MaterialTapTargetSize? materialTapTargetSize,
    Color? focusColor,
    Color? hoverColor,
    MaterialStateProperty<Color?>? overlayColor,
    double? splashRadius,
    ImageErrorListener? onActiveThumbImageError,
    ImageErrorListener? onInactiveThumbImageError,
    bool autofocus = false,
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
            return Switch(
              value: value,
              onChanged: readOnly
                  ? null
                  : (_) {
                      state.didChange(!value);
                      state.requestFocus();
                    },
              activeColor: activeColor,
              activeTrackColor: activeTrackColor,
              inactiveThumbColor: inactiveThumbColor,
              inactiveTrackColor: inactiveTrackColor,
              activeThumbImage: activeThumbImage,
              inactiveThumbImage: inactiveThumbImage,
              materialTapTargetSize: materialTapTargetSize,
              thumbColor: thumbColor,
              trackColor: trackColor,
              dragStartBehavior: dragStartBehavior ?? DragStartBehavior.start,
              focusColor: focusColor,
              hoverColor: hoverColor,
              overlayColor: overlayColor,
              splashRadius: splashRadius,
              onActiveThumbImageError: onActiveThumbImageError,
              onInactiveThumbImageError: onInactiveThumbImageError,
              focusNode: state.focusNode,
              autofocus: autofocus,
            );
          },
        );
}
