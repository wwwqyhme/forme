## FormeFileGrid

**this package only provide move,sort,display your picked files. you must implement file picker via file_picker or other packages by yourself**

### example

https://www.qyh.me/forme3/index.html

### screenshot

![forme_file_grid](https://raw.githubusercontent.com/wwwqyhme/forme/main/forme_file_picker/forme_file_grid.gif)

### Usage 

``` dart
 FormeFileGrid({
  Duration? animateDuration,/// animate duration , default 150ms
  int? maximum,/// the maximum number of files can picked , null means unlimited , default is null
  Widget Function(FormeFileGridState state)? filePickerBuilder,/// used to build pick widget
  required SliverGridDelegate gridDelegate,
  Color? gridItemRemoveIconColor,/// remove icon color , default is [Colors.redAccent]
  EdgeInsetsGeometry? gridItemPadding,/// grid item padding
  bool showFilePickerWhenReadOnly = true,// whether show picker when readOnly ,default true
  bool disableFilePicker = false,//disable file picker always , default is false
  Color? filePickerColor,// picker color , default is Colors.grey.withOpacity(0.3)
  Color? filePickerDisabledColor,/// color when picker disabled ,default is Theme.of(context).disabledColor
  Widget? filePickerChild, /// child widget of picker ,not worked when [imagePickerBuilder] not null
  IconData? gridItemRemoveIcon,/// grid item remove icon data , default is Icons.cancel
  bool showGridItemRemoveIcon = true,/// whether show remove icon on grid item
  double gridItemRemoveIconSize = 24,/// icon size of remove icon , default is 24
  bool supportCamera = false,/// whether support capture with camera , if is true , when tap on picker ,a bottomsheet will be shown. default is false
  Widget? pickImageFromGalleryOnBottomSheet,
  Widget? cancelOnBottomSheet,
  Curve? slideCurve,/// slide animate curve ,default is [Curves.liner]
  Widget Function(BuildContext, Object, StackTrace?)? imageLoadingErrorBuilder,/// widget builder when image load failed , default is a centered borken_image icon
  BoxFit imageFit = BoxFit.cover,/// image fit
  bool Function(FormeFile, int)? removable,/// whether a file or index can be removed , you can still remove them by [FormeFilePickerFieldController]
  bool Function(FormeFile, int)? draggable,/// whether a file or index is draggable
  Duration? longPressDelayStartDrag,/// long press delay when start drag , default is 500ms
  Widget Function(BuildContext, FormeFile, int, Widget)? childWhenDraggingBuilder,/// child builder when dragging
  Widget Function(BuildContext, FormeFile, int, Widget, Size?)? feedbackBuilder,/// feedback builder when dragging
  bool reOrderable = true, /// whether files is reorderable by drag
  void Function(FormeFileGridState state, int? max) pickFromGallery;/// pick your files here , use [FormeFileGridState.insertFiles] to insert your picked files; 
  Widget Function( BuildContext context,FormeFile item)? imageLoadingBuilder /// widget builder when loading image
})
```

### FormeFile

``` dart
abstract class FormeFile {
  Future<ImageProvider> get thumbnail; /// get file thumbnail

  bool get uploadable => false;/// override this method and return true if file is uploadable , do not forget to implement upload method
  bool get autoUpload => false;/// override this method and return true if you want to upload automatically

  bool get isUploading =>
      uploadable && (_uploadController?.isUploading ?? false);
  bool get isUploadSuccess =>
      uploadable && (_uploadController?.isUploadSuccess ?? false); /// is upload success
  Object? get uploadResult => _uploadController?.uploadResult; /// get upload result 
  bool get isUploadError =>
      uploadable && (_uploadController?.isUploadError ?? false); /// whether file upload is failed
  Object? get uploadError => _uploadController?.error; /// get upload error
  StackTrace? get uploadErrorStackTrace => _uploadController?.stackTrace;//get upload error  stacktrace

  Future<Object?> upload() => throw UnimplementedError(); /// implement file upload logic here if uploadable is true
  void cancelUpload() {} /// cancel file upload logic,typically abort a request or close client

  /// notify file upload progress
  void progress(Widget? widget) {
    _uploadController?.progress(widget);
  }
}
```