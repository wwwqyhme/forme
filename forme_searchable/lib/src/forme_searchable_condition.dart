import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class FormeSearchCondition {
  final Map<String, Object?> filter;
  final int page;

  FormeSearchCondition(this.filter, this.page);

  T? getFilter<T>(String name) {
    final Object? o = filter[name];
    if (o == null) {
      return null;
    }
    return o as T;
  }

  @override
  int get hashCode => hashValues(filter, page);

  @override
  bool operator ==(Object other) =>
      other is FormeSearchCondition &&
      other.page == page &&
      mapEquals(other.filter, filter);
}
