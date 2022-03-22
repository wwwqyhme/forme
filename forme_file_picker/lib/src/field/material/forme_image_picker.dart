import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import 'draggable_grid_view.dart';

typedef ImagePickerBuilder = Widget Function(
  FormeImagePickerState field,
);

typedef GridItemBuilder = Widget Function(
  ValueChanged<int> removeByUserInteractive,
  FormeImage item,
  int index,
  bool readOnly,
  bool enable,
);

class FormeImagePicker extends FormeField<List<FormeImage>> {
  final int? maximum;

  /// color of remove icon default is [Colors.redAccent]
  final Color? gridItemRemoveIconColor;

  /// padding of grid item , default is top:12 right:12
  final EdgeInsetsGeometry? gridItemPadding;

  final Color? imagePickerColor;
  final Color? imagePickerDisabledColor;
  final Widget? imagePickerChild;

  /// whether show image picker when readOnly or disabled, default is true
  final bool showImagePickerWhenReadOnly;

  final bool showGridItemRemoveIcon;

  /// whether an image can be removed by user interactive
  ///
  /// **if you only check removable by index , the file at index can still be removed after sort by drag , use [draggable] disable drag conditonal**
  ///
  /// **you call still remove this image by [FormeImagePickerState]**
  final bool Function(FormeImage image, int index)? removable;

  final IconData? gridItemRemoveIcon;

  /// grid item remove icon size , default is 24
  final double gridItemRemoveIconSize;

  final Widget? pickImageFromCameraOnBottomSheet;
  final Widget? pickImageFromGalleryOnBottomSheet;
  final Widget? cancelOnBottomSheet;

  /// builder display widget  when image loading failed
  final Widget Function(BuildContext context, FormeImage item, Object error,
      StackTrace? stackTrace)? imageLoadingErrorBuilder;

  /// builder display widget  when image is loading
  final Widget Function(
    BuildContext context,
    FormeImage item,
  )? imageLoadingBuilder;

  /// image fit , default is [BoxFit.cover]
  final BoxFit imageFit;

  /// whether item is draggable , default  every item is draggable
  ///
  /// **if you only check draggable by index , the file at index can still be draggable after sort by drag **
  final bool Function(FormeImage item, int index)? draggable;
  final Duration? longPressDelayStartDrag;
  final Widget Function(
          BuildContext context, FormeImage item, int index, Widget child)?
      childWhenDraggingBuilder;
  final Widget Function(BuildContext context, FormeImage item, int index,
      Widget child, Size? size)? feedbackBuilder;

  /// whether reOrderable on drag
  final bool reOrderable;

  final bool supportCamera;

  /// should not be null if [supportCamera] is true
  final Future<List<FormeImage>> Function(int? max)? pickFromCamera;

  /// parameter max is not a restriction but just tell you how many images can be inserted.
  final Future<List<FormeImage>> Function(int? max) pickFromGallery;

