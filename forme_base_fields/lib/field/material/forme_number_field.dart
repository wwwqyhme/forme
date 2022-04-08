import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:forme/forme.dart';

class FormeNumberField extends FormeField<double?> {
  final int decimal;
  final bool allowNegative;
  final double? max;

  FormeNumberField({
    double? initialValue,
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
    List<TextInputFormatter>? inputFormatters,
    AppPrivateCommandCallback? appPrivateCommandCallback,
    InputCounterWidgetBuilder? buildCounter,
    GestureTapCallback? onTap,
    ValueChanged<double?>? onSubmitted,
    ScrollController? scrollController,
    TextSelectionControls? textSelectionControls,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<double?>? onStatusChanged,
    FormeFieldInitialed<double?>? onInitialed,
    FormeFieldSetter<double?>? onSaved,
    FormeValidator<double?>? validator,
    FormeAsyncValidator<double?>? asyncValidator,
    this.decimal = 0,
    this.max,
    this.allowNegative = false,
    FormeFieldDecorator<double?>? decorator,
    bool registrable = true,
    FormeFieldValueUpdater<double?>? valueUpdater,
    FormeFieldValidationFilter<double?>? validationFilter,
    FocusNode? focusNode,
  }) : super(
          focusNode: focusNode,
          validationFilter: validationFilter,
          valueUpdater: valueUpdater,
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
          initialValue: initialValue,
          builder: (baseState) {
            final bool readOnly = baseState.readOnly;
            final bool enabled = baseState.enabled;
            final _FormeNumberFieldState state =
                baseState as _FormeNumberFieldState;
            final List<TextInputFormatter> formatters = numberFormatters(
                decimal: decimal, allowNegative: allowNegative, max: max);
            if (inputFormatters != null) {
              formatters.addAll(inputFormatters);
            }

            void onChanged(String value) {
              final double? parsed = double?.tryParse(value);
              if (parsed != null && parsed != state.value) {
                state.updateController = false;
                state.didChange(parsed);
              } else {
                if (value.isEmpty && state.value != null) {
                  state.didChange(null);
                }
              }
            }

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
              onSubmitted:
                  onSubmitted == null ? null : (v) => onSubmitted(state.value),
              onChanged: onChanged,
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
              inputFormatters: formatters,
              keyboardType: TextInputType.number,
              maxLength: maxLength,
              scrollController: scrollController,
              selectionControls: textSelectionControls,
            );
          },
        );

  @override
  _FormeNumberFieldState createState() => _FormeNumberFieldState();

  static List<TextInputFormatter> numberFormatters(
      {required int decimal,
      required bool allowNegative,
      required double? max}) {
    final RegExp regex =
        RegExp('[0-9${decimal > 0 ? '.' : ''}${allowNegative ? '-' : ''}]');
    return [
      TextInputFormatter.withFunction((oldValue, newValue) {
        if (newValue.text == '') {
          return newValue;
        }
        if (allowNegative && newValue.text == '-') {
          return newValue;
        }
        final double? parsed = double.tryParse(newValue.text);
        if (parsed == null) {
          return oldValue;
        }
        final int indexOfPoint = newValue.text.indexOf('.');
        if (indexOfPoint != -1) {
          final int decimalNum = newValue.text.length - (indexOfPoint + 1);
          if (decimalNum > decimal) {
            return oldValue;
          }
        }

        final double? oldParsed = double.tryParse(oldValue.text);

        if (max != null && parsed > max) {
          if (oldParsed != null && oldParsed > parsed) {
            return newValue;
          }
          return oldValue;
        }
        return newValue;
      }),
      FilteringTextInputFormatter.allow(regex)
    ];
  }
}

class _FormeNumberFieldState extends FormeFieldState<double?> {
  late final TextEditingController textEditingController;

  @override
  FormeNumberField get widget => super.widget as FormeNumberField;

  bool updateController = true;

  @override
  double? get value {
    if (super.value == null) {
      return null;
    }
    return double.parse(super.value!.toStringAsFixed(widget.decimal));
  }

  @override
  void initStatus() {
    super.initStatus();
    textEditingController = TextEditingController(
        text: initialValue == null ? '' : initialValue.toString());
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<double?> status) {
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
