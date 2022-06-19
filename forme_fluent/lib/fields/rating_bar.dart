import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:forme/forme.dart';

class FormeFluentRatingBar extends FormeField<double> {
  FormeFluentRatingBar({
    double? initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    FormeFieldDecorator<double>? decorator,
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
    bool requestFocusOnUserInteraction = true,
    int amount = 5,
    Duration animationDuration = Duration.zero,
    Curve? animationCurve,
    IconData? icon,
    double iconSize = 20,
    double starSpacing = 0,
    Color? ratedIconColor,
    Color? unratedIconColor,
    String? semanticLabel,
    DragStartBehavior dragStartBehavior = DragStartBehavior.down,
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
          initialValue: initialValue ?? 0.0,
          decorator: decorator,
          builder: (state) {
            final bool readOnly = state.readOnly;

            return RatingBar(
              ratedIconColor: ratedIconColor,
              amount: amount,
              animationDuration: animationDuration,
              animationCurve: animationCurve,
              icon: icon,
              iconSize: iconSize,
              starSpacing: starSpacing,
              unratedIconColor: unratedIconColor,
              dragStartBehavior: dragStartBehavior,
              semanticLabel: semanticLabel,
              autofocus: autofocus,
              focusNode: state.focusNode,
              onChanged: readOnly
                  ? null
                  : (double value) {
                      state.didChange(value);
                      state.requestFocusOnUserInteraction();
                    },
              rating: state.value,
            );
          },
        );
}
