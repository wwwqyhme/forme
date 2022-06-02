import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forme/forme.dart';

typedef FormeAutocompleteOptionsViewBuilder<T extends Object> = Widget Function(
    BuildContext context,
    AutocompleteOnSelected<T> onSelected,
    Iterable<T> options,
    double? width);

class FormeAutocomplete<T extends Object> extends FormeField<T?> {
  final AutocompleteOptionToString<T> displayStringForOption;

  FormeAutocomplete({
    T? initialValue,
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<T?>? onStatusChanged,
    FormeFieldSetter<T?>? onSaved,
    FormeValidator<T?>? validator,
    FormeAsyncValidator<T?>? asyncValidator,
    FormeFieldInitialed<T?>? onInitialed,
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
    FormeFieldValidationFilter<T?>? validationFilter,
  }) : super(
          validationFilter: validationFilter,
          enabled: enabled,
          registrable: registrable,
          //  decorator: decorator,
          order: order,
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          autovalidateMode: autovalidateMode,
          onStatusChanged: onStatusChanged,
          onSaved: onSaved,
          validator: validator,
          asyncValidator: asyncValidator,
          onInitialed: onInitialed,
          key: key,
          readOnly: readOnly,
          name: name,
          initialValue: initialValue,
          builder: (genericState) {
            final FormeAutoCompleteState<T> state =
                genericState as FormeAutoCompleteState<T>;
            final bool readOnly = state.readOnly;
            final bool enabled = genericState.enabled;
            return RawAutocomplete<T>(
              focusNode: state.focusNode,
              textEditingController: state.textEditingController,
              onSelected: state.didChange,
              optionsViewBuilder: (
                BuildContext context,
                AutocompleteOnSelected<T> onSelected,
                Iterable<T> options,
              ) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final Size? size = state._fieldSizeGetter?.call();
                    final double? width = size?.width;
                    return optionsViewBuilder?.call(
                            context, onSelected, options, width) ??
                        AutocompleteOptions(
                          displayStringForOption: displayStringForOption,
                          onSelected: onSelected,
                          options: options,
                          maxOptionsHeight: optionsMaxHeight,
                          width: width,
                        );
                  },
                );
              },
              optionsBuilder: readOnly
                  ? (TextEditingValue value) => const Iterable.empty()
                  : optionsBuilder,
              displayStringForOption: displayStringForOption,
              fieldViewBuilder:
                  (context, textEditingController, focusNode, onSubmitted) {
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
                state._fieldSizeGetter = () {
                  return (context.findRenderObject()! as RenderBox).size;
                };
                return decorator == null
                    ? field
                    : decorator.build(context, field);
              },
            );
          },
        );

  @override
  FormeFieldState<T?> createState() => FormeAutoCompleteState();
}

class FormeAutoCompleteState<T extends Object> extends FormeFieldState<T?> {
  late final TextEditingController textEditingController;

  Size? Function()? _fieldSizeGetter;

  @override
  FormeAutocomplete<T> get widget => super.widget as FormeAutocomplete<T>;

  @override
  void initStatus() {
    super.initStatus();
    textEditingController = TextEditingController(
        text: value == null ? '' : widget.displayStringForOption(value!));
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<T?> status) {
    super.onStatusChanged(status);
    if (status.isValueChanged && status.value != null) {
      final String text = widget.displayStringForOption(status.value!);
      if (textEditingController.text != text) {
        textEditingController.text = text;
      }
    }
    if (status.isReadOnlyChanged && readOnly && hasFocusNode) {
      focusNode.unfocus();
    }
  }

  @override
  void reset() {
    super.reset();

    if (hasFocusNode) {
      focusNode.unfocus();
    }
    if (value != null) {
      textEditingController.text = widget.displayStringForOption(value!);
    } else {
      textEditingController.text = '';
    }
  }

  String? get displayStringForOption =>
      value == null ? null : widget.displayStringForOption(value!);
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
                    Ambiguates.schedulerBinding
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
