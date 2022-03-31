import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class FormeSearchablePaginationBar extends StatefulWidget {
  final ValueChanged<int>? onPageChanged;
  final FormePaginationConfiguration configuration;
  final int currentPage;
  final int totalPage;

  const FormeSearchablePaginationBar({
    Key? key,
    required this.onPageChanged,
    required this.configuration,
    required this.currentPage,
    required this.totalPage,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FormeSearchablePaginationBarState();
}

class _FormeSearchablePaginationBarState
    extends State<FormeSearchablePaginationBar> {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller;

  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
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
  void didUpdateWidget(covariant FormeSearchablePaginationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _currentPage = widget.currentPage;
      _controller.text = '$_currentPage';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitInputPage() {
    final String text = _controller.text;
    final int? page = int.tryParse(text);
    if (page == null) {
      _controller.text = '$_currentPage';
    } else {
      if (page > widget.totalPage || page < 1) {
        _controller.text = '$_currentPage';
      } else {
        _goToPage(page);
      }
    }
  }

  void _nextPage() {
    if (_currentPage == widget.totalPage) {
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
    _currentPage = page;
    _controller.text = '$_currentPage';
    widget.onPageChanged?.call(_currentPage);
  }

  Widget _prev() {
    final VoidCallback? onTap =
        widget.onPageChanged == null || _currentPage == 1 ? null : _prevPage;
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
        widget.onPageChanged == null || _currentPage == widget.totalPage
            ? null
            : _nextPage;
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

  @override
  Widget build(BuildContext context) {
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
                readOnly: widget.onPageChanged == null,
                onFieldSubmitted: widget.onPageChanged == null
                    ? null
                    : (value) => _submitInputPage(),
                inputFormatters: <TextInputFormatter>[
                  _TextInputFormatter(widget.totalPage),
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(right: -2),
                  border: InputBorder.none,
                  suffixIcon: const SizedBox.shrink(),
                  suffixIconConstraints: const BoxConstraints.tightFor(),
                  suffixText: '/${widget.totalPage}',
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
