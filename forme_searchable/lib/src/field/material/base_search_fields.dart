import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import '../../forme_searchable_condition.dart';
import '../../forme_searchable_field.dart';

class BaseSearchFields<T extends Object> extends FormeSearchableField<T> {
  final InputDecoration? decoration;
  final bool performSearchAfterInitState;
  const BaseSearchFields({
    this.decoration = const InputDecoration(),
    this.performSearchAfterInitState = true,
    Key? key,
  }) : super(key: key);
  @override
  FormeSearchableFieldState<T> createState() => _BaseSearchFieldsState<T>();
}

class _BaseSearchFieldsState<T extends Object>
    extends FormeSearchableFieldState<T> {
  bool get readOnly => status.readOnly;

  final TextEditingController _controller = TextEditingController();

  @override
  BaseSearchFields<T> get widget => super.widget as BaseSearchFields<T>;
  final FormeKey formeKey = FormeKey();
  Map<String, Object?> get _condition =>
      formeKey.initialized ? formeKey.value : {};

  @override
  void initState() {
    super.initState();
    if (widget.performSearchAfterInitState) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        _search();
      });
    }
  }

  @override
  void dispose() {
    cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Forme(
        key: formeKey,
        child: FormeField<String>(
          name: 'query',
          initialValue: '',
          onStatusChanged: (state, status) {
            if (status.isValueChanged) {
              _search();
            }
          },
          builder: (state) {
            return TextField(
              autofocus: true,
              enabled: status.enabled,
              readOnly: readOnly,
              controller: _controller,
              decoration:
                  (widget.decoration ?? const InputDecoration()).copyWith(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: readOnly
                          ? null
                          : IconButton(
                              onPressed: () {
                                _controller.text = '';
                                state.value = '';
                              },
                              icon: const Icon(Icons.clear))),
              onChanged: (String value) {
                state.value = value;
              },
              onSubmitted: (String value) {
                state.value = value;
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void onQueryFail(
      FormeSearchCondition condition, Object error, StackTrace trace) {
    super.onQueryFail(condition, error, trace);
    debugPrint('$error');
    debugPrintStack(stackTrace: trace);
  }

  @override
  void onReset() {
    super.onReset();
    _controller.text = '';
  }

  void _search({bool withDebounce = true}) {
    if (readOnly) {
      return;
    }
    search(FormeSearchCondition(_condition, 1), withDebounce);
  }
}
