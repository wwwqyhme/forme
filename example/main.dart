import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FormeKey key = FormeKey();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Forme(
              key: key,
              child: Column(
                children: [
                  FormeTextField(
                    name: 'username',
                    decoration: const InputDecoration(labelText: 'username'),
                    onInitialed: (field) {
                      TextEditingController controller =
                          (field as FormeTextFieldController)
                              .textEditingController;
                      controller.value = const TextEditingValue(
                          text: '123',
                          selection:
                              TextSelection(baseOffset: 0, extentOffset: 1));
                    },
                  ),
                  FormeNumberField(
                    name: 'age',
                    max: 9999,
                    decimal: 2,
                    decoration: const InputDecoration(labelText: 'age'),
                  ),
                  FormeDateTimeField(
                    name: 'birthday',
                    type: FormeDateTimeType.dateTime,
                    decoration: InputDecoration(
                        labelText: 'birthday',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {},
                        )),
                  ),
                  FormeTimeField(
                      name: 'time',
                      decoration: const InputDecoration(
                        labelText: 'time',
                      )),
                  FormeDateTimeRangeField(
                    name: 'range',
                    decoration: const InputDecoration(labelText: 'date range'),
                    validator: (field, v) => '123',
                  ),
                  Row(
                    children: [
                      FormeSwitch(
                        name: "switch",
                        initialValue: true,
                      ),
                      FormeCheckbox(
                        name: "checkbox",
                        initialValue: true,
                      )
                    ],
                  ),
                  FormeRadioGroup<String>(
                    name: 'radioGroup',
                    decoration: const InputDecoration(
                      labelText: 'radioGroup',
                    ),
                    items: [
                      FormeListTileItem(
                          data: 'first', title: const Text('first')),
                      FormeListTileItem(
                          data: 'second', title: const Text('second')),
                    ],
                  ),
                  FormeListTile<String>(
                    name: 'listTile',
                    decoration: const InputDecoration(
                      labelText: 'radioGroup',
                    ),
                    items: [
                      FormeListTileItem(
                          data: 'first', title: const Text('first')),
                      FormeListTileItem(
                          data: 'second', title: const Text('second')),
                    ],
                  ),
                  FormeChoiceChip<String>(
                    name: 'choiceChip',
                    items: [
                      FormeChipItem(label: const Text('first'), data: 'first'),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'choiceChip',
                    ),
                  ),
                  FormeFilterChip<String>(
                    name: 'filterChip',
                    items: [
                      FormeChipItem(label: const Text('first'), data: 'first'),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'filterChip',
                    ),
                  ),
                  FormeSlider(
                    name: 'slider',
                    min: 1,
                    max: 100,
                    decoration: const InputDecoration(
                      labelText: 'slider',
                    ),
                  ),
                  FormeRangeSlider(
                    name: 'slider',
                    min: 1,
                    max: 100,
                    decoration: const InputDecoration(
                      labelText: 'range slider',
                    ),
                  ),
                  FormeDropdownButton<String>(
                    decoration: const InputDecoration(
                      labelText: 'Dropdown',
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onErrorChanged: (field, e) {},
                    asyncValidator: (field, v) {
                      return Future.delayed(const Duration(milliseconds: 500),
                          () {
                        return 'async validate fail';
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        child: Text('xxx'),
                        value: '123',
                      ),
                    ],
                    name: 'dropdown',
                  ),
                  FormeCupertinoTextField(
                    name: 'cupertinoField',
                    decorator: const FormeCupertinoInputDecoratorBuilder(
                        prefix: Text('email')),
                  ),
                  FormeCupertinoDateTimeField(
                    name: 'birthday2',
                    type: FormeDateTimeType.dateTime,
                    decorator: const FormeCupertinoInputDecoratorBuilder(
                        prefix: Text('birthday')),
                  ),
                  FormeCupertinoNumberField(
                    name: 'age2',
                    max: 100,
                    decimal: 2,
                    decorator: const FormeCupertinoInputDecoratorBuilder(
                        prefix: Text('age')),
                  ),
                  FormeCupertinoSlider(
                    name: 'slider2',
                    min: 1,
                    max: 100,
                    decorator: FormeCupertinoSliderFullWidthDecorator(
                        prefix: const Text('slider2')),
                  ),
                  FormeCupertinoSwitch(
                    name: 'switch2',
                    decorator: const FormeCupertinoInputDecoratorBuilder(
                        prefix: Text('switch2')),
                  ),
                  FormeCupertinoTimerField(
                    name: 'timer',
                    decorator: const FormeCupertinoInputDecoratorBuilder(
                        prefix: Text('timer')),
                  ),
                  FormeCupertinoSegmentedControl<String>(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    disableBorderColor: CupertinoColors.systemGrey,
                    decorator: const FormeCupertinoInputDecoratorBuilder(
                        prefix: Text('control')),
                    validator:
                        FormeValidates.equals('C', errorText: 'pls select C'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onValueChanged: (c, v) =>
                        print('value changed,current value is $v'),
                    name: 'segmentedControl',
                    children: {
                      'A': const Text('A'),
                      'B': const Text('B'),
                      'C': const Text('C'),
                    },
                  ),
                  FormeCupertinoSlidingSegmentedControl<String>(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decorator: const FormeCupertinoInputDecoratorBuilder(
                        prefix: Text('control')),
                    validator:
                        FormeValidates.equals('C', errorText: 'pls select C'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onValueChanged: (c, v) =>
                        print('value changed,current value is $v'),
                    name: 'slidingSegmentedControl',
                    children: {
                      'A': const Text('A'),
                      'B': const Text('B'),
                      'C': const Text('C'),
                    },
                  ),
                  FormeCupertinoPicker(
                      decorator: const FormeCupertinoInputDecoratorBuilder(
                          prefix: Text('picker')),
                      onValueChanged: (c, v) => print(v),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormeValidates.all([
                        FormeValidates.notNull(),
                        FormeValidates.min(100),
                      ], errorText: 'value must bigger than 100'),
                      name: 'picker',
                      initialValue: 50,
                      itemExtent: 50,
                      children: List<Widget>.generate(
                          1000, (index) => Text(index.toString()))),
                ],
              )),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
