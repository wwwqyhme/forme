import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:decimal/decimal.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forme/forme.dart';

class FormeSpinNumberField extends FormeField<double> {
  final int decimal;
  final double max;
  final double min;
  final double step;
  final double acceleration;
  final Duration interval;

  /// if [strictStep] is true ,  value is only accepted when  match condition `(value - initialValue) % step`
  ///
  /// acceleration will not work when [strictStep] is true
  final bool strictStep;

  FormeSpinNumberField({
    this.interval = const Duration(milliseconds: 100),
    this.step = 1,
    this.acceleration = 0,
    required this.max,
    required this.min,
    required double initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    InputDecoration? decoration,
    int? order,
    bool quietlyValidate = false,
    bool autofocus = false,
    ToolbarOptions? toolbarOptions,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    bool? showCursor,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
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
    GestureTapCallback? onTap,
    ValueChanged<double>? onSubmitted,
    TextSelectionControls? textSelectionControls,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<double>? onStatusChanged,
    FormeFieldInitialed<double>? onInitialed,
    FormeFieldSetter<double>? onSaved,
    FormeValidator<double>? validator,
    FormeAsyncValidator<double>? asyncValidator,
    this.decimal = 0,
    FormeFieldDecorator<double>? decorator,
    bool registrable = true,
    bool editable = true,
    this.strictStep = false,
    TextStyle? textStyle,
    ScrollController? scrollController,
    IconConfiguration? increasementIconConfiguration,
    IconConfiguration? decreasementIconConfiguration,
    FormeFieldValidationFilter<double>? validationFilter,
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
          initialValue: initialValue,
          builder: (baseState) {
            final bool readOnly = baseState.readOnly;
            final bool enabled = baseState.enabled;

            final _FormeSpinNumberFieldState state =
                baseState as _FormeSpinNumberFieldState;

            return TextField(
              inputFormatters: state.numberFormatters(
                  decimal: decimal,
                  allowNegative: min < 0,
                  max: max.toDouble()),
              onTap: onTap,
              autofocus: autofocus,
              autofillHints: autofillHints,
              onAppPrivateCommand: appPrivateCommandCallback,
              scrollController: scrollController,
              controller: state.textEditingController,
              focusNode: state.focusNode,
              onEditingComplete: onEditingComplete,
              textInputAction: textInputAction,
              keyboardAppearance: keyboardAppearance,
              enableInteractiveSelection: enableInteractiveSelection,
              showCursor: showCursor,
              textDirection: textDirection,
              style: textStyle,
              toolbarOptions: toolbarOptions,
              textCapitalization: textCapitalization,
              strutStyle: strutStyle,
              autocorrect: autocorrect,
              smartDashesType: smartDashesType,
              smartQuotesType: smartQuotesType,
              enableSuggestions: enableSuggestions,
              cursorWidth: cursorWidth,
              cursorHeight: cursorHeight,
              cursorRadius: cursorRadius,
              cursorColor: cursorColor,
              selectionHeightStyle: selectionHeightStyle,
              selectionWidthStyle: selectionWidthStyle,
              scrollPadding: scrollPadding,
              dragStartBehavior: dragStartBehavior,
              mouseCursor: mouseCursor,
              scrollPhysics: scrollPhysics,
              selectionControls: textSelectionControls,
              onSubmitted: readOnly
                  ? null
                  : (v) {
                      onSubmitted?.call(state.value);
                    },
              textAlign: TextAlign.center,
              enabled: enabled,
              readOnly: !editable || readOnly,
              onChanged: state.onTextFieldChange,
              decoration: (decoration ?? const InputDecoration()).copyWith(
                prefixIcon: IconButton(
                  iconSize: decreasementIconConfiguration?.iconSize ?? 24,
                  visualDensity: decreasementIconConfiguration?.visualDensity,
                  padding: decreasementIconConfiguration?.padding ??
                      const EdgeInsets.all(8.0),
                  alignment: decreasementIconConfiguration?.alignment ??
                      Alignment.center,
                  splashRadius: decreasementIconConfiguration?.splashRadius,
                  color: decreasementIconConfiguration?.color,
                  focusColor: decreasementIconConfiguration?.focusColor,
                  hoverColor: decreasementIconConfiguration?.hoverColor,
                  highlightColor: decreasementIconConfiguration?.highlightColor,
                  splashColor: decreasementIconConfiguration?.splashColor,
                  disabledColor: decreasementIconConfiguration?.disabledColor,
                  tooltip: decreasementIconConfiguration?.tooltip,
                  enableFeedback:
                      decreasementIconConfiguration?.enableFeedback ?? true,
                  constraints: decreasementIconConfiguration?.constraints,
                  onPressed: readOnly ? null : state.subtract,
                  icon: GestureDetector(
                    onLongPress: readOnly
                        ? null
                        : () {
                            state.startAccelerate(_CalcType.subtract);
                          },
                    onLongPressUp: state.stopAccelerate,
                    child: decreasementIconConfiguration?.icon ??
                        const Icon(Icons.remove),
                  ),
                ),
                suffixIcon: IconButton(
                  iconSize: increasementIconConfiguration?.iconSize ?? 24,
                  visualDensity: increasementIconConfiguration?.visualDensity,
                  padding: increasementIconConfiguration?.padding ??
                      const EdgeInsets.all(8.0),
                  alignment: increasementIconConfiguration?.alignment ??
                      Alignment.center,
                  splashRadius: increasementIconConfiguration?.splashRadius,
                  color: increasementIconConfiguration?.color,
                  focusColor: increasementIconConfiguration?.focusColor,
                  hoverColor: increasementIconConfiguration?.hoverColor,
                  highlightColor: increasementIconConfiguration?.highlightColor,
                  splashColor: increasementIconConfiguration?.splashColor,
                  disabledColor: increasementIconConfiguration?.disabledColor,
                  tooltip: increasementIconConfiguration?.tooltip,
                  enableFeedback:
                      increasementIconConfiguration?.enableFeedback ?? true,
                  constraints: increasementIconConfiguration?.constraints,
                  onPressed: readOnly ? null : state.add,
                  icon: GestureDetector(
                    onLongPress: readOnly
                        ? null
                        : () {
                            state.startAccelerate(_CalcType.plus);
                          },
                    onLongPressUp: state.stopAccelerate,
                    child: increasementIconConfiguration?.icon ??
                        const Icon(Icons.add),
                  ),
                ),
              ),
            );
          },
        );

  @override
  FormeFieldState<double> createState() => _FormeSpinNumberFieldState();
}

class _FormeSpinNumberFieldState extends FormeFieldState<double> {
  late TextEditingController textEditingController;

