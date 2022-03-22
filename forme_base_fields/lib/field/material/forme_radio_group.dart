import 'package:flutter/material.dart';

import 'package:forme/forme.dart';
import 'forme_list_tile.dart';

class FormeRadioGroup<T extends Object> extends FormeField<T?> {
  final List<FormeListTileItem<T>> items;

  FormeRadioGroup({
    T? initialValue,
    required String name,
    bool readOnly = false,
    required this.items,
    int split = 2,
    bool dense = true,
    ShapeBorder? shape,
    ListTileStyle? style,
    Color? selectedColor,
    Color? iconColor,
    Color? textColor,
    EdgeInsetsGeometry? contentPadding,
    Color? tileColor,
    Color? selectedTileColor,
    bool? enableFeedback,
    double? horizontalTitleGap,
    double? minVerticalPadding,
    double? minLeadingWidth,
    Color? activeColor,
    MaterialStateProperty<Color?>? fillColor,
    Color? focusColor,
    Color? hoverColor,
    MaterialStateProperty<Color?>? overlayColor,
    double? splashRadius,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? materialTapTargetSize,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    double spacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<T?>? onStatusChanged,
    FormeFieldInitialed<T?>? onInitialed,
    FormeFieldSetter<T?>? onSaved,
    FormeValidator<T?>? validator,
    FormeAsyncValidator<T?>? asyncValidator,
    InputDecoration? decoration,
    FormeFieldDecorator<T?>? decorator,
    bool requestFocusOnUserInteraction = true,
    bool registrable = true,
    bool enabled = true,
    FormeFieldValueUpdater<T?>? valueUpdater,
    FormeFieldValidationFilter<T?>? validationFilter,
  }) : super(
            validationFilter: validationFilter,
            valueUpdater: valueUpdater,
            enabled: enabled,
            registrable: registrable,
            requestFocusOnUserInteraction: requestFocusOnUserInteraction,
            quietlyValidate: quietlyValidate,
            asyncValidatorDebounce: asyncValidatorDebounce,
            autovalidateMode: autovalidateMode,
            onStatusChanged: onStatusChanged,
            onInitialed: onInitialed,
            onSaved: onSaved,
            validator: validator,
            asyncValidator: asyncValidator,
            order: order,
            decorator: decorator ??
                (decoration == null
                    ? null
                    : FormeInputDecoratorBuilder(decoration: decoration)),
            key: key,
            readOnly: readOnly,
            name: name,
            initialValue: initialValue,
            builder: (state) {
              final bool readOnly = state.readOnly;
              final List<Widget> wrapWidgets = [];

              void changeValue(T value) {
                state.didChange(value);
                state.requestFocusOnUserInteraction();
              }

              Widget createFormeListTileItem(
                  FormeListTileItem<T> item, bool selected, bool readOnly) {
                return RadioListTile<T>(
                  shape: shape,
                  tileColor: tileColor,
                  selectedTileColor: selectedTileColor,
                  activeColor: activeColor,
                  secondary: item.secondary,
                  subtitle: item.subtitle,
                  groupValue: state.value,
                  controlAffinity: item.controlAffinity,
                  contentPadding: item.padding,
                  dense: item.dense,
                  title: item.title,
                  value: item.data,
                  onChanged: readOnly ? null : (v) => changeValue(item.data),
                );
              }

              Widget createCommonItem(
                  FormeListTileItem<T> item, bool selected, bool readOnly) {
                return Radio<T>(
                  activeColor: activeColor,
                  fillColor: fillColor,
                  materialTapTargetSize: materialTapTargetSize,
                  focusColor: focusColor,
                  hoverColor: hoverColor,
                  overlayColor: overlayColor,
                  splashRadius: splashRadius,
                  visualDensity: visualDensity,
                  value: item.data,
                  groupValue: state.value,
                  onChanged: readOnly || item.readOnly
                      ? null
                      : (v) => changeValue(item.data),
                );
              }

              for (int i = 0; i < items.length; i++) {
                final FormeListTileItem<T> item = items[i];
                final bool isReadOnly = readOnly || item.readOnly;
                final bool selected = state.value == item.data;
                if (split > 0) {
                  final double factor = 1 / split;
                  if (factor == 1) {
                    wrapWidgets.add(
                        createFormeListTileItem(item, selected, isReadOnly));
                    continue;
                  }
                }

                final Widget tileItem =
                    createCommonItem(item, selected, readOnly);

                final Widget title = split == 0
                    ? item.title
                    : Flexible(
                        child: item.title,
                      );

                List<Widget> children;
                switch (item.controlAffinity) {
                  case ListTileControlAffinity.leading:
                    children = [tileItem, title];
                    break;
                  default:
                    children = [title, tileItem];
                    break;
                }

                final Row tileItemRow = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                );

                final Widget groupItemWidget = Padding(
                  padding: item.padding,
                  child: InkWell(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4.0)),
                      onTap: isReadOnly
                          ? null
                          : () {
                              changeValue(item.data);
                            },
                      child: tileItemRow),
                );

                final bool visible = item.visible;
                if (split <= 0) {
                  wrapWidgets.add(Visibility(
                    visible: visible,
                    child: groupItemWidget,
                  ));
                  if (visible && i < items.length - 1) {
                    wrapWidgets.add(const SizedBox(
                      width: 8.0,
                    ));
                  }
                } else {
                  final double factor = item.ignoreSplit ? 1 : 1 / split;
                  wrapWidgets.add(Visibility(
                    visible: visible,
                    child: FractionallySizedBox(
                      widthFactor: factor,
                      child: groupItemWidget,
                    ),
                  ));
                }
              }

              Widget child = Wrap(
                spacing: spacing,
                runSpacing: runSpacing,
                textDirection: textDirection,
                crossAxisAlignment: crossAxisAlignment,
                verticalDirection: verticalDirection,
                alignment: alignment,
                direction: direction,
                runAlignment: runAlignment,
                children: wrapWidgets,
              );
              if (split == 1) {
                child = ListTileTheme.merge(
                  child: child,
                  dense: dense,
                  shape: shape,
                  style: style,
                  selectedColor: selectedColor,
                  iconColor: iconColor,
                  textColor: textColor,
                  contentPadding: contentPadding,
                  tileColor: tileColor,
                  selectedTileColor: selectedTileColor,
                  enableFeedback: enableFeedback,
                  horizontalTitleGap: horizontalTitleGap,
                  minVerticalPadding: minVerticalPadding,
                  minLeadingWidth: minLeadingWidth,
                );
              }

              return Focus(
                focusNode: state.focusNode,
                child: child,
              );
            });
}
