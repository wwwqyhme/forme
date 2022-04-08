import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:forme/forme.dart';
import '../material/forme_number_field.dart';

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
    FormeFieldStatusChanged<num?>? onStatusChanged,
    FormeFieldInitialed<num?>? onInitialed,
    FormeFieldSetter<num?>? onSaved,
    FormeValidator<num?>? validator,
    FormeAsyncValidator<num?>? asyncValidator,
    FormeFieldDecorator<num?>? decorator,
    bool registrable = true,
    bool enableIMEPersonalizedLearning = true,
    FormeFieldValueUpdater<num?>? valueUpdater,
    FormeFieldValidationFilter<num?>? validationFilter,
    FocusNode? focusNode,
  }) : super(
          focusNode: focusNode,
          validationFilter: validationFilter,
          valueUpdater: valueUpdater,
          registrable: registrable,
          enabled: enabled,
          key: key,
          decorator: decorator,
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          autovalidateMode: autovalidateMode,
          onStatusChanged: onStatusChanged,
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
            final bool enabled = state.enabled;
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
              enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
              enabled: enabled,
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
              autofillHints: readOnly ? null : autofillHints,
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
  void initStatus() {
    super.initStatus();
    textEditingController = TextEditingController(
        text: initialValue == null ? '' : initialValue.toString());
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<num?> status) {
    super.onStatusChanged(status);
    if (status.isValueChanged) {
      if (updateController) {
        final String str = status.value == null ? '' : status.value.toString();
        if (textEditingController.text != str) {
          textEditingController.text = str;
        }
      } else {
        updateController = true;
      }
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}
