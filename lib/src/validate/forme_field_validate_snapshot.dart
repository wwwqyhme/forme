import '../../forme.dart';

class FormeValidateSnapshot {
  final List<FormeFieldValidateSnapshot> _snapshots;

  FormeValidateSnapshot(this._snapshots);

  /// get first invalid field
  FormeFieldValidateSnapshot? get firstInvalidField {
    final Iterable<FormeFieldValidateSnapshot> iterable = invalidFields;
    if (iterable.isNotEmpty) {
      return iterable.first;
    }
  }

  /// all field is valid
  bool get isValid => _snapshots.every((element) => element.isValid);

  /// get all invalid fields
  Iterable<FormeFieldValidateSnapshot> get invalidFields =>
      _snapshots.where((element) => element.isInvalid);

  /// get validated data
  ///
  /// **when you want to submit a form after all validation passed,
  /// you should use form data from this method rather than [FormeKey.data] due to
  /// form data may be changed during async validation**
  ///
  /// use [isValueChangedDuringValidation] to check whether form data changed during async validation
  Map<String, dynamic> get value =>
      _snapshots.asMap().map<String, dynamic>((key, value) =>
          MapEntry<String, dynamic>(value.controller.name, value.value));

  /// whether form' value changed during validation
  bool get isValueChangedDuringValidation =>
      _snapshots.any((element) => element.isValueChangedDuringValidation);

  /// whether value changed after initialized
  ///
  /// **unlike [FormeController.isValueChanged] , this method is compare snapshot value and initialValue**
  bool get isValueChanged =>
      _snapshots.any((element) => element.isValueChanged);
}

/// used to hold  validate result and validated value
///
/// since value may be changed during async validation
class FormeFieldValidateSnapshot<T> {
  /// validated value , may not equals the field's value
  final T value;

  /// validate result , may not equals the field's current error if performed another validate during async validation
  final FormeFieldValidationInfo info;

  final int order;
  final FormeFieldController<T> controller;
  final bool isValueChangedDuringValidation;

  /// whether value changed after initialized
  ///
  /// **unlike [FormeFieldController.isValueChanged] , this method is compare snapshot value and initialValue**
  final bool isValueChanged;

  FormeFieldValidateSnapshot(
    this.value,
    this.info,
    this.order,
    this.controller,
    this.isValueChangedDuringValidation,
    this.isValueChanged,
  );

  /// whether field is invalid
  bool get isInvalid => info.isInvalid;
  bool get isValid => info.isValid;
}
