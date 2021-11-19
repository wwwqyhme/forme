import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../../forme.dart';

import 'cupertinos.dart';

class FormeCupertinoDateTimeField extends FormeField<DateTime?> {
  final FormeDateTimeFormatter? formatter;
  final FormeDateTimeType type;
  final DateTime? maximumDate;
  final DateTime? minimumDate;
  final int? maximumYear;
  final int minimumYear;
  final int minuteInterval;

  FormeCupertinoDateTimeField({
    this.formatter,
    this.type = FormeDateTimeType.date,
    this.maximumDate,
    this.minimumDate,
    DateTime? initialValue,
    required String name,
    bool readOnly = false,
    bool use24hFormat = false,
    this.minimumYear = 1,
    this.maximumYear,
    this.minuteInterval = 1,
    ImageFilter? filter,
    Color barrierColor = kCupertinoModalBarrierColor,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    bool? semanticsDismissible,
    RouteSettings? routeSettings,
    VoidCallback? beforeOpen,
    VoidCallback? afterClose,
    Color? backgroundColor,
    double height = 216,
    Widget? confirmWidget,
    Widget? backWidget,
    Widget? cancelWidget,
    Key? key,
    FormeFieldDecorator<DateTime?>? decorator,
    int? maxLines = 1,
    int? order,
    BoxDecoration? decoration = defaultTextFieldDecoration,
    EdgeInsetsGeometry padding = const EdgeInsets.all(6.0),
    String? placeholder,
    TextStyle placeholderStyle = const TextStyle(
      fontWeight: FontWeight.w400,
      color: CupertinoColors.placeholderText,
    ),
    Widget? prefix,
    OverlayVisibilityMode prefixMode = OverlayVisibilityMode.always,
    Widget? suffix,
    OverlayVisibilityMode suffixMode = OverlayVisibilityMode.always,
    OverlayVisibilityMode clearButtonMode = OverlayVisibilityMode.never,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign textAlign = TextAlign.start,
    ToolbarOptions? toolbarOptions,
    TextAlignVertical? textAlignVertical,
    bool? showCursor,
    bool autofocus = false,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    int? minLines,
    bool expands = false,
    int? maxLength,
    MaxLengthEnforcement? maxLengthEnforcement,
    VoidCallback? onEditingComplete,
    bool enabled = true,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius cursorRadius = const Radius.circular(2.0),
    Color? cursorColor,
    BoxHeightStyle selectionHeightStyle = BoxHeightStyle.tight,
    BoxWidthStyle selectionWidthStyle = BoxWidthStyle.tight,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    TextSelectionControls? selectionControls,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollController? scrollController,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    bool borderless = false,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<DateTime?>? onValueChanged,
    FormeFocusChanged<DateTime?>? onFocusChanged,
    FormeFieldValidationChanged<DateTime?>? onValidationChanged,
    FormeFieldInitialed<DateTime?>? onInitialed,
    FormeFieldSetter<DateTime?>? onSaved,
    FormeValidator<DateTime?>? validator,
    FormeAsyncValidator<DateTime?>? asyncValidator,
    bool registrable = true,
    bool enableIMEPersonalizedLearning = true,
  }) : super(
          registrable: registrable,
          readOnly: readOnly,
          enabled: enabled,
          decorator: decorator,
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          autovalidateMode: autovalidateMode,
          onValueChanged: onValueChanged,
          onFocusChanged: onFocusChanged,
          onValidationChanged: onValidationChanged,
          onInitialed: onInitialed,
          onSaved: onSaved,
          validator: validator,
          asyncValidator: asyncValidator,
          order: order,
          key: key,
          name: name,
          initialValue: initialValue,
          builder: (state) {
            final bool readOnly = state.readOnly;
            final bool enabled = state.enabled;
            final FocusNode focusNode = state.focusNode;
            final TextEditingController textEditingController =
                (state as _FormeCupertinoDateFieldState).textEditingController;

            void pickTime() {
              beforeOpen?.call();
              showCupertinoModalPopup<dynamic>(
                context: state.context,
                builder: (context) => _PickerSheet(
                  height: height,
                  confirmWidget: confirmWidget,
                  backWidget: backWidget,
                  cancelWidget: cancelWidget,
                  backgroundColor: backgroundColor,
                  maximumDate: maximumDate,
                  minimumDate: minimumDate,
                  minimumYear: minimumYear,
                  maximumYear: maximumYear,
                  minuteInterval: minuteInterval,
                  use24hFormat: use24hFormat,
                  type: type,
                  initialDateTime: state.initialDateTime,
                  onChanged: (datetime) {
                    Navigator.of(context).pop();
                    state.didChange(datetime);
                  },
                ),
                barrierColor: barrierColor,
                filter: filter,
                barrierDismissible: barrierDismissible,
                useRootNavigator: useRootNavigator,
                semanticsDismissible: semanticsDismissible,
                routeSettings: routeSettings,
              ).whenComplete(() {
                state.focusNode.requestFocus();
                afterClose?.call();
              });
            }

            return buildCupertinoTextField(
              enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
              enabled: enabled,
              focusNode: focusNode,
              textEditingController: textEditingController,
              decoration: decoration,
              padding: padding,
              placeholder: placeholder,
              placeholderStyle: placeholderStyle,
              prefix: prefix,
              prefixMode: prefixMode,
              suffix: suffix,
              suffixMode: suffixMode,
              clearButtonMode: clearButtonMode,
              textInputAction: textInputAction,
              textCapitalization: textCapitalization,
              style: style,
              strutStyle: strutStyle,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              readOnly: true,
              toolbarOptions: toolbarOptions,
              showCursor: showCursor,
              autofocus: autofocus,
              obscuringCharacter: obscuringCharacter,
              obscureText: obscureText,
              autocorrect: autocorrect,
              smartDashesType: smartDashesType,
              smartQuotesType: smartQuotesType,
              enableSuggestions: enableSuggestions,
              maxLines: maxLines,
              minLines: minLines,
              expands: expands,
              maxLength: maxLength,
              maxLengthEnforcement: maxLengthEnforcement,
              onEditingComplete: onEditingComplete,
              cursorWidth: cursorWidth,
              cursorHeight: cursorHeight,
              cursorRadius: cursorRadius,
              cursorColor: cursorColor,
              selectionHeightStyle: selectionHeightStyle,
              selectionWidthStyle: selectionWidthStyle,
              keyboardAppearance: keyboardAppearance,
              scrollPadding: scrollPadding,
              dragStartBehavior: dragStartBehavior,
              enableInteractiveSelection: enableInteractiveSelection,
              selectionControls: selectionControls,
              onTap: readOnly ? null : pickTime,
              scrollController: scrollController,
              scrollPhysics: scrollPhysics,
              autofillHints: readOnly ? null : autofillHints,
              borderless: borderless,
            );
          },
        );

