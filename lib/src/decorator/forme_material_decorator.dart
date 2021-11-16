import 'package:flutter/material.dart';
import '../../forme.dart';

class FormeInputDecoratorBuilder<T> implements FormeFieldDecorator<T> {
  const FormeInputDecoratorBuilder(
      {this.emptyChecker, this.decoration, this.wrapper});
  final bool Function(T value, FormeFieldController<T> controller)?
      emptyChecker;
  final InputDecoration? decoration;
  final Widget Function(Widget child, FormeFieldController<T> controller)?
      wrapper;

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
  }) : super(key: key);

  final Widget child;
  final bool Function(T value, FormeFieldController<T> controller)?
      emptyChecker;
  final InputDecoration? decoration;
  final Widget Function(Widget child, FormeFieldController<T> controller)?
      wrapper;
  final FormeFieldController<T> controller;

  @override
  Widget build(BuildContext context) {
    final Widget child =
        wrapper == null ? this.child : wrapper!(this.child, controller);
    final InputDecoration _decoration = decoration ?? const InputDecoration();

    if (emptyChecker == null) {
      if (FormeKey.of(context)?.quietlyValidate ?? false) {
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
      if (FormeKey.of(context)?.quietlyValidate ?? false) {
        return ValueListenableBuilder3<bool, T, bool>(
            controller.focusListenable,
            controller.valueListenable,
            controller.enabledListenable,
            builder: (context, bool focus, T value, bool enabled, child) {
          return InputDecorator(
            isEmpty: emptyChecker!(value, controller),
            isFocused: focus,
            decoration: _decoration.copyWith(enabled: enabled),
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
            isEmpty: emptyChecker!(value, controller),
            isFocused: focus,
            decoration: _decoration.copyWith(
                errorText: validation.error, enabled: enabled),
            child: child,
          );
        },
      );
    }
  }
}
