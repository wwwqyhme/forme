import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';

import 'forme_searchable_writer.dart';

class FormeSearchableController<T extends Object> extends InheritedWidget {
  final FormeSearchableWriter<T> writer;
  final FormeFieldStatus<List<T>> status;
  final FocusNode focusNode;

  const FormeSearchableController(
    this.writer,
    this.focusNode,
    this.status, {
    Key? key,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static FormeSearchableController<T> of<T extends Object>(
      BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FormeSearchableController<T>>()!;
  }
}
