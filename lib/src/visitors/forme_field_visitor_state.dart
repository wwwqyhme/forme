import 'package:flutter/widgets.dart';

import '../forme_core.dart';
import '../forme_field.dart';
import '../forme_visitor.dart';

abstract class FormeFieldVisitorWidget extends StatefulWidget {
  final String name;

  const FormeFieldVisitorWidget({
    Key? key,
    required this.name,
  }) : super(key: key);
}

abstract class FormeFieldVisitorState<T extends FormeFieldVisitorWidget,
        E extends Object?> extends State<T>
    with FormeFieldVisitor<E>, FormeVisitor {
  late final FormeState? form;
  late final FormeFieldState<E>? field;

  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _inited = true;
      form = Forme.of(context);
      field = FormeField.of(context);
      if (field != null) {
        field!.addVisitor(this);
      } else if (form != null) {
        form!.addVisitor(this);
      }
    }
  }

  @override
  void dispose() {
    field?.removeVisitor(this);
    form?.removeVisitor(this);
    super.dispose();
  }

  @override
  void onFieldStatusChanged(FormeState form, FormeFieldState<Object?> field,
      FormeFieldChangedStatus<Object?> status) {
    if (field.name == widget.name) {
      onStatusChanged(form, field as FormeFieldState<E>,
          status as FormeFieldChangedStatus<E>);
    }
  }

  @override
  void onFieldsRegistered(
      FormeState form, List<FormeFieldState<Object?>> fields) {
    final Iterable<FormeFieldState<Object?>> iterable =
        fields.where((element) => element.name == widget.name);
    if (iterable.isNotEmpty) {
      onRegistered(form, iterable.first as FormeFieldState<E>);
    }
  }

  @override
  void onFieldsUnregistered(
      FormeState form, List<FormeFieldState<Object?>> fields) {
    final Iterable<FormeFieldState<Object?>> iterable =
        fields.where((element) => element.name == widget.name);
    if (iterable.isNotEmpty) {
      onUnregistered(form, iterable.first as FormeFieldState<E>);
    }
  }
}
