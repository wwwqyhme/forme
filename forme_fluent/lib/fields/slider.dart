import 'package:fluent_ui/fluent_ui.dart';
import 'package:forme/forme.dart';

typedef FormeFluentLabelRender = String Function(double value);

class FormeFluentSlider extends FormeField<double> {
  final double min;
  final double max;

  FormeFluentSlider({
    double? initialValue,
    required String name,
    bool readOnly = false,
    required this.min,
    required this.max,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    FormeFieldDecorator<double>? decorator,
    ValueChanged<double>? onChangeStart,
    ValueChanged<double>? onChangeEnd,
    ValueChanged<double>? onChanged,
    int? divisions,
    MouseCursor mouseCursor = MouseCursor.defer,
    FormeFluentLabelRender? labelRender,
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
    bool autofocus = false,
    SliderThemeData? style,
    bool vertical = false,
    bool requestFocusOnUserInteraction = true,
  }) : super(
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
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
          decorator: decorator,
          builder: (baseState) {
            final _FormeSliderState state = baseState as _FormeSliderState;
            final bool readOnly = state.readOnly;

            final Widget slider = ValueListenableBuilder<double?>(
              valueListenable: state.notifier,
              builder: (context, _value, child) {
                final String? sliderLabel =
                    labelRender == null ? null : labelRender(state.value);
                return Slider(
                  style: style,
                  vertical: vertical,
                  autofocus: autofocus,
                  value: state.value,
                  min: min,
                  max: max,
                  focusNode: state.focusNode,
                  label: sliderLabel,
                  divisions: divisions ?? (max - min).floor(),
                  onChangeStart: (v) {
                    state.requestFocusOnUserInteraction();
                    onChangeStart?.call(v);
                  },
                  onChangeEnd: (v) {
                    state.didChange(v);
                    onChangeEnd?.call(v);
                  },
                  mouseCursor: mouseCursor,
                  onChanged: readOnly
                      ? null
                      : (double value) {
                          state.updateValue(value);
                          onChanged?.call(value);
                        },
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
  FormeFluentSlider get widget => super.widget as FormeFluentSlider;

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
