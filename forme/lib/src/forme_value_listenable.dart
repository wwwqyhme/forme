import 'package:flutter/foundation.dart';

class FormeMountedValueNotifier<T> extends ValueNotifier<T> {
  bool _disposed = false;

  bool get disposed => _disposed;

  FormeMountedValueNotifier(T value) : super(value);

  @override
  set value(T newValue) {
    if (!_disposed) {
      super.value = newValue;
    }
  }

  @override
  void addListener(VoidCallback listener) {
    if (!_disposed) {
      super.addListener(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    if (!_disposed) {
      super.removeListener(listener);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
  }
}

class FormeValueListenableDelegate<T> extends ValueListenable<T> {
  final ValueListenable<T> _delegate;

  const FormeValueListenableDelegate(this._delegate);

  @override
  void addListener(VoidCallback listener) => _delegate.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _delegate.removeListener(listener);

  @override
  T get value => _delegate.value;
}
