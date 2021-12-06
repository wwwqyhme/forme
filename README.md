## Web Demo

https://www.qyh.me/forme3/

## Simple Usage

### add dependency

```
flutter pub add forme
```

### create forme

``` dart
FormeKey key = FormeKey();// formekey is a global key , also  used to control form
Widget child = FormeTextField(name:'username',decoration:const InputDecoration(labelText:'Username'));
Widget forme = Forme(
	key:key,
	child:child,
)
```

## Forme Attributes

| Attribute |  Required  | Type | Description  |
| --- | --- | --- | --- |
| key | false | `FormeKey` | a global key, also used to control form |
| child | true | `Widget` | form content widget|
| readOnly | false | `bool` | whether form should be readOnly,default is `false` |
| onValueChanged | false | `FormeValueChanged` | listen form field's value change |
| initialValue | false | `Map<String,dynamic>` | initialValue , **will override FormField's initialValue** |
| onFieldValidationChanged  | false | `FormeFieldValidationChanged` | listen form validation changed  |
| onValidationChanged  | false | `FormeValidationChanged` | listen form validation change  |
| onWillPop | false | `WillPopCallback` | Signature for a callback that verifies that it's OK to call Navigator.pop |
| quietlyValidate | false | `bool` | if this attribute is true , will not display default error text|
| onFocusChanged | false | `FormeFocusChanged` | listen form field's focus change |
| autovalidateMode| false | `AutovalidateMode` | auto validate form mode |
| autovalidateByOrder | false | `bool` | whether auto validate form by order |
| onFieldsChanged | false | function | listen every field initialled or disposed |


## FormeField

### attributes supported by all FormeField

| Attribute |  Required  | Type | Description  |
| --- | --- | --- | --- |
| name | true | `String` | field's id,**should be unique in form** |
| builder | true | `FieldContentBuilder` | build field content|
| readOnly | false | `bool` | whether field should be readOnly,default is `false` |
| enabled | false | `bool` | whether field is enabled , default is `true` |
| quietlyValidate | true | `bool` | whether validate quietly |
| asyncValidatorDebounce | false | `Duration` | async validate debounce , default is 500ms |
| autovalidateMode | false | `AutovalidateMode` | autovalidate mode |
| onValueChanged | false | `FormeValueChanged` | triggered when field's value changed |
| onFocusChanged | false | `FormeFocusChanged` | triggered when field's focus state changed |
| onValidationChanged | false | `FormeFieldValidationChanged` | triggered when field's validation error changed |
| onInitialed | false | `FormeFieldInitialed` | triggered when field initialed |
| onSaved | false | `FormeFieldSetter` | triggered when form saved |
| validator | false | `FormeValidator` | sync validator |
| asyncValidator | false | `FormeAsyncValidator` | async validator |
| decorator | false | `FormeFieldDecorator` | used to decorator a field |
| order | false | int | order of field |
| requestFocusOnUserInteraction | false | bool | whether request focus when field value changed by user interaction |
| registrable | false | `bool` | whether this field should be registered to Forme |



### currently supported fields

| Name | Return Value | Nullable|
| ---| ---| --- |
| FormeTextField|  string | false |
| FormeDateTimeField|  DateTime | true |
| FormeNumberField|  num | true |
| FormeTimeField | TimeOfDay | true | 
| FormeDateRangeField | DateTimeRange | true | 
| FormeSlider|  double | false |
| FormeRangeSlider|  RangeValues | false|
| FormeFilterChip|  List&lt; T&gt; | false |
| FormeChoiceChip|  T | true |
| FormeCheckbox| bool | true |
| FormeCheckboxListTile | bool | true |
| FormeSwitch| bool | false |
| FormeSwitchTile| bool | false |
| FormeDropdownButton | T | true | 
| FormeListTile|  List&lt; T&gt; | false |
| FormeRadioGroup|  T | true |
| FormeCupertinoTextField|  string | false |
| FormeCupertinoDateTimeField|  DateTime | true |
| FormeCupertinoNumberField|  num | true |
| FormeCupertinoPicker|  int | false |
| FormeCupertinoSegmentedControl|  T | true |
| FormeCupertinoSlidingSegmentedControl|  T | true |
| FormeCupertinoSlider|  double | false |
| FormeCupertinoSwitch| bool | false |
| FormeCupertinoTimerField| Duration | true |

