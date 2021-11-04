import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class FormeMountedValueNotifier<T> extends ValueNotifier<T> {
  final State state;

  FormeMountedValueNotifier(T value, this.state) : super(value);

  @override
  set value(T newValue) {
    if (state.mounted) {
      super.value = newValue;
    }
  }

  @override
  void addListener(VoidCallback listener) {
    if (state.mounted) {
      super.addListener(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    if (state.mounted) {
      super.removeListener(listener);
    }
  }
}

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
