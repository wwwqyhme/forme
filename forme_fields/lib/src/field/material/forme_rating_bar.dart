import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:forme/forme.dart';

/// https://pub.dev/packages/flutter_rating_bar
class FormeRatingBar extends FormeField<double> {
  FormeRatingBar({
    double initialValue = 0,
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<double>? onStatusChanged,
    FormeFieldInitialed<double>? onInitialed,
    FormeFieldSetter<double>? onSaved,
    FormeValidator<double>? validator,
    FormeAsyncValidator<double>? asyncValidator,
    bool requestFocusOnUserInteraction = true,
    FormeFieldDecorator<double>? decorator,
    bool registrable = true,
    RatingWidget? ratingWidget,
    Color? glowColor,
    double? maxRating,
    TextDirection? textDirection,
    Color? unratedColor,
    bool allowHalfRating = false,
    Axis direction = Axis.horizontal,
    bool glow = true,
    double glowRadius = 2,
    int itemCount = 5,
    EdgeInsetsGeometry itemPadding = EdgeInsets.zero,
    double itemSize = 40,
    double minRating = 0,
    bool tapOnlyMode = false,
    bool updateOnDrag = false,
    WrapAlignment wrapAlignment = WrapAlignment.start,
    Widget Function(double value, BuildContext context, int index)? itemBuilder,
    bool enabled = true,
  }) : super(
          enabled: enabled,
          registrable: registrable,
          decorator: decorator,
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
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
          initialValue: initialValue,
          builder: (state) {
            final bool readOnly = state.readOnly;
            final double value = state.value;

            void onRatingUpdate(double value) {
              state.didChange(value);
              state.requestFocusOnUserInteraction();
            }

            Widget ratingBar;

            if (ratingWidget == null) {
              final IndexedWidgetBuilder builder = itemBuilder == null
                  ? (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      )
                  : (context, _) {
                      return itemBuilder(state.value, context, _);
                    };
              ratingBar = RatingBar.builder(
                itemBuilder: builder,
                onRatingUpdate: onRatingUpdate,
                glowColor: glowColor,
                maxRating: maxRating,
                textDirection: textDirection,
                unratedColor: unratedColor,
                allowHalfRating: allowHalfRating,
                direction: direction,
                glow: glow,
                glowRadius: glowRadius,
                ignoreGestures: readOnly,
                initialRating: value,
                itemCount: itemCount,
                itemPadding: itemPadding,
                itemSize: itemSize,
                minRating: minRating,
                tapOnlyMode: tapOnlyMode,
                updateOnDrag: updateOnDrag,
                wrapAlignment: wrapAlignment,
              );
            } else {
              ratingBar = RatingBar(
                onRatingUpdate: onRatingUpdate,
                ratingWidget: ratingWidget,
                glowColor: glowColor,
                maxRating: maxRating,
                textDirection: textDirection,
                unratedColor: unratedColor,
                allowHalfRating: allowHalfRating,
                direction: direction,
                glow: glow,
                glowRadius: glowRadius,
                ignoreGestures: readOnly,
                initialRating: value,
                itemCount: itemCount,
                itemPadding: itemPadding,
                itemSize: itemSize,
                minRating: minRating,
                tapOnlyMode: tapOnlyMode,
                updateOnDrag: updateOnDrag,
                wrapAlignment: wrapAlignment,
              );
            }
            return Focus(
              focusNode: state.focusNode,
              child: ratingBar,
            );
          },
        );
}

class FormeRatingBarIndicator extends FormeField<double> {
  FormeRatingBarIndicator({
    double initialValue = 0,
    required String name,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<double>? onStatusChanged,
    FormeFieldInitialed<double>? onInitialed,
    FormeFieldSetter<double>? onSaved,
    FormeValidator<double>? validator,
    FormeAsyncValidator<double>? asyncValidator,
    bool requestFocusOnUserInteraction = true,
    FormeFieldDecorator<double>? decorator,
    bool registrable = true,
    TextDirection? textDirection,
    Color? unratedColor,
    Axis direction = Axis.horizontal,
    int itemCount = 5,
    EdgeInsets itemPadding = EdgeInsets.zero,
    double itemSize = 40,
    Widget Function(double value, BuildContext context, int index)? itemBuilder,
    ScrollPhysics physics = const NeverScrollableScrollPhysics(),
    FormeFieldValidationFilter<double>? validationFilter,
  }) : super(
          validationFilter: validationFilter,
          registrable: registrable,
          decorator: decorator,
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
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
          readOnly: true,
          name: name,
          initialValue: initialValue,
          builder: (state) {
            final IndexedWidgetBuilder builder = itemBuilder == null
                ? (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    )
                : (context, _) {
                    return itemBuilder(state.value, context, _);
                  };
            return RatingBarIndicator(
              itemBuilder: builder,
              textDirection: textDirection,
              unratedColor: unratedColor,
              direction: direction,
              itemCount: itemCount,
              itemPadding: itemPadding,
              itemSize: itemSize,
              physics: physics,
              rating: state.value,
            );
          },
        );
}
