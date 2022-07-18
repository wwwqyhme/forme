import 'package:fluent_ui/fluent_ui.dart';
import 'package:forme/forme.dart';

import 'fluent_time_of_day.dart';

class FormeFluentTimePicker extends FormeField<FluentTimeOfDay> {
  FormeFluentTimePicker({
    required FluentTimeOfDay initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    FormeFieldDecorator<FluentTimeOfDay>? decorator,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<FluentTimeOfDay>? onStatusChanged,
    FormeFieldInitialed<FluentTimeOfDay>? onInitialed,
    FormeFieldSetter<FluentTimeOfDay>? onSaved,
    FormeValidator<FluentTimeOfDay>? validator,
    FormeAsyncValidator<FluentTimeOfDay>? asyncValidator,
    bool registrable = true,
    bool enabled = true,
    FormeFieldValueUpdater<FluentTimeOfDay>? valueUpdater,
    FormeFieldValidationFilter<FluentTimeOfDay>? validationFilter,
    FocusNode? focusNode,
    bool requestFocusOnUserInteraction = true,
    VoidCallback? onCancel,
    HourFormat hourFormat = HourFormat.h,
    String? header,
    TextStyle? headerStyle,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 8.0,
      vertical: 4.0,
    ),
    bool autofocus = false,
    double popupHeight = 40 * 10,
    double minuteIncrement = 1,
  }) : super(
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
          focusNode: focusNode,
          validationFilter: validationFilter,
          valueUpdater: valueUpdater,
          enabled: enabled,
          registrable: registrable,
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
            return TimePicker(
              hourFormat: hourFormat,
              minuteIncrement: minuteIncrement,
              onCancel: onCancel,
              header: header,
              headerStyle: headerStyle,
              selected: state.value.toDateTime(),
              contentPadding: contentPadding,
              autofocus: autofocus,
              popupHeight: popupHeight,
              onChanged: readOnly
                  ? null
                  : (v) {
                      state.didChange(FluentTimeOfDay.fromDateTime(v));
                      state.requestFocusOnUserInteraction();
                    },
            );
          },
        );
}
