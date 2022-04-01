import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../forme_searchable_condition.dart';
import '../../forme_searchable_field.dart';
import '../../forme_searchable_result.dart';
import '../../page_info.dart';

class FormePaginationConfiguration {
  final Widget? prev;
  final Widget? next;
  final IconData? prevIcon;
  final IconData? nextIcon;

  const FormePaginationConfiguration({
    this.prev,
    this.next,
    this.prevIcon,
    this.nextIcon,
  });
}

class BasePaginationBar<T extends Object> extends FormeSearchableField<T> {
  /// build pagination bar
  final FormePaginationConfiguration configuration;

  const BasePaginationBar({
    Key? key,
    this.configuration = const FormePaginationConfiguration(),
  }) : super(key: key);
  @override
  FormeSearchableFieldState<T> createState() =>
      _FormeSearchablePaginationBarState<T>();
}

class _FormeSearchablePaginationBarState<T extends Object>
    extends FormeSearchableFieldState<T> {
  late final TextEditingController _controller;

  bool get readOnly => status.readOnly;
  final FocusNode _focusNode = FocusNode();
  late int _currentPage;

  PageInfo? _pageInfo;

  int get totalPage => _pageInfo?.totalPage ?? 1;

  @override
  BasePaginationBar<T> get widget => super.widget as BasePaginationBar<T>;

  @override
  void initState() {
    super.initState();
    _currentPage = _pageInfo?.currentPage ?? 1;
    _controller = TextEditingController(text: '$_currentPage');
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _controller.text = '$_currentPage';
      } else {
        final newText = _controller.text.toLowerCase();
        _controller.value = _controller.value.copyWith(
          text: newText,
          selection: TextSelection(baseOffset: 0, extentOffset: newText.length),
          composing: TextRange.empty,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (totalPage <= 1) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        _prev(),
        Expanded(
          child: Center(
            child: IntrinsicWidth(
              child: TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.go,
                focusNode: _focusNode,
                controller: _controller,
                readOnly: readOnly,
                onFieldSubmitted:
                    readOnly ? null : (value) => _submitInputPage(),
                inputFormatters: <TextInputFormatter>[
                  _TextInputFormatter(totalPage),
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(right: -2),
                  border: InputBorder.none,
                  suffixIcon: const SizedBox.shrink(),
                  suffixIconConstraints: const BoxConstraints.tightFor(),
                  suffixText: '/$totalPage',
                  suffixStyle: Theme.of(context).textTheme.subtitle1,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ),
        _next(),
      ],
    );
  }

  @override
  void onQuerySuccess(
      FormeSearchCondition condition, FormeSearchablePageResult<T> result) {
    super.onQuerySuccess(condition, result);
    setState(() {
      _pageInfo = PageInfo(condition.page, result.totalPage);
    });
  }

  @override
  void onQueryCancelled(FormeSearchCondition condition) {
    super.onQueryCancelled(condition);
    setState(() {
      _pageInfo = null;
    });
  }

  @override
  void onConditionChangeStart(FormeSearchCondition condition) {
    super.onConditionChangeStart(condition);
    setState(() {
      _pageInfo = null;
    });
  }

  @override
  void onReset() {
    super.onReset();
    _pageInfo = null;
  }

  void _submitInputPage() {
    final String text = _controller.text;
    final int? page = int.tryParse(text);
    if (page == null) {
      _controller.text = '$_currentPage';
    } else {
      if (page > totalPage || page < 1) {
        _controller.text = '$_currentPage';
      } else {
        _goToPage(page);
      }
    }
  }

  void _nextPage() {
    if (_currentPage == totalPage) {
      return;
    }
    _goToPage(_currentPage + 1);
  }

  void _prevPage() {
    if (_currentPage == 1) {
      return;
    }
    _goToPage(_currentPage - 1);
  }

  void _goToPage(int page) {
    if (readOnly) {
      return;
    }
    setState(() {
      _currentPage = page;
    });
    _controller.text = '$_currentPage';
    goToPage(_currentPage);
  }

  Widget _prev() {
    final VoidCallback? onTap =
        readOnly || _currentPage == 1 ? null : _prevPage;
    if (widget.configuration.prev == null) {
      return IconButton(
          onPressed: onTap,
          icon:
              Icon(widget.configuration.prevIcon ?? Icons.arrow_left_rounded));
    }
    return InkWell(
      onTap: onTap,
      child: widget.configuration.prev,
    );
  }

  Widget _next() {
    final VoidCallback? onTap =
        readOnly || _currentPage == totalPage ? null : _nextPage;
    if (widget.configuration.next == null) {
      return IconButton(
          onPressed: onTap,
          icon:
              Icon(widget.configuration.nextIcon ?? Icons.arrow_right_rounded));
    }
    return InkWell(
      onTap: onTap,
      child: widget.configuration.prev,
    );
  }
}

class _TextInputFormatter extends TextInputFormatter {
  final int max;

  _TextInputFormatter(this.max);
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final int? current = int.tryParse(newValue.text);
    if (current == null || current < 1 || current > max) {
      return oldValue;
    }
    return newValue;
  }
}