  FormeImagePicker({
    Duration? animateDuration,
    this.maximum,
    ImagePickerBuilder? imagePickerBuilder,
    GridItemBuilder? gridItemBuilder,
    required SliverGridDelegate gridDelegate,
    List<FormeImage>? initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    InputDecoration? decoration,
    FormeFieldDecorator<List<FormeImage>>? decorator,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<List<FormeImage>>? onStatusChanged,
    FormeFieldInitialed<List<FormeImage>>? onInitialed,
    FormeFieldSetter<List<FormeImage>>? onSaved,
    FormeValidator<List<FormeImage>>? validator,
    FormeAsyncValidator<List<FormeImage>>? asyncValidator,
    bool requestFocusOnUserInteraction = true,
    bool registrable = true,
    bool enabled = true,
    this.gridItemRemoveIconColor,
    this.gridItemPadding,
    this.showImagePickerWhenReadOnly = true,
    this.imagePickerColor,
    this.imagePickerDisabledColor,
    this.imagePickerChild,
    this.gridItemRemoveIcon,
    this.showGridItemRemoveIcon = true,
    this.gridItemRemoveIconSize = 24,
    this.pickImageFromCameraOnBottomSheet,
    this.pickImageFromGalleryOnBottomSheet,
    this.cancelOnBottomSheet,
    Curve? slideCurve,
    this.imageLoadingErrorBuilder,
    this.imageFit = BoxFit.cover,
    this.removable,
    this.draggable,
    this.longPressDelayStartDrag,
    this.childWhenDraggingBuilder,
    this.feedbackBuilder,
    this.reOrderable = true,
    EdgeInsetsGeometry? gridViewPadding,
    bool shrinkWrap = true,
    ScrollController? scrollController,
    ScrollPhysics? physics,
    required this.pickFromGallery,
    this.supportCamera = false,
    this.pickFromCamera,
    this.imageLoadingBuilder,
    FormeFieldValidationFilter<List<FormeImage>>? validationFilter,
    FormeValueComparator<List<FormeImage>>? comparator,
  }) : super(
            comparator: comparator,
            validationFilter: validationFilter,
            enabled: enabled,
            registrable: registrable,
            requestFocusOnUserInteraction: requestFocusOnUserInteraction,
            order: order,
            quietlyValidate: quietlyValidate,
            asyncValidatorDebounce: asyncValidatorDebounce,
            autovalidateMode: autovalidateMode,
            onStatusChanged: onStatusChanged,
            onInitialed: onInitialed,
            onSaved: onSaved,
            validator: validator,
            asyncValidator: asyncValidator,
            key: key,
            decorator: decorator ??
                (decoration == null
                    ? null
                    : FormeInputDecoratorBuilder(
                        decoration: decoration,
                        maxLength: maximum,
                        counter: (value) => value.length,
                      )),
            readOnly: readOnly,
            name: name,
            initialValue: initialValue ?? <FormeImage>[],
            builder: (genericState) {
              final FormeImagePickerState state =
                  genericState as FormeImagePickerState;
              return DraggableGridView<_Item<FormeImage>>(
                scrollController: scrollController,
                physics: physics ?? const NeverScrollableScrollPhysics(),
                shrinkWrap: shrinkWrap,
                padding: gridViewPadding,
                reOrderable: reOrderable,
                slideCurve: slideCurve,
                animateDuration:
                    animateDuration ?? const Duration(milliseconds: 150),
                gridDelegate: gridDelegate,
                onAccept: state._onAccept,
                builder: (context, item, index) {
                  if (maximum != null &&
                      state._gridController.value.length - 1 >= maximum &&
                      item.value == null) {
                    return Container();
                  }
                  Widget child;
                  if (item.value == null) {
                    child = (imagePickerBuilder ?? state._defaultImagePicker)
                        .call(state);
                  } else {
                    child = (gridItemBuilder ?? state._defaultGridItem).call(
                      (int index) {
                        if (readOnly) {
                          return;
                        }
                        state._removeByUserInteractive(index);
                      },
                      item.value!,
                      index,
                      state.readOnly,
                      state.enabled,
                    );
                  }
                  return child;
                },
                draggableConfiguration: state._draggableConfiguration(),
                controller: state._gridController,
              );
            });

  @override
  FormeFieldState<List<FormeImage>> createState() => FormeImagePickerState();
}

class FormeImagePickerState extends FormeFieldState<List<FormeImage>> {
  @override
  FormeImagePicker get widget => super.widget as FormeImagePicker;

  late GridController<_Item<FormeImage>> _gridController;

  late final ValueNotifier<bool> _draggingNotifer =
      FormeMountedValueNotifier(false);

  @override
  void initStatus() {
    super.initStatus();
    _gridController = GridController(_convert(List.of(initialValue)));
    _gridController.addListener(() {
      didChange(_gridController.value
          .where((element) => element.value != null)
          .map((e) => e.value!)
          .toList());
    });
  }

  /// when you have your own [DragTarget] and want to accept data from [FormeImagePicker]
  /// you can use this method in [DragTarget.onWillAccept]
  bool canAccept(dynamic data) => _gridController.canAccept(data);

  int? get maxInsertableNum => _maxInsetableNum;

  ValueListenable<bool> get draggingListenable =>
      FormeValueListenableDelegate(_draggingNotifer);

  List<_Item<FormeImage>> _convert(List<FormeImage> images) {
    List<_Item<FormeImage>> items = images.map((e) => _Item(e)).toList();
    if (widget.maximum != null && items.length > widget.maximum!) {
      items = items.sublist(0, widget.maximum);
    }

    final bool showImagePicker =
        (!readOnly && enabled) || widget.showImagePickerWhenReadOnly;
    if (showImagePicker &&
        (widget.maximum == null || items.length < widget.maximum!)) {
      items.add(_Item.empty());
    }
    return items;
  }

