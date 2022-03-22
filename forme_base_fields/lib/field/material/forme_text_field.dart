import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forme/forme.dart';

class FormeTextField extends FormeField<String> {
  final bool selectAllOnFocus;

  /// whether update value when text input is composing
  ///
  /// **on web this will not worked**
  /// https://github.com/flutter/flutter/issues/65357
  ///
  ///
  /// default is false
  final bool updateValueWhenComposing;

  FormeTextField({
    String? initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    InputDecoration? decoration,
    int? maxLines = 1,
    int? order,
    bool quietlyValidate = false,
    this.selectAllOnFocus = false,
    TextInputType? keyboardType,
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
    List<TextInputFormatter>? inputFormatters,
    AppPrivateCommandCallback? appPrivateCommandCallback,
    InputCounterWidgetBuilder? buildCounter,
    GestureTapCallback? onTap,
    ValueChanged<String>? onSubmitted,
    ScrollController? scrollController,
    TextSelectionControls? textSelectionControls,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<String>? onStatusChanged,
    FormeFieldInitialed<String>? onInitialed,
    FormeFieldSetter<String>? onSaved,
    FormeValidator<String>? validator,
    FormeAsyncValidator<String>? asyncValidator,
    bool enableIMEPersonalizedLearning = true,
    FormeFieldDecorator<String>? decorator,
    bool registrable = true,
    this.updateValueWhenComposing = false,
    FormeFieldValidationFilter<String>? validationFilter,
  }) : super(
          validationFilter: validationFilter,
          enabled: enabled,
          registrable: registrable,
          decorator: decorator,
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
          initialValue: initialValue ?? '',
          builder: (baseState) {
            final bool readOnly = baseState.readOnly;
            final bool enabled = baseState.enabled;
            final FormeTextFieldState state = baseState as FormeTextFieldState;

            return TextField(
              enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
              focusNode: state.focusNode,
              controller: state.textEditingController,
              decoration: decoration?.copyWith(errorText: state.errorText),
              obscureText: obscureText,
              maxLines: maxLines,
              minLines: minLines,
              enabled: enabled,
              readOnly: readOnly,
              onTap: onTap,
              onEditingComplete: onEditingComplete,
              onSubmitted: onSubmitted,
              // onChanged: state._didChange,
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
              maxLengthEnforcement: updateValueWhenComposing
                  ? maxLengthEnforcement
                  : MaxLengthEnforcement.truncateAfterCompositionEnds,
              inputFormatters: inputFormatters,
              keyboardType: keyboardType,
              maxLength: maxLength,
              scrollController: scrollController,
              selectionControls: textSelectionControls,
            );
          },
        );

  @override
  FormeTextFieldState createState() => FormeTextFieldState();
}

class FormeTextFieldState extends FormeFieldState<String> {
  late final TextEditingController textEditingController;

  @override
  FormeTextField get widget => super.widget as FormeTextField;

  @override
  void initStatus() {
    super.initStatus();
    textEditingController = TextEditingController(text: initialValue);
    textEditingController.addListener(_handleControllerChanged);
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<String> status) {
    super.onStatusChanged(status);
    if (status.isValueChanged) {
      if (textEditingController.text != status.value) {
        textEditingController.text = status.value;
      }
    }
    if (status.isFocusChanged) {
      if (status.hasFocus && widget.selectAllOnFocus) {
        textEditingController.selection =
            _selection(0, textEditingController.text.length);
      }
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (textEditingController.text != value &&
        (widget.updateValueWhenComposing ||
            !textEditingController.value.isComposingRangeValid)) {
      didChange(textEditingController.text);
    }
  }

  TextSelection _selection(int start, int end) {
    final int extendsOffset = end;
    final int baseOffset = start < 0
        ? 0
        : start > extendsOffset
            ? extendsOffset
            : start;
    return TextSelection(baseOffset: baseOffset, extentOffset: extendsOffset);
  }
}
