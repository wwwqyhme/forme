import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forme/forme.dart';
import '../../../forme_fields.dart';

typedef FormeAsyncInputChipFieldViewBuilder<T extends Object> = Widget Function(
  BuildContext context,
  List<T> selected,
  FormeAsyncInputChipState<T> field,
  TextEditingController textEditingController,
  FocusNode focusNode,
  VoidCallback onSubmitted,
);

typedef FormeAsyncInputChipOptionsViewBuilder<T extends Object> = Widget
    Function(
  FormeAsyncInputChipState<T> field,
  BuildContext context,
  void Function(List<T> option),
  Iterable<T> options,
  double? width,
);

typedef FormeAsyncInputChipBuilder<T> = Widget Function(
    T option, VoidCallback? onDelete);

class FormeAsyncInputChip<T extends Object> extends FormeField<List<T>> {
  final AutocompleteOptionToString<T> displayStringForOption;

  /// async loader debounce
  final Duration? debounce;

  final FormeAsyncAutocompleteOptionsBuilder<T> optionsBuilder;

  final double optionsMaxHeight;

  /// whether perform a search with current input
  ///
  /// return false means **DO NOT** perform a search and will clear prev options immediately
  final FormeSearchCondition? searchCondition;

  FormeAsyncInputChip({
    List<T> initialValue = const [],
    required String name,
    bool readOnly = false,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<List<T>>? onStatusChanged,
    FormeFieldSetter<List<T>>? onSaved,
    FormeValidator<List<T>>? validator,
    FormeAsyncValidator<List<T>>? asyncValidator,
    FormeFieldInitialed<List<T>>? onInitialed,
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
    FormeAsyncInputChipFieldViewBuilder<T>? fieldViewBuilder,
    FormeAsyncInputChipOptionsViewBuilder<T>? optionsViewBuilder,
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
    FormeFieldDecorator<List<T>>? decorator,
    bool registrable = true,
    InputDecoration? searchInputDecoration,
    Axis wrapDirection = Axis.horizontal,
    WrapAlignment wrapAlignment = WrapAlignment.start,
    double wrapSpacing = 4.0,
    WrapAlignment wrapRunAlignment = WrapAlignment.start,
    double wrapRunSpacing = 0.0,
    WrapCrossAlignment wrapCrossAxisAlignment = WrapCrossAlignment.center,
    TextDirection? wrapTextDirection,
    VerticalDirection wrapVerticalDirection = VerticalDirection.down,
    Clip wrapClipBehavior = Clip.none,
    double? searchInputStepWidth,
    double searchInputMinWidth = 50,
    FormeAsyncInputChipBuilder<T>? inputChipBuilder,
    FormeFieldValidationFilter<List<T>>? validationFilter,
    FormeValueComparator<List<T>>? comparator,
  }) : super(
          comparator: comparator,
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
            final FormeAsyncInputChipState<T> state =
                genericState as FormeAsyncInputChipState<T>;
            final bool readOnly = state.readOnly;
            final bool enabled = genericState.enabled;
            return RawAutocomplete<T>(
              focusNode: state.focusNode,
              textEditingController: state._textEditingController,
              onSelected: (T t) {
                state._add([t]);
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
                WidgetsBinding.instance!.addPostFrameCallback((timestamp) {
                  state._optionsViewVisibleStateNotifier.value = true;
                });

                void multiSelect(List<T> options) {
                  state._add(options);
                }

                return LayoutBuilder(builder: (context, constraints) {
                  final Size? size = state._fieldSizeGetter?.call();
                  final double? width = size?.width;
                  return optionsViewBuilder?.call(
                          state, context, multiSelect, state._options, width) ??
                      FormeMultiAutocompleteOptions(
                        displayStringForOption: displayStringForOption,
                        onSelected: multiSelect,
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
                  field = fieldViewBuilder(context, state.value, state,
                      state.effectiveController, focusNode, onSubmitted);
                } else {
                  field = TextField(
                    decoration: searchInputDecoration,
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
                  );

                  field = Wrap(
                    direction: wrapDirection,
                    alignment: wrapAlignment,
                    runAlignment: wrapRunAlignment,
                    runSpacing: wrapRunSpacing,
                    spacing: wrapSpacing,
                    crossAxisAlignment: wrapCrossAxisAlignment,
                    textDirection: wrapTextDirection,
                    verticalDirection: wrapVerticalDirection,
                    clipBehavior: wrapClipBehavior,
                    children: state.value.map<Widget>((e) {
                      void onDeleted() {
                        state.delete(e);
                      }

                      if (inputChipBuilder != null) {
                        return inputChipBuilder(
                            e, state.readOnly ? null : onDeleted);
                      }

                      return InputChip(
                        label: Text(displayStringForOption(e)),
                        onDeleted: state.readOnly ? null : onDeleted,
                      );
                    }).toList()
                      ..add(
                        IntrinsicWidth(
                          stepWidth: searchInputStepWidth,
                          child: Container(
                            constraints:
                                BoxConstraints(minWidth: searchInputMinWidth),
                            child: field,
                          ),
                        ),
                      ),
                  );
                }

                final FormeFieldDecorator<List<T>>? finalDecorator =
                    decorator ??
                        (decoration == null
                            ? null
                            : FormeInputDecoratorBuilder(
                                decoration: decoration,
                                emptyChecker: (value, state) {
                                  return state.value.isEmpty &&
                                      (state as FormeAsyncInputChipState<T>)
                                          ._textEditingController
                                          .text
                                          .isEmpty;
                                }));

                field = finalDecorator == null
                    ? field
                    : finalDecorator.build(context, field);

                if (fieldViewBuilder == null) {
                  field = GestureDetector(
                      onTap: () {
                        final bool needFocus = !state.focusNode.hasFocus;
                        if (needFocus) {
                          state.focusNode.requestFocus();
                        }
                        if (state.focusNode.hasFocus && !kIsWeb) {
                          SystemChannels.textInput
                              .invokeMethod<Object>('TextInput.show');
                        }
                      },
                      child: field);
                }
                state._fieldSizeGetter = () {
                  return (context.findRenderObject()! as RenderBox).size;
                };
                return field;
              },
            );
          },
        );

  @override
  FormeFieldState<List<T>> createState() => FormeAsyncInputChipState();
}

class FormeAsyncInputChipState<T extends Object>
    extends FormeFieldState<List<T>>
    with FormeAsyncOperationHelper<Iterable<T>> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController effectiveController = TextEditingController();
  final ValueNotifier<FormeAsyncOperationState?> _stateNotifier =
      FormeMountedValueNotifier(null);
  final ValueNotifier<bool> _optionsViewVisibleStateNotifier =
      FormeMountedValueNotifier(false);

