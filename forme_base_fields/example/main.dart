import 'package:flutter/material.dart';
import 'package:forme/forme.dart';
import 'package:forme_base_fields/field/material/forme_checkbox_tile.dart';
import 'package:forme_base_fields/field/material/forme_choice_chip.dart';
import 'package:forme_base_fields/field/material/forme_dropdown_button.dart';
import 'package:forme_base_fields/field/material/forme_filter_chip.dart';
import 'package:forme_base_fields/field/material/forme_slider.dart';
import 'package:forme_base_fields/field/material/forme_text_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Signup(),
    );
  }
}

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final FormeKey key = FormeKey();

  int phoneIndex = 0;
  final List<_PhoneField> phones = [];

  TextStyle _getErrorStyle() {
    final Color color = Theme.of(context).errorColor;
    return Theme.of(context).textTheme.caption!.copyWith(color: color);
  }

  String? phoneNumberValidator(FormeFieldState field, String v) {
    const String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    final RegExp regExp = RegExp(patttern);
    if (v.isEmpty) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(v)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  void appendPhone() {
    final int index = ++phoneIndex;
    final Widget widget = Container(
      padding: const EdgeInsets.all(10),
      child: FormeTextField(
        name: 'phone_$index',
        order: index + 7,
        validator: phoneNumberValidator,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          suffixIcon: Builder(builder: (context) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ValidationIcon(),
                IconButton(
                    onPressed: () {
                      setState(() {
                        phones.removeWhere((element) => element.index == index);
                      });
                    },
                    icon: const Icon(Icons.cancel))
              ],
            );
          }),
          suffixIconConstraints: const BoxConstraints.tightFor(),
          labelText: 'Phone $index',
        ),
      ),
    );
    setState(() {
      phones.add(_PhoneField(widget, index));
    });
  }

  InputBorder? getEnabledBorder(FormeFieldValidation? validation,
      {double width = 1}) {
    return (validation?.isInvalid ?? false)
        ? OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).errorColor, width: width),
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Expanded(
              child: Text('Signup'),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Forme(
              autovalidateByOrder: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: key,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 30),
                        )),
                    FormeTextField(
                      name: 'username',
                      order: 1,
                      validator: FormeValidates.notEmpty(
                          errorText: 'should not empty'),
                      asyncValidator: (field, value, isValid) {
                        return Future.delayed(const Duration(milliseconds: 800),
                            () {
                          if (value.length < 4) {
                            return 'username exists';
                          }
                          return null;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: ValidationIcon(),
                        suffixIconConstraints: BoxConstraints.tightFor(),
                        hintText: 'input at least 4 chars',
                        labelText: 'User Name',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: FormeDropdownButton<String>(
                        order: 2,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                        ),
                        validator: FormeValidates.notNull(
                            errorText: 'gender is required'),
                        name: 'gender',
                        items: const [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text('male'),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('female'),
                          ),
                          DropdownMenuItem(
                            value: 'secret',
                            child: Text('secret'),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: FormeSlider(
                        order: 3,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          border: InputBorder.none,
                        ),
                        name: 'age',
                        min: 13,
                        max: 99,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: FormeFilterChip<String>(
                          order: 4,
                          maxSelectedCount: 2,
                          validator: (f, v) {
                            if (v.isEmpty) {
                              return 'select at least one skill';
                            }
                            return null;
                          },
                          decorator: FormeInputDecoratorBuilder(
                              counter: (s) => s.length,
                              maxLength: 2,
                              wrapper: (child, field) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: child,
                                );
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(10),
                                labelText: 'Skill',
                              )),
                          name: 'skill',
                          items: [
                            FormeChipItem(
                                label: const Text('Flutter'), data: 'Flutter'),
                            FormeChipItem(
                                label: const Text('Java'), data: 'Java'),
                            FormeChipItem(
                                label: const Text('Android'), data: 'Android'),
                          ]),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Row(children: [
                        Expanded(
                          child: FormeFieldStatusListener(
                            name: 'password',
                            filter: (status) => status.isValidationChanged,
                            builder: (context, status, child) {
                              return FormeTextField(
                                order: 5,
                                obscureText: true,
                                name: 'password',
                                quietlyValidate: true,
                                validator: (f, v) {
                                  if (v.isEmpty) {
                                    return 'should not  empty';
                                  }
                                  return null;
                                },
                                asyncValidator: (field, value, isValid) {
                                  return Future.delayed(
                                      const Duration(milliseconds: 800), () {
                                    if (value.length < 4) {
                                      return 'not strong enough';
                                    }
                                    return null;
                                  });
                                },
                                decoration: InputDecoration(
                                  suffixIcon: const ValidationIcon(),
                                  suffixIconConstraints:
                                      const BoxConstraints.tightFor(),
                                  enabledBorder:
                                      getEnabledBorder(status?.validation),
                                  focusedBorder: getEnabledBorder(
                                      status?.validation,
                                      width: 2),
                                  border: const OutlineInputBorder(),
                                  labelText: 'Password',
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: FormeFieldStatusListener(
                              name: 'confirm',
                              filter: (status) => status.isValidationChanged,
                              builder: (context, status, child) {
                                return FormeTextField(
                                  order: 6,
                                  quietlyValidate: true,
                                  obscureText: true,
                                  name: 'confirm',
                                  validator: (f, v) {
                                    if (v != key.field('password').value) {
                                      return 'password not match';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    suffixIcon: const ValidationIcon(),
                                    suffixIconConstraints:
                                        const BoxConstraints.tightFor(),
                                    border: const OutlineInputBorder(),
                                    enabledBorder:
                                        getEnabledBorder(status?.validation),
                                    focusedBorder: getEnabledBorder(
                                        status?.validation,
                                        width: 2),
                                    labelText: 'Confirm',
                                  ),
                                );
                              }),
                        ),
                      ]),
                    ),
                    FormeFieldsValidationListener(
                      names: const {'password', 'confirm'},
                      builder: (context, validation) {
                        if (validation == null) {
                          return const SizedBox();
                        }
                        if (validation.isInvalid) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 24, top: 10),
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: FormeTextField(
                        name: 'phone',
                        order: 7,
                        validator: phoneNumberValidator,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: ValidationIcon(),
                          suffixIconConstraints: BoxConstraints.tightFor(),
                          labelText: 'Phone',
                        ),
                      ),
                    ),
                    Column(
                      children: phones.map((e) => e.widget).toList(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextButton(
                        onPressed: appendPhone,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.add),
                              Text('append phone')
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: FormeCheckboxTile(
                        order: phoneIndex + 8,
                        decorator: const FormeInputDecoratorBuilder(
                            decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        )),
                        name: 'agree',
                        validator: (f, v) {
                          if (!v!) {
                            return 'you must agree before continue';
                          }
                          return null;
                        },
                        title: const Text(
                            'I have read and agree to the terms and conditions'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: FormeIsValueChangedListener(
                                builder: (context, isValueChanged) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.orangeAccent),
                                onPressed: isValueChanged ? key.reset : null,
                                child: const Text('Reset'),
                              );
                            }),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: FormeValidationListener(
                                builder: (context, validation, child) {
                              return ElevatedButton(
                                onPressed: validation.isValid
                                    ? () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    key.value.toString())));
                                      }
                                    : null,
                                child: const Text('Signup'),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                    FormeValueListener(builder: (context, value, child) {
                      return Text(value.toString());
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ValidationIcon extends StatelessWidget {
  const ValidationIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormeFieldStatusListener<String>(
      filter: (status) => status.isValidationChanged,
      builder: (context, status, child) {
        if (status == null) {
          return const SizedBox.shrink();
        }
        return getIcon(status.validation);
      },
    );
  }

  static Widget getIcon(FormeFieldValidation validation) {
    Widget icon;
    if (validation.isValidating) {
      icon = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(),
      );
    } else if (validation.isValid) {
      icon = const Icon(
        Icons.check,
        color: Colors.greenAccent,
      );
    } else if (validation.isFail || validation.isInvalid) {
      icon = const Icon(
        Icons.error,
        color: Colors.redAccent,
      );
    } else {
      icon = const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(10),
      child: icon,
    );
  }
}

class _PhoneField {
  final Widget widget;
  final int index;

  _PhoneField(this.widget, this.index);
}
