import 'package:flutter/cupertino.dart';
import 'package:forme_searchable/forme_searchable.dart';
import 'package:forme_searchable/src/forme_searchable_reader.dart';

class FormeSearchableWriter<T extends Object> {
  final OnChanged<T> onChanged;
  FormeSearchableWriter({required this.onChanged});

  set value(List<T> newValue) => onChanged.onValueChanged?.call(newValue);
  set page(int page) => onChanged.onPageChanged?.call(page);
  set condition(FormeSearchCondition condition) =>
      onChanged.onConditionChanged?.call(condition);

  void addReader(FormeSearchableReader<T> reader) =>
      onChanged.onReaderAdd?.call(reader);
  void removeReader(FormeSearchableReader<T> reader) =>
      onChanged.onReaderRemove?.call(reader);
}

class OnChanged<T extends Object> {
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<FormeSearchCondition>? onConditionChanged;
  final ValueChanged<List<T>>? onValueChanged;
  final ValueChanged<FormeSearchableReader<T>>? onReaderAdd;
  final ValueChanged<FormeSearchableReader<T>>? onReaderRemove;

  OnChanged({
    this.onPageChanged,
    this.onConditionChanged,
    this.onValueChanged,
    this.onReaderAdd,
    this.onReaderRemove,
  });
}
