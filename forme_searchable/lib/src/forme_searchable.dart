import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import 'field/material/base_field_content.dart';
import 'field/material/base_route_field.dart';
import 'field/material/pagination_bar.dart';
import 'field/material/route_configuration.dart';
import 'forme_searchable_condition.dart';
import 'forme_searchable_state.dart';
import 'forme_searchable_controller.dart';
import 'forme_searchable_result.dart';

typedef FormeSearchableQuery<T extends Object>
    = Future<FormeSearchablePageResult<T>> Function(
        FormeSearchCondition condition);

typedef FormeSearchableQueryFilter = bool Function(
    FormeSearchCondition condition);

class FormeSearchable<T extends Object> extends FormeField<List<T>> {
  final FormeSearchableQuery<T> query;
  final int? maximum;
  final List<T> Function(List<T> value, int maximum)? onMaximumExceed;
  final Duration debounce;
  final FormeSearchableQueryFilter? queryFilter;

  FormeSearchable._({
    Key? key,
    required String name,
    required List<T> initialValue,
    required this.query,
    required Widget child,
    this.maximum,
    this.onMaximumExceed,
    required this.debounce,
    this.queryFilter,
    bool readOnly = false,
    FormeValueComparator<List<T>>? comparator,
    bool enabled = true,
    int? order,
    FormeFieldDecorator<List<T>>? decorator,
    FormeFieldStatusChanged<List<T>>? onStatusChanged,
    FormeFieldInitialed<List<T>>? onInitialed,
    FormeFieldSetter<List<T>>? onSaved,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    FormeValidator<List<T>>? validator,
    FormeAsyncValidator<List<T>>? asyncValidator,
    AutovalidateMode? autovalidateMode,
    bool registrable = true,
    FormeFieldValidationFilter<List<T>>? validationFilter,
    bool requestFocusOnUserInteraction = true,
  }) : super(
          requestFocusOnUserInteraction: requestFocusOnUserInteraction,
          validationFilter: validationFilter,
          registrable: registrable,
          autovalidateMode: autovalidateMode,
          asyncValidator: asyncValidator,
          validator: validator,
          asyncValidatorDebounce: asyncValidatorDebounce,
          quietlyValidate: quietlyValidate,
          onSaved: onSaved,
          onInitialed: onInitialed,
          onStatusChanged: onStatusChanged,
          decorator: decorator,
          order: order,
          enabled: enabled,
          comparator: comparator,
          readOnly: readOnly,
          key: key,
          name: name,
          valueUpdater: (oldWidget, newWidget, oldValue) {
            final int? newMaximum = (newWidget as FormeSearchable<T>).maximum;
            if (newMaximum != null && oldValue.length > newMaximum) {
              if (onMaximumExceed == null) {
                return oldValue.sublist(oldValue.length - newMaximum);
              }
              final List<T> newValue = onMaximumExceed(oldValue, newMaximum);
              if (newValue.length > newMaximum) {
                throw Exception(
                    'length of new value which returned by onMaximumExceed should smaller or equals than maximum');
              }
              return newValue;
            }
            return oldValue;
          },
          builder: (genericState) {
            final FormeSearchableState<T> state =
                genericState as FormeSearchableState<T>;
            return FormeSearchableController<T>(
              state,
              child: _MediaQueryHolder(child: child),
            );
          },
          initialValue: initialValue,
        );

  @override
  FormeFieldState<List<T>> createState() => FormeSearchableState<T>();

  factory FormeSearchable.bottomSheet({
    required String name,
    required FormeSearchableQuery<T> query,
    int? maximum,
    List<T> Function(List<T> value, int maximum)? onMaximumExceed,
    Duration? debounce,
    List<T>? initialValue,
    FormeSearchableQueryFilter? queryFilter,
    bool readOnly = false,
    FormeValueComparator<List<T>>? comparator,
    bool enabled = true,
    int? order,
    FormeFieldDecorator<List<T>>? decorator,
    FormeFieldStatusChanged<List<T>>? onStatusChanged,
    FormeFieldInitialed<List<T>>? onInitialed,
    FormeFieldSetter<List<T>>? onSaved,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    FormeValidator<List<T>>? validator,
    FormeAsyncValidator<List<T>>? asyncValidator,
    AutovalidateMode? autovalidateMode,
    bool registrable = true,
    FormeFieldValidationFilter<List<T>>? validationFilter,
    bool requestFocusOnUserInteraction = true,
    FormeBottomSheetConfiguration? bottomSheetConfiguration,
    AutocompleteOptionToString<T>? displayStringForOption,
    FormeSearchableDisplayWidgetBuilder<T>? displayBuilder,
    FormeSearchableOptionWidgetBuilder<T>? optionWidgetBuilder,
    FormeSearchablePaginationBarBuilder? paginationBarBuilder,
    WidgetBuilder? processingWidgetBuilder,
    WidgetBuilder? emptyContentWidgetBuilder,
    FormeSearchablePaginationBarPosition? paginationBarPosition,
    FormePaginationConfiguration? defaultPaginationConfiguration,
    FormeSearchableSearchFieldsBuilder? searchFieldsBuilder,
    Widget Function(BuildContext context, VoidCallback? refresh)?
        errorWidgetBuilder,
    InputDecoration? decoration,
  }) {
    return FormeSearchable<T>._(
      readOnly: readOnly,
      comparator: comparator,
      enabled: enabled,
      order: order,
      decorator: decorator,
      onStatusChanged: onStatusChanged,
      onInitialed: onInitialed,
      onSaved: onSaved,
      quietlyValidate: quietlyValidate,
      asyncValidatorDebounce: asyncValidatorDebounce,
      validator: validator,
      asyncValidator: asyncValidator,
      autovalidateMode: autovalidateMode,
      registrable: registrable,
      validationFilter: validationFilter,
      requestFocusOnUserInteraction: requestFocusOnUserInteraction,
      queryFilter: queryFilter,
      name: name,
      query: query,
      debounce: debounce ?? const Duration(milliseconds: 500),
      child: FormeSearchableBaseRouteField<T>(
        emptyContentWidgetBuilder: emptyContentWidgetBuilder,
        decoration: decoration,
        searchFieldsBuilder: searchFieldsBuilder,
        errorWidgetBuilder: errorWidgetBuilder,
        displayBuilder: displayBuilder,
        optionWidgetBuilder: optionWidgetBuilder,
        paginationBarBuilder: paginationBarBuilder,
        processingWidgetBuilder: processingWidgetBuilder,
        defaultPaginationConfiguration: defaultPaginationConfiguration,
        paginationBarPosition:
            paginationBarPosition ?? FormeSearchablePaginationBarPosition.top,
        displayStringForOption:
            displayStringForOption ?? RawAutocomplete.defaultStringForOption,
        mode: Mode.bottomSheet,
        bottomSheetConfiguration:
            bottomSheetConfiguration ?? const FormeBottomSheetConfiguration(),
      ),
      maximum: maximum,
      onMaximumExceed: onMaximumExceed,
      initialValue: initialValue ?? const [],
    );
  }

