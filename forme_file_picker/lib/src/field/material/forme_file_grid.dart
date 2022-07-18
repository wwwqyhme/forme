import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import 'draggable_grid_view.dart';
import 'forme_upload_controller.dart';
import 'upload_stack.dart';

typedef FilePickerBuilder = Widget Function(
  FormeFileGridState field,
);
typedef OnFileUploadSuccess = void Function(FormeFile file, Object? result);
typedef ONFileUploadFail = void Function(
    FormeFile file, Object error, StackTrace? stackTrace);

class FormeFileGrid extends FormeField<List<FormeFile>> {
  final int? maximum;

  /// color of remove icon default is [Colors.redAccent]
  final Color? gridItemRemoveIconColor;

  /// padding of grid item , default is top:12 right:12
  final EdgeInsetsGeometry? gridItemPadding;

  final Color? filePickerColor;
  final Color? filePickerDisabledColor;
  final Widget? filePickerChild;

  /// whether show image picker when readOnly or disabled, default is true
  final bool showFilePickerWhenReadOnly;
  final bool disableFilePicker;

  final bool showGridItemRemoveIcon;

  /// whether an image can be removed by user interactive
  ///
  /// **if you only check removable by index , the file at index can still be removed after sort by drag , use [draggable] disable drag conditonal**
  ///
  /// **you call still remove this image by [FormeFileGridState]**
  final bool Function(FormeFile image, int index)? removable;

  final IconData? gridItemRemoveIcon;

  /// grid item remove icon size , default is 24
  final double gridItemRemoveIconSize;

  /// builder display widget  when thumbnail create failed or image loading failed
  ///
  ///retry will be null if  image loading failed
  final Widget Function(
      BuildContext context,
      FormeFile item,
      VoidCallback? retry,
      Object error,
      StackTrace? stackTrace)? imageLoadingErrorBuilder;

  /// builder display widget  when image is loading
  final Widget Function(
    BuildContext context,
    FormeFile item,
  )? imageLoadingBuilder;

  /// image fit , default is [BoxFit.cover]
  final BoxFit imageFit;

  /// whether item is draggable , default  every item is draggable
  ///
  /// **if you only check draggable by index , the file at index can still be draggable after sort by drag **
  final bool Function(FormeFile item, int index)? draggable;
  final Duration? longPressDelayStartDrag;
  final Widget Function(
          BuildContext context, FormeFile item, int index, Widget child)?
      childWhenDraggingBuilder;
  final Widget Function(BuildContext context, FormeFile item, int index,
      Widget child, Size? size)? feedbackBuilder;

  /// use [FormeFileGridState.insertFiles] to insert your picked files
  final void Function(FormeFileGridState state, int? maximum) pickFiles;

  /// whether reOrderable on drag
  final bool reOrderable;

  final OnFileUploadSuccess? onUploadSuccess;
  final ONFileUploadFail? onUploadFail;

  FormeFileGrid({
    Duration? animateDuration,
    this.maximum,
    FilePickerBuilder? filePickerBuilder,
    required SliverGridDelegate gridDelegate,
    List<FormeFile>? initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    InputDecoration? decoration,
    FormeFieldDecorator<List<FormeFile>>? decorator,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<List<FormeFile>>? onStatusChanged,
    FormeFieldInitialed<List<FormeFile>>? onInitialed,
    FormeFieldSetter<List<FormeFile>>? onSaved,
    FormeValidator<List<FormeFile>>? validator,
    FormeAsyncValidator<List<FormeFile>>? asyncValidator,
    bool requestFocusOnUserInteraction = true,
    bool registrable = true,
    bool enabled = true,
    this.gridItemRemoveIconColor,
    this.gridItemPadding,
    this.showFilePickerWhenReadOnly = true,
    this.disableFilePicker = false,
    this.filePickerColor,
    this.filePickerDisabledColor,
    this.filePickerChild,
    this.gridItemRemoveIcon,
    this.showGridItemRemoveIcon = true,
    this.gridItemRemoveIconSize = 24,
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
    this.imageLoadingBuilder,
    FormeFieldValidationFilter<List<FormeFile>>? validationFilter,
    FormeValueComparator<List<FormeFile>>? comparator,
    ValueChanged<FormeFile>? onGridItemTap,
    this.onUploadSuccess,
    this.onUploadFail,
    required this.pickFiles,
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
            initialValue: initialValue ?? <FormeFile>[],
            builder: (genericState) {
              final FormeFileGridState state =
                  genericState as FormeFileGridState;
              return DraggableGridView<_Item<FormeFile>>(
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
                    child = (filePickerBuilder ?? state._defaultFilePicker)
                        .call(state);
                  } else {
                    child = GestureDetector(
                      onTap: onGridItemTap == null
                          ? null
                          : () {
                              onGridItemTap.call(item.value!);
                            },
                      child: state._gridItem.call(item.value!, index),
                    );
                  }
                  return child;
                },
                draggableConfiguration: state._draggableConfiguration(),
                controller: state._gridController,
              );
            });

  @override
  FormeFieldState<List<FormeFile>> createState() => FormeFileGridState();
}