## async validate

async validator is supported after Forme 2.5.0 , you can specific an `asyncValidator` on `FormeField` , the unique difference
between `validator` and `asyncValidator` is `asyncValidator` return a `Future<String>` and `validator` return a `String`

### when to perform an asyncValidator

if `FormeField.autovalidateMode` is `AutovalidateMode.disabled` , asyncValidator will never be performed unless you call `validate` from `FormeFieldController` manually.

if you specific both `validator` and `asyncValidator` , `asyncValidator` will only be performed after `validator` return null.

**after successful performed an asyncValidator , asyncValidator will not performed any more until field's value changed**

### debounce

you can specific a debounce on `FormeField` , **debounce will not worked when you manually call `validate` on `FormeFieldController`**


## validates

you can use `FormeValidates` to simplify your validators

| Validator Name |  Support Type  | When Valid |  When Invalid  |
| --- | --- | --- | --- |
| `notNull` | `dynamic` | value is not null | value is null |
| `size` | `Iterable` `Map` `String` | 1. value is null 2. max & min is null  3. String's length or Collection's size  is in [min,max] | String's length or Collection's size is not in [min,max] |
| `min` | `num` | 1. value is null  2. value is bigger than min | value is smaller than min |
| `max` | `num` | 1. value is null  2. value is smaller than max |  value is bigger than max |
| `notEmpty` | `Iterable` `Map` `String` | 1. value is not null 2. String's length or Collection's size  is bigger than zero | 1. value is null 2. String's length or Collection's size  is  zero |
| `notBlank` | `String` | 1. value is null 2. value.trim()'s length is not null |  value'length is zero after trimed |
| `positive` | `num` | 1. value is null 2. value is bigger than zero |  value  is smaller than or equals zero |
| `positiveOrZero` | `num` | 1. value is null 2. value is bigger than or equals zero |  value  is smaller than zero |
| `negative` | `num` | 1. value null 2. value is smaller than zero |  value  is bigger than or equals zero |
| `negativeOrZero` | `num` | 1. value  null 2. value is smaller than or equals zero |  value  is bigger than zero |
| `pattern`  | `String` | 1. value null 2. value matches pattern  |  value does not matches pattern |
| `email`  | `String` | 1. value null 2. value is a valid email  |  value is not a valid email |
| `url`  | `String` | 1. value is null 2. value is empty or value is a valid url  |  value is not a valid url |
| `range`  | `num` | 1. value null 2. value is in range  |  value is out of range |
| `equals`  | `dynamic` | 1. value null 2. value is equals target value  |  value is not equals target value |
| `any`  | `T` | any validators is valid  |  every validators is invalid |
| `all`  | `T` | all validators is valid  |  any validators is invalid |

when you use validators from `FormeValidates` , you must specific at least one errorText , otherwise errorText is an empty string

## FormeKey Methods

### whether form has a name field

``` Dart
bool hasField = formeKey.hasField(String name);
```

### whether current form is readOnly

``` Dart
bool readOnly = formeKey.readOnly;
```

### set readOnly 

``` Dart
formeKey.readOnly = bool readOnly;
```

### get field's controller

``` Dart
T controller = formeKey.field<T extends FormeFieldController>(String name);
```

### get form data

``` Dart
Map<String, dynamic> data = formeKey.data;
```

### set form data

``` Dart
formeKey.data = Map<String,dynamic> data;
```

### validate

**since 2.5.0 , this method will return a Future ranther than a Map** 

you can use `FormeValidateSnapshot.isValueChanged` to check whether form value is changed duration this validation , 
if is changed , typically means this validation is invalid , you should not submit your form even though validation is passed

