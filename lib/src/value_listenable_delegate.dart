import 'package:flutter/foundation.dart';

class ValueListenableDelegate<T> extends ValueListenable<T> {
  final ValueNotifier<T> _delegate;

  const ValueListenableDelegate(this._delegate);

  @override
  void addListener(VoidCallback listener) => _delegate.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _delegate.removeListener(listener);

  @override
  T get value => _delegate.value;
}
