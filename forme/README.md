## Web Demo

https://www.qyh.me/forme3/

## Simple Usage

### add dependency

``` 
flutter pub add forme
flutter pub add forme_base_fields 
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
| onFieldStatusChanged | false | `FormeFieldStatusChanged` | listen form field's value|read-only|focus|validation|enabled change |
| initialValue | false | `Map<String,dynamic>` | initialValue , **will override FormField's initialValue** |
| onWillPop | false | `WillPopCallback` | Signature for a callback that verifies that it's OK to call Navigator.pop |
| quietlyValidate | false | `bool` | if this attribute is true , will not display default error text|
| autovalidateMode| false | `AutovalidateMode` | auto validate form mode |
| autovalidateByOrder | false | `bool` | whether auto validate form by order |
| onFieldsRegistered | false | function | listen registered fields  |
| onFieldsUnregistered | false | function | listen unregistered fields |


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
| onStatusChanged | false | `FormeFieldStatusChanged` | listen value|read-only|focus|validation|enabled change |
| onInitialed | false | `FormeFieldInitialed` | triggered when field initialed |
| onSaved | false | `FormeFieldSetter` | triggered when form saved |
| validator | false | `FormeValidator` | sync validator |
| asyncValidator | false | `FormeAsyncValidator` | async validator |
| decorator | false | `FormeFieldDecorator` | used to decorator a field |
| order | false | int | order of field |
| requestFocusOnUserInteraction | false | bool | whether request focus when field value changed by user interaction |
| registrable | false | `bool` | whether this field should be registered to Forme |

## async validate

![https://raw.githubusercontent.com/wwwqyhme/wwwqyhme.github.io/main/forme3/async_validation.gif](https://raw.githubusercontent.com/wwwqyhme/wwwqyhme.github.io/main/forme3/async_validation.gif)

async validator is supported after Forme 2.5.0 , you can specific an `asyncValidator` on `FormeField` , the unique difference
between `validator` and `asyncValidator` is `asyncValidator` return a `Future<String>` and `validator` return a `String`

### when to perform an asyncValidator

if `FormeField.autovalidateMode` is `AutovalidateMode.disabled` , asyncValidator will never be performed unless you call `validate` from `FormeFieldController` manually.

if you specific both `validator` and `asyncValidator` , `asyncValidator` will only be performed after `validator` return null.

**after successful performed an asyncValidator , asyncValidator will not performed any more until field's value changed**

### debounce

you can specific a debounce on `FormeField` , **debounce will not worked when you manually call `validate` on `FormeFieldController`**


### whether validation itself is valid

in some cases,when an async validation is performing , another validation on same field is performed,in this case ,previous validation is invalid , so if you 
want to update UI before return validation result in async validator , you need to validate it first,eg:

``` Dart
asyncValidator:(field,value,isValid){
    return Future.delayed(const Duration(seconds:2),(){
        if(isUnexceptedValue(value)) {
            if(isValid()){
                updateUI();
            }
            return 'invalid';
        }
        return null;
    });    
}
```

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

## FormeKey|FormeState Methods

### whether form has a name field

``` Dart
bool hasField = formeKey.hasField(String name);
```

### get field by name

``` Dart
T field = formeKey.field<T extends FormeFieldState>(String name);
```

### get form data

``` Dart
Map<String, dynamic> data = formeKey.value;
```

### set form data

``` Dart
formeKey.data = Map<String,dynamic> data;
```

### validate

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

### get all fields (2.5.2)

``` Dart
List<FormeFieldState> fields = formeKey.fields;
```

## Forme Field Methods

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

### has focus node

``` Dart
bool hasFocusNode = field.hasFocusNode;
```

### get or create a focusNode

``` Dart
FocusNode focusNode = field.focusNode;
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

``` Dart
Future<FormeFieldValidateSnapshot> future = field.validate({bool quietly = false});
```

### get validation

``` Dart
FormeFieldValidation validation = field.validation;
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

### get generic type

``` Dart
Type type = field.type;
```

### whether field value is nullable 

``` Dart
bool isNullable = field.isNullable;
```

## FocusNode

for simplify form control , Forme not support set focus node on field,
FocusNode will  be auto created when needed.

### custom focus node

if you want to override default focusNode , you can extends `FormeFieldState` and use `set focusNode` method to do that,
in this case , you must dispose focusNode by yourself

## listener widgets

listener widgets used to build your widgets which depends on status of FormeField or form value , you must used them inside Forme or FormeField

### FormeFieldStatusListener

will rebuild whenever field's status changed , use filter to avoid unnecessary rebuild.

eg:

``` Dart
Forme(
    child:Column(children:[
        FormeFieldStatusListener(
            filter:(status) => status.isValueChanged,
            name:'name',
            builder:(context,status,child){
                return Text('current value:${status.value}')
            }
        ),
        FormeTextField(name:'name'),
    ]),
)
```

### FormeFieldsValidationListener

will rebuild whenever validation of any field changed 

eg:

``` Dart
FormeFieldsValidationListener(
      names: const {'password', 'confirm'},
      builder: (context, validation) {
        if (validation == null) {
          return const SizedBox();
        }
        if (validation.isInvalid) {
          return Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              validation.validations.values
                  .where((element) => element.isInvalid)
                  .first
                  .error!,
              style: _getErrorStyle(),
            ),
          );
        }
        return const SizedBox.shrink();
    },
),
```

### FormeValidationListener

will rebuild whenever form validation changed , useful when you want to create a submit button which only clickable when form validation passed

eg:

``` Dart
Forme(
    child:Column(children:[
        ...
        FormeValidationListener(
            builder:(context,validation,child){
                return TextButton(
                    onPressed:validation.isValid ? submit:null,
                    child:const Text('submit'),
                );
            }
        )
    ]),
)
```

### FormeIsValueChangedListener 

will rebuild whenever form value changed , useful when you want to create a reset button which depends on form value changed or not

eg:

``` Dart
Forme(
    child:Column(children:[
        ...
        FormeIsValueChangedListener(
            builder:(context,isValueChanged,child){
                return TextButton(
                    onPressed:isValueChanged ? reset:null,
                    child:const Text('reset'),
                );
            }
        )
    ]),
)
```

### FormeValueListener 

will rebuild whenever form value changed , typically used in debug .

eg:

``` Dart
Forme(
    child:Column(children:[
        ...
        FormeValueListener(
            builder:(context,value,child){
                return Text(value.toString());
            }
        )
    ]),
)
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