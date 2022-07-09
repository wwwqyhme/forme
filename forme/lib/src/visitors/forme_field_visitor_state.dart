import 'package:flutter/widgets.dart';

import '../forme_core.dart';
import '../forme_field.dart';
import '../forme_visitor.dart';

abstract class FormeFieldVisitorWidget extends StatefulWidget {
  final String? name;

  const FormeFieldVisitorWidget({
    Key? key,
    required this.name,
  }) : super(key: key);
}

abstract class FormeFieldVisitorState<T extends FormeFieldVisitorWidget, E>
    extends State<T> with FormeFieldVisitor<E>, FormeVisitor {
  FormeState? _form;
  FormeFieldState<E>? _field;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final FormeFieldState? currentField = FormeField.of(context);
    _removeVisitor();
    if (currentField != null &&
        (widget.name == null || currentField.name == widget.name)) {
      _form = null;
      final bool initialed = currentField != _field;
      _field = currentField as FormeFieldState<E>;
      _field!.addVisitor(this);
      if (initialed) {
        onInitialed(_field);
      }
    } else {
      _field = null;
      final FormeState currentForm = Forme.of(context)!;
      final bool initialed = currentForm != _form;
      _form = currentForm;
      _form!.addVisitor(this);
      if (initialed) {
        onInitialed(currentForm.hasField(widget.name!)
            ? currentForm.field(widget.name!)
            : null);
      }
    }
  }

  /// called when widget is initialed
  ///
  /// this method is called in [didChangeDependencies] , so there's no need to call [setState]
  void onInitialed(FormeFieldState<E>? field);

  @override
  void dispose() {
    _removeVisitor();
    super.dispose();
  }

  @override
  void onFieldStatusChanged(FormeState form, FormeFieldState<dynamic> field,
      FormeFieldChangedStatus<dynamic> status) {
    if (field.name == widget.name) {
      onStatusChanged(form, field as FormeFieldState<E>,
          status as FormeFieldChangedStatus<E>);
    }
  }

  @override
  void onFieldsRegistered(
      FormeState form, List<FormeFieldState<dynamic>> fields) {
    final Iterable<FormeFieldState<dynamic>> iterable =
        fields.where((element) => element.name == widget.name);
    if (iterable.isNotEmpty) {
      onRegistered(form, iterable.first as FormeFieldState<E>);
    }
  }

  @override
  void onFieldsUnregistered(
      FormeState form, List<FormeFieldState<dynamic>> fields) {
    final Iterable<FormeFieldState<dynamic>> iterable =
        fields.where((element) => element.name == widget.name);
    if (iterable.isNotEmpty) {
      onUnregistered(form, iterable.first as FormeFieldState<E>);
    }
  }

  void _removeVisitor() {
    _field?.removeVisitor(this);
    _form?.removeVisitor(this);
  }
}
