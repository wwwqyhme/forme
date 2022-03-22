import 'package:flutter/widgets.dart';

import '../forme_core.dart';
import '../forme_field.dart';
import '../forme_visitor.dart';

abstract class FormeDecoratorState<T, E extends StatefulWidget> extends State<E>
    with FormeFieldVisitor<T> {
  FormeFieldState<T>? _state;

  bool get isQuietlyValidate => Forme.of(context)?.quietlyValidate ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state?.removeVisitor(this);
    final FormeFieldState<T> currentField = FormeField.of(context)!;
    _state = currentField;
    _state!.addVisitor(this);
  }

  @protected
  FormeFieldState<T> get state => _state!;

  @override
  void dispose() {
    _state?.removeVisitor(this);
    super.dispose();
  }
}