  @override
  _FormeCupertinoDateFieldState createState() =>
      _FormeCupertinoDateFieldState();
}

class _FormeCupertinoDateFieldState extends FormeFieldState<DateTime?> {
  late final TextEditingController textEditingController;

  @override
  FormeCupertinoDateTimeField get widget =>
      super.widget as FormeCupertinoDateTimeField;

  FormeDateTimeFormatter get _formatter =>
      widget.formatter ?? defaultDateTimeFormatter;

  DateTime get initialDateTime {
    if (value != null) {
      return value!;
    }
    final DateTime now = DateTime.now();
    DateTime date =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    if (widget.maximumDate != null && widget.maximumDate!.isBefore(date)) {
      date = widget.maximumDate!;
    }
    if (widget.minimumDate != null && widget.minimumDate!.isAfter(date)) {
      date = widget.minimumDate!;
    }
    if (widget.maximumYear != null && date.year > widget.maximumYear!) {
      date = DateTime(
          widget.maximumYear!, date.month, date.day, date.hour, date.minute);
    }
    if (date.year < widget.minimumYear) {
      date = DateTime(
          widget.minimumYear, date.month, date.day, date.hour, date.minute);
    }
    if (widget.minuteInterval != 1 &&
        date.minute % widget.minuteInterval != 0) {
      date = DateTime(date.year, date.month, date.day, date.hour);
    }
    switch (widget.type) {
      case FormeDateTimeType.date:
        return DateTime(date.year, date.month, date.day);
      case FormeDateTimeType.dateTime:
        return date;
    }
  }

  @override
  void afterInitiation() {
    super.afterInitiation();
    textEditingController = TextEditingController(
        text: value == null ? '' : _formatter(widget.type, value!));
  }

  @override
  void onValueChanged(DateTime? value) {
    textEditingController.text =
        value == null ? '' : _formatter(widget.type, value);
  }

  @override
  DateTime? get value {
    final DateTime? value = super.value;
    if (value == null) {
      return null;
    }
    return simple(value);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void clearValue() {
    setValue(null);
    textEditingController.text = '';
  }

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<DateTime?> oldWidget) {
    if (value == null) {
      return;
    }
    if (widget.maximumDate != null && widget.maximumDate!.isBefore(value!)) {
      clearValue();
    }
    if (value != null &&
        widget.minimumDate != null &&
        widget.minimumDate!.isAfter(value!)) {
      clearValue();
    }
    if (value != null &&
        widget.maximumYear != null &&
        widget.maximumYear! < value!.year) {
      clearValue();
    }
    if (value != null && widget.minimumYear > value!.year) {
      clearValue();
    }
    if (value != null &&
        widget.minuteInterval != 1 &&
        value!.minute % widget.minuteInterval != 0) {
      setValue(DateTime(value!.year, value!.month, value!.day, value!.hour));
      textEditingController.text =
          (widget.formatter ?? defaultDateTimeFormatter)(widget.type, value!);
    }
    if (value != null &&
        (widget.formatter != null ||
            widget.type != (oldWidget as FormeCupertinoDateTimeField).type)) {
      textEditingController.text =
          (widget.formatter ?? defaultDateTimeFormatter)(widget.type, value!);
    }
    if (value != null &&
        widget.type != (oldWidget as FormeCupertinoDateTimeField).type &&
        widget.type == FormeDateTimeType.date) {
      setValue(DateTime(value!.year, value!.month, value!.day));
      textEditingController.text = (widget.formatter ??
          defaultDateTimeFormatter)(FormeDateTimeType.date, value!);
    }
  }

