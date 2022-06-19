import 'package:fluent_ui/fluent_ui.dart';

import 'package:forme/forme.dart';

class FormeFluentCombobox<T extends Object> extends FormeField<T?> {
  FormeFluentCombobox({
    required List<ComboboxItem<T>> items,
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
    FormeFieldDecorator<T?>? decorator,
    bool requestFocusOnUserInteraction = true,
    bool registrable = true,
    bool enabled = true,
    FormeFieldValueUpdater<T?>? valueUpdater,
    FormeFieldValidationFilter<T?>? validationFilter,
    FocusNode? focusNode,
    Widget? placeholder,
    Widget? disabledHint,
    ComboboxBuilder? selectedItemBuilder,
    int elevation = 8,
    TextStyle? style,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24,
    bool isExpanded = false,
    double? itemHeight,
    Color? focusColor,
    bool autofocus = false,
    Color? comboboxColor,
  }) : super(
          focusNode: focusNode,
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
          decorator: decorator,
          builder: (state) {
            final bool readOnly = state.readOnly;
            return Combobox<T>(
              items: items,
              onChanged: readOnly
                  ? null
                  : (value) {
                      state.didChange(value);
                      state.requestFocusOnUserInteraction();
                    },
              placeholder: placeholder,
              disabledHint: disabledHint,
              selectedItemBuilder: selectedItemBuilder,
              elevation: elevation,
              style: style,
              icon: icon,
              iconDisabledColor: iconDisabledColor,
              iconEnabledColor: iconEnabledColor,
              iconSize: iconSize,
              isExpanded: isExpanded,
              itemHeight: itemHeight,
              focusColor: focusColor,
              autofocus: autofocus,
              comboboxColor: comboboxColor,
              value: state.value,
            );
          },
        );
}