  /// get state listenable
  ValueListenable<FormeAsyncOperationState?> get stateListenable =>
      FormeValueListenableDelegate(_stateNotifier);

  /// get options view visiable state
  ValueListenable<bool?> get optionsViewVisibleStateListenable =>
      FormeValueListenableDelegate(_optionsViewVisibleStateNotifier);

  Iterable<T> _options = [];
  Timer? _debounce;
  String? _oldTextValue;

  Size? Function()? _fieldSizeGetter;

  @override
  void initStatus() {
    super.initStatus();
    effectiveController.addListener(_fieldChange);
  }

  bool _searchCondition(TextEditingValue value) {
    if (value.text.isNotEmpty) {
      return widget.searchCondition?.call(value) ?? true;
    }
    return false;
  }

  void _fieldChange() {
    final String text = effectiveController.text;
    if (_oldTextValue != text) {
      _oldTextValue = text;

      final bool performSearch = _searchCondition(effectiveController.value);

      if (!performSearch) {
        _clearOptionsAndWaiting();
        return;
      }

      _queryOptions(effectiveController.value);
    }
  }

  @override
  FormeAsyncInputChip<T> get widget => super.widget as FormeAsyncInputChip<T>;

  void _clearOptionsAndWaiting() {
    cancelAsyncOperation();
    _debounce?.cancel();
    _options = [];
    _stateNotifier.value = null;
    _updateTextEditingController();
    _optionsViewVisibleStateNotifier.value = false;
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<List<T>> status) {
    super.onStatusChanged(status);
    if (status.isFocusChanged && !status.hasFocus) {
      _optionsViewVisibleStateNotifier.value = false;
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
    _textEditingController.text = _textEditingController.text == '' ? '*' : '';
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
    _stateNotifier.value = null;
    effectiveController.text = '';
    super.reset();
  }

  void delete(T option) {
    final List<T> value = List.of(this.value);
    if (value.remove(option)) {
      didChange(value);
    }
  }

  void _add(List<T> options) {
    final List<T> value = List.of(this.value);
    bool needDidChange = false;
    for (final T option in options) {
      if (!value.contains(option)) {
        needDidChange = true;
        value.add(option);
      }
    }

    if (needDidChange) {
      didChange(value);
      effectiveController.text = '';
      _clearOptionsAndWaiting();
    }
  }

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

class FormeMultiAutocompleteOptions<T extends Object> extends StatefulWidget {
  const FormeMultiAutocompleteOptions({
    Key? key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.options,
    required this.maxOptionsHeight,
    required this.width,
  }) : super(key: key);

  final AutocompleteOptionToString<T> displayStringForOption;

  final void Function(List<T> options) onSelected;

  final Iterable<T> options;
  final double maxOptionsHeight;
  final double? width;

  @override
  State<StatefulWidget> createState() =>
      _FormeMultiAutocompleteOptionsState<T>();
}

// The default Material-style Autocomplete options.
class _FormeMultiAutocompleteOptionsState<T extends Object>
    extends State<FormeMultiAutocompleteOptions<T>> {
  final List<T> selected = [];

  void toggle(T option) {
    setState(() {
      if (!selected.remove(option)) {
        selected.add(option);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final BoxConstraints constraints = widget.width == null
        ? BoxConstraints(maxHeight: widget.maxOptionsHeight)
        : BoxConstraints(
            maxHeight: widget.maxOptionsHeight, maxWidth: widget.width!);
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: constraints,
          child: Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: widget.options.length,
                itemBuilder: (BuildContext context, int index) {
                  final T option = widget.options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      toggle(option);
                    },
                    child: Builder(builder: (BuildContext context) {
                      final bool highlight = index == 0;
                      return Container(
                        color: highlight ? Theme.of(context).focusColor : null,
                        padding: const EdgeInsets.all(16.0),
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Checkbox(
                              value: selected.contains(option),
                              onChanged: (value) {
                                toggle(option);
                              }),
                          title: Text(widget.displayStringForOption(option)),
                        ),
                      );
                    }),
                  );
                },
              ),
              if (selected.isNotEmpty)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: FloatingActionButton(
                      onPressed: () {
                        widget.onSelected(selected);
                      },
                      child: const Icon(Icons.check),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
