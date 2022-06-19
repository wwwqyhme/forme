import 'package:fluent_ui/fluent_ui.dart';

import 'package:forme/forme.dart';

class FormeFluentToggleSwitch extends FormeField<bool> {
  FormeFluentToggleSwitch({
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
    bool requestFocusOnUserInteraction = true,
    FormeFieldDecorator<bool>? decorator,
    bool registrable = true,
    bool enabled = true,
    FormeFieldValidationFilter<bool>? validationFilter,
    FocusNode? focusNode,
    Widget? thumb,
    ToggleSwitchThemeData? style,
    Widget? content,
    String? semanticLabel,
    bool autofocus = false,
  }) : super(
          focusNode: focusNode,
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
            return ToggleSwitch(
              thumb: thumb,
              semanticLabel: semanticLabel,
              style: style,
              content: content,
              checked: value,
              onChanged: readOnly
                  ? null
                  : (_) {
                      state.didChange(!value);
                      state.requestFocusOnUserInteraction();
                    },
              focusNode: state.focusNode,
              autofocus: autofocus,
            );
          },
        );
}
