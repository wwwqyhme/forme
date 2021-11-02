import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../forme.dart';
import '../../forme_core.dart';
import '../../forme_field.dart';

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
    bool requestFocusOnUserInteraction = true,
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
    AutocompleteFieldViewBuilder? fieldViewBuilder,
    required AutocompleteOptionsBuilder<T> optionsBuilder,
    AutocompleteOptionsViewBuilder<T>? optionsViewBuilder,
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
  }) : super(
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
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
          builder: (state) {
            final bool readOnly = state.readOnly;
            return Autocomplete<T>(
              onSelected: (T t) {
                state.didChange(t);
              },
              initialValue: initialValue == null
                  ? null
                  : TextEditingValue(
                      text: displayStringForOption(initialValue)),
              optionsMaxHeight: optionsMaxHeight,
              optionsViewBuilder: optionsViewBuilder,
              optionsBuilder: optionsBuilder,
              displayStringForOption: displayStringForOption,
              fieldViewBuilder:
                  (context, textEditingController, focusNode, onSubmitted) {
                (state as _FormeAutoCompleteState)
                    .initFieldView(textEditingController, focusNode);
                if (fieldViewBuilder != null) {
                  return fieldViewBuilder(
                      context, textEditingController, focusNode, onSubmitted);
                }
                return TextField(
                  enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
                  focusNode: focusNode,
                  controller: textEditingController,
                  decoration: decoration?.copyWith(errorText: state.errorText),
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
              },
            );
          },
        );

  @override
  FormeFieldState<T?> createState() => _FormeAutoCompleteState();
}

class _FormeAutoCompleteState<T extends Object> extends FormeFieldState<T?> {
  TextEditingController? textEditingController;

  void initFieldView(
      TextEditingController textEditingController, FocusNode focusNode) {
    final bool first = this.textEditingController == null;
    this.textEditingController = textEditingController;
    super.focusNode = focusNode;
    if (first) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        (widget as FormeAutocomplete<T>).onFieldViewInitialed?.call(controller);
      });
    }
  }

  @override
  void onValueChanged(T? value) {
    if (textEditingController == null) {
      return;
    }
    if (value != null) {
      final String text =
          (widget as FormeAutocomplete).displayStringForOption(value);
      if (textEditingController!.text != text) {
        textEditingController!.text = text;
      }
    }
  }

  @override
  FormeFieldController<T?> createFormeFieldController() {
    return FormeAutocompleteController(
        super.createFormeFieldController(), this);
  }
}

class FormeAutocompleteController<T> extends FormeFieldControllerDelegate<T> {
  final _FormeAutoCompleteState _state;
  FormeAutocompleteController(
      FormeFieldController<T> delegate, _FormeAutoCompleteState state)
      : _state = state,
        super(delegate);

  TextEditingController? get textFieldController =>
      _state.textEditingController;
}
