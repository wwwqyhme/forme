import 'package:flutter/widgets.dart';

/// forme validate error
@immutable
class FormeFieldValidationInfo {
  final String? error;
  final FormeValidationState state;

  const FormeFieldValidationInfo(this.error, this.state);

  bool get isValid => state == FormeValidationState.valid;

  bool get isInvalid => state == FormeValidationState.invalid;

  bool get isValidating => state == FormeValidationState.validating;

  bool get isFail => state == FormeValidationState.fail;

  bool get isUnnecessary => state == FormeValidationState.unnecessary;

  bool get isWaiting => state == FormeValidationState.waiting;

  @override
  int get hashCode => hashValues(error, state);

  @override
  bool operator ==(Object other) =>
      other is FormeFieldValidationInfo &&
      other.error == error &&
      other.state == state;

  @override
  String toString() => 'state: $state , errorText: $error';
}

enum FormeValidationState {
  /// validator return null errorText
  valid,

  ///validator return nonnull result
  invalid,

  /// async validator executing
  validating,

  /// an error occurred when performing an async validation
  fail,

  /// field has a validator but not performed a validation yet or reset after validate
  waiting,

  /// field has no validator at all , no need to validate
  unnecessary,
}

@immutable
class FormeValidationInfo {
  final Map<String, FormeFieldValidationInfo> _infos;

  const FormeValidationInfo(this._infos);

  /// all fields is valid or no validator
  bool get isValidOrUnnecessary => _infos.values
      .every((element) => element.isValid || element.isUnnecessary);

  /// any field is invalid
  bool get isInvalid => _infos.values.any((element) => element.isInvalid);

  /// any field is validating
  bool get isValidating => _infos.values.any((element) => element.isValidating);

  /// any field validate failed
  bool get isFail => _infos.values.any((element) => element.isFail);

  /// get validation info of field by field name
  FormeFieldValidationInfo? getValidationInfo(String name) => _infos[name];
}
