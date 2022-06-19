import 'package:fluent_ui/fluent_ui.dart';
import 'package:forme/forme.dart';

class FormeFluentDatePicker extends FormeField<DateTime> {
  FormeFluentDatePicker({
    required DateTime initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    FormeFieldDecorator<DateTime>? decorator,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<DateTime>? onStatusChanged,
    FormeFieldInitialed<DateTime>? onInitialed,
    FormeFieldSetter<DateTime>? onSaved,
    FormeValidator<DateTime>? validator,
    FormeAsyncValidator<DateTime>? asyncValidator,
    bool registrable = true,
    bool enabled = true,
    FormeFieldValueUpdater<DateTime>? valueUpdater,
    FormeFieldValidationFilter<DateTime>? validationFilter,
    FocusNode? focusNode,
    bool requestFocusOnUserInteraction = true,
    VoidCallback? onCancel,
    String? header,
    TextStyle? headerStyle,
    bool showMonth = true,
    bool showDay = true,
    bool showYear = true,
    int? startYear,
    int? endYear,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 8.0,
      vertical: 4.0,
    ),
    bool autofocus = false,
    double popupHeight = 40 * 10,
    Locale? locale,
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
            return DatePicker(
              onCancel: onCancel,
              header: header,
              headerStyle: headerStyle,
              selected: state.value,
              showDay: showDay,
              showYear: showYear,
              showMonth: showMonth,
              startYear: startYear,
              endYear: endYear,
              contentPadding: contentPadding,
              autofocus: autofocus,
              popupHeight: popupHeight,
              locale: locale,
              onChanged: readOnly
                  ? null
                  : (v) {
                      state.didChange(v);
                      state.requestFocusOnUserInteraction();
                    },
            );
          },
        );

  @override
  FormeFieldState<DateTime> createState() => FormeFluentDatePickerState();
}

class FormeFluentDatePickerState extends FormeFieldState<DateTime> {
  @override
  DateTime get value {
    final DateTime current = super.value;
    return DateTime(current.year, current.month, current.day);
  }
}
