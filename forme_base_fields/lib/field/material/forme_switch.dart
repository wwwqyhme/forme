import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:forme/forme.dart';

class FormeSwitch extends FormeField<bool> {
  FormeSwitch({
    bool initialValue = false,
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<bool>? onStatusChanged,
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
    bool requestFocusOnUserInteraction = true,
    FormeFieldDecorator<bool>? decorator,
    bool registrable = true,
    bool enabled = true,
    FormeFieldValidationFilter<bool>? validationFilter,
  }) : super(
          validationFilter: validationFilter,
          enabled: enabled,
          registrable: registrable,
          decorator: decorator,
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
          builder: (state) {
            final bool readOnly = state.readOnly;
            final bool value = state.value;
            return Switch(
              value: value,
              onChanged: readOnly
                  ? null
                  : (_) {
                      state.didChange(!value);
                      state.requestFocusOnUserInteraction();
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
