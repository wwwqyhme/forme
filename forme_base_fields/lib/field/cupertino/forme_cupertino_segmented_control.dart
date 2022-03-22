import 'package:flutter/cupertino.dart';
import 'package:forme/forme.dart';

class FormeCupertinoSegmentedControl<T extends Object> extends FormeField<T?> {
  final Map<T, Widget> children;

  FormeCupertinoSegmentedControl({
    required String name,
    required this.children,
    Color? unselectedColor,
    Color? selectedColor,
    Color? borderColor,
    Color? pressedColor,
    EdgeInsetsGeometry? padding,
    Color? disableUnselectedColor,
    Color? disableSelectedColor,
    Color? disableBorderColor,
    T? initialValue,
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
  }) : super(
            validationFilter: validationFilter,
            valueUpdater: valueUpdater,
            enabled: enabled,
            registrable: registrable,
            requestFocusOnUserInteraction: requestFocusOnUserInteraction,
            decorator: decorator,
            quietlyValidate: quietlyValidate,
            asyncValidatorDebounce: asyncValidatorDebounce,
            autovalidateMode: autovalidateMode,
            onStatusChanged: onStatusChanged,
            onInitialed: onInitialed,
            onSaved: onSaved,
            validator: validator,
            asyncValidator: asyncValidator,
            order: order,
            name: name,
            initialValue: initialValue,
            readOnly: readOnly,
            key: key,
            builder: (state) {
              final bool readOnly = state.readOnly;
              return Row(
                children: [
                  Expanded(
                      child: Focus(
                    focusNode: state.focusNode,
                    child: AbsorbPointer(
                      absorbing: readOnly,
                      child: CupertinoSegmentedControl<T>(
                          groupValue: state.value,
                          children: children,
                          unselectedColor: readOnly
                              ? disableUnselectedColor
                              : unselectedColor,
                          selectedColor:
                              readOnly ? disableSelectedColor : selectedColor,
                          borderColor:
                              readOnly ? disableBorderColor : borderColor,
                          pressedColor: pressedColor,
                          padding: padding,
                          onValueChanged: (v) {
                            state.didChange(v);
                            state.requestFocusOnUserInteraction();
                          }),
                    ),
                  ))
                ],
              );
            });
}
