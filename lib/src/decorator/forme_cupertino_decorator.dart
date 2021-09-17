import 'package:flutter/cupertino.dart';
import 'package:forme/forme.dart';

/// this builder will decorate current field with [CupertinoFormRow]
class FormeCupertinoInputDecoratorBuilder<T> implements FormeFieldDecorator<T> {
  final Widget? prefix;
  final EdgeInsets? padding;
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
      child: child,
      wrapper: wrapper,
    );
  }
}

class FormeCupertinoInputDecorator<T> extends StatelessWidget {
  final Widget? prefix;
  final EdgeInsets? padding;
  final Widget? helper;
  final Widget child;
  final Widget Function(Widget child)? wrapper;
  final FormeFieldController<T> controller;

  const FormeCupertinoInputDecorator(
      {Key? key,
      this.prefix,
      this.padding,
      this.helper,
      this.wrapper,
      required this.controller,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child = wrapper == null ? this.child : wrapper!(this.child);
    if (FormeKey.of(context)?.quietlyValidate ?? false) {
      return CupertinoFormRow(
        child: child,
        helper: helper,
        padding: padding,
        prefix: prefix,
      );
    }
    return ValueListenableBuilder<FormeValidateError?>(
      valueListenable: controller.errorTextListenable,
      builder: (context, FormeValidateError? error, _child) {
        return CupertinoFormRow(
          child: child,
          helper: helper,
          padding: padding,
          prefix: prefix,
          error: error == null
              ? null
              : error.invalid
                  ? Text(error.text!)
                  : null,
        );
      },
    );
  }
}
