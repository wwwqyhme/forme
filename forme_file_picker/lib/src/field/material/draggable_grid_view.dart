import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

typedef DraggableItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
);

class DraggableGridView<T> extends StatefulWidget {
  final List<T>? initialValue;
  final DraggableItemBuilder<T> builder;
  final Duration animateDuration;
  final GridController<T>? controller;
  final SliverGridDelegate gridDelegate;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final DraggableConfiguration<T> draggableConfiguration;
  final ValueChanged<List<T>>? onAccept;
  final Curve? slideCurve;
  final bool reOrderable;

  const DraggableGridView({
    this.padding,
    this.draggableConfiguration = const DraggableConfiguration.disabled(),
    required this.builder,
    this.initialValue,
    this.controller,
    required this.gridDelegate,
    this.animateDuration = const Duration(milliseconds: 100),
    this.onAccept,
    Key? key,
    this.slideCurve,
    this.reOrderable = true,
    this.shrinkWrap = true,
    this.scrollController,
    this.physics,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _DraggableGridViewState<T>();
}

class _DraggableGridViewState<T> extends State<DraggableGridView<T>> {
  GridController<T>? _controller;
  GridController<T> get _effectiveController =>
      widget.controller ?? _controller!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createLocalController(widget.initialValue ?? []);
    }
    _effectiveController.addListener(onValueChanged);
  }

  void onValueChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(onValueChanged);
    _controller?.dispose();
    super.dispose();
  }

  void _createLocalController(List<T> items) {
    _controller = GridController<T>(items);
  }

  @override
  void didUpdateWidget(DraggableGridView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller != null && widget.controller == null) {
        _createLocalController(oldWidget.controller!.value);
      }

      if (widget.controller != null) {
        if (oldWidget.controller == null) {
          _controller!.dispose();
          _controller = null;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: widget.shrinkWrap,
      controller: widget.scrollController,
      physics: widget.physics,
      padding: widget.padding,
      gridDelegate: widget.gridDelegate,
      itemCount: _effectiveController.value.length,
      itemBuilder: (context, index) {
        return DraggableGridItem<T>(
          widget.animateDuration,
          _effectiveController.createIfNotExists(index),
          _effectiveController,
          widget.builder,
          _effectiveController.value[index],
          widget.draggableConfiguration,
          widget.onAccept,
          widget.slideCurve,
          widget.reOrderable,
        );
      },
    );
  }
}

class _CompleteCallback {
  final List<int> gens;
  final VoidCallback onCompleted;

  _CompleteCallback(this.gens, this.onCompleted);

  bool complete(int gen) {
    return gens.remove(gen) && gens.isEmpty;
  }

  bool cancel(int gen) {
    return gens.contains(gen);
  }
}

class GridController<T> extends ValueNotifier<List<T>> {
  final Map<int, _DraggableController> _controllers = {};
  final List<_CompleteCallback> _completeCallbacks = [];
  final Map<int, int> _animateMap = {};
  List<T>? _animateItems;
  int _gen = 0;

  GridController(List<T> items) : super(items);

  _DraggableController createIfNotExists(int index) {
    return _controllers.putIfAbsent(index, () => _DraggableController(index));
  }

  List<T>? get currentItems => _animateItems;

  bool canAccept(dynamic data) {
    if (data == null) {
      return false;
    }
    return _controllers.values.contains(data);
  }

  bool get _accepted => _controllers.values.any((element) => element.accepted);

  @override
  void dispose() {
    _clearAnimations();
    super.dispose();
  }

  void removeData(dynamic data, [VoidCallback? onCompleted]) {
    if (!canAccept(data)) {
      return;
    }
    remove([(data as _DraggableController).index], onCompleted);
  }

  void remove(List<int> indexes, [VoidCallback? onCompleted]) {
    final List<int> validIndexes = indexes
        .where((element) => element >= 0 && element < value.length)
        .toSet()
        .toList()
      ..sort((a, b) => -a.compareTo(b));
    if (validIndexes.isEmpty) {
      onCompleted?.call();
      return;
    }
    _animateItems ??= List.of(value);
    validIndexes
        .map((e) => _controllers[e]!.currentIndex)
        .where((element) => element != -1)
        .forEach(_animateItems!.removeAt);
    _animate(onCompleted: onCompleted);
  }

  @override
  set value(List<T> newValue) {
    _clearAnimations();
    _animateItems = null;
    super.value = newValue;
  }

