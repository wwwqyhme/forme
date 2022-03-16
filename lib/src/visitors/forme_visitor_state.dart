import 'package:flutter/widgets.dart';

import '../forme_core.dart';
import '../forme_visitor.dart';

abstract class FormeVisitorState<T extends StatefulWidget> extends State<T>
    with FormeVisitor {
  late final FormeState state;

  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _inited = true;
      state = Forme.of(context)!;
      state.addVisitor(this);
    }
  }

  @override
  void dispose() {
    state.removeVisitor(this);
    super.dispose();
  }
}