  @override
  void dispose() {
    _draggingNotifer.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<List<FormeImage>> status) {
    super.onStatusChanged(status);
    if (status.isValueChanged) {
      _gridController.value = _convert(status.value);
    }
  }

  void _removeByUserInteractive(int index) {
    if (!mounted) {
      return;
    }
    if (widget.removable != null &&
        !widget.removable!(_gridController.value[index].value!, index)) {
      return;
    }
    remove([index]);
  }

  /// stop animations and commit changes
  void commit() {
    if (!mounted || _gridController.currentItems == null) {
      return;
    }
    _gridController.value = _convert(_gridController.currentItems!
        .where((element) => element.value != null)
        .map((e) => e.value!)
        .toList());
  }

  /// animate & remove item at index
  void remove(List<int> indexes) {
    if (!mounted) {
      return;
    }
    _gridController.remove(indexes, commit);
  }

  /// animate & remove data
  ///
  /// useful when you want to implement drag to remove
  void removeData(dynamic data) {
    if (!mounted) {
      return;
    }
    _gridController.removeData(data, commit);
  }

  Widget _errorBuilder(
      BuildContext context, FormeImage item, Object error, StackTrace? trace) {
    return widget.imageLoadingErrorBuilder?.call(context, item, error, trace) ??
        const Center(
            child: Icon(
          Icons.broken_image_rounded,
        ));
  }

