import 'package:flutter/material.dart';
import '../../forme.dart';
import 'forme_decorator_state.dart';

class FormeInputDecoratorBuilder<T> implements FormeFieldDecorator<T> {
  const FormeInputDecoratorBuilder({
    this.emptyChecker,
    this.decoration,
    this.wrapper,
    this.buildCounter,
    this.maxLength,
    this.counter,
  });
  final bool Function(T value, FormeFieldState<T> field)? emptyChecker;
  final InputDecoration? decoration;
  final Widget Function(Widget child, FormeFieldState<T> field)? wrapper;
  final InputCounterWidgetBuilder? buildCounter;
  final int? maxLength;

  /// used to count value length , if [maxLength] is null , no need to provide this
  final int Function(T value)? counter;

  @override
  Widget build(
    BuildContext context,
    Widget child,
  ) {
    return FormeInputDecorator<T>(
      emptyChecker: emptyChecker,
      decoration: decoration,
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
class FormeInputDecorator<T> extends StatefulWidget {
  const FormeInputDecorator({
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
  final bool Function(T value, FormeFieldState<T> field)? emptyChecker;
  final InputDecoration? decoration;
  final Widget Function(Widget child, FormeFieldState<T> field)? wrapper;
  final InputCounterWidgetBuilder? buildCounter;
  final int? maxLength;
  final int Function(T value)? counter;

  @override
  State<StatefulWidget> createState() => _FormeInputDecoratorState<T>();
}

class _FormeInputDecoratorState<T>
    extends FormeDecoratorState<T, FormeInputDecorator<T>> {
  @override
  Widget build(BuildContext context) {
    final Widget child = widget.wrapper == null
        ? widget.child
        : widget.wrapper!(widget.child, state);
    final InputDecoration _decoration =
        widget.decoration ?? const InputDecoration();
    final bool quietly = Forme.of(context)?.quietlyValidate ?? false;
    final bool isFocused = state.focusNode.hasFocus;

    if (widget.emptyChecker == null &&
        (widget.counter == null || widget.maxLength == null)) {
      if (quietly) {
        return InputDecorator(
          isFocused: isFocused,
          decoration: _decoration.copyWith(enabled: state.enabled),
          child: child,
        );
      } else {
        return InputDecorator(
          isFocused: isFocused,
          decoration: _decoration.copyWith(
            errorText: state.validation.error,
            enabled: state.enabled,
          ),
          child: child,
        );
      }
    } else {
      final bool isEmpty = widget.emptyChecker != null &&
          widget.emptyChecker!(state.value, state);
      if (quietly) {
        return InputDecorator(
          isEmpty: isEmpty,
          isFocused: isFocused,
          decoration: _getEffectiveDecoration(
                  context, _decoration, isFocused, state.value)
              .copyWith(enabled: state.enabled),
          child: child,
        );
      } else {
        return InputDecorator(
          isEmpty: isEmpty,
          isFocused: isFocused,
          decoration: _getEffectiveDecoration(
                  context, _decoration, isFocused, state.value)
              .copyWith(
                  errorText: state.validation.error, enabled: state.enabled),
          child: child,
        );
      }
    }
  }

  @override
  void onRegistered(FormeState form, FormeFieldState<T> field) {
    setState(() {});
  }

  @override
  void onStatusChanged(FormeState? form, FormeFieldState<T> field,
      FormeFieldChangedStatus<T> status) {
    setState(() {});
  }

  @override
  void onUnregistered(FormeState form, FormeFieldState<T> field) {
    setState(() {});
  }

  InputDecoration _getEffectiveDecoration(BuildContext context,
      InputDecoration decoration, bool isFocused, T value) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    // No need to build anything if counter or counterText were given directly.
    if (decoration.counter != null ||
        decoration.counterText != null ||
        widget.counter == null) {
      return decoration;
    }

    // If buildCounter was provided, use it to generate a counter widget.
    Widget? counterWidget;
    final int currentLength = widget.counter!(value);
    if (decoration.counter == null &&
        decoration.counterText == null &&
        widget.buildCounter != null) {
      final Widget? builtCounter = widget.buildCounter!(
        context,
        currentLength: currentLength,
        maxLength: widget.maxLength,
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

    if (widget.maxLength == null) {
      return decoration;
    } // No counter widget

    String counterText = '$currentLength';
    String semanticCounterText = '';

    if (widget.maxLength! > 0) {
      counterText += '/${widget.maxLength}';
      final int remaining =
          (widget.maxLength! - currentLength).clamp(0, widget.maxLength!);
      semanticCounterText =
          localizations.remainingTextFieldCharacterCount(remaining);
    }

    final bool hasIntrinsicError =
        widget.maxLength! > 0 && currentLength > widget.maxLength!;

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