  factory FormeSearchable.dialog({
    required String name,
    required FormeSearchableQuery<T> query,
    int? maximum,
    List<T> Function(List<T> value, int maximum)? onMaximumExceed,
    Duration? debounce,
    List<T>? initialValue,
    FormeSearchableQueryFilter? queryFilter,
    bool readOnly = false,
    FormeValueComparator<List<T>>? comparator,
    bool enabled = true,
    int? order,
    FormeFieldDecorator<List<T>>? decorator,
    FormeFieldStatusChanged<List<T>>? onStatusChanged,
    FormeFieldInitialed<List<T>>? onInitialed,
    FormeFieldSetter<List<T>>? onSaved,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    FormeValidator<List<T>>? validator,
    FormeAsyncValidator<List<T>>? asyncValidator,
    AutovalidateMode? autovalidateMode,
    bool registrable = true,
    FormeFieldValidationFilter<List<T>>? validationFilter,
    bool requestFocusOnUserInteraction = true,
    FormeDialogConfiguration? dialogConfiguration,
    AutocompleteOptionToString<T>? displayStringForOption,
    FormeSearchableDisplayWidgetBuilder<T>? displayBuilder,
    FormeSearchableOptionWidgetBuilder<T>? optionWidgetBuilder,
    FormeSearchablePaginationBarBuilder? paginationBarBuilder,
    WidgetBuilder? processingWidgetBuilder,
    WidgetBuilder? emptyContentWidgetBuilder,
    FormeSearchablePaginationBarPosition? paginationBarPosition,
    FormePaginationConfiguration? defaultPaginationConfiguration,
    FormeSearchableSearchFieldsBuilder? searchFieldsBuilder,
    Widget Function(BuildContext context, VoidCallback? refresh)?
        errorWidgetBuilder,
    InputDecoration? decoration,
  }) {
    return FormeSearchable<T>._(
      readOnly: readOnly,
      comparator: comparator,
      enabled: enabled,
      order: order,
      decorator: decorator,
      onStatusChanged: onStatusChanged,
      onInitialed: onInitialed,
      onSaved: onSaved,
      quietlyValidate: quietlyValidate,
      asyncValidatorDebounce: asyncValidatorDebounce,
      validator: validator,
      asyncValidator: asyncValidator,
      autovalidateMode: autovalidateMode,
      registrable: registrable,
      validationFilter: validationFilter,
      requestFocusOnUserInteraction: requestFocusOnUserInteraction,
      queryFilter: queryFilter,
      name: name,
      query: query,
      debounce: debounce ?? const Duration(milliseconds: 500),
      child: FormeSearchableBaseRouteField<T>(
        emptyContentWidgetBuilder: emptyContentWidgetBuilder,
        decoration: decoration,
        searchFieldsBuilder: searchFieldsBuilder,
        errorWidgetBuilder: errorWidgetBuilder,
        displayBuilder: displayBuilder,
        optionWidgetBuilder: optionWidgetBuilder,
        paginationBarBuilder: paginationBarBuilder,
        processingWidgetBuilder: processingWidgetBuilder,
        defaultPaginationConfiguration: defaultPaginationConfiguration,
        paginationBarPosition:
            paginationBarPosition ?? FormeSearchablePaginationBarPosition.top,
        displayStringForOption:
            displayStringForOption ?? RawAutocomplete.defaultStringForOption,
        mode: Mode.dialog,
        dialogConfiguration:
            dialogConfiguration ?? const FormeDialogConfiguration(),
      ),
      maximum: maximum,
      onMaximumExceed: onMaximumExceed,
      initialValue: initialValue ?? const [],
    );
  }
}

class _MediaQueryHolder extends StatefulWidget {
  final Widget child;

  const _MediaQueryHolder({Key? key, required this.child}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _MediaQueryHolderState();
}

class _MediaQueryHolderState extends State<_MediaQueryHolder>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    return MediaQuery(data: data, child: widget.child);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
