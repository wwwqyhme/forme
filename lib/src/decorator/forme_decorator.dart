import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';

abstract class FormeFieldDecorator<T> {
  Widget build(
    FormeFieldController<T> controller,
    Widget child,
  );
}
