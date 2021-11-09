import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../../forme.dart';

class FormeDateTimeField extends FormeField<DateTime?> {
  FormeDateTimeField({
    DateTime? initialValue,
    this.type = FormeDateTimeType.date,
    this.firstDate,
    this.lastDate,
    this.formatter,
    required String name,
    bool readOnly = false,
    Key? key,
    InputDecoration? decoration,
    int? maxLines = 1,
    int? order,
    bool quietlyValidate = false,
    bool autofocus = false,
    int? minLines,
    int? maxLength,
    TextStyle? style,
    ToolbarOptions? toolbarOptions,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    StrutStyle? strutStyle,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    TextDirection? textDirection,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    bool expands = false,
    MaxLengthEnforcement? maxLengthEnforcement,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    BoxHeightStyle selectionHeightStyle = BoxHeightStyle.tight,
    BoxWidthStyle selectionWidthStyle = BoxWidthStyle.tight,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20),
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    MouseCursor? mouseCursor,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    bool enableInteractiveSelection = true,
    bool enabled = true,
    VoidCallback? onEditingComplete,
    AppPrivateCommandCallback? appPrivateCommandCallback,
    InputCounterWidgetBuilder? buildCounter,
    ValueChanged<DateTime?>? onSubmitted,
    ScrollController? scrollController,
    TextSelectionControls? textSelectionControls,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<DateTime?>? onValueChanged,
    FormeFocusChanged<DateTime?>? onFocusChanged,
    FormeFieldValidationChanged<DateTime?>? onValidationChanged,
    FormeFieldInitialed<DateTime?>? onInitialed,
    FormeFieldSetter<DateTime?>? onSaved,
    FormeValidator<DateTime?>? validator,
    FormeAsyncValidator<DateTime?>? asyncValidator,
    String? helpText,
    String? cancelText,
    String? confirmText,
    RouteSettings? routeSettings,
    DatePickerMode? initialDatePickerMode,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
    TimePickerEntryMode? initialEntryMode,
    DatePickerEntryMode? dateInitialEntryMode,
    String? timeCancelText,
    String? timeConfirmText,
    String? timeHelpText,
    RouteSettings? timeRouteSettings,
    SelectableDayPredicate? selectableDayPredicate,
    TransitionBuilder? builder,
    bool use24hFormat = false,
    FormeFieldDecorator<DateTime?>? decorator,
    bool registrable = true,
  }) : super(
          registrable: registrable,
          decorator: decorator,
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
          name: name,
          readOnly: readOnly,
          initialValue: initialValue,
          builder: (baseState) {
            final readOnly = baseState.readOnly;
            final state = baseState as _FormeDateTimeFieldState;
            final _firstDate = firstDate ?? DateTime(1970);
            final _lastDate = lastDate ?? DateTime(2099);

            void pickTime() {
              final value = state.initialDateTime;
              final timeOfDay = state.value == null
                  ? null
                  : TimeOfDay(hour: value.hour, minute: value.minute);

              showDatePicker(
                context: state.context,
                initialDate: value,
                firstDate: _firstDate,
                lastDate: _lastDate,
                helpText: helpText,
                cancelText: cancelText,
                confirmText: confirmText,
                routeSettings: routeSettings,
                textDirection: textDirection,
                initialDatePickerMode:
                    initialDatePickerMode ?? DatePickerMode.day,
                errorFormatText: errorFormatText,
                errorInvalidText: errorInvalidText,
                fieldHintText: fieldHintText,
                fieldLabelText: fieldLabelText,
                initialEntryMode:
                    dateInitialEntryMode ?? DatePickerEntryMode.calendar,
                selectableDayPredicate: selectableDayPredicate,
                builder: builder,
              ).then((date) {
                if (date != null) {
                  if (type == FormeDateTimeType.dateTime) {
                    showTimePicker(
                        initialEntryMode:
                            initialEntryMode ?? TimePickerEntryMode.dial,
                        cancelText: timeCancelText,
                        confirmText: timeConfirmText,
                        helpText: timeHelpText,
                        routeSettings: timeRouteSettings,
                        context: state.context,
                        initialTime: timeOfDay ??
                            TimeOfDay(hour: value.hour, minute: value.minute),
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: use24hFormat),
                            child: child!,
                          );
                        }).then((value) {
                      if (value != null) {
                        final dateTime = DateTime(date.year, date.month,
                            date.day, value.hour, value.minute);
                        state.didChange(dateTime);
                      }
                    });
                  } else {
                    state.didChange(date);
                  }
                }
                state.focusNode.requestFocus();
              });
            }

            return TextField(
              focusNode: state.focusNode,
              controller: state.textEditingController,
              decoration: decoration?.copyWith(errorText: state.errorText),
              obscureText: obscureText,
              maxLines: maxLines,
              minLines: minLines,
              enabled: enabled,
              readOnly: true,
              onTap: readOnly ? null : pickTime,
              onEditingComplete: onEditingComplete,
              onSubmitted:
                  onSubmitted == null ? null : (v) => onSubmitted(state.value),
              onAppPrivateCommand: appPrivateCommandCallback,
              textInputAction: textInputAction,
              textCapitalization: textCapitalization,
              style: style,
              strutStyle: strutStyle,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              textDirection: textDirection,
              showCursor: showCursor,
              obscuringCharacter: obscuringCharacter,
              autocorrect: autocorrect,
              smartDashesType: smartDashesType,
              smartQuotesType: smartQuotesType,
              enableSuggestions: enableSuggestions,
              expands: expands,
              cursorWidth: cursorWidth,
              cursorHeight: cursorHeight,
              cursorRadius: cursorRadius,
              cursorColor: cursorColor,
              selectionHeightStyle: selectionHeightStyle,
              selectionWidthStyle: selectionWidthStyle,
              keyboardAppearance: keyboardAppearance,
              scrollPadding: scrollPadding,
              dragStartBehavior: dragStartBehavior,
              mouseCursor: mouseCursor,
              scrollPhysics: scrollPhysics,
              autofillHints: autofillHints,
              autofocus: autofocus,
              toolbarOptions: toolbarOptions,
              enableInteractiveSelection: enableInteractiveSelection,
              buildCounter: buildCounter,
              maxLengthEnforcement: maxLengthEnforcement,
              maxLength: maxLength,
              scrollController: scrollController,
              selectionControls: textSelectionControls,
            );
          },
        );

  @override
  _FormeDateTimeFieldState createState() => _FormeDateTimeFieldState();

  final FormeDateTimeFormatter? formatter;
  final FormeDateTimeType type;
  final DateTime? firstDate;
  final DateTime? lastDate;
}

