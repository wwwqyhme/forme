import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../../forme.dart';
import '../../value_listenable_delegate.dart';

typedef FormeAsyncAutocompleteOptionsBuilder<T> = Future<Iterable<T>> Function(
    TextEditingValue value);

typedef FormeSearchCondition = bool Function(TextEditingValue value);

class FormeAsyncAutocomplete<T extends Object> extends FormeField<T?> {
  final AutocompleteOptionToString<T> displayStringForOption;

  /// triggered after [Autocomplete] fieldViewBuilder called , will be only called once in [FormeAutocomplete]'s lifecycle
  ///
  /// use this listener instead of [FormeField]'s onInitialed
  final FormeFieldInitialed<T?>? onFieldViewInitialed;

  /// async loader debounce
  final Duration? debounce;

  final FormeAsyncAutocompleteOptionsBuilder<T> optionsBuilder;

  final double optionsMaxHeight;

  /// whether perform a search with current input
  ///
  /// return false means **DO NOT** perform a search and will clear prev options immediately
  final FormeSearchCondition? searchCondition;

  FormeAsyncAutocomplete({
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
    FormeAutocompleteOptionsViewBuilder<T>? optionsViewBuilder,
    this.optionsMaxHeight = 200,
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
    this.debounce,
    required this.optionsBuilder,
    this.searchCondition,
    FormeFieldDecorator<T?>? decorator,
    bool registrable = true,
  }) : super(
          registrable: registrable,
          // decorator: decorator,
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
            final _FormeAsyncAutoCompleteState<T> state =
                genericState as _FormeAsyncAutoCompleteState<T>;
            final bool readOnly = state.readOnly;
            return RawAutocomplete<T>(
              onSelected: (T t) {
                state.didChange(t);
                state.effectiveController.selection = TextSelection.collapsed(
                    offset: state.effectiveController.text.length);
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
                void onOptionSelected(T option) {
                  onSelected(option);
                  state.clearOptionsAndWaiting();
                }

                return ValueListenableBuilder<double?>(
                    valueListenable: state.optionsViewWidthNotifier,
                    builder: (context, width, _child) {
                      return optionsViewBuilder?.call(context, onOptionSelected,
                              state.options, width) ??
                          AutocompleteOptions(
                            displayStringForOption: displayStringForOption,
                            onSelected: onOptionSelected,
                            options: state.options,
                            maxOptionsHeight: optionsMaxHeight,
                            width: width,
                          );
                    });
              },
              optionsBuilder: (TextEditingValue value) {
                if (state.success) {
                  return state.options;
                }
                return const Iterable.empty();
              },
              displayStringForOption: displayStringForOption,
              fieldViewBuilder:
                  (context, textEditingController, focusNode, onSubmitted) {
                state.initFieldView(textEditingController, focusNode);
                void onFieldSubmitted() {
                  onSubmitted();
                  state.clearOptionsAndWaiting();
                }

                Widget field;
                if (fieldViewBuilder != null) {
                  field = fieldViewBuilder(context, state.effectiveController,
                      focusNode, onFieldSubmitted);
                } else {
                  field = TextField(
                    enableIMEPersonalizedLearning:
                        enableIMEPersonalizedLearning,
                    focusNode: focusNode,
                    controller: state.effectiveController,
                    decoration: decoration?.copyWith(
                        errorText: state.errorText,
                        suffixIcon: decoration.suffixIcon ??
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ValueListenableBuilder<
                                        FormeAsyncAutocompleteSearchState>(
                                    valueListenable: state.stateNotifier,
                                    builder: (context, state, child) {
                                      switch (state) {
                                        case FormeAsyncAutocompleteSearchState
                                            .loading:
                                          return const Padding(
                                            padding: EdgeInsets.all(0),
                                            child: SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                              ),
                                            ),
                                          );
                                        case FormeAsyncAutocompleteSearchState
                                            .success:
                                          return const SizedBox.shrink();
                                        case FormeAsyncAutocompleteSearchState
                                            .error:
                                          return const Icon(Icons.dangerous,
                                              color: Colors.redAccent);
                                        case FormeAsyncAutocompleteSearchState
                                            .waiting:
                                          return const SizedBox.shrink();
                                      }
                                    }),
                              ],
                            )),
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
                            onFieldSubmitted();
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
  FormeFieldState<T?> createState() => _FormeAsyncAutoCompleteState();
}

class _FormeAsyncAutoCompleteState<T extends Object>
    extends FormeFieldState<T?> {
  TextEditingController? textEditingController;
  late final TextEditingController effectiveController;
  late final ValueNotifier<FormeAsyncAutocompleteSearchState> stateNotifier =
      FormeMountedValueNotifier(
          FormeAsyncAutocompleteSearchState.waiting, this);
  late final ValueNotifier<double?> optionsViewWidthNotifier =
      FormeMountedValueNotifier(null, this);

  int gen = 0;
  int optionsGen = 0;
  Iterable<T> options = [];
  Timer? debounce;
  String? oldTextValue;

  bool get success =>
      stateNotifier.value == FormeAsyncAutocompleteSearchState.success;
  bool get error =>
      stateNotifier.value == FormeAsyncAutocompleteSearchState.error;

  @override
  void beforeInitiation() {
    super.beforeInitiation();
    final String initialText = initialValue == null
        ? ''
        : widget.displayStringForOption(initialValue!);
    effectiveController = TextEditingController(text: initialText);
  }

  @override
  void afterInitiation() {
    super.afterInitiation();
    effectiveController.addListener(fieldChange);
  }

  void fieldChange() {
    final String text = effectiveController.text;
    if (oldTextValue != text) {
      oldTextValue = text;
      if (value != null && widget.displayStringForOption(value!) == text) {
        return;
      }

      if (widget.searchCondition != null) {
        final bool performSearch =
            widget.searchCondition!(effectiveController.value);

        if (!performSearch) {
          clearOptionsAndWaiting();
          return;
        }
      }
      queryOptions(effectiveController.value);
    }
  }

  @override
  FormeAsyncAutocomplete<T> get widget =>
      super.widget as FormeAsyncAutocomplete<T>;

  void clearOptionsAndWaiting() {
    debounce?.cancel();
    options = [];
    optionsGen = ++gen;
    stateNotifier.value = FormeAsyncAutocompleteSearchState.waiting;
    updateTextEditingController();
  }

  void queryOptions(TextEditingValue value) {
    stateNotifier.value = FormeAsyncAutocompleteSearchState.loading;
    final int currentGen = ++gen;
    debounce?.cancel();
    debounce = Timer(widget.debounce ?? const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }
      widget.optionsBuilder(value).then((options) {
        if (currentGen == gen) {
          this.options = options;
          optionsGen = gen;
        }
      }).whenComplete(() {
        if (currentGen == gen && mounted) {
          if (optionsGen == gen) {
            stateNotifier.value = FormeAsyncAutocompleteSearchState.success;
          } else {
            stateNotifier.value = FormeAsyncAutocompleteSearchState.error;
          }
          if (success) {
            updateTextEditingController();
          }
        }
      });
    });
  }

  void updateTextEditingController() {
    textEditingController?.text = textEditingController?.text == '' ? '*' : '';
  }

  @override
  void dispose() {
    debounce?.cancel();
    stateNotifier.dispose();
    optionsViewWidthNotifier.dispose();
    effectiveController.dispose();
    super.dispose();
  }

  @override
  set readOnly(bool readOnly) {
    super.readOnly = readOnly;

    if (readOnly) {
      clearOptionsAndWaiting();
    }
  }

  @override
  void reset() {
    debounce?.cancel();
    oldTextValue = null;
    options = [];
    optionsGen = ++gen;
    super.reset();
    stateNotifier.value = FormeAsyncAutocompleteSearchState.waiting;
    controller.focusNode?.unfocus();
    // we do not want to perform a search
    effectiveController.removeListener(fieldChange);
    if (value != null) {
      effectiveController.text = widget.displayStringForOption(value!);
    } else {
      effectiveController.text = '';
    }
    effectiveController.addListener(fieldChange);
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
    if (value != null) {
      final String text = widget.displayStringForOption(value);
      if (effectiveController.text != text) {
        effectiveController.text = text;
      }
    }
  }

  @override
  FormeFieldController<T?> createFormeFieldController() {
    return FormeAsnycAutocompleteController._(
        super.createFormeFieldController(), this);
  }

  String? get displayStringForOption =>
      value == null ? null : widget.displayStringForOption(value!);
}

class FormeAsnycAutocompleteController<T>
    extends FormeFieldControllerDelegate<T> {
  final _FormeAsyncAutoCompleteState _state;
  final ValueListenable<FormeAsyncAutocompleteSearchState> stateListenable;
  FormeAsnycAutocompleteController._(
      FormeFieldController<T> delegate, this._state)
      : stateListenable = ValueListenableDelegate(_state.stateNotifier),
        super(delegate);

  /// get textFieldController used for Field view
  TextEditingController get textFieldController => _state.effectiveController;

  /// get display string for current value
  String? get displayString => _state.displayStringForOption;
}

enum FormeAsyncAutocompleteSearchState { loading, success, error, waiting }
