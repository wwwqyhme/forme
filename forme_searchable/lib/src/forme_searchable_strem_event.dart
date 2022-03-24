import 'package:forme/forme.dart';
import 'package:forme_searchable/src/forme_searchable_result.dart';

class FormeSearchableEvent<T extends Object> {
  final FormeAsyncOperationState state;
  final int page;
  final Map<String, Object?> condition;
  final FormeSearchablePageResult<T>? result;
  final Object? error;
  final StackTrace? stackTrace;
  final bool cancel;

  FormeSearchableEvent.success(this.result, this.page, this.condition)
      : error = null,
        stackTrace = null,
        state = FormeAsyncOperationState.success,
        cancel = false;

  FormeSearchableEvent.error(
      this.page, this.condition, this.error, this.stackTrace)
      : result = null,
        state = FormeAsyncOperationState.error,
        cancel = false;

  FormeSearchableEvent.cancel(
    this.page,
    this.condition,
  )   : result = null,
        error = null,
        stackTrace = null,
        state = FormeAsyncOperationState.processing,
        cancel = true;

  FormeSearchableEvent.processing(
    this.page,
    this.condition,
  )   : result = null,
        error = null,
        stackTrace = null,
        state = FormeAsyncOperationState.processing,
        cancel = false;

  bool get isCancel => cancel == true;
  bool get isProcessing => state == FormeAsyncOperationState.processing;

  bool get hasResult =>
      state == FormeAsyncOperationState.success && result != null;

  bool get hasError => state == FormeAsyncOperationState.error && error != null;
}
