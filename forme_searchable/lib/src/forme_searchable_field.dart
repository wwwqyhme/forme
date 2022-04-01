import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';

import 'forme_searchable_condition.dart';
import 'forme_searchable_listener.dart';
import 'forme_searchable_controller.dart';
import 'forme_searchable_result.dart';
import 'forme_searchable_state.dart';

abstract class FormeSearchableField<T extends Object> extends StatefulWidget {
  const FormeSearchableField({Key? key}) : super(key: key);

  @override
  FormeSearchableFieldState<T> createState();
}

abstract class FormeSearchableFieldState<T extends Object>
    extends State<FormeSearchableField<T>> with FormeSearchableListener<T> {
  FormeSearchableController<T>? _controller;

  FormeSearchableStatus<T> get status => _controller!.state.status;

  /// get focusNode
  FocusNode get focusNode => _controller!.state.focusNode;

  /// get latest query result
  FormeSearchablePageResult<T>? get result => status.result;

  /// whether latest query has result or not
  bool get hasResult => status.hasResult;

  /// whether a query is in processing
  bool get isProcessing => status.isProcessing;
  Object? get error => status.error;
  StackTrace? get stackTrace => status.stackTrace;
  bool get hasError => status.hasError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller?.state.removeListener(this);
    _controller = FormeSearchableController.of<T>(context);
    _controller!.state.addListener(this);
  }

  @override
  void dispose() {
    _controller?.state.removeListener(this);
    super.dispose();
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<List<T>> status) {
    setState(() {});
  }

  @override
  void onConditionChangeStart(FormeSearchCondition condition) {}

  @override
  void onPageChangeStart(FormeSearchCondition condition) {}

  void search(FormeSearchCondition condition, [bool debounce = true]) =>
      _controller?.state.search(condition, debounce);

  void goToPage(int page) => _controller?.state.goToPage(page);

  void reload() => _controller?.state.reload();

  set value(List<T> value) => _controller!.state.value = value;

  void cancel() {
    _controller?.state.cancel();
  }

  @override
  @mustCallSuper
  void onQueryCancelled(FormeSearchCondition condition) {}

  @override
  @mustCallSuper
  void onQuerySuccess(
      FormeSearchCondition condition, FormeSearchablePageResult<T> result) {}

  @override
  @mustCallSuper
  void onQueryFail(
      FormeSearchCondition condition, Object error, StackTrace trace) {}

  @override
  @mustCallSuper
  void onQueryProcessing(FormeSearchCondition condition) {}

  @override
  @mustCallSuper
  void onReset() {}

  Widget inherit(Widget child) {
    return FormeSearchableController<T>(_controller!.state, child: child);
  }
}