``` Dart
Future<FormeValidateSnapshot> future = formKey.validate({
    bool quietly = false,
    Set<String> names = const {},
    bool clearError = false,
    bool validateByOrder = false,
});
```

### get validation

``` Dart
FormeValidation validation = formKey.validation;
```

### reset form

``` Dart
formeKey.reset();
```

### save form

``` Dart
formeKey.save();
```

### whether validate is quietly

``` Dart
bool quietlyValidate = formKey.quietlyValidate;
```

### set quietlyValidate

``` Dart
formeKey.quieltyValidate = bool quietlyValidate;
```

### is value changed after initialed

``` Dart
bool isChanged = formeKey.isValueChanged
```

### get all field controllers (2.5.2)

``` Dart
List<FormeFieldController> controllers = formeKey.controllers;
```

### get fieldListenable

``` Dart
ValueListenable<FormeFieldController> fieldListenable = formeKey.fieldListenable(String name);
```

### get fieldsListenable

``` Dart
ValueListenable<Map<String, FormeFieldController<dynamic>?>> fieldsListenable = 
      formeKey.fieldsListenable;
```

used to listen every field initialed or disposed , value is an empty or single sized map , key is field name, value is `FormeFieldController`

### get validation listenable

``` Dart
ValueListenable<FormeValidation> validationListenable = formeKey.validationListenable;
```

useful when you want to show or hide a submit button when validation passed or not,eg:

```Dart
 Builder(
    builder: (context) {
    return ValueListenableBuilder<FormeValidation>(
        valueListenable: key.validationListenable,
        builder: (context, validation, child) {
            if (!validation.isValidOrUnnecessaryOrEmpty) {
                return const SizedBox.shrink();
            }
            return yourSubmitButton;
        });
    },
),
```

## Forme Field Methods

### get forme controller

``` Dart
FormeController? formeController = field.formeController;
```

### get field's name

``` Dart
String name = field.name
```

### whether current field is readOnly

``` Dart
bool readOnly = field.readOnly;
```

### set readOnly on field

``` Dart
field.readOnly = bool readOnly;
```

### whether current field is enabled

``` Dart
bool enabled = field.enabled;
```

### set enabled on field

``` Dart
field.enabled = bool enabled;
```

### get focusNode

``` Dart
FocusNode? focusNode = field.focusNode;
```

### get context

``` Dart
BuilderContext context = field.context;
```

### get focusListenable

``` Dart
ValueListenable<bool> focusListenable = field.focusListenable;
```

### get readOnlyListenable

``` Dart
ValueListenable<bool> readOnlyListenable = field.readOnlyListenable;
```

### get enabledListenable

``` Dart
ValueListenable<bool> enabledListenable = field.enabledListenable;
```

### get value

``` Dart
T value = field.value;
```

### set value

``` Dart
field.value = T data;
```

### reset field

``` Dart
field.reset();
```

### validate field

**since 2.5.0 , this method will return a Future ranther than a String** 

``` Dart
Future<FormeFieldValidateSnapshot> future = field.validate({bool quietly = false});
```

### get validation

``` Dart
FormeFieldValidation validation = field.validation;
```

### get validationListenable

``` Dart
ValueListenable<FormeFieldValidation>  validationListenable = field.validationListenable;
```

### get valueListenable

``` Dart
ValueListenable<T> valueListenable = field.valueListenable;
```

### get oldValue

if value changed , you can use this method to get previous value

``` Dart
T? value = field.oldValue;
```

### is value changed

``` Dart
bool isChanged = field.isValueChanged
```

###  whether is field mounted

``` Dart
bool mounted = field.mounted
```


## custom field

``` Dart
FormeField<String>(
    name: 'customField',
    initialValue: 'currentValue',
    builder: (FormeFieldState<String> state) {
        return TextButton(
        onPressed: () {
            state.didChange('newValue');
        },
        child: Text(state.value),
        );
    },
),
```