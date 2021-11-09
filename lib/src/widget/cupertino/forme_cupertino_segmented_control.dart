import 'package:flutter/cupertino.dart';
import '../../../forme.dart';

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
    FormeValueChanged<T?>? onValueChanged,
    FormeFocusChanged<T?>? onFocusChanged,
    FormeFieldValidationChanged<T?>? onValidationChanged,
    FormeFieldInitialed<T?>? onInitialed,
    FormeFieldSetter<T?>? onSaved,
    FormeValidator<T?>? validator,
    FormeAsyncValidator<T?>? asyncValidator,
    FormeFieldDecorator<T?>? decorator,
    bool requestFocusOnUserInteraction = true,
    bool registrable = true,
  }) : super(
            registrable: registrable,
            requestFocusOnUserInteraction: requestFocusOnUserInteraction,
            decorator: decorator,
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

  @override
  _FormeCupertinoSegmentedControlState<T> createState() =>
      _FormeCupertinoSegmentedControlState();
}

class _FormeCupertinoSegmentedControlState<T extends Object>
    extends FormeFieldState<T?> {
  @override
  FormeCupertinoSegmentedControl<T> get widget =>
      super.widget as FormeCupertinoSegmentedControl<T>;

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<T?> oldWidget) {
    if (value != null && !widget.children.containsKey(value)) {
      setValue(null);
    }
  }
}
