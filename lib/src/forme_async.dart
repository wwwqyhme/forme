import 'package:flutter/widgets.dart';

enum FormeAsyncOperationState {
  ///
  processing,

  ///
  success,

  ///
  error,
}

mixin FormeAsyncOperationHelper<E> {
  final Object _defaultKey = Object();
  final Map<Object, int> _genMap = {};

  @protected
  Future perform(Future<E> future, [Object? key]) async {
    final Object _key = key ?? _defaultKey;
    final int gen = _createGen(_key);
    onAsyncStateChanged(FormeAsyncOperationState.processing, key);
    E result;
    try {
      result = await future;
    } catch (e, stackTrace) {
      onError(e, stackTrace);
      return;
    }
    if (_compareGen(gen, _key)) {
      onAsyncStateChanged(FormeAsyncOperationState.success, key);
      onSuccess(result, key);
    }
  }

  @protected
  void onSuccess(E result, Object? key);

  @protected
  void onAsyncStateChanged(FormeAsyncOperationState state, Object? key);

  @protected
  void onError(Object error, StackTrace stackTrace) {
    debugPrintStack(stackTrace: stackTrace);
  }

  int _createGen(Object key) {
    _genMap[key] = _genMap.putIfAbsent(key, () => 0) + 1;
    return _genMap[key]!;
  }

  bool _compareGen(int gen, Object key) {
    return gen == _genMap[key];
  }
}
