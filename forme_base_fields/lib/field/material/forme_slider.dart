import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

typedef FormeLabelRender = String Function(double value);

class FormeSlider extends FormeField<double> {
  final double min;
  final double max;

  FormeSlider({
    double? initialValue,
    required String name,
    bool readOnly = false,
    required this.min,
    required this.max,
    Key? key,
    int? order,
    bool quietlyValidate = false,

    /// used for [FormeInputDecorator], if you specific a [FormeFieldDecorator] , this will not work
    InputDecoration? decoration,
    FormeFieldDecorator<double>? decorator,
    SemanticFormatterCallback? semanticFormatterCallback,
    ValueChanged<double>? onChangeStart,
    ValueChanged<double>? onChangeEnd,
    ValueChanged<double>? onChanged,
    int? divisions,
    Color? activeColor,
    Color? inactiveColor,
    SliderThemeData? sliderThemeData,
    MouseCursor? mouseCursor,
    FormeLabelRender? labelRender,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<double>? onStatusChanged,
    FormeFieldInitialed<double>? onInitialed,
    FormeFieldSetter<double>? onSaved,
    FormeValidator<double>? validator,
    FormeAsyncValidator<double>? asyncValidator,
    bool registrable = true,
    bool enabled = true,
    FormeFieldValueUpdater<double>? valueUpdater,
    FormeFieldValidationFilter<double>? validationFilter,
    FocusNode? focusNode,
  }) : super(
          focusNode: focusNode,
          validationFilter: validationFilter,
          valueUpdater: valueUpdater,
          enabled: enabled,
          registrable: registrable,
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
          initialValue: initialValue ?? min,
          decorator: decorator ??
              (decoration == null
                  ? null
                  : FormeInputDecoratorBuilder(decoration: decoration)),
          builder: (baseState) {
            final _FormeSliderState state = baseState as _FormeSliderState;
            final bool readOnly = state.readOnly;

            final Widget slider = ValueListenableBuilder<double?>(
              valueListenable: state.notifier,
              builder: (context, _value, child) {
                final String? sliderLabel =
                    labelRender == null ? null : labelRender(state.value);
                SliderThemeData _sliderThemeData =
                    sliderThemeData ?? SliderTheme.of(state.context);
                if (_sliderThemeData.thumbShape == null) {
                  _sliderThemeData = _sliderThemeData.copyWith(
                      thumbShape: CustomSliderThumbCircle(value: state.value));
                }
                return SliderTheme(
                  data: _sliderThemeData,
                  child: Slider(
                    value: state.value,
                    min: min,
                    max: max,
                    focusNode: state.focusNode,
                    label: sliderLabel,
                    divisions: divisions ?? (max - min).floor(),
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
                    mouseCursor: mouseCursor,
                    onChanged: readOnly
                        ? null
                        : (double value) {
                            state.updateValue(value);
                            onChanged?.call(value);
                          },
                  ),
                );
              },
            );

            return slider;
          },
        );

  @override
  _FormeSliderState createState() => _FormeSliderState();
}

class _FormeSliderState extends FormeFieldState<double> {
  final ValueNotifier<double?> notifier = FormeMountedValueNotifier(null);

  @override
  FormeSlider get widget => super.widget as FormeSlider;

  void updateValue(double value) {
    notifier.value = value;
  }

  @override
  double get initialValue {
    final double defaultInitialValue = widget.initialValue;
    if (defaultInitialValue < widget.min) {
      return widget.min;
    }
    if (defaultInitialValue > widget.max) {
      return widget.max;
    }
    return defaultInitialValue;
  }

  @override
  double get value => notifier.value ?? super.value;

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<double> status) {
    super.onStatusChanged(status);
    if (status.isValueChanged) {
      notifier.value = null;
    }
  }
}

// copied from https://medium.com/flutter-community/flutter-sliders-demystified-4b3ea65879c
class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final double value;

  const CustomSliderThumbCircle({
    this.thumbRadius = 12,
    required this.value,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );
    final Color color = colorTween.evaluate(enableAnimation)!;

    final Paint paint = Paint()
      ..color = color //Thumb Background Color
      ..style = PaintingStyle.fill;

    final TextSpan span = TextSpan(
        style: TextStyle(
          fontSize: thumbRadius * .8,
          fontWeight: FontWeight.w700,
          color: Colors.white, //Text Color of Value on Thumb
        ),
        text: this.value.round().toString());
    final TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    final Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawCircle(center, thumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }
}
