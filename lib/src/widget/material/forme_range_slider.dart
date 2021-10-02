import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../forme.dart';

import '../../forme_mounted_value_notifier.dart';

class FormRangeLabelRender {
  final FormeLabelRender startRender;
  final FormeLabelRender endRender;

  FormRangeLabelRender(this.startRender, this.endRender);
}

class FormeRangeSlider extends FormeField<RangeValues> {
  final double min;
  final double max;

  FormeRangeSlider({
    RangeValues? initialValue,
    required String name,
    bool readOnly = false,
    required this.min,
    required this.max,
    Key? key,
    InputDecoration? decoration,
    FormeFieldDecorator<RangeValues>? decorator,
    int? order,
    bool quietlyValidate = false,
    SemanticFormatterCallback? semanticFormatterCallback,
    ValueChanged<RangeValues>? onChangeStart,
    ValueChanged<RangeValues>? onChangeEnd,
    ValueChanged<RangeValues>? onChanged,
    int? divisions,
    Color? activeColor,
    Color? inactiveColor,
    SliderThemeData? sliderThemeData,
    FormRangeLabelRender? rangeLabelRender,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<RangeValues>? onValueChanged,
    FormeFocusChanged<RangeValues>? onFocusChanged,
    FormeFieldValidationInfoChanged<RangeValues>? onValidationChanged,
    FormeFieldInitialed<RangeValues>? onInitialed,
    FormeFieldSetter<RangeValues>? onSaved,
    FormeValidator<RangeValues>? validator,
    FormeAsyncValidator<RangeValues>? asyncValidator,
  }) : super(
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
            decorator: decorator ??
                (decoration == null
                    ? null
                    : FormeInputDecoratorBuilder(decoration: decoration)),
            key: key,
            readOnly: readOnly,
            name: name,
            initialValue: initialValue ?? RangeValues(min, max),
            builder: (baseState) {
              final _FormeRangeSliderState state =
                  baseState as _FormeRangeSliderState;
              final bool readOnly = state.readOnly;

              final Widget slider = ValueListenableBuilder(
                  valueListenable: state.notifier,
                  builder: (context, _value, _child) {
                    RangeLabels? sliderLabels;

                    if (rangeLabelRender != null) {
                      final String start =
                          rangeLabelRender.startRender(state.value.start);
                      final String end =
                          rangeLabelRender.endRender(state.value.end);
                      sliderLabels = RangeLabels(start, end);
                    }

                    SliderThemeData _sliderThemeData =
                        sliderThemeData ?? SliderTheme.of(state.context);
                    if (_sliderThemeData.thumbShape == null) {
                      _sliderThemeData = _sliderThemeData.copyWith(
                          rangeThumbShape:
                              CustomRangeSliderThumbCircle(value: state.value));
                    }
                    return SliderTheme(
                      data: _sliderThemeData,
                      child: RangeSlider(
                        values: state.value,
                        min: min,
                        max: max,
                        divisions: divisions ?? (max - min).floor(),
                        labels: sliderLabels,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        onChangeStart: (v) {
                          state.focusNode.requestFocus();
                          onChangeStart?.call(v);
                        },
                        onChangeEnd: (v) {
                          state.didChange(v);
                          onChangeEnd?.call(v);
                        },
                        semanticFormatterCallback: semanticFormatterCallback,
                        onChanged: readOnly
                            ? null
                            : (RangeValues values) {
                                state.updateValue(values);
                                onChanged?.call(values);
                              },
                      ),
                    );
                  });

              return Focus(
                focusNode: state.focusNode,
                child: slider,
              );
            });

  @override
  _FormeRangeSliderState createState() => _FormeRangeSliderState();
}

class _FormeRangeSliderState extends FormeFieldState<RangeValues> {
  late final ValueNotifier<RangeValues?> notifier;

  @override
  FormeRangeSlider get widget => super.widget as FormeRangeSlider;

  void updateValue(RangeValues value) {
    notifier.value = value;
  }

  @override
  void beforeInitiation() {
    super.beforeInitiation();
    notifier = FormeMountedValueNotifier(null, this);
  }

  @override
  RangeValues get initialValue {
    final RangeValues defaultInitialValue = super.initialValue;
    RangeValues currentInitialValue = defaultInitialValue;
    if (defaultInitialValue.start < widget.min) {
      currentInitialValue = RangeValues(widget.min, defaultInitialValue.end);
    } else if (defaultInitialValue.end < widget.min) {
      currentInitialValue = RangeValues(defaultInitialValue.start, widget.min);
    }
    if (defaultInitialValue.end > widget.max) {
      currentInitialValue = RangeValues(defaultInitialValue.start, widget.max);
    } else if (defaultInitialValue.start > widget.max) {
      currentInitialValue = RangeValues(widget.max, defaultInitialValue.end);
    }
    return currentInitialValue;
  }

  @override
  RangeValues get value => notifier.value ?? super.value;

  @override
  void onValueChanged(RangeValues? value) {
    notifier.value = null;
  }

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<RangeValues> oldWidget) {
    final RangeValues value = super.value;
    if (value.start < widget.min) {
      setValue(RangeValues(widget.min, value.end));
    } else if (value.end < widget.min) {
      setValue(RangeValues(value.start, widget.min));
    }
    if (value.end > widget.max) {
      setValue(RangeValues(value.start, widget.max));
    } else if (value.start > widget.max) {
      setValue(RangeValues(widget.max, value.end));
    }
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }
}

class CustomRangeSliderThumbCircle extends RangeSliderThumbShape {
  final double enabledThumbRadius;
  final double elevation;
  final double pressedElevation;
  final RangeValues value;

  CustomRangeSliderThumbCircle(
      {this.enabledThumbRadius = 12,
      this.elevation = 1,
      this.pressedElevation = 6,
      required this.value});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    String value;
    final Thumb _thumb = thumb ?? Thumb.start;
    switch (_thumb) {
      case Thumb.start:
        value = this.value.start.round().toString();
        break;
      case Thumb.end:
        value = this.value.end.round().toString();
        break;
    }

    final Canvas canvas = context.canvas;
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );
    final Color color = colorTween.evaluate(enableAnimation)!;

    final paint = Paint()
      ..color = color //Thumb Background Color
      ..style = PaintingStyle.fill;

    final TextSpan span = TextSpan(
        style: TextStyle(
          fontSize: enabledThumbRadius * .8,
          fontWeight: FontWeight.w700,
          color: Colors.white, //Text Color of Value on Thumb
        ),
        text: value);

    final TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    final Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawCircle(center, enabledThumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }
}
