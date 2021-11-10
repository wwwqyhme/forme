import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../../forme.dart';

typedef FormeAutocompleteOptionsViewBuilder<T extends Object> = Widget Function(
    BuildContext context,
    AutocompleteOnSelected<T> onSelected,
    Iterable<T> options,
    double? width);

class FormeAutocomplete<T extends Object> extends FormeField<T?> {
  final AutocompleteOptionToString<T> displayStringForOption;

  /// triggered after [Autocomplete] fieldViewBuilder called , will be only called once in [FormeAutocomplete]'s lifecycle
  ///
  /// use this listener instead of [FormeField]'s onInitialed
  final FormeFieldInitialed<T?>? onFieldViewInitialed;

  FormeAutocomplete({
    T? initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<T?>? onValueChanged,
    FormeFocusChanged<T?>? onFocusChanged,
    FormeFieldSetter<T?>? onSaved,
    FormeValidator<T?>? validator,
    FormeAsyncValidator<T?>? asyncValidator,
    FormeFieldValidationChanged<T?>? onValidationChanged,
    this.onFieldViewInitialed,
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
    AutocompleteFieldViewBuilder? fieldViewBuilder,
    required AutocompleteOptionsBuilder<T> optionsBuilder,
    FormeAutocompleteOptionsViewBuilder<T>? optionsViewBuilder,
    double optionsMaxHeight = 200,
    InputDecoration? decoration,
    int? maxLines = 1,
    TextInputType? keyboardType,
    bool autofocus = false,
    int? minLines,
    int? maxLength,
    TextStyle? style,
    ToolbarOptions? toolbarOptions,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    StrutStyle? strutStyle,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    TextDirection? textDirection,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    bool expands = false,
    MaxLengthEnforcement? maxLengthEnforcement,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    BoxHeightStyle selectionHeightStyle = BoxHeightStyle.tight,
    BoxWidthStyle selectionWidthStyle = BoxWidthStyle.tight,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20),
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    MouseCursor? mouseCursor,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    bool enableInteractiveSelection = true,
    bool enabled = true,
    VoidCallback? onEditingComplete,
    List<TextInputFormatter>? inputFormatters,
    AppPrivateCommandCallback? appPrivateCommandCallback,
    InputCounterWidgetBuilder? buildCounter,
    GestureTapCallback? onTap,
    ScrollController? scrollController,
    TextSelectionControls? textSelectionControls,
    bool enableIMEPersonalizedLearning = true,
    FormeFieldDecorator<T?>? decorator,
    bool registrable = true,
  }) : super(
          registrable: registrable,
          //  decorator: decorator,
          order: order,
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          autovalidateMode: autovalidateMode,
          onValueChanged: onValueChanged,
          onFocusChanged: onFocusChanged,
          onValidationChanged: onValidationChanged,
          onSaved: onSaved,
          validator: validator,
          asyncValidator: asyncValidator,
          key: key,
          readOnly: readOnly,
          name: name,
          initialValue: initialValue,
          builder: (genericState) {
            final _FormeAutoCompleteState<T> state =
                genericState as _FormeAutoCompleteState<T>;
            final bool readOnly = state.readOnly;
            return Autocomplete<T>(
              onSelected: state.didChange,
              initialValue: initialValue == null
                  ? null
                  : TextEditingValue(
                      text: displayStringForOption(initialValue)),
              optionsMaxHeight: optionsMaxHeight,
              optionsViewBuilder: (
                BuildContext context,
                AutocompleteOnSelected<T> onSelected,
                Iterable<T> options,
              ) {
                return ValueListenableBuilder<double?>(
                    valueListenable: state.optionsViewWidthNotifier,
                    builder: (context, width, _child) {
                      return optionsViewBuilder?.call(
                              context, onSelected, options, width) ??
                          AutocompleteOptions(
                            displayStringForOption: displayStringForOption,
                            onSelected: onSelected,
                            options: options,
                            maxOptionsHeight: optionsMaxHeight,
                            width: width,
                          );
                    });
              },
              optionsBuilder: readOnly
                  ? (TextEditingValue value) => const Iterable.empty()
                  : optionsBuilder,
              displayStringForOption: displayStringForOption,
              fieldViewBuilder:
                  (context, textEditingController, focusNode, onSubmitted) {
                state.initFieldView(textEditingController, focusNode);
                Widget field;
                if (fieldViewBuilder != null) {
                  field = fieldViewBuilder(
                      context, textEditingController, focusNode, onSubmitted);
                } else {
                  field = TextField(
                    enableIMEPersonalizedLearning:
                        enableIMEPersonalizedLearning,
                    focusNode: focusNode,
                    controller: textEditingController,
                    decoration:
                        decoration?.copyWith(errorText: state.errorText),
                    obscureText: obscureText,
                    maxLines: maxLines,
                    minLines: minLines,
                    enabled: enabled,
                    readOnly: readOnly,
                    onTap: onTap,
                    onEditingComplete: onEditingComplete,
                    onSubmitted: readOnly
                        ? null
                        : (v) {
                            onSubmitted();
                          },
                    onAppPrivateCommand: appPrivateCommandCallback,
                    textInputAction: textInputAction,
                    textCapitalization: textCapitalization,
                    style: style,
                    strutStyle: strutStyle,
                    textAlign: textAlign,
                    textAlignVertical: textAlignVertical,
                    textDirection: textDirection,
                    showCursor: showCursor,
                    obscuringCharacter: obscuringCharacter,
                    autocorrect: autocorrect,
                    smartDashesType: smartDashesType,
                    smartQuotesType: smartQuotesType,
                    enableSuggestions: enableSuggestions,
                    expands: expands,
                    cursorWidth: cursorWidth,
                    cursorHeight: cursorHeight,
                    cursorRadius: cursorRadius,
                    cursorColor: cursorColor,
                    selectionHeightStyle: selectionHeightStyle,
                    selectionWidthStyle: selectionWidthStyle,
                    keyboardAppearance: keyboardAppearance,
                    scrollPadding: scrollPadding,
                    dragStartBehavior: dragStartBehavior,
                    mouseCursor: mouseCursor,
                    scrollPhysics: scrollPhysics,
                    autofillHints: autofillHints,
                    autofocus: autofocus,
                    toolbarOptions: toolbarOptions,
                    enableInteractiveSelection: enableInteractiveSelection,
                    buildCounter: buildCounter,
                    maxLengthEnforcement: maxLengthEnforcement,
                    inputFormatters: inputFormatters,
                    keyboardType: keyboardType,
                    maxLength: maxLength,
                    scrollController: scrollController,
                    selectionControls: textSelectionControls,
                    onChanged: readOnly
                        ? null
                        : (String v) {
                            final T? value = state.value;
                            if (value != null &&
                                displayStringForOption(value) != v) {
                              state.didChange(null);
                            }
                          },
                  );
                }
                return OrientationBuilder(builder: (context, orientation) {
                  WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                    final RenderObject? renderObject =
                        context.findRenderObject();
                    if (renderObject != null && renderObject is RenderBox) {
                      state.optionsViewWidthNotifier.value =
                          renderObject.size.width;
                    }
                  });
                  return decorator == null
                      ? field
                      : decorator.build(state.controller, field);
                });
              },
            );
          },
        );

  @override
  FormeFieldState<T?> createState() => _FormeAutoCompleteState();
}

