import 'package:fluent_ui/fluent_ui.dart';

import 'package:forme/forme.dart';

class FormeFluentCheckbox extends FormeField<bool?> {
  FormeFluentCheckbox({
    bool? initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<bool?>? onStatusChanged,
    FormeFieldInitialed<bool?>? onInitialed,
    FormeFieldSetter<bool?>? onSaved,
    FormeValidator<bool?>? validator,
    FormeAsyncValidator<bool?>? asyncValidator,
    bool autofocus = false,
    bool requestFocusOnUserInteraction = true,
    FormeFieldDecorator<bool?>? decorator,
    bool registrable = true,
    bool enabled = true,
    FormeFieldValueUpdater<bool?>? valueUpdater,
    FormeFieldValidationFilter<bool?>? validationFilter,
    FocusNode? focusNode,
    CheckboxThemeData? style,
    Widget? content,
    String? semanticLabel,
  }) : super(
          focusNode: focusNode,
          validationFilter: validationFilter,
          valueUpdater: valueUpdater,
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
            final bool? value = state.value;
            return Checkbox(
              semanticLabel: semanticLabel,
              style: style,
              content: content,
              autofocus: autofocus,
              focusNode: state.focusNode,
              checked: value,
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
