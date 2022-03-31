import 'package:flutter/widgets.dart';

import 'forme_searchable_state.dart';

class FormeSearchableController<T extends Object> extends InheritedWidget {
  final FormeSearchableState<T> state;

  const FormeSearchableController(
    this.state, {
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