class FormeFileGridState extends FormeFieldState<List<FormeFile>> {
  @override
  FormeFileGrid get widget => super.widget as FormeFileGrid;

  late GridController<_Item<FormeFile>> _gridController;

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

  /// when you have your own [DragTarget] and want to accept data from [FormeFileGrid]
  /// you can use this method in [DragTarget.onWillAccept]
  bool canAccept(dynamic data) => _gridController.canAccept(data);

  int? get maxInsertableNum => _maxInsetableNum;

  ValueListenable<bool> get draggingListenable =>
      FormeValueListenableDelegate(_draggingNotifer);

  List<_Item<FormeFile>> _convert(List<FormeFile> files) {
    List<_Item<FormeFile>> items = files.map((e) => _Item(e)).toList();
    if (widget.maximum != null && items.length > widget.maximum!) {
      items = items.sublist(0, widget.maximum);
    }

    final bool showFilePicker = !widget.disableFilePicker &&
        ((!readOnly && enabled) || widget.showFilePickerWhenReadOnly);
    if (showFilePicker &&
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
  void onStatusChanged(FormeFieldChangedStatus<List<FormeFile>> status) {
    super.onStatusChanged(status);
    if (status.isValueChanged) {
      _gridController.value = _convert(status.value);
      if (oldValue != null) {
        final List<FormeFile> removed = oldValue!
            .where((element) => !status.value.contains(element))
            .toList();
        for (final FormeFile file in removed) {
          file._uploadController?.cancel();
        }
      }
    }
  }

  void _removeByUserInteractive(FormeFile item, int index) {
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

  /// upload all uploadable file
  void upload([List<FormeFile>? files]) {
    for (final FormeFile element in _find(files)) {
      _createFileUploadController(element).upload();
    }
  }

  void retryUpload([List<FormeFile>? files]) {
    for (final FormeFile element in _find(files)) {
      _createFileUploadController(element).retry();
    }
  }

  void cancelUpload([List<FormeFile>? files]) {
    for (final FormeFile element in _find(files)) {
      _createFileUploadController(element).cancel();
    }
  }

  FormeFileUploadController _createFileUploadController(FormeFile file) {
    return file._createUploadController(
        widget.onUploadSuccess == null
            ? null
            : (result) {
                widget.onUploadSuccess?.call(file, result);
              },
        widget.onUploadFail == null
            ? null
            : (error, trace) {
                widget.onUploadFail?.call(file, error, trace);
              });
  }

  List<FormeFile> _find(List<FormeFile>? files) {
    return files == null
        ? value
        : value.where((element) => files.contains(element)).toList();
  }

  Widget _errorBuilder(BuildContext context, FormeFile item,
      VoidCallback? retry, Object error, StackTrace? trace) {
    return widget.imageLoadingErrorBuilder
            ?.call(context, item, retry, error, trace) ??
        Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
              child: IconButton(
            onPressed: retry,
            icon: const Icon(Icons.broken_image_rounded),
            color: Theme.of(context).errorColor,
          )),
        );
  }

  Widget _loadingBuilder(
    BuildContext context,
    FormeFile item,
  ) {
    return widget.imageLoadingBuilder?.call(context, item) ??
        const Center(
          child: CircularProgressIndicator(),
        );
  }

  Widget _thumbnail(ImageProvider provider, FormeFile item) {
    return Image(
      image: provider,
      fit: widget.imageFit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return Stack(
            children: [
              child,
              if (item.uploadable)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
              if (item.uploadable)
                UploadStack(
                  autoUpload: item.autoUpload,
                  controller: _createFileUploadController(item),
                ),
            ],
          );
        }
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _errorBuilder(context, item, null, error, stackTrace);
      },
    );
  }

  Widget _gridItem(
    FormeFile item,
    int index,
  ) {
    final bool readOnly = this.readOnly;
    Widget thumbnail;
    if (item._cache != null) {
      thumbnail = _thumbnail(item._cache!, item);
    } else {
      thumbnail = Builder(builder: (builderContext) {
        return FutureBuilder<ImageProvider>(
          future: item._thumbnail,
          builder: (context, builder) {
            if (builder.connectionState == ConnectionState.waiting) {
              return _loadingBuilder(context, item);
            } else {
              if (builder.hasError) {
                return _errorBuilder(context, item, () {
                  if (mounted) {
                    item._future = null;
                    (builderContext as Element).markNeedsBuild();
                  }
                }, builder.error!, builder.stackTrace);
              }
              if (builder.hasData) {
                item._cache = builder.data;
                return _thumbnail(builder.data!, item);
              }
            }
            return const SizedBox.shrink();
          },
        );
      });
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
          child: thumbnail,
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
                _removeByUserInteractive(item, index);
              },
            ),
          )
      ],
    );
  }

  void insertFiles(List<FormeFile> files) {
    if (!mounted || files.isEmpty) {
      return;
    }

    final List<FormeFile> currentValue =
        (_gridController.currentItems ?? _gridController.value)
            .where((element) => element.value != null)
            .map((e) => e.value!)
            .toList();
    final int num = currentValue.length;
    final int? canInsertNums =
        widget.maximum == null ? null : widget.maximum! - num;
    if (canInsertNums != null && canInsertNums <= 0) {
      return;
    }

    List<FormeFile> needInserts =
        files.where((element) => !currentValue.contains(element)).toList();
    if (needInserts.isEmpty) {
      return;
    }

    if (canInsertNums != null && canInsertNums < needInserts.length) {
      needInserts = needInserts.sublist(0, canInsertNums);
    }

    final List<FormeFile> list = [];
    for (final FormeFile item in needInserts) {
      if (!list.contains(item)) {
        list.add(item);
      }
    }
    _gridController.value = _convert(currentValue..addAll(list));
  }

  int? get _maxInsetableNum =>
      widget.maximum == null ? null : widget.maximum! - value.length;

  Widget _defaultFilePicker(FormeFileGridState field) {
    return GestureDetector(
      onTap: readOnly
          ? null
          : () {
              widget.pickFiles.call(this, _maxInsetableNum);
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
              ? widget.filePickerDisabledColor ??
                  Theme.of(context).disabledColor
              : widget.filePickerColor ?? Colors.grey.withOpacity(0.3),
          child: widget.filePickerChild ?? const Center(child: Icon(Icons.add)),
        ),
      ),
    );
  }

  DraggableConfiguration<_Item<FormeFile>> _draggableConfiguration() {
    return DraggableConfiguration<_Item<FormeFile>>(
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

  void _onAccept(List<_Item<FormeFile>> value) {
    _gridController.value = value;
  }
}

@immutable
class _Item<T> {
  final T? value;
  const _Item(this.value);

  _Item.empty() : value = null;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    return other is _Item<T> && other.value == value;
  }
}

