import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../forme.dart';

class ValueListenableBuilder3<A, B, C> extends StatelessWidget {
  const ValueListenableBuilder3(
    this.first,
    this.second,
    this.third, {
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final ValueListenable<C> third;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, C c, Widget? child)
      builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (_, a, __) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, __) {
            return ValueListenableBuilder<C>(
              valueListenable: third,
              builder: (context, c, __) {
                return builder(context, a, b, c, child);
              },
            );
          },
        );
      },
    );
  }
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  const ValueListenableBuilder2(
    this.first,
    this.second, {
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (_, a, __) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, __) {
            return builder(context, a, b, child);
          },
        );
      },
    );
  }
}

class FormeFieldValidationInfoBuilder<T> extends StatelessWidget {
  const FormeFieldValidationInfoBuilder({
    Key? key,
    this.name,
    required this.builder,
    this.child,
  }) : super(key: key);

  final String? name;
  final Widget? child;
  final Widget Function(
      BuildContext context,
      FormeFieldController<T>? controller,
      FormeFieldValidationInfo? info,
      Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    final FormeFieldController<T>? fieldController = FormeField.of<T>(context);

    if (name == null && fieldController == null) {
      throw Exception(
          'this widget must be placed in FormeField , otherwise you must specific  a field name');
    }

    if (fieldController != null &&
        (name == null || fieldController.name == name)) {
      return ValueListenableBuilder<FormeFieldValidationInfo>(
          valueListenable: fieldController.validationInfoListenable,
          builder: (context, info, child) {
            return builder(context, fieldController, info, child);
          });
    }

    final FormeController? controller = Forme.of(context);

    if (controller == null) {
      throw Exception('this widget must be placed in FormeField or Forme');
    }

    return ValueListenableBuilder<FormeFieldController<T>?>(
        valueListenable: controller.fieldListenable<T>(name!),
        builder: (context, controller, child) {
          if (controller == null) {
            return builder(context, null, null, child);
          }
          return ValueListenableBuilder<FormeFieldValidationInfo>(
              valueListenable: controller.validationInfoListenable,
              builder: (context, info, child) {
                return builder(context, controller, info, child);
              });
        });
  }
}
