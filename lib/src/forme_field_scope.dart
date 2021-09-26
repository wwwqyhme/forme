import 'package:flutter/widgets.dart';

import '../forme.dart';

/// share FormFieldController in sub tree
class FormeFieldScope extends InheritedWidget {
  final FormeFieldController controller;

  const FormeFieldScope(this.controller, Widget child, {Key? key})
      : super(child: child, key: key);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static FormeFieldController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FormeFieldScope>()?.controller;
}