  Image _image(ImageProvider provider, FormeImage item) {
    return Image(
      image: provider,
      fit: widget.imageFit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        item._broken = true;
        return _errorBuilder(context, item, error, stackTrace);
      },
    );
  }

  Widget _defaultGridItem(ValueChanged<int> remove, FormeImage item, int index,
      bool readOnly, bool enable) {
    Widget image;
    if (item.cache != null) {
      image = _image(item.cache!, item);
    } else {
      image = FutureBuilder<ImageProvider>(
        future: item.image,
        builder: (context, builder) {
          if (builder.connectionState == ConnectionState.waiting) {
            if (widget.imageLoadingBuilder != null) {
              return widget.imageLoadingBuilder!(context, item);
            }
          } else {
            if (builder.hasError) {
              return _errorBuilder(
                  context, item, builder.error!, builder.stackTrace);
            }
            if (builder.hasData) {
              item._cache = builder.data;
              return _image(builder.data!, item);
            }
          }
          return const SizedBox.shrink();
        },
      );
    }

    final bool showGridItemRemoveIcon = widget.showGridItemRemoveIcon &&
        (widget.removable == null || widget.removable!(item, index));

    return Stack(
      children: [
        Padding(
          padding: widget.gridItemPadding ??
              (widget.showGridItemRemoveIcon
                  ? EdgeInsets.only(
                      top: readOnly ? 0 : widget.gridItemRemoveIconSize / 2,
                      right: readOnly ? 0 : widget.gridItemRemoveIconSize / 2,
                    )
                  : EdgeInsets.zero),
          child: image,
        ),
        if (!readOnly && showGridItemRemoveIcon)
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              highlightColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: Icon(
                widget.gridItemRemoveIcon ?? Icons.cancel,
                color: widget.gridItemRemoveIconColor ?? Colors.redAccent,
                size: widget.gridItemRemoveIconSize,
              ),
              onTap: () {
                remove(index);
              },
            ),
          )
      ],
    );
  }

  void insertPickedImages(List<FormeImage> images) {
    if (!mounted || images.isEmpty) {
      return;
    }

    final List<FormeImage> currentValue =
        (_gridController.currentItems ?? _gridController.value)
            .where((element) => element.value != null)
            .map((e) => e.value!)
            .toList();
    final int num = currentValue.length;
    if (widget.maximum != null && num >= widget.maximum!) {
      return;
    }
    final Iterable<FormeImage> needInserts =
        images.where((element) => !currentValue.contains(element)).toList();
    if (needInserts.isEmpty) {
      return;
    }
    final List<FormeImage> list = [];
    for (final FormeImage item in needInserts) {
      if (!list.contains(item)) {
        list.add(item);
      }
    }
    _gridController.value = _convert(currentValue..addAll(list));
  }

  int? get _maxInsetableNum =>
      widget.maximum == null ? null : widget.maximum! - value.length;

  Future _pickFromGallery() async {
    final int? maxNum = _maxInsetableNum;
    if (readOnly || (maxNum != null && maxNum < 1)) {
      return;
    }
    final List<FormeImage> images = await widget.pickFromGallery(maxNum);
    insertPickedImages(images);
  }

  Future _pickFromCamera() async {
    final int? maxNum = _maxInsetableNum;
    if (readOnly ||
        widget.pickFromCamera == null ||
        (maxNum != null && maxNum < 1)) {
      return;
    }
    final List<FormeImage> images = await widget.pickFromCamera!(maxNum);
    insertPickedImages(images);
  }

  Widget _defaultImagePicker(FormeImagePickerState field) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: readOnly
          ? null
          : () {
              if (widget.supportCamera) {
                showModalBottomSheet<dynamic>(
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10.0)),
                  ),
                  context: context,
                  builder: (context) {
                    return Wrap(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _pickFromCamera();
                          },
                          child: widget.pickImageFromCameraOnBottomSheet ??
                              const ListTile(
                                title: Center(
                                    child: Text('Pick Image from Camera')),
                              ),
                        ),
                        const Divider(),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _pickFromGallery();
                          },
                          child: widget.pickImageFromGalleryOnBottomSheet ??
                              const ListTile(
                                title: Center(
                                    child: Text('Pick Image from Gallery')),
                              ),
                        ),
                        Divider(
                          color: Colors.grey.withOpacity(0.1),
                          thickness: 10,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: widget.cancelOnBottomSheet ??
                              const ListTile(
                                title: Center(
                                  child: Text('Cancel'),
                                ),
                              ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                _pickFromGallery();
              }
            },
      child: Padding(
        padding: widget.gridItemPadding ??
            (widget.showGridItemRemoveIcon
                ? EdgeInsets.only(
                    top: widget.gridItemRemoveIconSize / 2,
                    right: widget.gridItemRemoveIconSize / 2,
                  )
                : EdgeInsets.zero),
        child: Container(
          color: readOnly
              ? widget.imagePickerDisabledColor ??
                  Theme.of(context).disabledColor
              : widget.imagePickerColor ?? Colors.grey.withOpacity(0.3),
          child:
              widget.imagePickerChild ?? const Center(child: Icon(Icons.add)),
        ),
      ),
    );
  }

  DraggableConfiguration<_Item<FormeImage>> _draggableConfiguration() {
    return DraggableConfiguration<_Item<FormeImage>>(
      draggable: (item, index) {
        if (item.value == null) {
          return false;
        }
        return widget.draggable?.call(item.value!, index) ?? true;
      },
      longPressDelay: widget.longPressDelayStartDrag,
      childWhenDraggingBuilder: widget.childWhenDraggingBuilder == null
          ? null
          : (context, item, index, child) {
              return widget.childWhenDraggingBuilder!(
                  context, item.value!, index, child);
            },
      feedbackBuilder: widget.feedbackBuilder == null
          ? null
          : (context, item, index, child, size) {
              return widget.feedbackBuilder!(
                  context, item.value!, index, child, size);
            },
      onDragStart: (int index) {
        _draggingNotifer.value = true;
      },
      onDragEnd: (int index) {
        _draggingNotifer.value = false;
      },
    );
  }

  void _onAccept(List<_Item<FormeImage>> value) {
    _gridController.value = value;
  }
}

abstract class FormeImage {
  Future<ImageProvider> get image;
  bool? _broken;
  ImageProvider? _cache;

  ///  typically this `image` is not a real image or can not be decoded by current platform
  ///
  /// return null if image not decoded
  bool? get isBroken => _broken;

  /// cached imageprovider after successful load from [image]
  ImageProvider? get cache => _cache;

  /// get file name
  String? get name;

  /// get image bytes,used to save to a file
  ///
  /// there's no need to implementing this method in your custom `FormeImage`
  Future<Uint8List>? readAsBytes();
}

class _Item<T> {
  final T? value;

  const _Item(this.value);

  _Item.empty() : value = null;
}
