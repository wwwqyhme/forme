import 'package:flutter/widgets.dart';

/// forme validate error
@immutable
class FormeValidateError {
  final String? text;
  final FormeValidateState state;

  const FormeValidateError(this.text, this.state);

  bool get valid => state == FormeValidateState.valid;

  bool get invalid => state == FormeValidateState.invalid;

  bool get validating => state == FormeValidateState.validating;

  bool get fail => state == FormeValidateState.fail;

  @override
  int get hashCode => hashValues(text, state);

  @override
  bool operator ==(Object other) =>
      other is FormeValidateError && other.text == text && other.state == state;

  @override
  String toString() => 'state: $state , errorText: $text';
}

enum FormeValidateState {
  /// validator return null errorText
  valid,

  ///validator return nonnull result
  invalid,

  /// validator executing
  validating,

  /// may be an error occured when perform an async validate
  fail,
}