class _FormeAutoCompleteState<T extends Object> extends FormeFieldState<T?> {
  TextEditingController? textEditingController;

  late final ValueNotifier<double?> optionsViewWidthNotifier =
      FormeMountedValueNotifier(null, this);

  @override
  FormeAutocomplete<T> get widget => super.widget as FormeAutocomplete<T>;

  @override
  void dispose() {
    super.dispose();
    optionsViewWidthNotifier.dispose();
  }

  @override
  set readOnly(bool readOnly) {
    super.readOnly = readOnly;

    if (readOnly) {
      //unfocus textField to hide options view
      controller.focusNode?.unfocus();
    }
  }

  @override
  void reset() {
    super.reset();

    controller.focusNode?.unfocus();
    if (value != null) {
      textEditingController?.text = widget.displayStringForOption(value!);
    } else {
      textEditingController?.text = '';
    }
  }

  void initFieldView(
      TextEditingController textEditingController, FocusNode focusNode) {
    final bool first = this.textEditingController == null;
    this.textEditingController = textEditingController;
    super.focusNode = focusNode;
    if (first) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        widget.onFieldViewInitialed?.call(controller);
      });
    }
  }

  @override
  void onValueChanged(T? value) {
    if (textEditingController == null) {
      return;
    }
    if (value != null) {
      final String text = widget.displayStringForOption(value);
      if (textEditingController!.text != text) {
        textEditingController!.text = text;
      }
    }
  }

  @override
  FormeFieldController<T?> createFormeFieldController() {
    return FormeAutocompleteController._(
        super.createFormeFieldController(), this);
  }

  String? get displayStringForOption =>
      value == null ? null : widget.displayStringForOption(value!);
}

class FormeAutocompleteController<T> extends FormeFieldControllerDelegate<T> {
  final _FormeAutoCompleteState _state;
  FormeAutocompleteController._(FormeFieldController<T> delegate, this._state)
      : super(delegate);

  /// get textFieldController of FieldView
  TextEditingController? get textFieldController =>
      _state.textEditingController;

  /// get display string for current value
  String? get displayString => _state.displayStringForOption;
}

// The default Material-style Autocomplete options.
class AutocompleteOptions<T extends Object> extends StatelessWidget {
  const AutocompleteOptions({
    Key? key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.options,
    required this.maxOptionsHeight,
    required this.width,
  }) : super(key: key);

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T> onSelected;

  final Iterable<T> options;
  final double maxOptionsHeight;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final BoxConstraints constraints = width == null
        ? BoxConstraints(maxHeight: maxOptionsHeight)
        : BoxConstraints(maxHeight: maxOptionsHeight, maxWidth: width!);
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: constraints,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final T option = options.elementAt(index);
              return InkWell(
                onTap: () {
                  onSelected(option);
                },
                child: Builder(builder: (BuildContext context) {
                  final bool highlight =
                      AutocompleteHighlightedOption.of(context) == index;
                  if (highlight) {
                    SchedulerBinding.instance!
                        .addPostFrameCallback((Duration timeStamp) {
                      Scrollable.ensureVisible(context, alignment: 0.5);
                    });
                  }
                  return Container(
                    color: highlight ? Theme.of(context).focusColor : null,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(displayStringForOption(option)),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
