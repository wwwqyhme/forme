import 'package:forme/forme.dart';

mixin FormeVisitor {
  void onFieldsRegistered(
    FormeController form,
    List<FormeFieldController> fields,
  );

  void onFieldsStatusChanged(
    FormeController form,
    FormeFieldController field,
    FormeFieldStatus oldStatus,
    FormeFieldStatus newStatus,
  );

  void onFieldsUnregistered(
    FormeController form,
    List<String> names,
  );
}
