import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';
import 'package:forme_searchable/src/searchable_controller.dart';
import 'package:forme_searchable/src/forme_searchable_strem_event.dart';

class FormeSearchableController<T extends Object> extends InheritedWidget {
  final SearchController controller;
  final Stream<FormeSearchableEvent<T>> eventStream;
  final Stream<FormeFieldChangedStatus<List<T>>> statusStream;
  final FormeFieldStatus<List<T>> status;
  final ValueChanged<List<T>> valueUpdater;
  final int? maximum;
  final FocusNode focusNode;

  const FormeSearchableController(
    this.controller,
    this.eventStream,
    this.statusStream,
    this.status,
    this.valueUpdater,
    this.focusNode, {
    Key? key,
    required Widget child,
    this.maximum,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    final FormeSearchableController old =
        oldWidget as FormeSearchableController;
    return old.status != status ||
        old.maximum != maximum ||
        old.focusNode != focusNode;
  }

  static FormeSearchableController<T> of<T extends Object>(
      BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FormeSearchableController<T>>()!;
  }
}
