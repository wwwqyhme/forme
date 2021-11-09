import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../../forme.dart';

import 'cupertinos.dart';

class FormeCupertinoNumberField extends FormeField<num?> {
  final int decimal;
  final double? max;
  final bool allowNegative;

  FormeCupertinoNumberField({
    Key? key,
    this.decimal = 0,
    this.max,
    this.allowNegative = false,
    num? initialValue,
    required String name,
    bool readOnly = false,
    int? order,
    int? maxLines = 1,
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
    FormeValueChanged<num?>? onValueChanged,
    FormeFocusChanged<num?>? onFocusChanged,
    FormeFieldValidationChanged<num?>? onValidationChanged,
    FormeFieldInitialed<num?>? onInitialed,
    FormeFieldSetter<num?>? onSaved,
    FormeValidator<num?>? validator,
    FormeAsyncValidator<num?>? asyncValidator,
    FormeFieldDecorator<num?>? decorator,
    bool registrable = true,
  }) : super(
          registrable: registrable,
          enabled: enabled,
          key: key,
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
          readOnly: readOnly,
          name: name,
          initialValue: initialValue,
          builder: (state) {
            final bool readOnly = state.readOnly;
            final FocusNode focusNode = state.focusNode;
            final TextEditingController textEditingController =
                (state as _NumberFieldState).textEditingController;
            final List<TextInputFormatter> formatters =
                FormeNumberField.numberFormatters(
                    decimal: decimal, allowNegative: allowNegative, max: max);
            if (inputFormatters != null) {
              formatters.addAll(inputFormatters);
            }

            void onChanged(String value) {
              final num? parsed = num.tryParse(value);
              if (parsed != null && parsed != state.value) {
                state.updateController = false;
                state.didChange(parsed);
              } else {
                if (value.isEmpty && state.value != null) {
                  state.didChange(null);
                }
              }
            }

            return buildCupertinoTextField(
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
              keyboardType: TextInputType.number,
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
              onChanged: onChanged,
              onEditingComplete: onEditingComplete,
              inputFormatters: formatters,
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
              autofillHints: autofillHints,
              borderless: borderless,
            );
          },
        );

  @override
  _NumberFieldState createState() => _NumberFieldState();
}

class _NumberFieldState extends FormeFieldState<num?> {
  late final TextEditingController textEditingController;

  @override
  FormeCupertinoNumberField get widget =>
      super.widget as FormeCupertinoNumberField;

  bool updateController = true;

  @override
  num? get value => super.value == null
      ? null
      : widget.decimal == 0
          ? super.value!.toInt()
          : super.value!.toDouble();

  @override
  void afterInitiation() {
    super.afterInitiation();
    textEditingController = TextEditingController(
        text: initialValue == null ? '' : initialValue.toString());
  }

  @override
  void onValueChanged(num? value) {
    if (updateController) {
      final String str = value == null ? '' : value.toString();
      if (textEditingController.text != str) {
        textEditingController.text = str;
      }
    } else {
      updateController = true;
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void clearValue() {
    textEditingController.text = '';
    setValue(null);
  }

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<num?> oldWidget) {
    if (value == null) {
      return;
    }
    if (widget.max != null && widget.max! < value!) {
      clearValue();
    }
    if (!widget.allowNegative && value! < 0) {
      clearValue();
    }
    final int indexOfPoint = value.toString().indexOf('.');
    if (indexOfPoint == -1) {
      return;
    }
    final int decimalNum = value.toString().length - (indexOfPoint + 1);
    if (decimalNum > widget.decimal) {
      clearValue();
    }
  }
}
