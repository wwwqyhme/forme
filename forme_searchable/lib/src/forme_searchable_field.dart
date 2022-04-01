import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';
import 'package:forme_searchable/forme_searchable.dart';

import 'forme_searchable_listener.dart';
import 'forme_searchable_controller.dart';
import 'forme_searchable_state.dart';

abstract class FormeSearchableField<T extends Object> extends StatefulWidget {
  const FormeSearchableField({Key? key}) : super(key: key);

  @override
  FormeSearchableFieldState<T> createState();
}

abstract class FormeSearchableFieldState<T extends Object>
    extends State<FormeSearchableField<T>> with FormeSearchableListener<T> {
  FormeSearchableController<T>? _controller;
  FormeSearchablePageResult<T>? _result;
  FormeSearchablePageResult<T>? _lastNonnullResult;

  FormeSearchableStatus<T> get status => _controller!.state.status;

  /// get focusNode
  FocusNode get focusNode => _controller!.state.focusNode;

  /// get latest query result
  FormeSearchablePageResult<T>? get result => _result;

  /// get latest nonull result
  FormeSearchablePageResult<T>? get lastNonnullResult => _lastNonnullResult;
  bool _isProcessing = false;

  /// whether latest query has result or not
  bool get hasResult => _result != null;

  /// whether a query is in processing
  bool get isProcessing => _isProcessing;

  Object? _error;
  StackTrace? _stackTrace;

  Object? get error => _error;
  StackTrace? get stackTrace => _stackTrace;

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
  void onFocusNodeChanged(FocusNode node) {
    setState(() {});
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
  void onQuerySuccess(
      FormeSearchCondition condition, FormeSearchablePageResult<T> result) {
    _isProcessing = false;
    _result = result;
    _lastNonnullResult = _result;
    _error = null;
    _stackTrace = null;
    onQueryComplete(condition);
  }

  @override
  @mustCallSuper
  void onQueryFail(
      FormeSearchCondition condition, Object error, StackTrace trace) {
    _isProcessing = false;
    _result = null;
    _error = error;
    _stackTrace = trace;
    onQueryComplete(condition);
  }

  @override
  @mustCallSuper
  void onQueryProcessing(FormeSearchCondition condition) {
    _isProcessing = true;
    _result = null;
    _error = null;
    _stackTrace = null;
    onQueryComplete(condition);
  }

  @override
  @mustCallSuper
  void onReset() {
    _result = null;
    _lastNonnullResult = null;
    _error = null;
    _stackTrace = null;
  }

  void onQueryComplete(FormeSearchCondition condition) {}

  Widget inherit(Widget child) {
    return FormeSearchableController<T>(_controller!.state, child: child);
  }
}
