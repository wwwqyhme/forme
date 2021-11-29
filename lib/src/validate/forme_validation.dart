import 'package:flutter/widgets.dart';

/// forme validate error
@immutable
class FormeFieldValidation {
  final String? error;
  final FormeValidationState state;

  const FormeFieldValidation(this.error, this.state);

  static FormeFieldValidation unnecessary =
      const FormeFieldValidation(null, FormeValidationState.unnecessary);
  static FormeFieldValidation valid =
      const FormeFieldValidation(null, FormeValidationState.valid);
  static FormeFieldValidation validating =
      const FormeFieldValidation(null, FormeValidationState.validating);
  static FormeFieldValidation waiting =
      const FormeFieldValidation(null, FormeValidationState.waiting);
  static FormeFieldValidation fail =
      const FormeFieldValidation(null, FormeValidationState.fail);

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
      other is FormeFieldValidation &&
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
class FormeValidation {
  final Map<String, FormeFieldValidation> _validations;

  const FormeValidation(this._validations);

  /// whether form has any fields
  bool get isEmpty => _validations.isEmpty;

  /// form has no fields or  all fields is valid or no validator or no fields in form
  bool get isValidOrUnnecessaryOrEmpty =>
      isEmpty ||
      _validations.values
          .every((element) => element.isValid || element.isUnnecessary);

  /// any field is invalid
  bool get isInvalid =>
      _validations.values.isNotEmpty &&
      _validations.values.any((element) => element.isInvalid);

  /// any field is validating
  bool get isValidating =>
      _validations.values.isNotEmpty &&
      _validations.values.any((element) => element.isValidating);

  /// any field validate failed
  bool get isFail =>
      _validations.values.isNotEmpty &&
      _validations.values.any((element) => element.isFail);

  /// get all fields validations
  Map<String, FormeFieldValidation> get validations =>
      Map.unmodifiable(_validations);
}