  void _clearAnimations() {
    _animateMap.clear();
    _completeCallbacks.clear();
    for (final _DraggableController element in _controllers.values) {
      element.dispose();
    }
    _controllers.clear();
  }

  /// [start] the index of DraggableItem
  ///
  /// [end] the **current index** of DraggableItem
  void _move(int start, int end) {
    _animateItems ??= List.of(value);
    final T item = value[start];
    _animateItems!
        .insert(end, _animateItems!.removeAt(_animateItems!.indexOf(item)));
    _animate();
  }

  int _beforeAnimate(int index) {
    _onAnimateCanceled(index);
    final int gen = ++_gen;
    _animateMap[gen] = index;
    return gen;
  }

  /// perform animate grid items
  ///
  /// [onCompleted] only called when all animated grid items completed
  /// if any grid item intercepted by another animation , [onCompleted] will not
  /// be triggered
  void _animate({VoidCallback? onCompleted}) {
    for (final element in _controllers.values) {
      final T _item = value[element.index];
      element._currentIndex = _animateItems!.indexOf(_item);
    }
    final List<int> gens = [];
    for (final _DraggableController controller in _controllers.values) {
      if (controller.animatedIndex != controller.currentIndex) {
        if (controller.currentIndex == -1) {
          _onAnimateCanceled(controller.index);
          controller.value = null;
        } else {
          final int gen = _beforeAnimate(controller.index);
          gens.add(gen);
          final Offset targetPosition = _controllers.values
              .where((element) => element.index == controller.currentIndex)
              .first
              .renderBox
              .localToGlobal(Offset.zero);
          final RenderBox current = _controllers.values
              .where((element) => element.index == controller.index)
              .first
              .renderBox;
          final Offset position = current.localToGlobal(Offset.zero);
          controller.value = _AnimateInfo(
              Offset(
                (targetPosition.dx - position.dx) / current.size.width,
                (targetPosition.dy - position.dy) / current.size.height,
              ),
              gen);
        }
        controller._animatedIndex = controller.currentIndex;
      }
    }
    if (gens.isNotEmpty) {
      if (onCompleted != null) {
        _completeCallbacks.add(_CompleteCallback(gens, onCompleted));
      }
    } else {
      if (onCompleted != null) {
        onCompleted.call();
      }
    }
  }

  void _onAnimateCanceled(int index) {
    if (!_animateMap.values.contains(index)) {
      return;
    }
    int? gen;
    _animateMap.removeWhere((key, value) {
      if (value == index) {
        gen = key;
        return true;
      }
      return false;
    });
    if (gen != null) {
      _completeCallbacks.removeWhere((element) => element.cancel(gen!));
    }
  }

  void _onAnimateEnd(int gen) {
    _animateMap.remove(gen);
    final List<VoidCallback> callbacks = [];
    _completeCallbacks.removeWhere((element) {
      if (element.complete(gen)) {
        /// we should not call onCompleted here
        /// if onCompleted required a new animation
        /// we'll get an concurrent modified exception
        callbacks.add(element.onCompleted);
        return true;
      }
      return false;
    });
    for (final VoidCallback e in callbacks) {
      e.call();
    }
  }
}

class DraggableGridItem<T> extends StatefulWidget {
  final _DraggableController controller;
  final GridController<T> gridController;
  final DraggableItemBuilder<T> builder;
  final Duration duration;
  final T item;
  final DraggableConfiguration<T> draggableConfiguration;

  /// called when drag canceled or accepted
  final ValueChanged<List<T>>? onAccept;

  final Curve? slideCurve;
  final bool reOrderable;
  DraggableGridItem(
    this.duration,
    this.controller,
    this.gridController,
    this.builder,
    this.item,
    this.draggableConfiguration,
    this.onAccept,
    this.slideCurve,
    this.reOrderable,
  ) : super(key: controller.key);

  @override
  State<StatefulWidget> createState() => _DraggableItemState<T>();
}

