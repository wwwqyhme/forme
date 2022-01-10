import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import '../../../forme.dart';

import 'cupertinos.dart';

class FormeCupertinoTextField extends FormeField<String> {
  /// whether update value when text input is composing
  ///
  /// **on web this will not worked**
  /// https://github.com/flutter/flutter/issues/65357
  ///
  ///
  /// default is false
  final bool updateValueWhenComposing;
  FormeCupertinoTextField({
    String? initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    int? maxLines = 1,
    int? order,
    BoxDecoration? decoration = defaultTextFieldDecoration,
    EdgeInsetsGeometry padding = const EdgeInsets.all(6.0),
    String? placeholder,
    TextStyle placeholderStyle = const TextStyle(
      fontWeight: FontWeight.w400,
      color: CupertinoColors.placeholderText,
    ),
    Widget? prefix,
    OverlayVisibilityMode prefixMode = OverlayVisibilityMode.always,
    Widget? suffix,
    OverlayVisibilityMode suffixMode = OverlayVisibilityMode.always,
    OverlayVisibilityMode clearButtonMode = OverlayVisibilityMode.never,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign textAlign = TextAlign.start,
    ToolbarOptions? toolbarOptions,
    TextAlignVertical? textAlignVertical,
    bool? showCursor,
    bool autofocus = false,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    int? minLines,
    bool expands = false,
    int? maxLength,
    MaxLengthEnforcement? maxLengthEnforcement,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius cursorRadius = const Radius.circular(2.0),
    Color? cursorColor,
    BoxHeightStyle selectionHeightStyle = BoxHeightStyle.tight,
    BoxWidthStyle selectionWidthStyle = BoxWidthStyle.tight,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    TextSelectionControls? selectionControls,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollController? scrollController,
    ScrollPhysics? scrollPhysics,
    GestureTapCallback? onTap,
    Iterable<String>? autofillHints,
    bool borderless = false,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<String>? onValueChanged,
    FormeFocusChanged<String>? onFocusChanged,
    FormeFieldValidationChanged<String>? onValidationChanged,
    FormeFieldInitialed<String>? onInitialed,
    FormeFieldSetter<String>? onSaved,
    FormeValidator<String>? validator,
    FormeAsyncValidator<String>? asyncValidator,
    FormeFieldDecorator<String>? decorator,
    bool enableIMEPersonalizedLearning = true,
    bool registrable = true,
    this.updateValueWhenComposing = false,
  }) : super(
            registrable: registrable,
            enabled: enabled,
            decorator: decorator,
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
            order: order,
            key: key,
            name: name,
            readOnly: readOnly,
            initialValue: initialValue ?? '',
            builder: (baseState) {
              final _FormeCupertinoTextFieldState state =
                  baseState as _FormeCupertinoTextFieldState;
              final bool readOnly = state.readOnly;
              final bool enabled = state.enabled;
              final FocusNode focusNode = state.focusNode;
              final TextEditingController textEditingController =
                  state.textEditingController;

              return buildCupertinoTextField(
                enabled: enabled,
                enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
                focusNode: focusNode,
                textEditingController: textEditingController,
                decoration: decoration,
                padding: padding,
                placeholder: placeholder,
                placeholderStyle: placeholderStyle,
                prefix: prefix,
                prefixMode: prefixMode,
                suffix: suffix,
                suffixMode: suffixMode,
                clearButtonMode: clearButtonMode,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                textCapitalization: textCapitalization,
                style: style,
                strutStyle: strutStyle,
                textAlign: textAlign,
                textAlignVertical: textAlignVertical,
                readOnly: readOnly,
                toolbarOptions: toolbarOptions,
                showCursor: showCursor,
                autofocus: autofocus,
                obscuringCharacter: obscuringCharacter,
                obscureText: obscureText,
                autocorrect: autocorrect,
                smartDashesType: smartDashesType,
                smartQuotesType: smartQuotesType,
                enableSuggestions: enableSuggestions,
                maxLines: maxLines,
                minLines: minLines,
                expands: expands,
                maxLength: maxLength,
                maxLengthEnforcement: maxLengthEnforcement,
                onChanged: state._didChange,
                onEditingComplete: onEditingComplete,
                onSubmitted: onSubmitted,
                inputFormatters: inputFormatters,
                cursorWidth: cursorWidth,
                cursorHeight: cursorHeight,
                cursorRadius: cursorRadius,
                cursorColor: cursorColor,
                selectionHeightStyle: selectionHeightStyle,
                selectionWidthStyle: selectionWidthStyle,
                keyboardAppearance: keyboardAppearance,
                scrollPadding: scrollPadding,
                dragStartBehavior: dragStartBehavior,
                enableInteractiveSelection: enableInteractiveSelection,
                selectionControls: selectionControls,
                onTap: onTap,
                scrollController: scrollController,
                scrollPhysics: scrollPhysics,
                autofillHints: readOnly ? null : autofillHints,
                borderless: borderless,
              );
            });

  @override
  _FormeCupertinoTextFieldState createState() =>
      _FormeCupertinoTextFieldState();
}

class _FormeCupertinoTextFieldState extends FormeFieldState<String> {
  late final TextEditingController textEditingController;

  @override
  FormeCupertinoTextField get widget => super.widget as FormeCupertinoTextField;

  void _didChange(String newValue) {
    if (widget.updateValueWhenComposing ||
        !textEditingController.value.isComposingRangeValid) {
      didChange(newValue);
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

  @override
  FormeFieldController<String> createFormeFieldController() =>
      FormeCupertinoTextFieldController._(
          super.createFormeFieldController(), textEditingController);
}

class FormeCupertinoTextFieldController
    extends FormeFieldControllerDelegate<String> {
  final TextEditingController textEditingController;

  FormeCupertinoTextFieldController._(
      FormeFieldController<String> delegate, this.textEditingController)
      : super(delegate);
}
