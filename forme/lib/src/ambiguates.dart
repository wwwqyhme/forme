import 'package:flutter/scheduler.dart';

class Ambiguates {
  /// This allows a value of type T or T?
  /// to be treated as a value of type T?.
  ///
  /// We use this so that APIs that have become
  /// non-nullable can still be used with `!` and `?`
  /// to support older versions of the API as well.
  static T? _ambiguate<T>(T? value) => value;

  static SchedulerBinding get schedulerBinding =>
      _ambiguate(SchedulerBinding.instance)!;
}
