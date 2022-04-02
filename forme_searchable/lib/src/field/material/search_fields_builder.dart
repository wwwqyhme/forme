import 'package:flutter/cupertino.dart';
import 'package:forme/forme.dart';
import 'package:forme_searchable/forme_searchable.dart';

class FormeSearchableSearchFields<T extends Object>
    extends FormeSearchableField<T> {
  final Widget Function(FormeKey key, BuildContext context, VoidCallback? query)
      builder;

  const FormeSearchableSearchFields({Key? key, required this.builder})
      : super(key: key);
  @override
  FormeSearchableFieldState<T> createState() => _FormeSearchableFieldState<T>();
}

class _FormeSearchableFieldState<T extends Object>
    extends FormeSearchableFieldState<T> {
  final FormeKey formeKey = FormeKey();

  Map<String, Object?> get _condition =>
      formeKey.initialized ? formeKey.value : {};

  @override
  FormeSearchableSearchFields<T> get widget =>
      super.widget as FormeSearchableSearchFields<T>;

  @override
  Widget build(BuildContext context) {
    return widget.builder(formeKey, context, status.readOnly ? null : _search);
  }

  void _search() {
    super.search(FormeSearchCondition(_condition, 1));
  }
}
