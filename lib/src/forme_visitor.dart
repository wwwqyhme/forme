import 'package:forme/forme.dart';

mixin FormeVisitor {
  void onFieldsRegistered(
    FormeState form,
    List<FormeFieldState> fields,
  );

  void onFieldStatusChanged(
    FormeState form,
    FormeFieldState field,
    FormeFieldChangedStatus status,
  );

  void onFieldsUnregistered(
    FormeState form,
    List<FormeFieldState> fields,
  );
}

mixin FormeFieldVisitor<T extends Object?> {
  void onRegistered(
    FormeState form,
    FormeFieldState<T> field,
  );

  void onStatusChanged(
    FormeState? form,
    FormeFieldState<T> field,
    FormeFieldChangedStatus<T> status,
  );

  void onUnregistered(
    FormeState form,
    FormeFieldState<T> field,
  );
}
