import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../forme_core.dart';
import '../../forme_field.dart';

class FormeNumberField extends FormeField<num?> {
  final int decimal;
  final bool allowNegative;
  final double? max;

  FormeNumberField({
    num? initialValue,
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
    ValueChanged<num?>? onSubmitted,
    ScrollController? scrollController,
    TextSelectionControls? textSelectionControls,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<num?>? onValueChanged,
    FormeFocusChanged<num?>? onFocusChanged,
    FormeErrorChanged<num?>? onErrorChanged,
    FormeFieldInitialed<num?>? onInitialed,
    FormeFieldSetter<num?>? onSaved,
    FormeValidator<num?>? validator,
    FormeAsyncValidator<num?>? asyncValidator,
    this.decimal = 0,
    this.max,
    this.allowNegative = false,
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
          initialValue: initialValue,
          builder: (baseState) {
            final bool readOnly = baseState.readOnly;
            final _FormeNumberFieldState state =
                baseState as _FormeNumberFieldState;
            final List<TextInputFormatter> formatters = numberFormatters(
                decimal: decimal, allowNegative: allowNegative, max: max);
            if (inputFormatters != null) {
              formatters.addAll(inputFormatters);
            }

            void onChanged(String value) {
              final num? parsed = num?.tryParse(value);
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
              autofillHints: autofillHints,
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
      {required int decimal, required bool allowNegative, required num? max}) {
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

        if (max != null && parsed > max) {
          return oldValue;
        }
        return newValue;
      }),
      FilteringTextInputFormatter.allow(regex)
    ];
  }
}

class _FormeNumberFieldState extends FormeFieldState<num?> {
  late final TextEditingController textEditingController;

  @override
  FormeNumberField get widget => super.widget as FormeNumberField;

  bool updateController = true;

  @override
  num? get value => super.value == null
      ? null
      : widget.decimal == 0
          ? super.value!.toInt()
          : super.value!.toDouble();

  @override
  void beforeInitiation() {
    super.beforeInitiation();
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

  void _clearValue() {
    textEditingController.text = '';
    setValue(null);
  }

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<num?> oldWidget) {
    if (value == null) {
      return;
    }
    if (widget.max != null && widget.max! < value!) {
      _clearValue();
    }
    if (!widget.allowNegative && value! < 0) {
      _clearValue();
    }
    final int decimal = widget.decimal;
    final int indexOfPoint = value.toString().indexOf('.');
    if (indexOfPoint == -1) {
      return;
    }
    final int decimalNum = value.toString().length - (indexOfPoint + 1);
    if (decimalNum > decimal) {
      _clearValue();
    }
  }
}
