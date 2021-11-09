import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import '../../../forme.dart';

class FormeCupertinoSwitch extends FormeField<bool> {
  FormeCupertinoSwitch({
    bool initialValue = false,
    required String name,
    bool readOnly = false,
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
    FormeFieldValidationChanged<bool>? onValidationChanged,
    FormeFieldInitialed<bool>? onInitialed,
    FormeFieldSetter<bool>? onSaved,
    FormeValidator<bool>? validator,
    FormeAsyncValidator<bool>? asyncValidator,
    FormeFieldDecorator<bool>? decorator,
    bool requestFocusOnUserInteraction = true,
    bool registrable = true,
  }) : super(
          registrable: registrable,
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
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
          order: order,
          key: key,
          decorator: decorator,
          readOnly: readOnly,
          name: name,
          initialValue: initialValue,
          builder: (state) {
            final bool readOnly = state.readOnly;
            final bool value = state.value;
            return CupertinoSwitch(
              value: value,
              onChanged: readOnly
                  ? null
                  : (v) {
                      state.didChange(v);
                      state.requestFocusOnUserInteraction();
                    },
              activeColor: activeColor,
              trackColor: trackColor,
              dragStartBehavior: dragStartBehavior,
            );
          },
        );
}
