import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import '../../../forme.dart';

import 'cupertinos.dart';

typedef FormeCupertinoDurationFormatter = String Function(
    Duration duration, CupertinoTimerPickerMode mode);

/// used to pick time only
class FormeCupertinoTimerField extends FormeField<Duration?> {
  final FormeCupertinoDurationFormatter? formatter;
  final int minuteInterval;
  final int secondInterval;
  final CupertinoTimerPickerMode mode;

  FormeCupertinoTimerField({
    this.formatter,
    Duration? initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    Widget? confirmWidget,
    this.minuteInterval = 1,
    this.secondInterval = 1,
    this.mode = CupertinoTimerPickerMode.hms,
    Alignment alignment = Alignment.center,
    Color? backgroundColor,
    int? maxLines = 1,
    int? order,
    ImageFilter? filter,
    Color barrierColor = kCupertinoModalBarrierColor,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    bool? semanticsDismissible,
    RouteSettings? routeSettings,
    VoidCallback? beforeOpen,
    VoidCallback? afterClose,
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
    Iterable<String>? autofillHints,
    bool borderless = false,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<Duration?>? onValueChanged,
    FormeFocusChanged<Duration?>? onFocusChanged,
    FormeFieldValidationChanged<Duration?>? onValidationChanged,
    FormeFieldInitialed<Duration?>? onInitialed,
    FormeFieldSetter<Duration?>? onSaved,
    FormeValidator<Duration?>? validator,
    FormeAsyncValidator<Duration?>? asyncValidator,
    FormeFieldDecorator<Duration?>? decorator,
    bool registrable = true,
    bool enableIMEPersonalizedLearning = true,
  }) : super(
          registrable: registrable,
          enabled: enabled,
          readOnly: readOnly,
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
          initialValue: initialValue,
          builder: (state) {
            final bool readOnly = state.readOnly;
            final bool enabled = state.enabled;
            final FocusNode focusNode = state.focusNode;
            final TextEditingController textEditingController =
                (state as _FormeCupertinoTimerFieldState).textEditingController;

            void pickDuration() {
              state.duration = null;
              beforeOpen?.call();
              showCupertinoModalPopup<dynamic>(
                context: state.context,
                builder: (context) {
                  return Container(
                    color: CupertinoColors.systemBackground,
                    child: Wrap(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CupertinoButton(
                            onPressed: () {
                              if (state.duration == null) {
                                if (state.value == null) {
                                  state.didChange(Duration.zero);
                                }
                              } else {
                                state.didChange(state.duration);
                              }
                              state.duration = null;
                              Navigator.of(context).pop();
                            },
                            child: confirmWidget ??
                                const Icon(
                                  CupertinoIcons.check_mark,
                                ),
                          ),
                        ],
                      ),
                      CupertinoTimerPicker(
                        minuteInterval: minuteInterval,
                        secondInterval: secondInterval,
                        backgroundColor: backgroundColor,
                        alignment: alignment,
                        initialTimerDuration: state.value ?? Duration.zero,
                        mode: mode,
                        onTimerDurationChanged: (Duration timer) {
                          state.duration = timer;
                        },
                      ),
                    ]),
                  );
                },
                barrierColor: barrierColor,
                filter: filter,
                barrierDismissible: barrierDismissible,
                useRootNavigator: useRootNavigator,
                semanticsDismissible: semanticsDismissible,
                routeSettings: routeSettings,
              ).whenComplete(() {
                state.focusNode.requestFocus();
                afterClose?.call();
              });
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
              textInputAction: textInputAction,
              textCapitalization: textCapitalization,
              style: style,
              strutStyle: strutStyle,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              readOnly: true,
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
              onEditingComplete: onEditingComplete,
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
              onTap: readOnly ? null : pickDuration,
              scrollController: scrollController,
              scrollPhysics: scrollPhysics,
              autofillHints: readOnly ? null : autofillHints,
              borderless: borderless,
            );
          },
        );

  @override
  _FormeCupertinoTimerFieldState createState() =>
      _FormeCupertinoTimerFieldState();
}

class _FormeCupertinoTimerFieldState extends FormeFieldState<Duration?> {
  FormeCupertinoDurationFormatter get _formatter =>
      widget.formatter ?? _defaultDurationFormatter;

  late final TextEditingController textEditingController;

  Duration? duration;

  @override
  FormeCupertinoTimerField get widget =>
      super.widget as FormeCupertinoTimerField;

  @override
  void afterInitiation() {
    super.afterInitiation();
    textEditingController = TextEditingController(
        text:
            initialValue == null ? '' : _formatter(initialValue!, widget.mode));
  }

  @override
  void onValueChanged(Duration? value) {
    textEditingController.text =
        value == null ? '' : _formatter(value, widget.mode);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void clearValue() {
    setValue(null);
    textEditingController.text = '';
  }

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<Duration?> oldWidget) {
    if (value == null) {
      return;
    }
    if (value!.inMinutes % widget.minuteInterval != 0) {
      clearValue();
    }
    if (value != null && value!.inSeconds % widget.secondInterval != 0) {
      clearValue();
    }
    if (value != null && widget.formatter != null ||
        widget.mode != (oldWidget as FormeCupertinoTimerField).mode) {
      textEditingController.text = value == null
          ? ''
          : (widget.formatter ?? _formatter)(value!, widget.mode);
    }
  }

  String _defaultDurationFormatter(Duration v, CupertinoTimerPickerMode mode) {
    switch (mode) {
      case CupertinoTimerPickerMode.hm:
        return '${v.inHours.toString().padLeft(2, '0')}:${v.inMinutes.remainder(60).toString().padLeft(2, '0')}';
      case CupertinoTimerPickerMode.ms:
        return '${v.inMinutes.remainder(60).toString().padLeft(2, '0')}:${v.inSeconds.remainder(60).toString().padLeft(2, '0')}';
      case CupertinoTimerPickerMode.hms:
        return '${v.inHours.toString().padLeft(2, '0')}:${v.inMinutes.remainder(60).toString().padLeft(2, '0')}:${v.inSeconds.remainder(60).toString().padLeft(2, '0')}';
      default:
        throw Exception('unknown mode:$mode');
    }
  }
}
