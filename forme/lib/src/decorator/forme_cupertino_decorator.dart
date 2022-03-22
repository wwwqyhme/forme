import 'package:flutter/cupertino.dart';

import '../../forme.dart';
import 'forme_decorator_state.dart';

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
    BuildContext context,
    Widget child,
  ) {
    return FormeCupertinoInputDecorator<T>(
      helper: helper,
      padding: padding,
      prefix: prefix,
      wrapper: wrapper,
      child: child,
    );
  }
}

class FormeCupertinoInputDecorator<T> extends StatefulWidget {
  const FormeCupertinoInputDecorator(
      {Key? key,
      this.prefix,
      this.padding,
      this.helper,
      this.wrapper,
      required this.child})
      : super(key: key);

  final Widget? prefix;
  final EdgeInsetsGeometry? padding;
  final Widget? helper;
  final Widget child;
  final Widget Function(Widget child)? wrapper;

  @override
  State<StatefulWidget> createState() =>
      _FormeCupertinoInputDecoratorState<T>();
}

class _FormeCupertinoInputDecoratorState<T>
    extends FormeDecoratorState<T, FormeCupertinoInputDecorator<T>> {
  @override
  Widget build(BuildContext context) {
    final Widget child =
        widget.wrapper == null ? widget.child : widget.wrapper!(widget.child);
    if (isQuietlyValidate) {
      return CupertinoFormRow(
        helper: widget.helper,
        padding: widget.padding,
        prefix: widget.prefix,
        child: child,
      );
    }

    return CupertinoFormRow(
      helper: widget.helper,
      padding: widget.padding,
      prefix: widget.prefix,
      error: state.validation.isInvalid ? Text(state.validation.error!) : null,
      child: child,
    );
  }

  @override
  void onRegistered(FormeState form, FormeFieldState<T> field) {
    setState(() {});
  }

  @override
  void onStatusChanged(FormeState? form, FormeFieldState<T> field,
      FormeFieldChangedStatus<T> status) {
    if (!isQuietlyValidate && status.isValidationChanged) {
      setState(() {});
    }
  }

  @override
  void onUnregistered(FormeState form, FormeFieldState<T> field) {}
}
