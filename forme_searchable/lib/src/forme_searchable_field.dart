import 'package:flutter/widgets.dart';
import 'package:forme/forme.dart';
import 'package:forme_searchable/forme_searchable.dart';

import 'forme_searchable_reader.dart';
import 'forme_searchable_controller.dart';

abstract class FormeSearchableField<T extends Object> extends StatefulWidget {
  const FormeSearchableField({Key? key}) : super(key: key);

  @override
  FormeSearchableFieldState<T> createState();
}

abstract class FormeSearchableFieldState<T extends Object>
    extends State<FormeSearchableField<T>> with FormeSearchableReader<T> {
  FormeSearchableController<T>? _controller;
  late FormeFieldStatus<List<T>> _status;
  late FocusNode _focusNode;
  FormeSearchablePageResult<T>? _result;
  FormeSearchablePageResult<T>? _lastNonnullResult;

  FormeFieldStatus<List<T>> get status => _status;
  FocusNode get focusNode => _focusNode;
  FormeSearchablePageResult<T>? get result => _result;
  FormeSearchablePageResult<T>? get lastNonnullResult => _lastNonnullResult;
  bool _isProcessing = false;

  bool get hasResult => _result != null;
  bool get isProcessing => _isProcessing;

  FormeSearchCondition? _cache;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller?.writer.removeReader(this);
    _controller = FormeSearchableController.of<T>(context);
    _status = _controller!.status;
    _focusNode = _controller!.focusNode;
    _controller!.writer.addReader(this);
  }

  @override
  void onFocusNodeChanged(FocusNode node) {
    setState(() {
      _focusNode = node;
    });
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<List<T>> status) {
    setState(() {
      _status = status;
    });
  }

  set page(int page) {
    if (_cache?.page == page) {
      return;
    }
    _controller!.writer.page = page;
  }

  set condition(FormeSearchCondition condition) {
    if (condition == _cache) {
      return;
    }
    _controller!.writer.condition = condition;
  }

  set value(List<T> value) => _controller!.writer.value = value;

  @override
  @mustCallSuper
  void onQuerySuccess(
      FormeSearchCondition condition, FormeSearchablePageResult<T> result) {
    _isProcessing = false;
    _result = result;
    _lastNonnullResult = _result;
    _cache = condition;
    onQueryComplete(condition);
  }

  @override
  @mustCallSuper
  void onQueryFail(
      FormeSearchCondition condition, Object error, StackTrace trace) {
    _isProcessing = false;
    _result = null;
    onQueryComplete(condition);
  }

  @override
  @mustCallSuper
  void onQueryProcessing(FormeSearchCondition condition) {
    _isProcessing = true;
    _result = null;
    onQueryComplete(condition);
  }

  void onQueryComplete(FormeSearchCondition condition) {}
}
