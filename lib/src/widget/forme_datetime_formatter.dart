import 'package:flutter/material.dart';

import 'forme_datetime_type.dart';

typedef FormeDateTimeFormatter = String Function(
    FormeDateTimeType type, DateTime dateTime);

typedef FormeDateRangeFormatter = String Function(DateTimeRange range);

String defaultDateTimeFormatter(FormeDateTimeType type, DateTime dateTime) {
  switch (type) {
    case FormeDateTimeType.date:
      return '${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    case FormeDateTimeType.dateTime:
      return '${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

String defaultDateRangeFormatter(DateTimeRange range) =>
    '${defaultDateTimeFormatter(FormeDateTimeType.date, range.start)} ~ ${defaultDateTimeFormatter(FormeDateTimeType.date, range.end)}';
