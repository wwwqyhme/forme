import 'package:flutter/widgets.dart';
import '../../forme.dart';

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

@immutable
class FormeValidateErrors {
  final Map<String, FormeFieldController<dynamic>> _fields;

  const FormeValidateErrors(this._fields);

  /// all fields is valid or no validator
  bool get valid => _fields.values.every((element) {
        return (element.error != null && element.error!.valid) ||
            !element.hasValidator;
      });

  /// any field is invalid
  bool get invalid => _fields.values
      .any((element) => element.error != null && element.error!.invalid);

  /// any field is validating
  bool get validating => _fields.values
      .any((element) => element.error != null && element.error!.validating);

  /// any field validate failed
  bool get fail => _fields.values
      .any((element) => element.error != null && element.error!.fail);
}
