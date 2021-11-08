## 3.1.5

1. replace EdgeInsets with EdgeInsetsGeometry in some files
2. bug fix: if value in `FormeNumerTextField` bigger than max ,backspace will not work

## 3.1.4

1. bug fix

## 3.1.3 

1. `FormeAsyncAutocomplete` can override default suffixIcon

## 3.1.2

1. support set `FocusNode` in `FormeFieldState`
2. support `FormeAutocomplete`
3. `FormeCheckbox` is `bool?` now
4. support `FormeAsyncAutocomplete`

## 3.1.1

1. fix `FormeValidation` can not be found 

## 3.1.0

1. remove `hasValidator`
2. `onErrorChanged` renamed to `onValidationChanged`
3. `FormeValidateError` renamed to `FormeValidation`
4. `FormeValidateState` renamed to `FormeValidationState` and add new state `unnecessary` and `waiting`

## 3.0.1

1. support `hasValidator` on `FormeFieldController`
2. support `errorListenable` on `FormeController`
3. add `FormeValidateErrorBuilder` widget
4. use `FormeField.of` get `FormeFieldController` and it is nullable
5. use `Forme.of` get `FormeController` and it is nullable

## 3.0.0

**Forme3 is not an upgrade but a simple version of Forme2**

differences:
1. Forme3 removed model which used to provide render data in Forme2 and moved model properties into field's constructor
2. Forme3 removed listener from field's constructor and moved listener properties into field's constructor
3. Forme3 removed CommonField and renamed ValueField to FormeField
4. Forme3 has big api breaks
5. Forme3 is based on flutter 2.5

## 2.5.3

1. `BaseValueField` support `quietlyValidate`
2. `FormeController` add `fieldListenable` method , used to listen field's initial and dispose

## 2.5.2

1. `FormeController`'s `validate` method support `clearError` and `validateByOrder` params. if `clearError` is true , field error will be cleared before validate. if `validateByOrder` is true , will only validate one field at a time , and break validation chain  if any field validate not passed or failed

## 2.5.1

1. add `autovalidateByOrder` on `Forme` ,support validate form fields by order  , and stop validate further if validate failed
2. add a nullable attribute `order` on `BaseValueField`
3. `Future<Map<FormeValueFieldController, String>> validate({bool quietly = false})` changed to `  Future<FormeValidateSnapshot> validate({bool quietly = false, Set<String> names = const {}})`
4. ` Future<String?>? validate({bool quietly = false})` changed to `Future<FormeFieldValidateSnapshot<T>> validate({bool quietly = false})`
5. add `isValueChanged` method on `FormeController` , used to check whether form data changed after initialed

## 2.5.0

1. remove `onValueChanged`,`onValidationChanged`,`onFocusChanged`,`onInitialed`,`validator`,`autovalidateMode` on `Field` , they are moved to `FormeFieldListener` , `validator` is renamed to `onValidate` 
2. support `onAsyncValidate` and `asyncValidatorDebounce` on `FormeValueFieldListener` to support async validate
3. remove `fieldListenable` from `FormeFieldController`
4. remove `lazyFieldListenable` from `FormeKey`
5. `ValueField` is not a `FormField` any more
6. you can create a nonnull or nullable `ValueField` by `ValueField`'s generic type , eg:`ValueField<String>` is nonnull , but `ValueField<String?>` is nullable
7. remove `clearValue` from `FormeValueFieldController`
8. support 'autovalidateMode' on `Forme`

## 2.1.2

1. remove `buildTextSpan` from `FormeTextFieldController` , it cannot be compiled success before flutter 2.2.2

## 2.1.1

1. bug fix: can't get current field error in onValueChanged
2. `FormeSingleSwitch` & `FormeListTile` always use material switch
3. `FormeValidates` add `range` and `equals` vaidator

## 2.1.0

1. remove `Cupertino` fields ,they will be moved to another package
2. `FormeSlider` and `FormeRangeSlider` will perform validate in onChangeEnd ,not in onChange
3. `FormeTextField`'s controller can be cast to `FormeTextController`, set `TextEditingValue` and `Selection` is easily via this controller
4. `FormeValueFieldController` support `nextFocus` , used to focus next focusable widget
5. remove `beforeUpdateModel` from `AbstractFieldState` , you can do some logic in `afterUpdateModel`
6. `AbstractFieldState`'s didUpdateWidget will call `afterUpdateModel` by default
7. bug fix 

## 2.0.4+1

1. bug fix: timer in `FormeRawAutocomplete` will be cancelled in dispose !

## 2.0.4

1. add `modelListenable` on `FormeFieldController`
2. after value changed , you can get old value via `FormeValueFieldController`'s `oldValue`
3. validate method add parameter `notify` , used to determine  whether trigger `errorListenable`
4. `FormeAsnycAutocompleteChipModel` support `max` and `exceedCallback`.

## 2.0.3+1

1. bug fix: readOnlyNotifier will be disposed !

## 2.0.3

1. fields add `InputDecoration` and `maxLines` properties , used to quickly specific labelText or others
2. add `FormeAsyncAutocompleteChip`

## 2.0.2

1. add `FormeAutocompleteText`
2. add `FormeAsyncAutocompleteText`

## 2.0.1

1. StatefulField support `onInitialed` , used to listen `FormeFieldController` initialed
2. add `FormeValidateUtils`
3. bug fix : onValidationChanged and errorTextListenable not triggered in build 

## 2.0.0

forme is completely rewrite version of https://pub.dev/packages/form_builder much more powerful and won't break your layout