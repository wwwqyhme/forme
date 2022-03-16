import 'package:flutter/widgets.dart';
import 'package:forme/src/forme_core.dart';
import 'package:forme/src/visitors/forme_field_visitor_state.dart';

/// used to listen target field status
///
/// eg:
///
/// ``` Dart
/// FormeFieldStatusListener(
///   name:'username',
///   builder:(context,field,status,child){
///     if(status == null) {
///       //field is disposed or not created yet
///       return const SizedBox.shrink();
///     }
///     return Text(status.toString());
///   }
/// )
/// ```
///
/// no need to care about order of fields
///
/// **this widget must used inside in  [Forme] or [FormeField]**
class FormeFieldStatusListener<T extends Object?>
    extends FormeFieldVisitorWidget {
  final bool Function(FormeFieldChangedStatus<T> status)? filter;
  final Widget? child;
  final Widget Function(
    BuildContext context,
    FormeFieldStatus<T>? status,
    Widget? child,
  ) builder;

  const FormeFieldStatusListener({
    Key? key,
    required this.builder,
    String? name,
    this.child,
    this.filter,
  }) : super(name: name, key: key);

  @override
  State<StatefulWidget> createState() => _FormeFieldStatusListenerState<T>();
}

class _FormeFieldStatusListenerState<T extends Object?>
    extends FormeFieldVisitorState<FormeFieldStatusListener<T>, T> {
  FormeFieldStatus<T>? status;
  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      status,
      widget.child,
    );
  }

  @override
  void onRegistered(FormeState form, FormeFieldState<T> field) {
    setState(() {
      status = field.status;
    });
  }

  @override
  void onStatusChanged(FormeState? form, FormeFieldState<T> field,
      FormeFieldChangedStatus<T> status) {
    final bool notify = widget.filter == null ? true : widget.filter!(status);
    if (notify) {
      setState(() {
        this.status = status;
      });
    }
  }

  @override
  void onUnregistered(FormeState form, FormeFieldState<T> field) {
    setState(() {
      status = null;
    });
  }

  @override
  void onInitialed(FormeFieldState<T>? field) {
    status = field?.status;
  }
}
