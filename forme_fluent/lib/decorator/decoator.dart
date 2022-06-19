import 'package:fluent_ui/fluent_ui.dart';

import 'package:forme/forme.dart';

/// this builder will decorate current field with [FormRow]
class FormeFluentInputDecoratorBuilder<T> implements FormeFieldDecorator<T> {
  final EdgeInsetsGeometry padding;
  final Widget? helper;
  final TextStyle? textStyle;
  final Widget Function(Widget child)? wrapper;

  const FormeFluentInputDecoratorBuilder({
    this.wrapper,
    this.padding = const EdgeInsetsDirectional.fromSTEB(
      20.0,
      6.0,
      6.0,
      6.0,
    ),
    this.helper,
    this.textStyle,
  });

  @override
  Widget build(
    BuildContext context,
    Widget child,
  ) {
    return FormeFluentInputDecorator<T>(
      helper: helper,
      padding: padding,
      wrapper: wrapper,
      textStyle: textStyle,
      child: child,
    );
  }
}

class FormeFluentInputDecorator<T> extends StatefulWidget {
  const FormeFluentInputDecorator({
    Key? key,
    required this.padding,
    this.helper,
    this.wrapper,
    required this.child,
    this.textStyle,
  }) : super(key: key);

  final EdgeInsetsGeometry padding;
  final Widget? helper;
  final Widget child;
  final Widget Function(Widget child)? wrapper;
  final TextStyle? textStyle;

  @override
  State<StatefulWidget> createState() => _FormeFluentInputDecoratorState<T>();
}

class _FormeFluentInputDecoratorState<T>
    extends FormeDecoratorState<T, FormeFluentInputDecorator<T>> {
  @override
  Widget build(BuildContext context) {
    final Widget child =
        widget.wrapper == null ? widget.child : widget.wrapper!(widget.child);
    if (isQuietlyValidate) {
      return FormRow(
        textStyle: widget.textStyle,
        helper: widget.helper,
        padding: widget.padding,
        child: child,
      );
    }

    return FormRow(
      helper: widget.helper,
      padding: widget.padding,
      error: state.validation.isInvalid ? Text(state.validation.error!) : null,
      textStyle: widget.textStyle,
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
