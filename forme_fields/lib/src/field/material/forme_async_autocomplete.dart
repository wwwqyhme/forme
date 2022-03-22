import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forme/forme.dart';
import '../../../forme_fields.dart';

typedef FormeAsyncAutocompleteOptionsBuilder<T> = Future<Iterable<T>> Function(
    TextEditingValue value);

typedef FormeSearchCondition = bool Function(TextEditingValue value);

class FormeAsyncAutocomplete<T extends Object> extends FormeField<T?> {
  final AutocompleteOptionToString<T> displayStringForOption;

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
    FormeFieldStatusChanged<T?>? onStatusChanged,
    FormeFieldSetter<T?>? onSaved,
    FormeValidator<T?>? validator,
    FormeAsyncValidator<T?>? asyncValidator,
    FormeFieldInitialed<T?>? onInitialed,
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

    /// **this decorator is used to decorate fieldView Only**
    FormeFieldDecorator<T?>? decorator,
    bool registrable = true,
    FormeFieldValidationFilter<T?>? validationFilter,
  }) : super(
          validationFilter: validationFilter,
          enabled: enabled,
          onInitialed: onInitialed,
          registrable: registrable,
          order: order,
          quietlyValidate: quietlyValidate,
          asyncValidatorDebounce: asyncValidatorDebounce,
          autovalidateMode: autovalidateMode,
          onStatusChanged: onStatusChanged,
          onSaved: onSaved,
          validator: validator,
          asyncValidator: asyncValidator,
          key: key,
          readOnly: readOnly,
          name: name,
          initialValue: initialValue,
          builder: (genericState) {
            final FormeAsyncAutoCompleteState<T> state =
                genericState as FormeAsyncAutoCompleteState<T>;
            final bool readOnly = state.readOnly;
            final bool enabled = genericState.enabled;
            return RawAutocomplete<T>(
              focusNode: state.focusNode,
              textEditingController: state._textEditingController,
              onSelected: (T t) {
                state.didChange(t);
                state.effectiveController.selection = TextSelection.collapsed(
                    offset: state.effectiveController.text.length);
                state._clearOptionsAndWaiting();
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
                state._optionsViewVisibleStateNotifier.value = true;

                return LayoutBuilder(builder: (context, constraints) {
                  final Size? size = state._fieldSizeGetter?.call();
                  final double? width = size?.width;
                  return optionsViewBuilder?.call(
                          context, onSelected, state._options, width) ??
                      AutocompleteOptions(
                        displayStringForOption: displayStringForOption,
                        onSelected: onSelected,
                        options: state._options,
                        maxOptionsHeight: optionsMaxHeight,
                        width: width,
                      );
                });
              },
              optionsBuilder: (TextEditingValue value) {
                if (state._stateNotifier.value ==
                    FormeAsyncOperationState.success) {
                  return state._options;
                }
                return const Iterable.empty();
              },
              displayStringForOption: displayStringForOption,
              fieldViewBuilder:
                  (context, textEditingController, focusNode, onSubmitted) {
                Widget field;
                if (fieldViewBuilder != null) {
                  field = fieldViewBuilder(context, state.effectiveController,
                      focusNode, onSubmitted);
                } else {
                  field = TextField(
                    decoration: decoration?.copyWith(
                        errorText: state.errorText,
                        suffixIcon: decoration.suffixIcon ??
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ValueListenableBuilder<
                                        FormeAsyncOperationState?>(
                                    valueListenable: state._stateNotifier,
                                    builder: (context, state, child) {
                                      if (state == null) {
                                        return const SizedBox.shrink();
                                      }
                                      switch (state) {
                                        case FormeAsyncOperationState
                                            .processing:
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
                                        case FormeAsyncOperationState.success:
                                          return const SizedBox.shrink();
                                        case FormeAsyncOperationState.error:
                                          return const Icon(Icons.dangerous,
                                              color: Colors.redAccent);
                                      }
                                    }),
                              ],
                            )),
                    enableIMEPersonalizedLearning:
                        enableIMEPersonalizedLearning,
                    focusNode: focusNode,
                    controller: state.effectiveController,
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
  FormeFieldState<T?> createState() => FormeAsyncAutoCompleteState();
}

class FormeAsyncAutoCompleteState<T extends Object> extends FormeFieldState<T?>
    with FormeAsyncOperationHelper<Iterable<T>> {
  final TextEditingController _textEditingController = TextEditingController();
  late final TextEditingController effectiveController;
  final ValueNotifier<FormeAsyncOperationState?> _stateNotifier =
      FormeMountedValueNotifier(null);
  final ValueNotifier<bool> _optionsViewVisibleStateNotifier =
      FormeMountedValueNotifier(false);

  Iterable<T> _options = [];
  Timer? _debounce;
  String? _oldTextValue;
  Size? Function()? _fieldSizeGetter;

  ValueListenable<bool> get optionsViewVisibleListenable =>
      FormeValueListenableDelegate(_optionsViewVisibleStateNotifier);

  @override
  void initStatus() {
    super.initStatus();
    final String initialText = initialValue == null
        ? ''
        : widget.displayStringForOption(initialValue!);
    effectiveController = TextEditingController(text: initialText);
    effectiveController.addListener(_fieldChange);
  }

  void _fieldChange() {
    final String text = effectiveController.text;
    if (_oldTextValue != text) {
      _oldTextValue = text;
      if (value != null && widget.displayStringForOption(value!) == text) {
        return;
      }

      if (widget.searchCondition != null) {
        final bool performSearch =
            widget.searchCondition!(effectiveController.value);

        if (!performSearch) {
          _clearOptionsAndWaiting();
          return;
        }
      }
      _queryOptions(effectiveController.value);
    }
  }

  @override
  FormeAsyncAutocomplete<T> get widget =>
      super.widget as FormeAsyncAutocomplete<T>;

  void _clearOptionsAndWaiting() {
    cancelAsyncOperation();
    _debounce?.cancel();
    _options = [];
    _stateNotifier.value = null;
    _updateTextEditingController();
    _optionsViewVisibleStateNotifier.value = false;
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<T?> status) {
    super.onStatusChanged(status);
    if (status.isFocusChanged) {
      if (!status.hasFocus) {
        _optionsViewVisibleStateNotifier.value = false;
      }
    }

    if (status.isValueChanged) {
      if (status.value != null) {
        final String text = widget.displayStringForOption(status.value!);
        if (effectiveController.text != text) {
          effectiveController.text = text;
        }
      }
    }

    if (status.isReadOnlyChanged && status.readOnly) {
      _clearOptionsAndWaiting();
    }
  }

  void _queryOptions(TextEditingValue value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounce ?? const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }
      perform(widget.optionsBuilder(value));
    });
  }

  void _updateTextEditingController() {
    String newText =
        value == null ? '' : '${widget.displayStringForOption(value!)} ';
    if (newText == _textEditingController.text) {
      newText += ' ';
    }
    _textEditingController.text = newText;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _stateNotifier.dispose();
    _optionsViewVisibleStateNotifier.dispose();
    _textEditingController.dispose();
    effectiveController.dispose();
    super.dispose();
  }

  @override
  void reset() {
    _debounce?.cancel();
    _oldTextValue = null;
    _options = [];
    super.reset();
    _stateNotifier.value = null;
    if (hasFocusNode) {
      focusNode.unfocus();
    }
    // we do not want to perform a search
    effectiveController.removeListener(_fieldChange);
    if (value != null) {
      effectiveController.text = widget.displayStringForOption(value!);
    } else {
      effectiveController.text = '';
    }
    effectiveController.addListener(_fieldChange);
  }

  String? get displayStringForOption =>
      value == null ? null : widget.displayStringForOption(value!);

  @override
  void onAsyncStateChanged(FormeAsyncOperationState state, Object? key) {
    if (mounted) {
      _stateNotifier.value = state;
    }
  }

  @override
  void onSuccess(Iterable<T> result, Object? key) {
    if (mounted) {
      _options = result;
      _updateTextEditingController();
    }
  }
}
