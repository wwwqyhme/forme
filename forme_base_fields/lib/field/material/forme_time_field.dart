import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:forme/forme.dart';

typedef FormeTimeFieldFormatter = String Function(TimeOfDay timeOfDay);

class FormeTimeField extends FormeField<TimeOfDay?> {
  final FormeTimeFieldFormatter? formatter;

  FormeTimeField({
    TimeOfDay? initialValue,
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
    ScrollController? scrollController,
    TextSelectionControls? textSelectionControls,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    ValueChanged<TimeOfDay?>? onSubmitted,
    FormeFieldStatusChanged<TimeOfDay?>? onStatusChanged,
    FormeFieldInitialed<TimeOfDay?>? onInitialed,
    FormeFieldSetter<TimeOfDay?>? onSaved,
    FormeValidator<TimeOfDay?>? validator,
    FormeAsyncValidator<TimeOfDay?>? asyncValidator,
    TimePickerEntryMode? initialEntryMode,
    String? cancelText,
    String? confirmText,
    String? helpText,
    RouteSettings? routeSettings,
    TransitionBuilder? builder,
    bool requestFocusOnUserInteraction = true,
    FormeFieldDecorator<TimeOfDay?>? decorator,
    bool registrable = true,
    FormeFieldValidationFilter<TimeOfDay?>? validationFilter,
    FocusNode? focusNode,
  }) : super(
          focusNode: focusNode,
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
          name: name,
          readOnly: readOnly,
          initialValue: initialValue,
          builder: (baseState) {
            final bool readOnly = baseState.readOnly;
            final bool enabled = baseState.enabled;
            final _FormeTimeFieldState state =
                baseState as _FormeTimeFieldState;

            void pickTime() {
              showTimePicker(
                context: state.context,
                initialTime: state.value ?? TimeOfDay.now(),
                builder: builder,
                routeSettings: routeSettings,
                initialEntryMode: initialEntryMode ?? TimePickerEntryMode.dial,
                cancelText: cancelText,
                confirmText: confirmText,
                helpText: helpText,
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
  _FormeTimeFieldState createState() => _FormeTimeFieldState();

  static String defaultFormeTimeFieldFormatter(TimeOfDay v) =>
      '${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}';
}

class _FormeTimeFieldState extends FormeFieldState<TimeOfDay?> {
  FormeTimeFieldFormatter get _formatter =>
      widget.formatter ?? FormeTimeField.defaultFormeTimeFieldFormatter;

  late final TextEditingController textEditingController;

  @override
  FormeTimeField get widget => super.widget as FormeTimeField;

  @override
  void initStatus() {
    super.initStatus();
    textEditingController = TextEditingController(
        text: initialValue == null ? '' : _formatter(initialValue!));
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<TimeOfDay?> status) {
    super.onStatusChanged(status);
    if (status.isValueChanged) {
      textEditingController.text =
          status.value == null ? '' : _formatter(status.value!);
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FormeField<TimeOfDay?> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.formatter != null && value != null) {
      textEditingController.text =
          value == null ? '' : widget.formatter!(value!);
    }
  }
}