class _FormeDateTimeFieldState extends FormeFieldState<DateTime?> {
  FormeDateTimeFormatter get _formatter =>
      widget.formatter ?? defaultDateTimeFormatter;

  late final TextEditingController textEditingController;

  @override
  FormeDateTimeField get widget => super.widget as FormeDateTimeField;

  @override
  void beforeInitiation() {
    super.beforeInitiation();
    textEditingController = TextEditingController(
        text: value == null ? '' : _formatter(widget.type, value!));
  }

  @override
  void onValueChanged(DateTime? value) {
    textEditingController.text =
        value == null ? '' : _formatter(widget.type, value);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _clearValue() {
    setValue(null);
    textEditingController.text = '';
  }

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<DateTime?> oldWidget) {
    if (value == null) {
      return;
    }
    if (widget.firstDate != null && widget.firstDate!.isAfter(value!)) {
      _clearValue();
    }
    if (value != null &&
        widget.lastDate != null &&
        widget.lastDate!.isBefore(value!)) {
      _clearValue();
    }
    if (value != null &&
        (widget.formatter != null ||
            widget.type != (oldWidget as FormeDateTimeField).type)) {
      textEditingController.text =
          (widget.formatter ?? defaultDateTimeFormatter)(widget.type, value!);
    }
    if (value != null &&
        widget.type != (oldWidget as FormeDateTimeField).type &&
        widget.type == FormeDateTimeType.date) {
      setValue(DateTime(value!.year, value!.month, value!.day));
      textEditingController.text = (widget.formatter ??
          defaultDateTimeFormatter)(FormeDateTimeType.date, value!);
    }
  }

  @override
  DateTime? get value {
    final value = super.value;
    if (value == null) {
      return null;
    }
    return simple(value);
  }

  DateTime get initialDateTime {
    if (value != null) {
      return value!;
    }
    final DateTime now = DateTime.now();
    DateTime date =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    if (widget.lastDate != null && widget.lastDate!.isBefore(date)) {
      date = widget.lastDate!;
    }
    if (widget.firstDate != null && widget.firstDate!.isAfter(date)) {
      date = widget.firstDate!;
    }
    switch (widget.type) {
      case FormeDateTimeType.date:
        return DateTime(date.year, date.month, date.day);
      case FormeDateTimeType.dateTime:
        return date;
    }
  }

  DateTime simple(DateTime time) {
    switch (widget.type) {
      case FormeDateTimeType.date:
        return DateTime(time.year, time.month, time.day);
      case FormeDateTimeType.dateTime:
        return DateTime(
            time.year, time.month, time.day, time.hour, time.minute);
    }
  }
}