  List<TextInputFormatter> numberFormatters(
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

  @override
  FormeSpinNumberField get widget => super.widget as FormeSpinNumberField;

  String get formatText => doFormat(value);

  Timer? timer;
  late double step;

  double? copyValue;

  @override
  void initStatus() {
    super.initStatus();
    step = widget.step;
    textEditingController = TextEditingController(text: formatText);
  }

  void onTextFieldChange(String text) {
    if (timer != null) {
      return;
    }
    final double? value = double.tryParse(text);
    if (value != null) {
      didChange(double.parse(value.toString()), format: false);
    }
  }

  void subtract() {
    if (widget.step == 0) {
      return;
    }
    didChange(max(widget.min, doSubtract(value, widget.step)));
  }

  void add() {
    if (widget.step == 0) {
      return;
    }
    didChange(min(widget.max, doAdd(value, widget.step)));
  }

  String doFormat(double value) {
    return value.toStringAsFixed(widget.decimal);
  }

  void startAccelerate(_CalcType type) {
    if (timer != null) {
      return;
    }
    timer = Timer.periodic(widget.interval, (timer) {
      copyValue ??= value;

      if (!widget.strictStep) {
        step = doAdd(step, widget.acceleration);
      }

      if (step == 0) {
        stopAccelerate();
        return;
      }

      double calcValue;

      switch (type) {
        case _CalcType.subtract:
          calcValue = doSubtract(copyValue!, step);
          break;
        case _CalcType.plus:
          calcValue = doAdd(copyValue!, step);
          break;
      }

      if (calcValue > widget.max || calcValue < widget.min) {
        if (widget.strictStep) {
          stopAccelerate();
          return;
        }

        if (copyValue! < widget.max && copyValue! > widget.min) {
          switch (type) {
            case _CalcType.subtract:
              copyValue = widget.min;
              break;
            case _CalcType.plus:
              copyValue = widget.max;
              break;
          }
        } else {
          stopAccelerate();
          return;
        }
      } else {
        copyValue = calcValue;
      }

      formatTextField(copyValue!);
    });
  }

  void formatTextField(double value) {
    final String text = doFormat(value);
    if (textEditingController.text != text) {
      textEditingController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(
            offset: text.length,
          ));
    }
  }

  @override
  void didChange(
    double newValue, {
    bool format = true,
  }) {
    if (newValue < widget.min || newValue > widget.max) {
      return;
    }
    if (widget.strictStep && !isStrictStep(newValue)) {
      return;
    }

    super.didChange(double.parse(newValue.toStringAsFixed(widget.decimal)));
    if (format) {
      formatTextField(value);
    }
  }

  @override
  void reset() {
    super.reset();
    formatTextField(value);
  }

  void stopAccelerate() {
    timer?.cancel();
    timer = null;
    step = widget.step;

    if (copyValue != null && mounted) {
      didChange(copyValue!);
      copyValue = null;
    }
  }

  @override
  void dispose() {
    stopAccelerate();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<double> status) {
    super.onStatusChanged(status);
    if (!status.hasFocus) {
      formatTextField(value);
    }
  }

  bool isStrictStep(double v1) {
    return (Decimal.parse(v1.toString()) -
                Decimal.parse(widget.initialValue.toString())) %
            Decimal.parse(widget.step.toString()) ==
        Decimal.zero;
  }

  double doAdd(double v1, double v2) {
    return (Decimal.parse(v1.toString()) + Decimal.parse(v2.toString()))
        .toDouble();
  }

  double doSubtract(double v1, double v2) {
    return (Decimal.parse(v1.toString()) - Decimal.parse(v2.toString()))
        .toDouble();
  }
}

enum _CalcType {
  subtract,
  plus,
}

class IconConfiguration {
  final double iconSize;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final double? splashRadius;
  final Widget? icon;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? color;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? disabledColor;
  final String? tooltip;
  final bool enableFeedback;
  final BoxConstraints? constraints;

  IconConfiguration({
    this.iconSize = 24,
    this.visualDensity,
    this.padding = const EdgeInsets.all(8.0),
    this.alignment = Alignment.center,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.tooltip,
    this.enableFeedback = true,
    this.constraints,
    required this.icon,
  });
}
