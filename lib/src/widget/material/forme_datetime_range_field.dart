import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../../forme.dart';

class FormeDateTimeRangeField extends FormeField<DateTimeRange?> {
  final DateTime? firstDate;
  final DateTime? lastDate;
  final FormeDateRangeFormatter? formatter;

  FormeDateTimeRangeField({
    DateTimeRange? initialValue,
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
    ValueChanged<DateTimeRange?>? onSubmitted,
    ScrollController? scrollController,
    TextSelectionControls? textSelectionControls,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<DateTimeRange?>? onValueChanged,
    FormeFocusChanged<DateTimeRange?>? onFocusChanged,
    FormeFieldValidationChanged<DateTimeRange?>? onValidationChanged,
    FormeFieldInitialed<DateTimeRange?>? onInitialed,
    FormeFieldSetter<DateTimeRange?>? onSaved,
    FormeValidator<DateTimeRange?>? validator,
    FormeAsyncValidator<DateTimeRange?>? asyncValidator,
    DatePickerEntryMode? initialEntryMode,
    String? helpText,
    String? cancelText,
    String? confirmText,
    String? saveText,
    String? errorFormatText,
    String? errorInvalidText,
    String? errorInvalidRangeText,
    String? fieldStartHintText,
    String? fieldEndHintText,
    String? fieldStartLabelText,
    String? fieldEndLabelText,
    RouteSettings? routeSettings,
    TransitionBuilder? builder,
    FormeFieldDecorator<DateTimeRange?>? decorator,
    bool registrable = true,
  }) : super(
          enabled: enabled,
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
            final bool readOnly = baseState.readOnly;
            final _FormeDateTimeRangeFieldState state =
                baseState as _FormeDateTimeRangeFieldState;

            final DateTime _firstDate = firstDate ?? DateTime(1970);
            final DateTime _lastDate = lastDate ?? DateTime(2099);

            void pickRange() {
              showDateRangePicker(
                initialDateRange: state.value,
                context: state.context,
                firstDate: _firstDate,
                lastDate: _lastDate,
                builder: builder,
                initialEntryMode:
                    initialEntryMode ?? DatePickerEntryMode.calendar,
                helpText: helpText,
                cancelText: cancelText,
                confirmText: confirmText,
                saveText: saveText,
                errorFormatText: errorFormatText,
                errorInvalidText: errorInvalidText,
                errorInvalidRangeText: errorInvalidRangeText,
                fieldStartHintText: fieldStartHintText,
                fieldEndHintText: fieldEndHintText,
                fieldStartLabelText: fieldStartLabelText,
                fieldEndLabelText: fieldEndLabelText,
                routeSettings: routeSettings,
                textDirection: textDirection,
              ).then((value) {
                if (value != null) {
                  state.didChange(value);
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
              onTap: readOnly ? null : pickRange,
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
              autofillHints: readOnly ? null : autofillHints,
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
  _FormeDateTimeRangeFieldState createState() =>
      _FormeDateTimeRangeFieldState();
}

class _FormeDateTimeRangeFieldState extends FormeFieldState<DateTimeRange?> {
  FormeDateRangeFormatter get _formatter =>
      widget.formatter ?? defaultDateRangeFormatter;

  late final TextEditingController textEditingController;

  @override
  FormeDateTimeRangeField get widget => super.widget as FormeDateTimeRangeField;

  @override
  DateTimeRange? get value {
    final DateTimeRange? value = super.value;
    if (value == null) {
      return null;
    }
    return DateTimeRange(start: simple(value.start), end: simple(value.end));
  }

  @override
  void beforeInitiation() {
    super.beforeInitiation();
    textEditingController = TextEditingController(
        text: initialValue == null ? '' : _formatter(initialValue!));
  }

  @override
  void onValueChanged(DateTimeRange? value) {
    textEditingController.text = value == null ? '' : _formatter(value);
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
  void updateFieldValueInDidUpdateWidget(FormeField<DateTimeRange?> oldWidget) {
    if (value == null) {
      return;
    }
    if (widget.firstDate != null && widget.firstDate!.isAfter(value!.start)) {
      _clearValue();
    }
    if (value != null &&
        widget.lastDate != null &&
        widget.lastDate!.isBefore(value!.end)) {
      _clearValue();
    }
    if (widget.formatter != null && value != null) {
      textEditingController.text = widget.formatter!(value!);
    }
  }

  DateTime simple(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
