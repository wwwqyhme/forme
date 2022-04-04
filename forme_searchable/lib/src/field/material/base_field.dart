import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import '../../../forme_searchable.dart';
import 'base_display_widget.dart';
import 'base_field_content.dart';
import 'base_search_fields.dart';
import 'base_pagination_bar.dart';
import 'base_searchable_display_widget.dart';

enum Mode {
  bottomSheet,
  dialog,
  base,
  overlay,
}

class FormeSearchableBaseField<T extends Object>
    extends FormeSearchableField<T> {
  final AutocompleteOptionToString<T> displayStringForOption;
  final WidgetBuilder? displayBuilder;
  final FormeSearchableOptionWidgetBuilder<T>? optionWidgetBuilder;
  final WidgetBuilder? paginationBarBuilder;
  final WidgetBuilder? contentBuilder;
  final WidgetBuilder? processingWidgetBuilder;
  final WidgetBuilder? emptyContentWidgetBuilder;
  final FormePaginationConfiguration? defaultPaginationConfiguration;
  final WidgetBuilder? searchFieldsBuilder;
  final FormeBottomSheetConfiguration bottomSheetConfiguration;
  final FormeOverlayConfiguration overlayConfiguration;
  final FormeDialogConfiguration dialogConfiguration;
  final FormeBaseConfiguration baseConfiguration;
  final FormeSearchableErrorWidgetBuilder? errorWidgetBuilder;
  final InputDecoration? decoration;
  final InputDecoration? searchFieldDecoration;

  final Mode mode;

  const FormeSearchableBaseField({
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
    this.decoration = const InputDecoration(),
    this.baseConfiguration = const FormeBaseConfiguration(),
    this.searchFieldDecoration = const InputDecoration(),
    this.contentBuilder,
    this.overlayConfiguration = const FormeOverlayConfiguration(),
  }) : super(key: key);

  @override
  FormeSearchableFieldState<T> createState() =>
      _FormeSearchableBaseFieldState<T>();
}

