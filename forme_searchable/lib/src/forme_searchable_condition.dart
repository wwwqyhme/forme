import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class FormeSearchCondition {
  final Map<String, Object?> condition;
  final int page;

  FormeSearchCondition(this.condition, this.page);

  T? getCondition<T>(String name) {
    final Object? o = condition[name];
    if (o == null) {
      return null;
    }
    return o as T;
  }

  @override
  int get hashCode => hashValues(condition, page);

  @override
  bool operator ==(Object other) =>
      other is FormeSearchCondition &&
      other.page == page &&
      mapEquals(other.condition, condition);
}
