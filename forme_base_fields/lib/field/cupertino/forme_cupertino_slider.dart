import 'package:flutter/cupertino.dart';
import 'package:forme/forme.dart';

class FormeCupertinoSlider extends FormeField<double> {
  final double min;
  final double max;

  FormeCupertinoSlider({
    required String name,
    required this.min,
    required this.max,
    int? divisions,
    double? initialValue,
    bool readOnly = false,
    Key? key,
    int? order,
    ValueChanged<double>? onChangeStart,
    ValueChanged<double>? onChangeEnd,
    ValueChanged<double>? onChanged,
    Color? activeColor,
    Color thumbColor = CupertinoColors.white,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<double>? onStatusChanged,
    FormeFieldInitialed<double>? onInitialed,
    FormeFieldSetter<double>? onSaved,
    FormeValidator<double>? validator,
    FormeAsyncValidator<double>? asyncValidator,
    FormeFieldDecorator<double>? decorator,
    bool registrable = true,
    bool enabled = true,
    FormeFieldValueUpdater<double>? valueUpdater,
    FormeFieldValidationFilter<double>? validationFilter,
  }) : super(
          validationFilter: validationFilter,
          valueUpdater: valueUpdater,
          enabled: enabled,
          registrable: registrable,
          order: order,
          decorator: decorator,
          key: key,
          readOnly: readOnly,
          name: name,
          initialValue: initialValue ?? min,
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          autovalidateMode: autovalidateMode,
          onStatusChanged: onStatusChanged,
          onInitialed: onInitialed,
          onSaved: onSaved,
          validator: validator,
          asyncValidator: asyncValidator,
          builder: (baseState) {
            final _FormeCupertinoSliderState state =
                baseState as _FormeCupertinoSliderState;
            return ValueListenableBuilder<double?>(
                valueListenable: state.notifier,
                builder: (context, _value, child) {
                  return Focus(
                    focusNode: state.focusNode,
                    child: CupertinoSlider(
                        value: state.value,
                        min: min,
                        max: max,
                        onChangeStart: (v) {
                          state.focusNode.requestFocus();
                          onChangeStart?.call(v);
                        },
                        onChangeEnd: (v) {
                          state.didChange(v);
                          onChangeEnd?.call(v);
                        },
                        activeColor: activeColor,
                        thumbColor: thumbColor,
                        divisions: divisions ?? (max - min).floor(),
                        onChanged: state.readOnly
                            ? null
                            : (v) {
                                state.updateValue(v);
                                onChanged?.call(v);
                              }),
                  );
                });
          },
        );

  @override
  _FormeCupertinoSliderState createState() => _FormeCupertinoSliderState();
}

class FormeCupertinoSliderFullWidthDecorator
    extends FormeCupertinoInputDecoratorBuilder<double> {
  FormeCupertinoSliderFullWidthDecorator({
    Widget? prefix,
    EdgeInsetsGeometry? padding,
    Widget? helper,
  }) : super(
          wrapper: (child) {
            return Row(
              children: [
                Expanded(
                  child: child,
                )
              ],
            );
          },
          padding: padding,
          helper: helper,
          prefix: prefix,
        );
}

class _FormeCupertinoSliderState extends FormeFieldState<double> {
  @override
  FormeCupertinoSlider get widget => super.widget as FormeCupertinoSlider;

  late final ValueNotifier<double?> notifier;

  void updateValue(double value) {
    notifier.value = value;
  }

  @override
  void initStatus() {
    super.initStatus();
    notifier = FormeMountedValueNotifier(null);
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
