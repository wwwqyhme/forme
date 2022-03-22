import 'package:flutter/widgets.dart';

import '../forme_core.dart';
import '../forme_visitor.dart';

abstract class FormeVisitorState<T extends StatefulWidget> extends State<T>
    with FormeVisitor {
  FormeState? _state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final FormeState currentForm = Forme.of(context)!;
    if (currentForm != _state) {
      _state?.removeVisitor(this);
      _state = currentForm;
      _state!.addVisitor(this);
      onInitialed(_state!);
    }
  }

  /// called when widget is initialed
  ///
  /// this method is called in [didChangeDependencies] , so there's no need to call [setState]
  void onInitialed(FormeState form);

  @override
  void dispose() {
    _state?.removeVisitor(this);
    super.dispose();
  }
}
