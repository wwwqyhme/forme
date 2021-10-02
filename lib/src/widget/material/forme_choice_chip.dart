import 'package:flutter/material.dart';
import '../../../forme.dart';

class FormeChoiceChip<T extends Object> extends FormeField<T?> {
  final List<FormeChipItem<T>> items;

  FormeChoiceChip({
    T? initialValue,
    required String name,
    bool readOnly = false,
    required this.items,
    Key? key,
    InputDecoration? decoration,
    FormeFieldDecorator<T?>? decorator,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<T?>? onValueChanged,
    FormeFocusChanged<T?>? onFocusChanged,
    FormeFieldValidationChanged<T?>? onValidationChanged,
    FormeFieldInitialed<T?>? onInitialed,
    FormeFieldSetter<T?>? onSaved,
    FormeValidator<T?>? validator,
    FormeAsyncValidator<T?>? asyncValidator,
    ChipThemeData? chipThemeData,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    double spacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    bool requestFocusOnUserInteraction = true,
  }) : super(
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
          order: order,
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
          key: key,
          decorator: decorator ??
              (decoration == null
                  ? null
                  : FormeInputDecoratorBuilder(decoration: decoration)),
          readOnly: readOnly,
          name: name,
          initialValue: initialValue,
          builder: (state) {
            final bool readOnly = state.readOnly;
            final ChipThemeData _chipThemeData =
                chipThemeData ?? ChipTheme.of(state.context);
            final List<Widget> chips = [];
            for (final FormeChipItem<T> item in items) {
              final bool isReadOnly = readOnly || item.readOnly;
              final ChoiceChip chip = ChoiceChip(
                selected: state.value == item.data,
                label: item.label,
                avatar: item.avatar,
                padding: item.padding,
                pressElevation: item.pressElevation,
                tooltip: item.tooltip ?? item.tooltip,
                materialTapTargetSize: item.materialTapTargetSize,
                avatarBorder: item.avatarBorder ?? const CircleBorder(),
                backgroundColor: item.backgroundColor,
                shadowColor: item.shadowColor,
                disabledColor: item.disabledColor,
                selectedColor: item.selectedColor,
                selectedShadowColor: item.selectedShadowColor,
                visualDensity: item.visualDensity,
                elevation: item.elevation,
                labelPadding: item.labelPadding,
                labelStyle: item.labelStyle,
                shape: item.shape,
                side: item.side,
                onSelected: isReadOnly
                    ? null
                    : (bool selected) {
                        if (state.value == item.data) {
                          state.didChange(null);
                        } else {
                          state.didChange(item.data);
                        }
                        state.requestFocusOnUserInteraction();
                      },
              );
              chips.add(Visibility(
                  visible: item.visible,
                  child: Padding(
                    padding: item.padding,
                    child: chip,
                  )));
            }

            final Widget chipWidget = Wrap(
              spacing: spacing,
              runSpacing: runSpacing,
              textDirection: textDirection,
              crossAxisAlignment: crossAxisAlignment,
              verticalDirection: verticalDirection,
              alignment: alignment,
              direction: direction,
              runAlignment: runAlignment,
              children: chips,
            );
            return Focus(
              focusNode: state.focusNode,
              child: ChipTheme(
                data: _chipThemeData,
                child: chipWidget,
              ),
            );
          },
        );

  @override
  _FormeChoiceChipState<T> createState() => _FormeChoiceChipState();
}

class _FormeChoiceChipState<T extends Object> extends FormeFieldState<T?> {
  @override
  FormeChoiceChip<T> get widget => super.widget as FormeChoiceChip<T>;

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<T?> oldWidget) {
    if (value == null) {
      return;
    }
    if (!widget.items.any((element) => element.data == value)) {
      setValue(null);
    }
  }
}

class FormeChipItem<T extends Object> {
  final Widget label;
  final Widget? avatar;
  final T data;
  final EdgeInsets? labelPadding;
  final EdgeInsets padding;
  final bool readOnly;
  final bool visible;
  final String? tooltip;
  final TextStyle? labelStyle;
  final double? pressElevation;
  final Color? disabledColor;
  final Color? selectedColor;
  final BorderSide? side;
  final OutlinedBorder? shape;
  final Color? backgroundColor;
  final VisualDensity? visualDensity;
  final MaterialTapTargetSize? materialTapTargetSize;
  final double? elevation;
  final Color? shadowColor;
  final Color? selectedShadowColor;
  final bool? showCheckmark;
  final Color? checkmarkColor;
  final CircleBorder? avatarBorder;

  FormeChipItem({
    required this.label,
    this.avatar,
    required this.data,
    EdgeInsets? padding,
    this.readOnly = false,
    this.visible = true,
    this.labelPadding,
    this.tooltip,
    this.labelStyle,
    this.avatarBorder,
    this.backgroundColor,
    this.checkmarkColor,
    this.showCheckmark,
    this.shadowColor,
    this.disabledColor,
    this.selectedColor,
    this.selectedShadowColor,
    this.visualDensity,
    this.elevation,
    this.pressElevation,
    this.materialTapTargetSize,
    this.shape,
    this.side,
  }) : padding = padding ?? const EdgeInsets.symmetric(horizontal: 10);
}
