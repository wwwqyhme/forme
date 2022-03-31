import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import '../../forme_searchable_field.dart';
import 'base_display_widget.dart';
import 'base_field_content.dart';
import 'pagination_bar.dart';
import 'route_configuration.dart';

enum Mode {
  bottomSheet,
  dialog,
}

typedef FormeSearchableDisplayWidgetBuilder<T extends Object> = Widget Function(
    BuildContext context,
    ValueChanged<T>? delete,
    FocusNode focusNode,
    FormeFieldStatus<List<T>> status);

class FormeSearchableBaseRouteField<T extends Object>
    extends FormeSearchableField<T> {
  final AutocompleteOptionToString<T> displayStringForOption;
  final FormeSearchableDisplayWidgetBuilder<T>? displayBuilder;
  final FormeSearchableOptionWidgetBuilder<T>? optionWidgetBuilder;
  final FormeSearchablePaginationBarBuilder? paginationBarBuilder;
  final WidgetBuilder? processingWidgetBuilder;
  final WidgetBuilder? emptyContentWidgetBuilder;
  final FormeSearchablePaginationBarPosition paginationBarPosition;
  final FormePaginationConfiguration? defaultPaginationConfiguration;
  final FormeSearchableSearchFieldsBuilder? searchFieldsBuilder;
  final FormeBottomSheetConfiguration bottomSheetConfiguration;
  final FormeDialogConfiguration dialogConfiguration;
  final Widget Function(BuildContext context, VoidCallback? refresh)?
      errorWidgetBuilder;
  final InputDecoration? decoration;

  final Mode mode;

  const FormeSearchableBaseRouteField({
    Key? key,
    this.displayBuilder,
    this.emptyContentWidgetBuilder,
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
    this.optionWidgetBuilder,
    this.paginationBarBuilder,
    this.paginationBarPosition = FormeSearchablePaginationBarPosition.top,
    this.defaultPaginationConfiguration,
    this.searchFieldsBuilder,
    this.bottomSheetConfiguration = const FormeBottomSheetConfiguration(),
    this.processingWidgetBuilder,
    required this.mode,
    this.dialogConfiguration = const FormeDialogConfiguration(),
    this.errorWidgetBuilder,
    this.decoration,
  }) : super(key: key);

  @override
  FormeSearchableFieldState<T> createState() =>
      _FormeSearchableBaseRouteFieldState<T>();
}

class _FormeSearchableBaseRouteFieldState<T extends Object>
    extends FormeSearchableFieldState<T> {
  @override
  FormeSearchableBaseRouteField<T> get widget =>
      super.widget as FormeSearchableBaseRouteField<T>;

  FormeMaterialConfiguration get materialConfiguration =>
      widget.dialogConfiguration.materialConfiguration;

  @override
  Widget build(BuildContext context) {
    final delete = status.readOnly ? null : _delete;
    return GestureDetector(
      onTap: status.readOnly
          ? null
          : () {
              switch (widget.mode) {
                case Mode.bottomSheet:
                  _showModalBottomSheet();
                  break;
                case Mode.dialog:
                  _showDialog();
                  break;
              }
            },
      child: widget.displayBuilder?.call(
            context,
            delete,
            focusNode,
            status,
          ) ??
          BaseDisplayWidget<T>(
              status: status,
              delete: delete,
              focusNode: focusNode,
              displayStringForOption: widget.displayStringForOption),
    );
  }

  void _delete(T option) {
    final List<T> newValue = List.of(status.value)
      ..removeWhere((element) => element == option);
    if (newValue.length != status.value.length) {
      value = newValue;
    }
  }

  Widget _baseFieldContent({bool flexiable = false}) {
    return BaseFieldContent<T>(
      emptyContentWidgetBuilder: widget.emptyContentWidgetBuilder,
      displayStringForOption: widget.displayStringForOption,
      errorWidgetBuilder: widget.errorWidgetBuilder,
      optionWidgetBuilder: widget.optionWidgetBuilder,
      searchFieldsBuilder: widget.searchFieldsBuilder,
      paginationBarPosition: widget.paginationBarPosition,
      processingWidgetBuilder: widget.processingWidgetBuilder,
      paginationBarBuilder: widget.paginationBarBuilder,
      defaultPaginationConfiguration: widget.defaultPaginationConfiguration,
      flexiable: flexiable,
    );
  }

  void _showDialog() {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    showDialog<void>(
      barrierDismissible: widget.dialogConfiguration.barrierDismissible,
      barrierColor: widget.dialogConfiguration.barrierColor,
      barrierLabel: widget.dialogConfiguration.barrierLabel,
      useSafeArea: widget.dialogConfiguration.useSafeArea,
      useRootNavigator: widget.dialogConfiguration.useRootNavigator,
      context: context,
      builder: (context) {
        final MediaQueryData query = MediaQuery.of(context);
        final Size size =
            widget.dialogConfiguration.sizeProvider?.call(context, query) ??
                query.size;
        return Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: inherit(
              Material(
                animationDuration: materialConfiguration.animationDuration,
                clipBehavior: materialConfiguration.clipBehavior,
                borderOnForeground: materialConfiguration.borderOnForeground,
                shape: widget.dialogConfiguration.materialConfiguration.shape,
                borderRadius: materialConfiguration.borderRadius,
                textStyle: materialConfiguration.textStyle,
                shadowColor: materialConfiguration.shadowColor,
                color: widget.dialogConfiguration.materialConfiguration.color,
                type: widget.dialogConfiguration.materialConfiguration.type,
                elevation: materialConfiguration.elevation,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: 10 +
                                (widget.dialogConfiguration.closeButtonRadius ??
                                        20) *
                                    2),
                        child: _baseFieldContent(flexiable: true),
                      ),
                      Positioned.fill(
                        bottom: 5,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: CircleAvatar(
                            backgroundColor: widget
                                .dialogConfiguration.closeButtonBackgroundColor,
                            radius:
                                widget.dialogConfiguration.closeButtonRadius,
                            child: IconButton(
                              iconSize:
                                  widget.dialogConfiguration.closeButtonSize,
                              icon: Icon(
                                widget.dialogConfiguration.closeButtonIcon ??
                                    Icons.close,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showModalBottomSheet() {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    showModalBottomSheet(
        context: context,
        backgroundColor: widget.bottomSheetConfiguration.backgroundColor,
        elevation: widget.bottomSheetConfiguration.elevation,
        shape: widget.bottomSheetConfiguration.shape,
        clipBehavior: widget.bottomSheetConfiguration.clipBehavior,
        constraints: widget.bottomSheetConfiguration.constraints,
        barrierColor: widget.bottomSheetConfiguration.barrierColor,
        isScrollControlled: widget.bottomSheetConfiguration.isScrollControlled,
        isDismissible: widget.bottomSheetConfiguration.isDismissible,
        transitionAnimationController:
            widget.bottomSheetConfiguration.transitionAnimationController,
        useRootNavigator: widget.bottomSheetConfiguration.useRootNavigator,
        builder: (context) {
          return inherit(Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: widget.bottomSheetConfiguration.maxmiumHeight ??
                    double.infinity,
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 150),
                child: _baseFieldContent(),
              ),
            ),
          ));
        });
  }
}
