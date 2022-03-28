import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'forme_searchable_condition.dart';

class SearchController extends ValueNotifier<FormeSearchCondition> {
  SearchController(value) : super(value);

  int get page => value.page;

  Map<String, Object?> get condition => value.condition;

  set page(int page) => value = FormeSearchCondition(condition, page);

  set condition(Map<String, Object?> condition) =>
      value = FormeSearchCondition(condition, page);
}
