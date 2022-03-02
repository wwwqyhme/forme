import 'package:flutter/material.dart';
import '../../forme.dart';

class FormeInputDecoratorBuilder<T> implements FormeFieldDecorator<T> {
  const FormeInputDecoratorBuilder({
    this.emptyChecker,
    this.decoration,
    this.wrapper,
    this.buildCounter,
    this.maxLength,
    this.counter,
  });
  final bool Function(T value, FormeFieldController<T> controller)?
      emptyChecker;
  final InputDecoration? decoration;
  final Widget Function(Widget child, FormeFieldController<T> controller)?
      wrapper;
  final InputCounterWidgetBuilder? buildCounter;
  final int? maxLength;

  /// used to count value length , if [maxLength] is null , no need to provide this
  final int Function(T value)? counter;

  @override
  Widget build(
    FormeFieldController<T> controller,
    Widget child,
  ) {
    return FormeInputDecorator<T>(
      emptyChecker: emptyChecker,
      decoration: decoration,
      controller: controller,
      wrapper: wrapper,
      buildCounter: buildCounter,
      maxLength: maxLength,
      counter: counter,
      child: child,
    );
  }
}

/// wrap your field in a [InputDecorator]
///
/// **worked well if you no need to support prefixIcon & suffixIcon & prefix & sufix**
class FormeInputDecorator<T> extends StatelessWidget {
  const FormeInputDecorator({
    required this.controller,
    Key? key,
    required this.child,
    this.decoration,
    this.emptyChecker,
    this.wrapper,
    this.buildCounter,
    this.maxLength,
    this.counter,
  }) : super(key: key);

  final Widget child;
  final bool Function(T value, FormeFieldController<T> controller)?
      emptyChecker;
  final InputDecoration? decoration;
  final Widget Function(Widget child, FormeFieldController<T> controller)?
      wrapper;
  final FormeFieldController<T> controller;
  final InputCounterWidgetBuilder? buildCounter;
  final int? maxLength;
  final int Function(T value)? counter;

  @override
  Widget build(BuildContext context) {
    final Widget child =
        wrapper == null ? this.child : wrapper!(this.child, controller);
    final InputDecoration _decoration = decoration ?? const InputDecoration();

    if (emptyChecker == null && (counter == null || maxLength == null)) {
      if (Forme.of(context)?.quietlyValidate ?? false) {
        return ValueListenableBuilder2<bool, bool>(
          controller.focusListenable,
          controller.enabledListenable,
          builder: (context, focus, enabled, _child) {
            return InputDecorator(
              isFocused: focus,
              decoration: _decoration.copyWith(enabled: enabled),
              child: child,
            );
          },
        );
      }
      return ValueListenableBuilder3(
        controller.focusListenable,
        controller.validationListenable,
        controller.enabledListenable,
        builder: (context, bool focus, FormeFieldValidation validation,
            bool enabled, _child) {
          return InputDecorator(
            isFocused: focus,
            decoration: _decoration.copyWith(
              errorText: validation.error,
              enabled: enabled,
            ),
            child: child,
          );
        },
      );
    } else {
      if (Forme.of(context)?.quietlyValidate ?? false) {
        return ValueListenableBuilder3<bool, T, bool>(
            controller.focusListenable,
            controller.valueListenable,
            controller.enabledListenable,
            builder: (context, bool focus, T value, bool enabled, child) {
          return InputDecorator(
            isEmpty: emptyChecker != null && emptyChecker!(value, controller),
            isFocused: focus,
            decoration:
                _getEffectiveDecoration(context, _decoration, focus, value)
                    .copyWith(enabled: enabled),
            child: child,
          );
        });
      }
      return ValueListenableBuilder4(
        controller.focusListenable,
        controller.validationListenable,
        controller.valueListenable,
        controller.enabledListenable,
        builder: (context, bool focus, FormeFieldValidation validation, T value,
            bool enabled, _child) {
          return InputDecorator(
            isEmpty: emptyChecker != null && emptyChecker!(value, controller),
            isFocused: focus,
            decoration:
                _getEffectiveDecoration(context, _decoration, focus, value)
                    .copyWith(errorText: validation.error, enabled: enabled),
            child: child,
          );
        },
      );
    }
  }

  InputDecoration _getEffectiveDecoration(BuildContext context,
      InputDecoration decoration, bool isFocused, T value) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    // No need to build anything if counter or counterText were given directly.
    if (decoration.counter != null ||
        decoration.counterText != null ||
        counter == null) {
      return decoration;
    }

    // If buildCounter was provided, use it to generate a counter widget.
    Widget? counterWidget;
    final int currentLength = counter!(value);
    if (decoration.counter == null &&
        decoration.counterText == null &&
        buildCounter != null) {
      final Widget? builtCounter = buildCounter!(
        context,
        currentLength: currentLength,
        maxLength: maxLength,
        isFocused: isFocused,
      );
      // If buildCounter returns null, don't add a counter widget to the field.
      if (builtCounter != null) {
        counterWidget = Semantics(
          container: true,
          liveRegion: isFocused,
          child: builtCounter,
        );
      }
      return decoration.copyWith(counter: counterWidget);
    }

    if (maxLength == null) {
      return decoration;
    } // No counter widget

    String counterText = '$currentLength';
    String semanticCounterText = '';

    if (maxLength! > 0) {
      counterText += '/$maxLength';
      final int remaining = (maxLength! - currentLength).clamp(0, maxLength!);
      semanticCounterText =
          localizations.remainingTextFieldCharacterCount(remaining);
    }

    final bool hasIntrinsicError = maxLength! > 0 && currentLength > maxLength!;

    if (hasIntrinsicError) {
      final ThemeData themeData = Theme.of(context);
      return decoration.copyWith(
        counterStyle: decoration.errorStyle ??
            themeData.textTheme.caption!.copyWith(color: themeData.errorColor),
        counterText: counterText,
        semanticCounterText: semanticCounterText,
      );
    }

    return decoration.copyWith(
      counterText: counterText,
      semanticCounterText: semanticCounterText,
    );
  }
}
