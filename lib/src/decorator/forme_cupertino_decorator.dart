import 'package:flutter/cupertino.dart';

import '../../forme.dart';

/// this builder will decorate current field with [CupertinoFormRow]
class FormeCupertinoInputDecoratorBuilder<T> implements FormeFieldDecorator {
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
    return FormeCupertinoInputDecorator(
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
  State<StatefulWidget> createState() => _FormeCupertinoInputDecoratorState();
}

class _FormeCupertinoInputDecoratorState<T>
    extends State<FormeCupertinoInputDecorator<T>> with FormeFieldVisitor<T> {
  bool _inited = false;

  late FormeFieldState<T> state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _inited = true;
      state = FormeField.of(context)!;
      final bool quietly = Forme.of(context)?.quietlyValidate ?? false;
      if (!quietly) {
        state.addVisitor(this);
      }
    }
  }

  @override
  void dispose() {
    state.removeVisitor(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child =
        widget.wrapper == null ? widget.child : widget.wrapper!(widget.child);
    if (Forme.of(context)?.quietlyValidate ?? false) {
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
    if (status.isValidationChanged) {
      setState(() {});
    }
  }

  @override
  void onUnregistered(FormeState form, FormeFieldState<T> field) {}
}
