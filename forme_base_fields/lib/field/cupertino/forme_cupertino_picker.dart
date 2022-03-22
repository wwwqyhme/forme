import 'package:flutter/cupertino.dart';
import 'package:forme/forme.dart';

class FormeCupertinoPicker extends FormeField<int> {
  final List<Widget> children;

  FormeCupertinoPicker({
    int? initialValue,
    required String name,
    bool readOnly = false,
    required double itemExtent,
    required this.children,
    Key? key,
    int? order,
    double diameterRatio = 1.07,
    Color? backgroundColor,
    double offAxisFraction = 0.0,
    bool useMagnifier = false,
    double magnification = 1.0,
    double squeeze = 1.45,
    Widget? selectionOverlay,
    bool looping = false,
    double aspectRatio = 3,
    bool locked = false,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<int>? onStatusChanged,
    FormeFieldInitialed<int>? onInitialed,
    FormeFieldSetter<int>? onSaved,
    FormeValidator<int>? validator,
    FormeAsyncValidator<int>? asyncValidator,
    FormeFieldDecorator<int>? decorator,
    bool registrable = true,
    bool enabled = true,
    FormeFieldValueUpdater<int>? valueUpdater,
    FormeFieldValidationFilter<int>? validationFilter,
  }) : super(
          validationFilter: validationFilter,
          valueUpdater: valueUpdater,
          enabled: enabled,
          registrable: registrable,
          decorator: decorator,
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          autovalidateMode: autovalidateMode,
          onStatusChanged: onStatusChanged,
          onInitialed: onInitialed,
          onSaved: onSaved,
          validator: validator,
          asyncValidator: asyncValidator,
          order: order,
          key: key,
          name: name,
          readOnly: readOnly,
          initialValue: initialValue ?? 0,
          builder: (baseState) {
            final _FormeCupertinoPickerState state =
                baseState as _FormeCupertinoPickerState;
            final Widget child = NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollStartNotification) {
                    state.focusNode.requestFocus();
                    state.onScrollStatusChanged(true);
                  }
                  if (scrollNotification is ScrollEndNotification) {
                    state.onScrollStatusChanged(false);
                  }
                  return true;
                },
                child: AbsorbPointer(
                  absorbing: state.readOnly || locked,
                  child: CupertinoPicker(
                    scrollController: state.scrollController,
                    diameterRatio: diameterRatio,
                    backgroundColor: backgroundColor,
                    offAxisFraction: offAxisFraction,
                    useMagnifier: useMagnifier,
                    magnification: magnification,
                    squeeze: squeeze,
                    looping: looping,
                    selectionOverlay: selectionOverlay ??
                        const CupertinoPickerDefaultSelectionOverlay(),
                    itemExtent: itemExtent,
                    onSelectedItemChanged: (index) => state.index = index,
                    children: children,
                  ),
                ));

            return Focus(
              focusNode: state.focusNode,
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: child,
              ),
            );
          },
        );

  @override
  _FormeCupertinoPickerState createState() => _FormeCupertinoPickerState();
}

class _FormeCupertinoPickerState extends FormeFieldState<int> {
  late FixedExtentScrollController scrollController;

  @override
  FormeCupertinoPicker get widget => super.widget as FormeCupertinoPicker;

  late int index;

  @override
  void initStatus() {
    super.initStatus();
    index = initialValue;
    scrollController = FixedExtentScrollController(initialItem: initialValue);
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<int> status) {
    super.onStatusChanged(status);
    if (status.isValueChanged) {
      scrollController.jumpToItem(status.value);
    }
  }

  void onScrollStatusChanged(bool scrolling) {
    if (!scrolling) {
      didChange(index);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    scrollController.jumpToItem(value);
  }
}
