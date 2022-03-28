import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';
import 'package:forme_searchable/forme_searchable.dart';

/// ``` Dart
/// try{
///   onQueryProcessing();
///   onQuerySuccess();
/// } catch(e,trace) {
///   onQueryFail();
/// }
/// ```
///
mixin FormeSearchableReader<T extends Object> {
  /// field status changed
  void onStatusChanged(FormeFieldChangedStatus<List<T>> status);

  /// in query
  void onQueryProcessing(FormeSearchCondition condition);

  ///
  void onQuerySuccess(
      FormeSearchCondition condition, FormeSearchablePageResult<T> result);

  /// an error occured when query
  void onQueryFail(
      FormeSearchCondition condition, Object error, StackTrace trace);

  /// field reset
  void onReset();

  /// when focusNode changed
  void onFocusNodeChanged(FocusNode node);
}
