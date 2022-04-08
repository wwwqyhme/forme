import 'package:flutter/material.dart';

import 'package:forme/forme.dart';
import 'forme_choice_chip.dart';

class FormeFilterChip<T extends Object> extends FormeField<List<T>> {
  final List<FormeChipItem<T>> items;
  final int? maxSelectedCount;

  FormeFilterChip({
    List<T>? initialValue,
    required String name,
    bool readOnly = false,
    required this.items,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<List<T>>? onStatusChanged,
    FormeFieldInitialed<List<T>>? onInitialed,
    FormeFieldSetter<List<T>>? onSaved,
    FormeValidator<List<T>>? validator,
    FormeAsyncValidator<List<T>>? asyncValidator,
    ChipThemeData? chipThemeData,
    this.maxSelectedCount,
    VoidCallback? maxSelectedExceedCallback,
    Key? key,
    int? order,
    InputDecoration? decoration,
    FormeFieldDecorator<List<T>>? decorator,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    double spacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    bool requestFocusOnUserInteraction = true,
    bool registrable = true,
    bool enabled = true,
    FormeFieldValueUpdater<List<T>>? valueUpdater,
    FormeValueComparator<List<T>>? comparator,
    FormeFieldValidationFilter<List<T>>? validationFilter,
    FocusNode? focusNode,
  }) : super(
          focusNode: focusNode,
          validationFilter: validationFilter,
          comparator: comparator,
          valueUpdater: valueUpdater,
          enabled: enabled,
          registrable: registrable,
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
          order: order,
          decorator: decorator ??
              (decoration == null
                  ? null
                  : FormeInputDecoratorBuilder(
                      decoration: decoration,
                      maxLength: maxSelectedCount,
                      counter: (value) => value.length,
                    )),
          key: key,
          readOnly: readOnly,
          name: name,
          initialValue: initialValue ?? [],
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          autovalidateMode: autovalidateMode,
          onStatusChanged: onStatusChanged,
          onInitialed: onInitialed,
          onSaved: onSaved,
          validator: validator,
          asyncValidator: asyncValidator,
          builder: (state) {
            final bool readOnly = state.readOnly;
            final ChipThemeData _chipThemeData =
                chipThemeData ?? ChipTheme.of(state.context);

            final List<Widget> chips = [];
            for (final FormeChipItem<T> item in items) {
              final bool isReadOnly = readOnly || item.readOnly;
              final FilterChip chip = FilterChip(
                selected: state.value.contains(item.data),
                label: item.label,
                avatar: item.avatar,
                padding: item.padding,
                pressElevation: item.pressElevation,
                tooltip: item.tooltip,
                materialTapTargetSize: item.materialTapTargetSize,
                avatarBorder: item.avatarBorder ?? const CircleBorder(),
                backgroundColor: item.backgroundColor,
                checkmarkColor: item.checkmarkColor,
                showCheckmark: item.showCheckmark,
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
                        final List<T> value = List.of(state.value);
                        if (selected) {
                          if (maxSelectedCount != null &&
                              value.length >= maxSelectedCount) {
                            if (maxSelectedExceedCallback != null) {
                              maxSelectedExceedCallback();
                            }
                            return;
                          }
                          state.didChange(value..add(item.data));
                        } else {
                          state.didChange(value..remove(item.data));
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
                ));
          },
        );
}