abstract class FormeFile {
  Future<ImageProvider> get thumbnail;
  Future<ImageProvider> get _thumbnail => _future ??= thumbnail;

  bool get uploadable => false;
  bool get autoUpload => false;

  bool get isUploading =>
      uploadable && (_uploadController?.isUploading ?? false);
  bool get isUploadSuccess =>
      uploadable && (_uploadController?.isUploadSuccess ?? false);
  Object? get uploadResult => _uploadController?.uploadResult;
  bool get isUploadError =>
      uploadable && (_uploadController?.isUploadError ?? false);
  Object? get uploadError => _uploadController?.error;
  StackTrace? get uploadErrorStackTrace => _uploadController?.stackTrace;

  Future<Object?> upload() => throw UnimplementedError();
  void cancelUpload() {}

  /// notify file upload progress
  void progress(Widget? widget) {
    _uploadController?.progress(widget);
  }

  /// cached thumbnail feature
  Future<ImageProvider>? _future;
  ImageProvider? _cache;

  FormeFileUploadController? _uploadController;
  FormeFileUploadController _createUploadController(
      Function(Object? result)? onUploadSuccess,
      Function(Object error, StackTrace? trace)? onUploadFail) {
    return _uploadController ??= FormeFileUploadController(
        upload, cancelUpload, onUploadSuccess, onUploadFail);
  }
}
