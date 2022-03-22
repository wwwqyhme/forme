import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forme/forme.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

/// https://pub.dev/packages/pin_code_fields
class FormePinCodeTextField extends FormeField<String> {
  final int length;
  FormePinCodeTextField({
    String? initialValue,
    required String name,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<String>? onStatusChanged,
    FormeFieldInitialed<String>? onInitialed,
    FormeFieldSetter<String>? onSaved,
    FormeValidator<String>? validator,
    FormeAsyncValidator<String>? asyncValidator,
    FormeFieldDecorator<String>? decorator,
    bool registrable = true,
    bool readOnly = false,
    required this.length,
    VoidCallback? onTap,
    TextStyle? textStyle,
    Curve animationCurve = Curves.easeInOut,
    bool autofocus = false,
    Brightness? keyboardAppearance,
    List<TextInputFormatter> inputFormatters = const [],
    TextInputType keyboardType = TextInputType.visiblePassword,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction = TextInputAction.done,
    double cursorWidth = 2,
    Color? cursorColor,
    double? cursorHeight,
    String obscuringCharacter = '●',
    Widget? obscuringWidget,
    bool blinkWhenObscuring = false,
    Duration blinkDuration = const Duration(milliseconds: 500),
    Color? backgroundColor,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.spaceBetween,
    Duration animationDuration = const Duration(milliseconds: 150),
    AnimationType animationType = AnimationType.slide,
    bool useHapticFeedback = false,
    bool enableActiveFill = false,
    bool autoDismissKeyboard = true,
    PinTheme pinTheme = const PinTheme.defaults(),
    double errorTextSpace = 16,
    bool enablePinAutofill = false,
    int errorAnimationDuration = 500,
    String? hintCharacter,
    TextStyle? hintStyle,
    AutofillContextAction onAutoFillDisposeAction =
        AutofillContextAction.commit,
    bool useExternalAutoFillGroup = false,
    EdgeInsets scrollPadding = const EdgeInsets.all(20),
    HapticFeedbackTypes hapticFeedbackTypes = HapticFeedbackTypes.light,
    TextStyle? pastedTextStyle,
    StreamController<ErrorAnimationType>? errorAnimationController,
    bool Function(String? text)? beforeTextPaste,
    DialogConfig? dialogConfig,
    List<BoxShadow>? boxShadows,
    bool showCursor = true,
    Gradient? textGradient,
    bool enabled = true,
    ValueChanged<String>? onCompleted,
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
          readOnly: readOnly,
          name: name,
          initialValue: initialValue ?? '',
          builder: (genericState) {
            final bool readOnly = genericState.readOnly;
            final bool enabled = genericState.enabled;
            final _FormePinCodeTextFieldState state =
                genericState as _FormePinCodeTextFieldState;
            return PinCodeTextField(
              onChanged: state.didChange,
              onCompleted: onCompleted,
              appContext: state.context,
              length: length,
              onTap: onTap,
              controller: state.textEditingController,
              focusNode: state.focusNode,
              textStyle: textStyle,
              animationCurve: animationCurve,
              animationDuration: animationDuration,
              enabled: enabled,
              keyboardAppearance: keyboardAppearance,
              inputFormatters: inputFormatters,
              keyboardType: keyboardType,
              obscureText: obscureText,
              textCapitalization: textCapitalization,
              textInputAction: textInputAction,
              cursorWidth: cursorWidth,
              cursorHeight: cursorHeight,
              cursorColor: cursorColor,
              obscuringCharacter: obscuringCharacter,
              obscuringWidget: obscuringWidget,
              blinkWhenObscuring: blinkWhenObscuring,
              blinkDuration: blinkDuration,
              backgroundColor: backgroundColor,
              mainAxisAlignment: mainAxisAlignment,
              animationType: animationType,
              autoFocus: autofocus,
              readOnly: readOnly,
              useHapticFeedback: useHapticFeedback,
              hapticFeedbackTypes: hapticFeedbackTypes,
              pastedTextStyle: pastedTextStyle,
              enableActiveFill: enableActiveFill,
              autoDismissKeyboard: autoDismissKeyboard,
              autoDisposeControllers: false,
              errorAnimationController: errorAnimationController,
              beforeTextPaste: beforeTextPaste,
              dialogConfig: dialogConfig,
              pinTheme: pinTheme,
              errorTextSpace: errorTextSpace,
              enablePinAutofill: !readOnly && enablePinAutofill,
              errorAnimationDuration: errorAnimationDuration,
              boxShadows: boxShadows,
              showCursor: showCursor,
              hintCharacter: hintCharacter,
              hintStyle: hintStyle,
              textGradient: textGradient,
              onAutoFillDisposeAction: onAutoFillDisposeAction,
              useExternalAutoFillGroup: useExternalAutoFillGroup,
              scrollPadding: scrollPadding,
            );
          },
        );

  @override
  FormeFieldState<String> createState() => _FormePinCodeTextFieldState();
}

class _FormePinCodeTextFieldState extends FormeFieldState<String> {
  late final TextEditingController textEditingController;

  @override
  FormePinCodeTextField get widget => super.widget as FormePinCodeTextField;

  @override
  void initStatus() {
    super.initStatus();
    textEditingController = TextEditingController(text: value);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  String get value {
    final String value = super.value;
    if (value.length > widget.length) {
      return value.substring(0, widget.length);
    }
    return value;
  }

  @override
  void didChange(String newValue) {
    final String value = newValue.length > widget.length
        ? newValue.substring(0, widget.length)
        : newValue;
    super.didChange(value);
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<String> status) {
    super.onStatusChanged(status);
    if (status.isValueChanged) {
      if (textEditingController.text != status.value) {
        textEditingController.text = status.value;
      }
    }
  }
}
