import 'package:forme/forme.dart';

class FormeFieldValidationContext<T> {
  /// current validate field
  final FormeFieldState<T> field;

  /// current form
  final FormeState? form;

  /// latest successful validation value
  final T? latestSuccessfulValidationValue;
  final T currentValidateValue;
  final T? validatingValue;

  /// value comparator
  ///
  /// use this to compare [latestSuccessfulValidationValue] & [currentValidateValue]
  final FormeValueComparator<T> comparator;

  FormeFieldValidation get validation => field.validation;

  const FormeFieldValidationContext(
      this.field,
      this.form,
      this.latestSuccessfulValidationValue,
      this.currentValidateValue,
      this.validatingValue,
      this.comparator);
}
