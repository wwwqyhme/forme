import 'package:flutter/cupertino.dart';

import '../../forme.dart';

/// this builder will decorate current field with [CupertinoFormRow]
class FormeCupertinoInputDecoratorBuilder<T> implements FormeFieldDecorator<T> {
  final Widget? prefix;
  final EdgeInsetsGeometry? padding;
  final Widget? helper;
  final Widget Function(Widget child)? wrapper;

  const FormeCupertinoInputDecoratorBuilder({
    this.wrapper,
    this.prefix,
    this.padding,
    this.helper,
  });

  @override
  Widget build(
    FormeFieldController<T> controller,
    Widget child,
  ) {
    return FormeCupertinoInputDecorator(
      helper: helper,
      padding: padding,
      prefix: prefix,
      controller: controller,
      wrapper: wrapper,
      child: child,
    );
  }
}

class FormeCupertinoInputDecorator<T> extends StatelessWidget {
  const FormeCupertinoInputDecorator(
      {Key? key,
      this.prefix,
      this.padding,
      this.helper,
      this.wrapper,
      required this.controller,
      required this.child})
      : super(key: key);

  final Widget? prefix;
  final EdgeInsetsGeometry? padding;
  final Widget? helper;
  final Widget child;
  final Widget Function(Widget child)? wrapper;
  final FormeFieldController<T> controller;

  @override
  Widget build(BuildContext context) {
    final Widget child = wrapper == null ? this.child : wrapper!(this.child);
    if (FormeKey.of(context)?.quietlyValidate ?? false) {
      return CupertinoFormRow(
        helper: helper,
        padding: padding,
        prefix: prefix,
        child: child,
      );
    }
    return ValueListenableBuilder<FormeFieldValidation>(
      valueListenable: controller.validationListenable,
      builder: (context, FormeFieldValidation validation, _child) {
        return CupertinoFormRow(
          helper: helper,
          padding: padding,
          prefix: prefix,
          error: validation.isInvalid ? Text(validation.error!) : null,
          child: child,
        );
      },
    );
  }
}
