import 'package:flutter/material.dart';
import 'package:forme/forme.dart';
import 'package:forme_searchable/src/field/material/base_search_fields.dart';

import '../../../forme_searchable.dart';
import 'base_display_widget.dart';
import 'base_field_content.dart';
import 'pagination_bar.dart';

enum Mode {
  bottomSheet,
  dialog,
}

class FormeSearchableBaseRouteField<T extends Object>
    extends FormeSearchableField<T> {
  final AutocompleteOptionToString<T> displayStringForOption;
  final WidgetBuilder? displayBuilder;
  final FormeSearchableOptionWidgetBuilder<T>? optionWidgetBuilder;
  final WidgetBuilder? paginationBarBuilder;
  final WidgetBuilder? processingWidgetBuilder;
  final WidgetBuilder? emptyContentWidgetBuilder;
  final FormePaginationConfiguration? defaultPaginationConfiguration;
  final WidgetBuilder? searchFieldsBuilder;
  final FormeBottomSheetConfiguration bottomSheetConfiguration;
  final FormeDialogConfiguration dialogConfiguration;
  final FormeSearchableErrorWidgetBuilder? errorWidgetBuilder;
  final InputDecoration? decoration;
  final bool performSearchAfterOpen;

  final Mode mode;

  const FormeSearchableBaseRouteField({
    Key? key,
    this.displayBuilder,
    this.emptyContentWidgetBuilder,
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
    this.optionWidgetBuilder,
    this.paginationBarBuilder,
    this.defaultPaginationConfiguration,
    this.searchFieldsBuilder,
    this.bottomSheetConfiguration = const FormeBottomSheetConfiguration(),
    this.processingWidgetBuilder,
    required this.mode,
    this.dialogConfiguration = const FormeDialogConfiguration(),
    this.errorWidgetBuilder,
    this.decoration,
    this.performSearchAfterOpen = true,
  }) : super(key: key);

  @override
  FormeSearchableFieldState<T> createState() =>
      _FormeSearchableBaseRouteFieldState<T>();
}

class _FormeSearchableBaseRouteFieldState<T extends Object>
    extends FormeSearchableFieldState<T> with WidgetsBindingObserver {
  @override
  FormeSearchableBaseRouteField<T> get widget =>
      super.widget as FormeSearchableBaseRouteField<T>;

  FormeMaterialConfiguration get materialConfiguration =>
      widget.dialogConfiguration.materialConfiguration;

  late final ValueNotifier<MediaQueryData?> _mediaQueryDataNotifier =
      FormeMountedValueNotifier(null);

  bool get readOnly => status.readOnly;

  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    _mediaQueryDataNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _mediaQueryDataNotifier.value =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
  }

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

  Widget _createSearchFields() {
    if (widget.searchFieldsBuilder != null) {
      return widget.searchFieldsBuilder!.call(
        context,
      );
    }
    return BaseSearchFields<T>(decoration: widget.decoration);
  }

  Widget _createPaginationBar() {
    if (widget.paginationBarBuilder != null) {
      return widget.paginationBarBuilder!.call(
        context,
      );
    }
    return FormeSearchablePaginationBar<T>(
      configuration: widget.defaultPaginationConfiguration ??
          const FormePaginationConfiguration(),
    );
  }

  Widget _baseFieldContent({bool flexiable = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _createSearchFields(),
        _createPaginationBar(),
        BaseFieldContent<T>(
          emptyContentWidgetBuilder: widget.emptyContentWidgetBuilder,
          displayStringForOption: widget.displayStringForOption,
          errorWidgetBuilder: widget.errorWidgetBuilder,
          optionWidgetBuilder: widget.optionWidgetBuilder,
          processingWidgetBuilder: widget.processingWidgetBuilder,
          flexiable: flexiable,
        )
      ],
    );
  }

  double _getDialogBottomPadding(MediaQueryData data, Size dialogSize) {
    double bottomPadding;
    if (dialogSize == data.size) {
      bottomPadding = data.viewInsets.bottom;
    } else {
      double statusBarHeight = 0;
      if (widget.dialogConfiguration.useSafeArea) {
        statusBarHeight = data.padding.top;
      }
      final double bottom = (data.size.height - dialogSize.height) / 2;
      bottomPadding = data.viewInsets.bottom - bottom + statusBarHeight / 2;
      if (bottomPadding < 0) {
        bottomPadding = 0;
      }
    }
    return bottomPadding;
  }

  void _showDialog() {
    showDialog<void>(
      barrierDismissible: widget.dialogConfiguration.barrierDismissible,
      barrierColor: widget.dialogConfiguration.barrierColor,
      barrierLabel: widget.dialogConfiguration.barrierLabel,
      useSafeArea: widget.dialogConfiguration.useSafeArea,
      useRootNavigator: widget.dialogConfiguration.useRootNavigator,
      context: context,
      builder: (context) {
        return ValueListenableBuilder<MediaQueryData?>(
          valueListenable: _mediaQueryDataNotifier,
          builder: (context, nullableData, child) {
            final MediaQueryData data = nullableData ?? MediaQuery.of(context);
            final Size size =
                widget.dialogConfiguration.sizeProvider?.call(context, data) ??
                    data.size;

            return Center(
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: inherit(
                  Material(
                    animationDuration: materialConfiguration.animationDuration,
                    clipBehavior: materialConfiguration.clipBehavior,
                    borderOnForeground:
                        materialConfiguration.borderOnForeground,
                    shape:
                        widget.dialogConfiguration.materialConfiguration.shape,
                    borderRadius: materialConfiguration.borderRadius,
                    textStyle: materialConfiguration.textStyle,
                    shadowColor: materialConfiguration.shadowColor,
                    color:
                        widget.dialogConfiguration.materialConfiguration.color,
                    type: widget.dialogConfiguration.materialConfiguration.type,
                    elevation: materialConfiguration.elevation,
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: _getDialogBottomPadding(data, size)),
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: 10 +
                                    (widget.dialogConfiguration
                                                .closeButtonRadius ??
                                            20) *
                                        2),
                            child: _baseFieldContent(flexiable: true),
                          ),
                          Positioned.fill(
                            bottom: 5,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: CircleAvatar(
                                backgroundColor: widget.dialogConfiguration
                                    .closeButtonBackgroundColor,
                                radius: widget
                                    .dialogConfiguration.closeButtonRadius,
                                child: IconButton(
                                  iconSize: widget
                                      .dialogConfiguration.closeButtonSize,
                                  icon: Icon(
                                    widget.dialogConfiguration
                                            .closeButtonIcon ??
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
      },
    );
  }

  void _showModalBottomSheet() {
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
          return ValueListenableBuilder<MediaQueryData?>(
              valueListenable: _mediaQueryDataNotifier,
              builder: (context, nullableData, child) {
                final MediaQueryData data =
                    nullableData ?? MediaQuery.of(context);
                return inherit(Padding(
                  padding: EdgeInsets.only(bottom: data.viewInsets.bottom),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight:
                          widget.bottomSheetConfiguration.maxmiumHeight ??
                              double.infinity,
                    ),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 150),
                      child: _baseFieldContent(),
                    ),
                  ),
                ));
              });
        });
  }
}
