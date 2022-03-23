import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';
import 'package:forme_searchable/src/forme_searchable_controller.dart';
import 'package:forme_searchable/src/forme_searchable_strem_event.dart';

class FormeSearchableInheritController<T extends Object>
    extends InheritedWidget {
  final FormeSearchableController controller;
  final Stream<FormeSearchableEvent<T>> stream;
  final FormeFieldStatus<List<T>> status;
  final ValueChanged<List<T>> valueUpdater;
  final int? maximum;
  final FocusNode focusNode;

  const FormeSearchableInheritController(
    this.controller,
    this.stream,
    this.status,
    this.valueUpdater,
    this.focusNode, {
    Key? key,
    required Widget child,
    this.maximum,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    final FormeSearchableInheritController old =
        oldWidget as FormeSearchableInheritController;
    return old.status != status ||
        old.maximum != maximum ||
        old.focusNode != focusNode;
  }

  static FormeSearchableInheritController<T> of<T extends Object>(
      BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<
        FormeSearchableInheritController<T>>()!;
  }
}