  DateTime simple(DateTime dateTime) {
    switch (widget.type) {
      case FormeDateTimeType.date:
        return DateTime(dateTime.year, dateTime.month, dateTime.day);
      case FormeDateTimeType.dateTime:
        return DateTime(dateTime.year, dateTime.month, dateTime.day,
            dateTime.hour, dateTime.minute);
    }
  }
}

class _PickerSheet extends StatefulWidget {
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onChanged;
  final bool use24hFormat;
  final FormeDateTimeType type;
  final Widget? backWidget;
  final Widget? confirmWidget;
  final Widget? cancelWidget;
  final Color? backgroundColor;
  final DateTime? maximumDate;
  final DateTime? minimumDate;
  final int minimumYear;
  final int? maximumYear;
  final int minuteInterval;
  final double height;

  const _PickerSheet({
    Key? key,
    required this.use24hFormat,
    required this.initialDateTime,
    required this.onChanged,
    required this.type,
    this.backWidget,
    this.confirmWidget,
    this.cancelWidget,
    this.backgroundColor,
    this.maximumDate,
    this.minimumDate,
    required this.minimumYear,
    this.maximumYear,
    required this.minuteInterval,
    required this.height,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  int index = 0;
  late final DateTime initialDateTime;

  DateTime? selectedDateTime;
  bool timeChanged = false;
  bool dateChanged = false;

  @override
  void initState() {
    super.initState();
    initialDateTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        IndexedStack(
          index: index,
          children: [
            SizedBox(
              height: widget.height,
              child: buildCupertinoDatePicker(CupertinoDatePickerMode.date,
                  (DateTime newDate) {
                dateChanged = true;
                if (selectedDateTime == null) {
                  selectedDateTime =
                      DateTime(newDate.year, newDate.month, newDate.day);
                } else {
                  selectedDateTime = DateTime(
                      newDate.year,
                      newDate.month,
                      newDate.day,
                      selectedDateTime!.hour,
                      selectedDateTime!.minute);
                }
              }),
            ),
            SizedBox(
              height: widget.height,
              child: buildCupertinoDatePicker(CupertinoDatePickerMode.time,
                  (DateTime newDate) {
                timeChanged = true;
                selectedDateTime ??= DateTime(initialDateTime.year,
                    initialDateTime.month, initialDateTime.day);
                selectedDateTime = DateTime(
                    selectedDateTime!.year,
                    selectedDateTime!.month,
                    selectedDateTime!.day,
                    newDate.hour,
                    newDate.minute);
              }),
            ),
          ],
        ),
        CupertinoActionSheetAction(
          child: widget.cancelWidget ??
              const Text('Cancel',
                  style: TextStyle(color: CupertinoColors.systemRed)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        if (index == 1)
          CupertinoActionSheetAction(
            child: widget.backWidget ?? const Text('Back'),
            onPressed: () {
              setState(() {
                index = 0;
              });
            },
          ),
        CupertinoActionSheetAction(
          child: widget.confirmWidget ?? const Text('Done'),
          onPressed: () {
            if (index == 1 || widget.type == FormeDateTimeType.date) {
              DateTime selectedDateTime;
              if (!dateChanged && !timeChanged) {
                selectedDateTime = initialDateTime;
              } else {
                if (dateChanged && timeChanged) {
                  selectedDateTime = this.selectedDateTime!;
                } else {
                  if (dateChanged) {
                    selectedDateTime = DateTime(
                        this.selectedDateTime!.year,
                        this.selectedDateTime!.month,
                        this.selectedDateTime!.day,
                        initialDateTime.hour,
                        initialDateTime.minute);
                  } else {
                    selectedDateTime = this.selectedDateTime!;
                  }
                }
              }

              widget.onChanged(selectedDateTime);
              return;
            }
            if (widget.type == FormeDateTimeType.dateTime) {
              setState(() {
                index = 1;
              });
            }
          },
        )
      ],
    );
  }

  CupertinoDatePicker buildCupertinoDatePicker(
      CupertinoDatePickerMode mode, ValueChanged<DateTime> onDateTimeChanged) {
    return CupertinoDatePicker(
      initialDateTime: initialDateTime,
      onDateTimeChanged: onDateTimeChanged,
      use24hFormat: widget.use24hFormat,
      maximumDate: widget.maximumDate,
      minimumDate: widget.minimumDate,
      minimumYear: widget.minimumYear,
      maximumYear: widget.maximumYear,
      minuteInterval: widget.minuteInterval,
      mode: mode,
      backgroundColor: widget.backgroundColor,
    );
  }
}
