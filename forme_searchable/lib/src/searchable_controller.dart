import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class SearchController extends ValueNotifier<SearchCondition> {
  SearchController(value) : super(value);

  int get page => value.page;

  Map<String, Object?> get condition => value.condition;

  set page(int page) => value = SearchCondition(condition, page);

  set condition(Map<String, Object?> condition) =>
      value = SearchCondition(condition, page);
}

class SearchCondition {
  final Map<String, Object?> condition;
  final int page;

  SearchCondition(this.condition, this.page);

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
      other is SearchCondition &&
      other.page == page &&
      mapEquals(other.condition, condition);
}
