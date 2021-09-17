import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../../forme.dart';

class FormeTextField extends FormeField<String> {
  final bool selectAllOnFocus;

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
    FormeValueChanged<String>? onValueChanged,
    FormeFocusChanged<String>? onFocusChanged,
    FormeErrorChanged<String>? onErrorChanged,
    FormeFieldInitialed<String>? onInitialed,
    FormeFieldSetter<String>? onSaved,
    FormeValidator<String>? validator,
    FormeAsyncValidator<String>? asyncValidator,
  }) : super(
          order: order,
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          autovalidateMode: autovalidateMode,
          onValueChanged: onValueChanged,
          onFocusChanged: onFocusChanged,
          onErrorChanged: onErrorChanged,
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
            final _FormeTextFieldState state =
                baseState as _FormeTextFieldState;

            return TextField(
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
              onChanged: state.didChange,
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
              inputFormatters: inputFormatters,
              keyboardType: keyboardType,
              maxLength: maxLength,
              scrollController: scrollController,
              selectionControls: textSelectionControls,
            );
          },
        );

  @override
  _FormeTextFieldState createState() => _FormeTextFieldState();
}

class _FormeTextFieldState extends FormeFieldState<String> {
  late final TextEditingController textEditingController;

  @override
  FormeTextField get widget => super.widget as FormeTextField;

  @override
  FormeFieldController<String> createFormeFieldController() =>
      FormeTextFieldController._(
          super.createFormeFieldController(), textEditingController);

  @override
  void onFocusChanged(bool hasFocus) {
    if (hasFocus && widget.selectAllOnFocus) {
      textEditingController.selection =
          _selection(0, textEditingController.text.length);
    }
  }

  @override
  void beforeInitiation() {
    super.beforeInitiation();
    textEditingController = TextEditingController(text: initialValue);
  }

  @override
  void afterInitiation() {
    super.afterInitiation();
    textEditingController.addListener(_handleControllerChanged);
  }

  @override
  void onValueChanged(String value) {
    if (textEditingController.text != value) {
      textEditingController.text = value;
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (textEditingController.text != value) {
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

class FormeTextFieldController extends FormeFieldControllerDelegate<String> {
  final TextEditingController textEditingController;

  FormeTextFieldController._(
      FormeFieldController<String> delegate, this.textEditingController)
      : super(delegate);
}
