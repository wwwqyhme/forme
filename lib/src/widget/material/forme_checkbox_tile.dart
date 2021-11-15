import 'package:flutter/material.dart';
import '../../../forme.dart';

class FormeCheckboxTile extends FormeField<bool?> {
  final bool tristate;
  FormeCheckboxTile({
    bool? initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<bool?>? onValueChanged,
    FormeFocusChanged<bool?>? onFocusChanged,
    FormeFieldValidationChanged<bool?>? onValidationChanged,
    FormeFieldInitialed<bool?>? onInitialed,
    FormeFieldSetter<bool?>? onSaved,
    FormeValidator<bool?>? validator,
    FormeAsyncValidator<bool?>? asyncValidator,
    Color? activeColor,
    Color? checkColor,
    Color? tileColor,
    Color? selectedTileColor,
    OutlinedBorder? shape,
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
  }) : super(
          registrable: registrable,
          decorator: decorator,
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
          initialValue: tristate ? initialValue : initialValue ?? false,
          builder: (state) {
            final bool readOnly = state.readOnly;
            final bool? value = state.value;
            return CheckboxListTile(
              selected: selected,
              value: value,
              activeColor: activeColor,
              checkColor: checkColor,
              tileColor: tileColor,
              title: title,
              subtitle: subtitle,
              isThreeLine: isThreeLine,
              dense: dense,
              secondary: secondary,
              controlAffinity: controlAffinity,
              autofocus: autofocus,
              contentPadding: contentPadding,
              tristate: tristate,
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

  @override
  FormeFieldState<bool?> createState() => _FormeCheckboxTileState();
}

class _FormeCheckboxTileState extends FormeFieldState<bool?> {
  @override
  FormeCheckboxTile get widget => super.widget as FormeCheckboxTile;

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<bool?> oldWidget) {
    super.updateFieldValueInDidUpdateWidget(oldWidget);
    final FormeCheckbox old = oldWidget as FormeCheckbox;
    if (old.tristate && !widget.tristate && value == null) {
      setValue(false);
    }
  }

  @override
  void didChange(bool? newValue) {
    if (newValue == null && !widget.tristate) {
      throw Exception(
          'current value can not be null, set tristate to true if you want to support nullable');
    }
    super.didChange(newValue);
  }
}
