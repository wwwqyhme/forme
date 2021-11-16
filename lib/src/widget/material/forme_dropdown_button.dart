import 'package:flutter/material.dart';

import '../../decorator/forme_decorator.dart';
import '../../decorator/forme_material_decorator.dart';
import '../../forme_core.dart';
import '../../forme_field.dart';

class FormeDropdownButton<T extends Object> extends FormeField<T?> {
  final List<DropdownMenuItem<T>> items;

  FormeDropdownButton({
    required this.items,
    T? initialValue,
    required String name,
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
    DropdownButtonBuilder? selectedItemBuilder,
    VoidCallback? onTap,
    bool autofocus = false,
    Widget? hint,
    Widget? disabledHint,
    int elevation = 8,
    TextStyle? style,
    bool isDense = true,
    bool isExpanded = true,
    double itemHeight = kMinInteractiveDimension,
    Color? focusColor,
    Color? dropdownColor,
    double iconSize = 24,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    InputDecoration? decoration,
    FormeFieldDecorator<T?>? decorator,
    bool requestFocusOnUserInteraction = true,
    bool registrable = true,
    bool enabled = true,
  }) : super(
          enabled: enabled,
          registrable: registrable,
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
          order: order,
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
          key: key,
          readOnly: readOnly,
          name: name,
          initialValue: initialValue,
          decorator: decorator ??
              (decoration == null
                  ? null
                  : FormeInputDecoratorBuilder<T?>(
                      decoration: decoration,
                      emptyChecker: (value, controller) => value == null,
                      wrapper: (child, controller) {
                        return DropdownButtonHideUnderline(child: child);
                      })),
          builder: (state) {
            final bool readOnly = state.readOnly;
            final DropdownButton<T> dropdownButton = DropdownButton<T>(
              focusNode: state.focusNode,
              autofocus: autofocus,
              selectedItemBuilder: selectedItemBuilder,
              value: state.value,
              items: items,
              onTap: onTap,
              icon: icon,
              iconSize: iconSize,
              iconEnabledColor: iconEnabledColor,
              iconDisabledColor: iconDisabledColor,
              hint: hint,
              disabledHint: disabledHint,
              elevation: elevation,
              style: style,
              isDense: isDense,
              isExpanded: isExpanded,
              itemHeight: itemHeight,
              focusColor: focusColor,
              dropdownColor: dropdownColor,
              onChanged: readOnly
                  ? null
                  : (value) {
                      state.didChange(value);
                      state.requestFocusOnUserInteraction();
                    },
            );

            return dropdownButton;
          },
        );

  @override
  _FormDropdownButtonState<T> createState() => _FormDropdownButtonState();
}

class _FormDropdownButtonState<T extends Object> extends FormeFieldState<T?> {
  @override
  FormeDropdownButton<T> get widget => super.widget as FormeDropdownButton<T>;

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<T?> oldWidget) {
    if (widget.items.any((element) => element.value == value)) {
      setValue(null);
    }
  }
}
