import 'package:flutter/material.dart';
import '../../forme.dart';

class FormeInputDecoratorBuilder<T> implements FormeFieldDecorator<T> {
  const FormeInputDecoratorBuilder(
      {this.emptyChecker, this.decoration, this.wrapper});
  final bool Function(T? value, FormeFieldController<T> controller)?
      emptyChecker;
  final InputDecoration? decoration;
  final Widget Function(Widget child)? wrapper;

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
  final bool Function(T? value, FormeFieldController<T> controller)?
      emptyChecker;
  final InputDecoration? decoration;
  final Widget Function(Widget child)? wrapper;
  final FormeFieldController<T> controller;

  @override
  Widget build(BuildContext context) {
    final Widget child = wrapper == null ? this.child : wrapper!(this.child);
    final InputDecoration _decoration = decoration ?? const InputDecoration();

    if (emptyChecker == null) {
      if (FormeKey.of(context)?.quietlyValidate ?? false) {
        return ValueListenableBuilder<bool>(
          valueListenable: controller.focusListenable,
          builder: (context, focus, _child) {
            return InputDecorator(
              isFocused: focus,
              decoration: _decoration,
              child: child,
            );
          },
        );
      }
      return ValueListenableBuilder2(
        controller.focusListenable,
        controller.validationListenable,
        builder:
            (context, bool focus, FormeFieldValidation validation, _child) {
          return InputDecorator(
            isFocused: focus,
            decoration: _decoration.copyWith(errorText: validation.error),
            child: child,
          );
        },
      );
    } else {
      if (FormeKey.of(context)?.quietlyValidate ?? false) {
        return ValueListenableBuilder2(
            controller.focusListenable, controller.valueListenable,
            builder: (context, bool focus, T? value, child) {
          return InputDecorator(
            isEmpty: emptyChecker!(value, controller),
            isFocused: focus,
            decoration: _decoration,
            child: child,
          );
        });
      }
      return ValueListenableBuilder3(
        controller.focusListenable,
        controller.validationListenable,
        controller.valueListenable,
        builder: (context, bool focus, FormeFieldValidation validation,
            T? value, _child) {
          return InputDecorator(
            isEmpty: emptyChecker!(value, controller),
            isFocused: focus,
            decoration: _decoration.copyWith(errorText: validation.error),
            child: child,
          );
        },
      );
    }
  }
}
