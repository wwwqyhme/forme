import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../decorator/forme_decorator.dart';
import '../../decorator/forme_material_decorator.dart';
import '../../forme_core.dart';
import '../../forme_field.dart';

class FormeListTileItem<T extends Object> {
  final Widget title;
  final bool readOnly;
  final bool visible;
  final EdgeInsets padding;

  /// only work when split = 1
  final Widget? secondary;
  final ListTileControlAffinity controlAffinity;

  /// only work when split = 1
  final Widget? subtitle;
  final bool dense;
  final T data;
  final bool ignoreSplit;

  FormeListTileItem(
      {required this.title,
      this.subtitle,
      this.secondary,
      ListTileControlAffinity? controlAffinity,
      this.readOnly = false,
      this.visible = true,
      this.dense = false,
      EdgeInsets? padding,
      required this.data,
      this.ignoreSplit = false})
      : controlAffinity = controlAffinity ?? ListTileControlAffinity.platform,
        padding = padding ?? EdgeInsets.zero;
}

enum FormeListTileType { checkbox, switch_ }

class FormeListTile<T extends Object> extends FormeField<List<T>> {
  final List<FormeListTileItem<T>> items;

  FormeListTile({
    List<T>? initialValue,
    required String name,
    bool readOnly = false,
    FormeListTileType type = FormeListTileType.checkbox,
    required this.items,
    Key? key,
    int? order,
    bool quietlyValidate = false,
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
    MouseCursor? mouseCursor,
    MaterialStateProperty<Color?>? fillColor,
    Color? checkColor,
    Color? focusColor,
    Color? hoverColor,
    MaterialStateProperty<Color?>? overlayColor,
    double? splashRadius,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? materialTapTargetSize,
    Color? activeTrackColor,
    Color? inactiveThumbColor,
    Color? inactiveTrackColor,
    ImageProvider? imageProvider,
    ImageProvider? activeThumbImage,
    ImageProvider? inactiveThumbImage,
    MaterialStateProperty<Color?>? thumbColor,
    MaterialStateProperty<Color?>? trackColor,
    DragStartBehavior? dragStartBehavior,
    ImageErrorListener? onActiveThumbImageError,
    ImageErrorListener? onInactiveThumbImageError,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double? space,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    double spacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    InputDecoration? decoration,
    FormeFieldDecorator<List<T>>? decorator,
  }) : super(
            quietlyValidate: quietlyValidate,
            order: order,
            key: key,
            readOnly: readOnly,
            name: name,
            initialValue: initialValue ?? [],
            decorator: decorator ??
                (decoration == null
                    ? null
                    : FormeInputDecoratorBuilder(decoration: decoration)),
            builder: (state) {
              bool readOnly = state.readOnly;

              List<Widget> wrapWidgets = [];

              void changeValue(T value) {
                state.requestFocus();
                List<T> values = List.of(state.value);
                if (!values.remove(value)) {
                  values.add(value);
                }
                state.didChange(values);
              }

              Widget createFormeListTileItem(
                  FormeListTileItem<T> item, bool selected, bool readOnly) {
                switch (type) {
                  case FormeListTileType.checkbox:
                    return CheckboxListTile(
                      shape: shape,
                      tileColor: tileColor,
                      selectedTileColor: selectedTileColor,
                      activeColor: activeColor,
                      checkColor: checkColor,
                      secondary: item.secondary,
                      subtitle: item.subtitle,
                      controlAffinity: item.controlAffinity,
                      contentPadding: item.padding,
                      dense: item.dense,
                      title: item.title,
                      value: selected,
                      onChanged:
                          readOnly ? null : (v) => changeValue(item.data),
                    );
                  case FormeListTileType.switch_:
                    return SwitchListTile(
                      tileColor: tileColor,
                      activeColor: activeColor,
                      activeTrackColor: activeTrackColor,
                      inactiveThumbColor: inactiveThumbColor,
                      inactiveTrackColor: inactiveTrackColor,
                      activeThumbImage: activeThumbImage,
                      inactiveThumbImage: inactiveThumbImage,
                      shape: shape,
                      selectedTileColor: selectedTileColor,
                      secondary: item.secondary,
                      subtitle: item.subtitle,
                      controlAffinity: item.controlAffinity,
                      contentPadding: item.padding,
                      dense: item.dense,
                      title: item.title,
                      value: selected,
                      onChanged:
                          readOnly ? null : (v) => changeValue(item.data),
                    );
                }
              }

              Widget createCommonItem(
                  FormeListTileItem<T> item, bool selected, bool readOnly) {
                switch (type) {
                  case FormeListTileType.checkbox:
                    return Checkbox(
                      activeColor: activeColor,
                      fillColor: fillColor,
                      checkColor: checkColor,
                      materialTapTargetSize: materialTapTargetSize,
                      focusColor: focusColor,
                      hoverColor: hoverColor,
                      overlayColor: overlayColor,
                      splashRadius: splashRadius,
                      visualDensity: visualDensity,
                      value: selected,
                      onChanged: readOnly || item.readOnly
                          ? null
                          : (v) => changeValue(item.data),
                    );
                  case FormeListTileType.switch_:
                    return Switch(
                      value: selected,
                      onChanged: readOnly || item.readOnly
                          ? null
                          : (v) => changeValue(item.data),
                      activeColor: activeColor,
                      activeTrackColor: activeTrackColor,
                      inactiveThumbColor: inactiveThumbColor,
                      inactiveTrackColor: inactiveTrackColor,
                      activeThumbImage: activeThumbImage,
                      inactiveThumbImage: inactiveThumbImage,
                      materialTapTargetSize: materialTapTargetSize,
                      thumbColor: thumbColor,
                      trackColor: trackColor,
                      dragStartBehavior:
                          dragStartBehavior ?? DragStartBehavior.start,
                      focusColor: focusColor,
                      hoverColor: hoverColor,
                      overlayColor: overlayColor,
                      splashRadius: splashRadius,
                      onActiveThumbImageError: onActiveThumbImageError,
                      onInactiveThumbImageError: onInactiveThumbImageError,
                    );
                }
              }

              for (int i = 0; i < items.length; i++) {
                FormeListTileItem<T> item = items[i];
                bool isReadOnly = readOnly || item.readOnly;
                bool selected = state.value.contains(item.data);
                if (split > 0) {
                  double factor = 1 / split;
                  if (factor == 1) {
                    wrapWidgets.add(
                        createFormeListTileItem(item, selected, isReadOnly));
                    continue;
                  }
                }

                Widget tileItem = createCommonItem(item, selected, readOnly);

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

                Row tileItemRow = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                );

                Widget groupItemWidget = Padding(
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

                bool visible = item.visible;
                if (split <= 0) {
                  wrapWidgets.add(Visibility(
                    child: groupItemWidget,
                    visible: visible,
                  ));
                  if (visible && i < items.length - 1) {
                    wrapWidgets.add(const SizedBox(
                      width: 8.0,
                    ));
                  }
                } else {
                  double factor = item.ignoreSplit ? 1 : 1 / split;
                  wrapWidgets.add(Visibility(
                    child: FractionallySizedBox(
                      widthFactor: factor,
                      child: groupItemWidget,
                    ),
                    visible: visible,
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

  @override
  _FormeListTileState<T> createState() => _FormeListTileState();
}

class _FormeListTileState<T extends Object> extends FormeFieldState<List<T>> {
  @override
  FormeListTile<T> get widget => super.widget as FormeListTile<T>;

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<List<T>> oldWidget) {
    List<T> items = List.of(value);
    Iterable<T> datas = widget.items.map((e) => e.data);
    bool removed = false;
    items.removeWhere((element) {
      if (!datas.contains(element)) {
        removed = true;
        return true;
      }
      return false;
    });
    if (removed) setValue(items);
  }
}