class _DraggableItemState<T> extends State<DraggableGridItem<T>>
    with SingleTickerProviderStateMixin {
  late _AnimateInfo? _animateInfo = widget.controller.value;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          _animateInfo = widget.controller.value;
        });
      }
    });
  }

  void onAnimateEnd() {
    widget.gridController._onAnimateEnd(_animateInfo!.gen);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Ambiguates.schedulerBinding.addPostFrameCallback((t) {
      if (!mounted) {
        return;
      }
      widget.controller.context = context;
    });
    final Widget child =
        widget.builder(context, widget.item, widget.controller.index);

    final Widget transition = _animateInfo != null
        ? AnimatedSlide(
            offset: _animateInfo!.offset,
            onEnd: onAnimateEnd,
            duration: widget.duration,
            curve: widget.slideCurve ?? Curves.linear,
            child: child,
          )
        : const SizedBox.shrink();

    if (!widget.draggableConfiguration
        .draggable(widget.item, widget.controller.index)) {
      return transition;
    }

    void _onAccept() {
      if (widget.gridController._animateItems != null) {
        widget.onAccept?.call(widget.gridController._animateItems!);
      }
    }

    void _onDragCompleted(int index) {
      final bool accepted = widget.gridController._accepted;
      if (accepted) {
        _onAccept();
        return;
      }
    }

    return DragTarget<_DraggableController>(
      onWillAccept: (data) {
        if (!widget.reOrderable || !widget.gridController.canAccept(data)) {
          return false;
        }
        widget.gridController._move(data!.index, widget.controller.index);
        return true;
      },
      onAccept: (data) {
        widget.controller.accepted = true;
      },
      builder: (context, candidateData, rejectedData) {
        return LayoutBuilder(builder: (context, constraints) {
          return LongPressDraggable(
            maxSimultaneousDrags: 1,
            delay: widget.draggableConfiguration.longPressDelay ??
                kLongPressTimeout,
            childWhenDragging:
                widget.draggableConfiguration.childWhenDraggingBuilder?.call(
                        context, widget.item, widget.controller.index, child) ??
                    const SizedBox.shrink(),
            feedback: Material(
              color: Colors.transparent,
              child: widget.draggableConfiguration.feedbackBuilder?.call(
                      context,
                      widget.item,
                      widget.controller.index,
                      child,
                      Size(constraints.maxWidth, constraints.maxHeight)) ??
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: child,
                  ),
            ),
            data: widget.controller,
            onDragStarted: () {
              widget.draggableConfiguration.onDragStart
                  ?.call(widget.controller.index);
            },
            onDragCompleted: () {
              if (!mounted) {
                return;
              }
              _onDragCompleted(widget.controller.index);
            },
            onDraggableCanceled: (velocity, offset) {
              if (!mounted) {
                return;
              }
              _onAccept();
            },
            onDragEnd: (d) {
              if (!mounted) {
                return;
              }
              widget.draggableConfiguration.onDragEnd
                  ?.call(widget.controller.index);
            },
            child: transition,
          );
        });
      },
    );
  }
}

class _DraggableController extends ValueNotifier<_AnimateInfo?> {
  /// grid item index
  final int index;

  final Key key = UniqueKey();

  int? _currentIndex;
  int? _animatedIndex;

  /// current index after drag
  int get currentIndex => _currentIndex ?? index;
  int get animatedIndex => _animatedIndex ?? index;

  bool accepted = false;

  late BuildContext context;

  RenderBox get renderBox => context.findRenderObject()! as RenderBox;

  _DraggableController(
    this.index,
  ) : super(const _AnimateInfo(Offset.zero, 0));
}

@immutable
class _AnimateInfo {
  final Offset offset;
  final int gen;

  const _AnimateInfo(this.offset, this.gen);

  @override
  bool operator ==(Object o) =>
      o is _AnimateInfo && gen == o.gen && offset == o.offset;
  @override
  int get hashCode => Object.hash(offset, gen);
}

class DraggableConfiguration<T> {
  final bool Function(T item, int index) draggable;
  final Duration? longPressDelay;
  final Widget Function(BuildContext context, T item, int index, Widget child)?
      childWhenDraggingBuilder;
  final Widget Function(
          BuildContext context, T item, int index, Widget child, Size? size)?
      feedbackBuilder;
  final ValueChanged<int>? onDragStart;
  final ValueChanged<int>? onDragEnd;

  static bool _enableAll(dynamic item, int index) {
    return true;
  }

  static bool _disableAll(dynamic item, int index) {
    return false;
  }

  DraggableConfiguration({
    this.draggable = _enableAll,
    this.childWhenDraggingBuilder,
    this.feedbackBuilder,
    this.longPressDelay = kLongPressTimeout,
    this.onDragStart,
    this.onDragEnd,
  });

  const DraggableConfiguration.disabled()
      : draggable = _disableAll,
        longPressDelay = null,
        childWhenDraggingBuilder = null,
        feedbackBuilder = null,
        onDragStart = null,
        onDragEnd = null;
}
