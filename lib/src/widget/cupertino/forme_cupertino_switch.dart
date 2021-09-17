import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:forme/forme.dart';

class FormeCupertinoSwitch extends FormeField<bool> {
  FormeCupertinoSwitch({
    bool initialValue = false,
    required String name,
    bool readOnly = false,
    Widget? label,
    Key? key,
    int? order,
    Color? activeColor,
    Color? trackColor,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
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
    FormeFieldDecorator<bool>? decorator,
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
          order: order,
          key: key,
          decorator: decorator,
          readOnly: readOnly,
          name: name,
          initialValue: initialValue,
          builder: (state) {
            bool readOnly = state.readOnly;
            bool value = state.value;
            return CupertinoSwitch(
              value: value,
              onChanged: readOnly
                  ? null
                  : (v) {
                      state.didChange(v);
                      state.requestFocus();
                    },
              activeColor: activeColor,
              trackColor: trackColor,
              dragStartBehavior: dragStartBehavior,
            );
          },
        );
}
