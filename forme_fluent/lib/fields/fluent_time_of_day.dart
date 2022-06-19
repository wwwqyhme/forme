import 'package:flutter/widgets.dart';

@immutable
class FluentTimeOfDay {
  final int hour;
  final int minute;
  const FluentTimeOfDay({required this.hour, required this.minute});

  FluentTimeOfDay.fromDateTime(DateTime time)
      : hour = time.hour,
        minute = time.minute;

  DateTime toDateTime() {
    final DateTime current = DateTime.now();
    return DateTime(current.year, current.month, current.day, hour, minute);
  }

  @override
  bool operator ==(Object other) {
    return other is FluentTimeOfDay &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() {
    String _addLeadingZeroIfNeeded(int value) {
      if (value < 10) {
        return '0$value';
      }
      return value.toString();
    }

    final String hourLabel = _addLeadingZeroIfNeeded(hour);
    final String minuteLabel = _addLeadingZeroIfNeeded(minute);

    return '$FluentTimeOfDay($hourLabel:$minuteLabel)';
  }
}
