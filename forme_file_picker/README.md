## FormeFileGrid

**this package only provide move,sort,display your picked images. you must implement image picker via image_picker or other packages by yourself**

### example

https://www.qyh.me/forme3/index.html

### screenshot

![forme_file_grid](https://raw.githubusercontent.com/wwwqyhme/forme/main/forme_file_picker/forme_file_grid.gif)

### Usage 

``` dart
 FormeImagePicker({
  Duration? animateDuration,/// animate duration , default 150ms
  int? maximum,/// the maximum number of files can picked , null means unlimited , default is null
  Widget Function(bool, void Function(ImageSource))? imagePickerBuilder,/// used to build pick widget
  Widget Function(void Function(int), FormeImage, int, bool, bool)? gridItemBuilder,/// used to build grid item
  required SliverGridDelegate gridDelegate,
  List<FormeImage>? initialValue,/// inital value
  Color? gridItemRemoveIconColor,/// remove icon color , default is [Colors.redAccent]
  EdgeInsetsGeometry? gridItemPadding,/// grid item padding
  bool showImagePickerWhenReadOnly = true,// whether show picker when readOnly ,default true
  Color? imagePickerColor,// picker color , default is Colors.grey.withOpacity(0.3)
  Color? imagePickerDisabledColor,/// color when picker disabled ,default is Theme.of(context).disabledColor
  Widget? imagePickerChild, /// child widget of picker ,not worked when [imagePickerBuilder] not null
  IconData? gridItemRemoveIcon,/// grid item remove icon data , default is Icons.cancel
  bool showGridItemRemoveIcon = true,/// whether show remove icon on grid item
  double gridItemRemoveIconSize = 24,/// icon size of remove icon , default is 24
  bool supportCamera = false,/// whether support capture with camera , if is true , when tap on picker ,a bottomsheet will be shown. default is false
  Widget? pickImageFromGalleryOnBottomSheet,
  Widget? cancelOnBottomSheet,
  Curve? slideCurve,/// slide animate curve ,default is [Curves.liner]
  Widget Function(BuildContext, Object, StackTrace?)? imageLoadingErrorBuilder,/// widget builder when image load failed , default is a centered borken_image icon
  BoxFit imageFit = BoxFit.cover,/// image fit
  bool Function(FormeImage, int)? removable,/// whether a file or index can be removed , you can still remove them by [FormeImagePickerFieldController]
  bool Function(FormeImage, int)? draggable,/// whether a file or index is draggable
  Duration? longPressDelayStartDrag,/// long press delay when start drag , default is 500ms
  Widget Function(BuildContext, FormeImage, int, Widget)? childWhenDraggingBuilder,/// child builder when dragging
  Widget Function(BuildContext, FormeImage, int, Widget, Size?)? feedbackBuilder,/// feedback builder when dragging
  bool reOrderable = true, /// whether files is reorderable by drag
  Future<List<FormeImage>> Function(int? max) pickFromGallery;/// pick images from gallery 
  Future<List<FormeImage>> Function(int? max)? pickFromCamera; /// capture with camera
  Widget Function( BuildContext context,FormeImage item)? imageLoadingBuilder /// widget builder when loading image
})
```