class _FormeSearchableBaseFieldState<T extends Object>
    extends FormeSearchableFieldState<T> with WidgetsBindingObserver {
  @override
  FormeSearchableBaseField<T> get widget =>
      super.widget as FormeSearchableBaseField<T>;

  late final ValueNotifier<MediaQueryData?> _mediaQueryDataNotifier =
      FormeMountedValueNotifier(null);

  bool get readOnly => status.readOnly;

  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _baseContentEnableNotifier =
      FormeMountedValueNotifier(false);
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _entry;

  Route? _route;

  bool get isDialogRoute => _route != null && _route is DialogRoute;
  bool get isBottomSheetRoute => _route != null && _route is PopupRoute;

  @override
  void initState() {
    super.initState();
    _baseContentEnableNotifier.addListener(() {
      if (mounted && !_baseContentEnableNotifier.value) {
        resetQueryStatus();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _controller.dispose();
    _close();
    _baseContentEnableNotifier.dispose();
    _mediaQueryDataNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FormeSearchableField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((oldWidget as FormeSearchableBaseField).mode != widget.mode) {
      _close();
    }
  }

  @override
  void didChangeMetrics() {
    _mediaQueryDataNotifier.value =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
  }

  @override
  void onQueryCancelled(FormeSearchCondition condition) {
    super.onQueryCancelled(condition);
    if (widget.mode == Mode.base) {
      _baseContentEnableNotifier.value = false;
    }
    if (widget.mode == Mode.overlay) {
      _removeOverlay();
    }
  }

  @override
  void onQueryProcessing(FormeSearchCondition condition) {
    super.onQueryProcessing(condition);
    if (widget.mode == Mode.base) {
      _baseContentEnableNotifier.value = true;
    }
    if (widget.mode == Mode.overlay) {
      _insertOverlay();
    }
  }

  @override
  void onReset() {
    super.onReset();
    _close();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == Mode.overlay) {
      return CompositedTransformTarget(
        link: _layerLink,
        child: _buildDisplay(),
      );
    }
    if (widget.mode == Mode.base) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDisplay(),
            ValueListenableBuilder<bool>(
                valueListenable: _baseContentEnableNotifier,
                builder: (context, enable, child) {
                  return Visibility(
                      visible: enable,
                      child: _buildMaterial(
                        widget.baseConfiguration.materialConfiguration,
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: widget.baseConfiguration.maximumHeight ??
                                double.infinity,
                          ),
                          child: _build(),
                        ),
                      ));
                }),
          ]);
    }

    return GestureDetector(
      onTap: status.readOnly
          ? null
          : () {
              switch (widget.mode) {
                case Mode.bottomSheet:
                  focusNode.requestFocus();
                  _showModalBottomSheet();
                  break;
                case Mode.dialog:
                  focusNode.requestFocus();
                  _showDialog();
                  break;
                case Mode.base:
                  break;
                case Mode.overlay:
                  break;
              }
            },
      child: _buildDisplay(),
    );
  }

  void _delete(T option) {
    final List<T> newValue = List.of(status.value)
      ..removeWhere((element) => element == option);
    if (newValue.length != status.value.length) {
      value = newValue;
    }
  }

  Widget _buildDisplay() {
    return widget.displayBuilder?.call(
          context,
        ) ??
        (widget.mode == Mode.base || widget.mode == Mode.overlay
            ? BaseSearchableDisplayWidget(
                decoration: widget.decoration,
                displayStringForOption: widget.displayStringForOption,
              )
            : BaseDisplayWidget<T>(
                decoration: widget.decoration,
                status: status,
                delete: status.readOnly ? null : _delete,
                focusNode: focusNode,
                displayStringForOption: widget.displayStringForOption));
  }

  Widget _build() {
    final bool closeable =
        widget.mode == Mode.base || widget.mode == Mode.overlay;
    final bool animationEnable = widget.mode == Mode.base
        ? widget.baseConfiguration.animationEnable
        : widget.mode == Mode.bottomSheet
            ? widget.bottomSheetConfiguration.animationEnable
            : widget.mode == Mode.overlay
                ? widget.overlayConfiguration.animationEnable
                : false;
    final bool flexiable = widget.mode == Mode.dialog;
    final bool inherit = widget.mode != Mode.base;
    final bool buildSearchFields =
        widget.mode != Mode.base && widget.mode != Mode.overlay;
    final bool performSearchAfterOpen =
        (widget.mode == Mode.base || widget.mode == Mode.overlay)
            ? false
            : widget.mode == Mode.dialog
                ? widget.dialogConfiguration.performSearchAfterOpen
                : widget.bottomSheetConfiguration.performSearchAfterOpen;
    Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (closeable)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                if (widget.mode == Mode.base) {
                  _baseContentEnableNotifier.value = false;
                } else {
                  _removeOverlay();
                }
              },
            ),
          ),
        if (buildSearchFields)
          widget.searchFieldsBuilder?.call(
                context,
              ) ??
              BaseSearchFields<T>(
                decoration: widget.searchFieldDecoration,
                performSearchAfterInitState: performSearchAfterOpen,
              ),
        widget.paginationBarBuilder?.call(
              context,
            ) ??
            BasePaginationBar<T>(
              configuration: widget.defaultPaginationConfiguration ??
                  const FormePaginationConfiguration(),
            ),
        widget.contentBuilder?.call(context) ??
            BaseFieldContent<T>(
              emptyContentWidgetBuilder: widget.emptyContentWidgetBuilder,
              displayStringForOption: widget.displayStringForOption,
              errorWidgetBuilder: widget.errorWidgetBuilder,
              optionWidgetBuilder: widget.optionWidgetBuilder,
              processingWidgetBuilder: widget.processingWidgetBuilder,
              flexiable: flexiable,
            ),
      ],
    );
    if (animationEnable) {
      final Duration duration = widget.mode == Mode.bottomSheet
          ? widget.bottomSheetConfiguration.animationDuration
          : widget.mode == Mode.base
              ? widget.baseConfiguration.animationDuration
              : widget.overlayConfiguration.animationDuration;
      final Curve curve = widget.mode == Mode.bottomSheet
          ? widget.bottomSheetConfiguration.animationCurve
          : widget.mode == Mode.base
              ? widget.baseConfiguration.animationCurve
              : widget.overlayConfiguration.animationCurve;
      column = AnimatedSize(
          curve: curve,
          alignment: Alignment.topCenter,
          duration: duration,
          child: column);
    }
    if (inherit) {
      return super.inherit(column);
    }
    return column;
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
                child: _buildMaterial(
                    widget.dialogConfiguration.materialConfiguration,
                    Padding(
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
                            child: _build(),
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
                    )),
              ),
            );
          },
        );
      },
    ).then((value) {
      if (mounted) {
        resetQueryStatus();
      }
    });
    Navigator.popUntil(context, (route) {
      _route = route;
      return true;
    });
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
                return Padding(
                  padding: EdgeInsets.only(bottom: data.viewInsets.bottom),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight:
                          widget.bottomSheetConfiguration.maximumHeight ??
                              double.infinity,
                    ),
                    child: _build(),
                  ),
                );
              });
        }).then((value) {
      if (mounted) {
        resetQueryStatus();
      }
    });
    Navigator.popUntil(context, (route) {
      _route = route;
      return true;
    });
  }

  Widget _buildMaterial(
      FormeMaterialConfiguration configuration, Widget child) {
    return Material(
      animationDuration: configuration.animationDuration,
      clipBehavior: configuration.clipBehavior,
      borderOnForeground: configuration.borderOnForeground,
      shape: configuration.shape,
      borderRadius: configuration.borderRadius,
      textStyle: configuration.textStyle,
      shadowColor: configuration.shadowColor,
      color: configuration.color,
      type: configuration.type,
      elevation: configuration.elevation,
      child: child,
    );
  }

  void _close() {
    _removeOverlay();
    _closeRoute();
    _baseContentEnableNotifier.value = false;
  }

  void _removeOverlay() {
    if (_entry != null && _entry!.mounted) {
      _entry!.remove();
    }
  }

  void _closeRoute() {
    if (_route != null && _route!.isActive) {
      Navigator.popUntil(context, (route) {
        if (route == _route) {
          Navigator.pop(context);
          return true;
        }
        return false;
      });
    }
  }

  void _insertOverlay() {
    if (_entry != null && _entry!.mounted) {
      return;
    }
    _entry = OverlayEntry(builder: (context) {
      return CompositedTransformFollower(
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        link: _layerLink,
        child: LayoutBuilder(
          builder: (context, c) {
            return Align(
              alignment: Alignment.topLeft,
              child: _buildMaterial(
                widget.overlayConfiguration.materialConfiguration,
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: widget.baseConfiguration.maximumHeight ??
                        double.infinity,
                    maxWidth: _layerLink.leaderSize!.width,
                    minWidth: _layerLink.leaderSize!.width,
                  ),
                  child: _build(),
                ),
              ),
            );
          },
        ),
      );
    });
    Overlay.of(context)!.insert(_entry!);
  }
}
