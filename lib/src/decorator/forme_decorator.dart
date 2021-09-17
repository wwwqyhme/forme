import 'package:flutter/widgets.dart';
import '../../forme.dart';

mixin FormeFieldDecorator<T> {
  Widget build(
    FormeFieldController<T> controller,
    Widget child,
  );
}
