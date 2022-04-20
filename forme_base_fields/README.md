

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
| FormeExpansionListTile | List&lt; T&gt; | false |



## TextEditingController

for simplify form control , set `TextEditingController` is not supported on some fields , eg : `FormeTextField`,`FormeNumberField`,`FormeDateTimeField` and etc...

if you want to access underlying `TextEditingController`, you can try to convert `FormeFieldController` to `FormeTextFieldController` or other to do that 