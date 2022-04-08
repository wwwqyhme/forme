import 'package:flutter/cupertino.dart';
import 'package:forme/forme.dart';

class FormeCupertinoSlidingSegmentedControl<T extends Object>
    extends FormeField<T?> {
  final Map<T, Widget> children;

  FormeCupertinoSlidingSegmentedControl({
    required String name,
    required this.children,
    Color? thumbColor,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    Color? disableThumbColor,
    Color? disableBackgroundColor,
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
    FocusNode? focusNode,
  }) : super(
            focusNode: focusNode,
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
                      child: CupertinoSlidingSegmentedControl<T>(
                          groupValue: state.value,
                          children: children,
                          thumbColor:
                              (readOnly ? disableThumbColor : thumbColor) ??
                                  const CupertinoDynamicColor.withBrightness(
                                    color: Color(0xFFFFFFFF),
                                    darkColor: Color(0xFF636366),
                                  ),
                          backgroundColor: (readOnly
                                  ? disableBackgroundColor
                                  : backgroundColor) ??
                              CupertinoColors.tertiarySystemFill,
                          padding: padding ??
                              const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 3),
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
