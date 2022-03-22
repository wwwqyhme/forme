import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

class FormeSwitchTile extends FormeField<bool> {
  final bool tristate;
  FormeSwitchTile({
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
    Color? tileColor,
    Color? selectedTileColor,
    Color? activeTrackColor,
    Color? inactiveThumbColor,
    Color? inactiveTrackColor,
    ImageProvider<Object>? activeThumbImage,
    ImageProvider<Object>? inactiveThumbImage,
    ShapeBorder? shape,
    bool autofocus = false,
    this.tristate = false,
    bool requestFocusOnUserInteraction = true,
    FormeFieldDecorator<bool>? decorator,
    bool registrable = true,
    Widget? title,
    Widget? subtitle,
    bool isThreeLine = false,
    bool dense = false,
    Widget? secondary,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
    EdgeInsets? contentPadding,
    bool selected = false,
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
            return SwitchListTile(
              selected: selected,
              value: value,
              activeColor: activeColor,
              activeTrackColor: activeTrackColor,
              inactiveThumbColor: inactiveThumbColor,
              inactiveTrackColor: inactiveTrackColor,
              activeThumbImage: activeThumbImage,
              inactiveThumbImage: inactiveThumbImage,
              tileColor: tileColor,
              title: title,
              subtitle: subtitle,
              isThreeLine: isThreeLine,
              dense: dense,
              secondary: secondary,
              controlAffinity: controlAffinity,
              autofocus: autofocus,
              contentPadding: contentPadding,
              shape: shape,
              selectedTileColor: selectedTileColor,
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
