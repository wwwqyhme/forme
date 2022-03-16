import 'package:flutter/widgets.dart';

import '../forme.dart';

/// share FormFieldController in sub tree
class FormeFieldScope extends InheritedWidget {
  final FormeFieldState state;

  const FormeFieldScope(this.state, Widget child, {Key? key})
      : super(child: child, key: key);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static FormeFieldState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FormeFieldScope>()?.state;
}
