import 'package:flutter/material.dart';
import 'package:forme/forme.dart';
import 'expansion_list_tile.dart' as e;

typedef FormeExpansionListTileControlBuilder<T extends Object> = Widget
    Function(
  BuildContext context,
  T data,
  bool isSelected,
  VoidCallback? toggle,
);

class FormeExpansionListTileItem<T extends Object> {
  final Widget title;
  final bool readOnly;
  final EdgeInsetsGeometry padding;
  final Widget? secondary;
  final ListTileControlAffinity controlAffinity;
  final Widget? subtitle;

  FormeExpansionListTileItem._({
    required this.title,
    this.subtitle,
    this.secondary,
    ListTileControlAffinity? controlAffinity,
    this.readOnly = false,
    EdgeInsetsGeometry? padding,
  })  : controlAffinity = controlAffinity ?? ListTileControlAffinity.platform,
        padding = padding ?? EdgeInsets.zero;

  factory FormeExpansionListTileItem.expansion({
    required Widget title,
    Widget? subtitle,
    Widget? secondary,
    ListTileControlAffinity? controlAffinity,
    bool readOnly = false,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? childrenPadding,
    required List<FormeExpansionListTileItem<T>> children,
    FormeExpansionItemControl<T>? control,
    CrossAxisAlignment? expandedCrossAxisAlignment,
    Alignment? expandedAlignment,
    Color? backgroundColor,
    Color? collapsedBackgroundColor,
    Color? textColor,
    Color? collapsedTextColor,
    Color? iconColor,
    Color? collapsedIconColor,
  }) {
    return _ExpansionItem(
      children: children,
      title: title,
      secondary: secondary,
      subtitle: subtitle,
      childrenPadding: childrenPadding,
      controlAffinity: controlAffinity,
      readOnly: readOnly,
      padding: padding,
      control: control,
      expandedCrossAxisAlignment: expandedCrossAxisAlignment,
      expandedAlignment: expandedAlignment,
      backgroundColor: backgroundColor,
      collapsedBackgroundColor: collapsedBackgroundColor,
      textColor: textColor,
      collapsedTextColor: collapsedTextColor,
      iconColor: iconColor,
      collapsedIconColor: collapsedIconColor,
    );
  }

  factory FormeExpansionListTileItem.data({
    required Widget title,
    Widget? subtitle,
    Widget? secondary,
    ListTileControlAffinity? controlAffinity,
    bool readOnly = false,
    EdgeInsetsGeometry? padding,
    required FormeExpansionItemControl<T> control,
    ListTileStyle? style,
    Color? selectedColor,
    Color? iconColor,
    Color? textColor,
    Color? focusColor,
    Color? hoverColor,
    Color? tileColor,
    Color? selectedTileColor,
    bool? enableFeedback,
    double? horizontalTitleGap,
    double? minVerticalPadding,
    double? minLeadingWidth,
    bool dense = false,
  }) {
    return _DataItem<T>(
      title: title,
      secondary: secondary,
      subtitle: subtitle,
      controlAffinity: controlAffinity,
      readOnly: readOnly,
      padding: padding,
      control: control,
      style: style,
      selectedColor: selectedColor,
      selectedTileColor: selectedTileColor,
      iconColor: iconColor,
      textColor: textColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      tileColor: tileColor,
      enableFeedback: enableFeedback,
      horizontalTitleGap: horizontalTitleGap,
      minLeadingWidth: minLeadingWidth,
      minVerticalPadding: minVerticalPadding,
      dense: dense,
    );
  }
}

class FormeExpansionItemControl<T extends Object> {
  final T data;
  final FormeExpansionListTileControlBuilder<T> builder;

  FormeExpansionItemControl({
    required this.data,
    required this.builder,
  });

  factory FormeExpansionItemControl.checkbox({
    required T data,
  }) {
    return FormeExpansionItemControl<T>(
        data: data,
        builder: (context, data, isSelected, toggle) {
          return Checkbox(
            value: isSelected,
            onChanged: toggle == null
                ? null
                : (v) {
                    toggle();
                  },
          );
        });
  }
}

class _ExpansionItem<T extends Object> extends FormeExpansionListTileItem<T> {
  _ExpansionItem(
      {this.childrenPadding,
      required this.children,
      required Widget title,
      Widget? subtitle,
      Widget? secondary,
      ListTileControlAffinity? controlAffinity,
      bool readOnly = false,
      this.control,
      EdgeInsetsGeometry? padding,
      this.expandedAlignment,
      this.expandedCrossAxisAlignment,
      this.backgroundColor,
      this.collapsedBackgroundColor,
      this.textColor,
      this.collapsedIconColor,
      this.collapsedTextColor,
      this.iconColor})
      : super._(
          controlAffinity: controlAffinity,
          title: title,
          secondary: secondary,
          subtitle: subtitle,
          readOnly: readOnly,
          padding: padding,
        );

  final CrossAxisAlignment? expandedCrossAxisAlignment;
  final Alignment? expandedAlignment;
  final Color? backgroundColor;
  final Color? collapsedBackgroundColor;
  final Color? textColor;
  final Color? collapsedTextColor;
  final Color? iconColor;
  final Color? collapsedIconColor;
  final EdgeInsetsGeometry? childrenPadding;
  final List<FormeExpansionListTileItem<T>> children;
  final FormeExpansionItemControl<T>? control;
  bool get hasChildren => children.isNotEmpty;
}

class _DataItem<T extends Object> extends FormeExpansionListTileItem<T> {
  final FormeExpansionItemControl<T> control;
  final ListTileStyle? style;
  final Color? selectedColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? tileColor;
  final Color? selectedTileColor;
  final bool? enableFeedback;
  final double? horizontalTitleGap;
  final double? minVerticalPadding;
  final double? minLeadingWidth;
  final bool dense;
  _DataItem({
    required Widget title,
    Widget? subtitle,
    Widget? secondary,
    ListTileControlAffinity? controlAffinity,
    bool readOnly = false,
    EdgeInsetsGeometry? padding,
    this.dense = false,
    required this.control,
    this.style,
    this.selectedColor,
    this.iconColor,
    this.textColor,
    this.focusColor,
    this.hoverColor,
    this.tileColor,
    this.selectedTileColor,
    this.enableFeedback,
    this.horizontalTitleGap,
    this.minLeadingWidth,
    this.minVerticalPadding,
  }) : super._(
          controlAffinity: controlAffinity,
          title: title,
          secondary: secondary,
          subtitle: subtitle,
          readOnly: readOnly,
          padding: padding,
        );
}

class FormeExpansionListTile<T extends Object> extends FormeField<List<T>> {
  final List<FormeExpansionListTileItem<T>> items;

  FormeExpansionListTile({
    List<T>? initialValue,
    required String name,
    bool readOnly = false,
    required this.items,
    Key? key,
    int? order,
    bool quietlyValidate = false,
    bool dense = true,
    ShapeBorder? shape,
    ListTileStyle? style,
    Color? selectedColor,
    Color? iconColor,
    Color? textColor,
    EdgeInsetsGeometry? contentPadding,
    Color? tileColor,
    Color? selectedTileColor,
    bool? enableFeedback,
    double? horizontalTitleGap,
    double? minVerticalPadding,
    double? minLeadingWidth,
    InputDecoration? decoration,
    FormeFieldDecorator<List<T>>? decorator,
    bool requestFocusOnUserInteraction = true,
    bool registrable = true,
    bool enabled = true,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeFieldStatusChanged<List<T>>? onStatusChanged,
    FormeFieldInitialed<List<T>>? onInitialed,
    FormeFieldSetter<List<T>>? onSaved,
    FormeValidator<List<T>>? validator,
    FormeAsyncValidator<List<T>>? asyncValidator,
    FormeFieldValueUpdater<List<T>>? valueUpdater,
    FormeValueComparator<List<T>>? comparator,
    FormeFieldValidationFilter<List<T>>? validationFilter,
    FocusNode? focusNode,
    bool expanded = true,
    bool selectParentsWhenChildSelectedOnUserInteraction = true,
    bool selectAllChildrenWhenParentSelectedOnUserInteraction = true,
    bool expandAllChildrenWhenParentToggledOnUserInteraction = true,
  }) : super(
            focusNode: focusNode,
            validationFilter: validationFilter,
            comparator: comparator,
            valueUpdater: valueUpdater,
            asyncValidatorDebounce: asyncValidatorDebounce,
            autovalidateMode: autovalidateMode,
            onStatusChanged: onStatusChanged,
            onInitialed: onInitialed,
            onSaved: onSaved,
            validator: validator,
            asyncValidator: asyncValidator,
            enabled: enabled,
            registrable: registrable,
            requestFocusOnUserInteraction: requestFocusOnUserInteraction,
            quietlyValidate: quietlyValidate,
            order: order,
            key: key,
            readOnly: readOnly,
            name: name,
            initialValue: initialValue ?? [],
            decorator: decorator ??
                (decoration == null
                    ? null
                    : FormeInputDecoratorBuilder(decoration: decoration)),
            builder: (genericState) {
              final FormeExpansionListTileState<T> state =
                  genericState as FormeExpansionListTileState<T>;
              return Focus(
                focusNode: state.focusNode,
                child: ListTileTheme.merge(
                    dense: dense,
                    shape: shape,
                    style: style,
                    selectedColor: selectedColor,
                    selectedTileColor: selectedTileColor,
                    iconColor: iconColor,
                    textColor: textColor,
                    contentPadding: contentPadding,
                    tileColor: tileColor,
                    enableFeedback: enableFeedback,
                    horizontalTitleGap: horizontalTitleGap,
                    minVerticalPadding: minVerticalPadding,
                    minLeadingWidth: minLeadingWidth,
                    child: _SelectableTree<T>(
                      selectParentsWhenChildSelectedOnUserInteraction:
                          selectParentsWhenChildSelectedOnUserInteraction,
                      selectAllChildrenWhenParentSelectedOnUserInteraction:
                          selectAllChildrenWhenParentSelectedOnUserInteraction,
                      expandAllChildrenWhenParentToggledOnUserInteraction:
                          expandAllChildrenWhenParentToggledOnUserInteraction,
                      key: state._globalKey,
                      items: items,
                      readOnly: genericState.readOnly,
                      expanded: expanded,
                      onValueChanged: (values) {
                        final List<T> selected =
                            values.map((e) => e.selected).toList();
                        state._didChange(selected);
                      },
                    )),
              );
            });

  @override
  FormeFieldState<List<T>> createState() => FormeExpansionListTileState<T>();
}

class FormeExpansionListTileState<T extends Object>
    extends FormeFieldState<List<T>> {
  final GlobalKey<_SelectableTreeState<T>> _globalKey = GlobalKey();

  /// get node
  FormeExpansionNode<T>? getNode(T data) {
    final _Node<T>? node = _tree._tree.getNodeByData(data);
    if (node == null) {
      return null;
    }
    return FormeExpansionNode._(node, _globalKey);
  }

  void select(
    List<T> values, {
    bool selectAllChildren = false,
    bool selectParents = false,
  }) {
    final List<_Node<T>> nodes = _tree._tree.getNodesByDatas(values);
    _tree._setSelectNodes(nodes,
        selectAllChildren: selectAllChildren, selectParents: selectParents);
  }

  @override
  void didChange(List<T> newValue) {
    super.didChange(value);
    _tree._setSelectNodes(_tree._tree.getNodesByDatas(newValue));
  }

  @override
  void reset() {
    super.reset();
    _tree._reset();
  }

  void _didChange(List<T> newValue) {
    super.didChange(newValue);
  }

  _SelectableTreeState<T> get _tree => _globalKey.currentState!;
}

class FormeExpansionNode<T extends Object> {
  final _Node<T> _node;
  final GlobalKey<_SelectableTreeState<T>> _key;

  FormeExpansionNode._(this._node, this._key);

  FormeExpansionNode<T>? get parent =>
      _node.parent == null ? null : FormeExpansionNode._(_node.parent!, _key);

  List<FormeExpansionNode<T>> get children =>
      _node.children.map((e) => FormeExpansionNode._(e, _key)).toList();

  bool get isExpanded => _tree._isExpanded(_node);

  bool get isSelected => _tree._isSelected(_node);

  void expand({
    bool expandAllChildren = false,
  }) {
    _tree._expand(_node, expandAllChildren: expandAllChildren);
  }

  void collapse() {
    _tree._collapse(_node);
  }

  void select({
    bool selectParents = false,
    bool selectAllChildren = false,
  }) {
    _tree._select(
      _node,
      selectAllChildren: selectAllChildren,
      selectParents: selectParents,
    );
  }

  void unselect({
    bool unselectAllChildren = false,
  }) {
    _tree._unselect(_node, unselectAllChildren: unselectAllChildren);
  }

  _SelectableTreeState<T> get _tree => _key.currentState!;
}

class _SelectableTree<T extends Object> extends StatefulWidget {
  final List<FormeExpansionListTileItem<T>> items;
  final bool readOnly;
  final bool expanded;
  final bool selectParentsWhenChildSelectedOnUserInteraction;
  final bool selectAllChildrenWhenParentSelectedOnUserInteraction;
  final bool expandAllChildrenWhenParentToggledOnUserInteraction;
  final ValueChanged<List<_SelectedValue<T>>> onValueChanged;

  const _SelectableTree({
    Key? key,
    required this.items,
    this.readOnly = false,
    this.expanded = true,
    this.selectParentsWhenChildSelectedOnUserInteraction = true,
    this.selectAllChildrenWhenParentSelectedOnUserInteraction = true,
    this.expandAllChildrenWhenParentToggledOnUserInteraction = true,
    required this.onValueChanged,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SelectableTreeState<T>();
}

class _SelectableTreeState<T extends Object> extends State<_SelectableTree<T>> {
  late _Tree<T> _tree;
  int nodeId = 0;

  List<_SelectedValue<T>> _values = [];

  bool get readOnly => widget.readOnly;

  final Map<int, bool> _expandedState = {};

  @override
  void initState() {
    super.initState();
    _buildTree();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];

    for (final _Node<T> node in _tree.children) {
      widgets.add(_createExpansionListTile(node));
    }

    return Column(
      children: widgets,
    );
  }

  bool _isExpanded(_Node<T> node) => _expandedState[node.id] ?? widget.expanded;

  void _expand(
    _Node<T> node, {
    bool expandAllChildren = false,
  }) {
    _expandedState[node.id] = true;
    final List<_Node<T>> parents = _tree.getParents(node);
    for (final _Node<T> parent in parents) {
      _expandedState[parent.id] = true;
    }
    if (expandAllChildren) {
      for (final _Node<T> element in node.allChildren) {
        _expandedState[element.id] = true;
      }
    }
    setState(() {});
  }

  void _collapse(_Node<T> node) {
    setState(() {
      _expandedState[node.id] = false;
    });
  }

  void _reset() {
    setState(() {
      _expandedState.clear();
      _values = [];
    });
  }

  void _select(
    _Node<T> node, {
    bool selectParents = false,
    bool selectAllChildren = false,
  }) {
    final List<_SelectedValue<T>> values = List.of(_values);
    final List<_Node<T>> needSelectNodes = [];
    if (selectParents) {
      needSelectNodes.addAll(_tree.getParents(node).toList());
    }
    needSelectNodes.add(node);
    if (selectAllChildren) {
      needSelectNodes.addAll(node.allChildren.toList());
    }
    for (final _Node<T> needSelectNode in needSelectNodes) {
      if (!needSelectNode.hasData ||
          values.any((element) => element.id == needSelectNode.id)) {
        continue;
      }
      values.add(_SelectedValue<T>(needSelectNode.data!, needSelectNode.id));
    }
    setState(() {
      _values = values;
    });
    widget.onValueChanged(_values);
  }

  void _unselect(
    _Node<T> node, {
    bool unselectAllChildren = false,
  }) {
    final List<_SelectedValue<T>> values = List.of(_values);
    final List<int> nodeIds = List.of([node.id]);
    if (unselectAllChildren) {
      nodeIds.addAll(node.allChildren.map((e) => e.id));
    }
    values.removeWhere((element) => nodeIds.contains(element.id));
    setState(() {
      _values = values;
    });
    widget.onValueChanged(_values);
  }

  void _setSelectNodes(
    List<_Node<T>> nodes, {
    bool selectParents = false,
    bool selectAllChildren = false,
  }) {
    final List<_Node<T>> collector = [];
    for (final _Node<T> node in nodes) {
      collector.add(node);

      if (selectParents) {
        collector.addAll(_tree.getParents(node));
      }
      if (selectAllChildren) {
        collector.addAll(node.allChildren);
      }
    }
    final List<_SelectedValue<T>> newValues = [];
    for (final _Node<T> node in collector) {
      if (!node.hasData || newValues.any((element) => element.id == node.id)) {
        continue;
      }
      newValues.add(_SelectedValue<T>(node.data!, node.id));
    }
    setState(() {
      _values = newValues;
    });
    widget.onValueChanged(_values);
  }

  void _didChangeOnUserInteraction(_Node<T> node) {
    if (!node.hasData) {
      return;
    }
    if (_isSelected(node)) {
      _unselect(node, unselectAllChildren: true);
    } else {
      _select(
        node,
        selectAllChildren:
            widget.selectAllChildrenWhenParentSelectedOnUserInteraction,
        selectParents: widget.selectParentsWhenChildSelectedOnUserInteraction,
      );
    }
    if (widget.expandAllChildrenWhenParentToggledOnUserInteraction) {
      _expandedState[node.id] = true;
      for (final _Node<T> node in node.allChildren) {
        _expandedState[node.id] = true;
      }
    }
  }

  bool _isControlLeading(_Node<T> node) {
    switch (node.item.controlAffinity) {
      case ListTileControlAffinity.leading:
        return true;
      case ListTileControlAffinity.trailing:
      case ListTileControlAffinity.platform:
        return false;
    }
  }

  Widget _getControl(_Node<T> node) {
    FormeExpansionItemControl<T>? control;

    if (node.isExpansionNode) {
      control = (node.item as _ExpansionItem<T>).control;
    } else if (node.isDataNode) {
      control = (node.item as _DataItem<T>).control;
    }
    if (control == null) {
      return const SizedBox.shrink();
    }

    return control.builder(
      context,
      node.data!,
      _isSelected(node),
      readOnly || node.item.readOnly
          ? null
          : () {
              _didChangeOnUserInteraction(node);
            },
    );
  }

  Widget _createListTile(_Node<T> node) {
    final Widget control = _getControl(node);
    final bool controlLeading = _isControlLeading(node);
    final _DataItem<T> item = node.item as _DataItem<T>;
    return ListTile(
      selected: _isSelected(node),
      leading: controlLeading ? control : node.item.secondary,
      trailing: controlLeading ? node.item.secondary : control,
      subtitle: node.item.subtitle,
      title: item.title,
      dense: item.dense,
      contentPadding: node.item.padding,
      style: item.style,
      selectedColor: item.selectedColor,
      iconColor: item.iconColor,
      textColor: item.textColor,
      tileColor: item.tileColor,
      focusColor: item.focusColor,
      hoverColor: item.hoverColor,
      selectedTileColor: item.selectedTileColor,
      enableFeedback: item.enableFeedback,
      horizontalTitleGap: item.horizontalTitleGap,
      minLeadingWidth: item.minLeadingWidth,
      minVerticalPadding: item.minVerticalPadding,
      onTap: readOnly || item.readOnly
          ? null
          : () {
              _didChangeOnUserInteraction(node);
            },
    );
  }

  void _buildTree() {
    nodeId = 0;
    _tree = _Tree<T>(widget.items.map((e) => _buildNode(e, null)).toList());
  }

  _Node<T> _buildNode(FormeExpansionListTileItem<T> item, _Node<T>? parent) {
    final _Node<T> node = _Node<T>(
        id: nodeId++,
        parent: parent,
        item: item,
        children: [],
        level: parent == null ? 0 : parent.level + 1);
    if (node.isExpansionNode) {
      final _ExpansionItem<T> _expansionItem = item as _ExpansionItem<T>;
      for (final FormeExpansionListTileItem<T> child
          in _expansionItem.children) {
        node.children.add(_buildNode(child, node));
      }
    }
    return node;
  }

  bool _isSelected(_Node<T> node) {
    return _values.any((element) => element.id == node.id);
  }

  Widget _createExpansionListTile(_Node<T> node) {
    if (node.item is! _ExpansionItem) {
      return _createListTile(node);
    }
    final _ExpansionItem<T> _expansionItem = node.item as _ExpansionItem<T>;
    final Widget control = _getControl(node);
    final bool controlLeading = _isControlLeading(node);
    final bool isExpanded = _expandedState[node.id] ?? widget.expanded;
    return e.ExpansionTile(
      onExpansionChanged: (value) {
        setState(() {
          _expandedState[node.id] = value;
        });
      },
      initiallyExpanded: isExpanded,
      leading: controlLeading ? control : _expansionItem.secondary,
      trailing: controlLeading ? _expansionItem.secondary : control,
      subtitle: _expansionItem.subtitle,
      title: _expansionItem.title,
      tilePadding: _expansionItem.padding,
      childrenPadding: _expansionItem.childrenPadding,
      expandedCrossAxisAlignment: _expansionItem.expandedCrossAxisAlignment,
      expandedAlignment: _expansionItem.expandedAlignment,
      backgroundColor: _expansionItem.backgroundColor,
      collapsedBackgroundColor: _expansionItem.collapsedBackgroundColor,
      textColor: _expansionItem.textColor,
      collapsedTextColor: _expansionItem.collapsedTextColor,
      iconColor: _expansionItem.iconColor,
      collapsedIconColor: _expansionItem.collapsedIconColor,
      children: node.children.map(_createExpansionListTile).toList(),
    );
  }
}

class _Tree<T extends Object> {
  final List<_Node<T>> children;

  _Tree(this.children);

  _Node<T>? getNodeByData(T data) => _findNodeByData(data, children);

  _Node<T>? getNode(int id) => _findNode(id, children);

  List<_Node<T>> getNodesByDatas(List<T> datas) {
    final List<_Node<T>> collector = [];
    _findNodesByDatas(datas, children, collector);
    return collector;
  }

  void _findNodesByDatas(
      List<T> datas, List<_Node<T>> nodes, List<_Node<T>> collector) {
    for (final _Node<T> node in nodes) {
      if (datas.contains(node.data)) {
        collector.add(node);
      }
      _findNodesByDatas(datas, node.children, collector);
    }
  }

  _Node<T>? _findNode(int id, List<_Node<T>> nodes) {
    for (final _Node<T> node in nodes) {
      if (node.id == id) {
        return node;
      }
      final _Node<T>? nestedNode = _findNode(id, node.children);
      if (nestedNode != null) {
        return nestedNode;
      }
    }
    return null;
  }

  _Node<T>? _findNodeByData(T data, List<_Node<T>> nodes) {
    for (final _Node<T> node in nodes) {
      if (node.data == data) {
        return node;
      }
      final _Node<T>? nestedNode = _findNodeByData(data, node.children);
      if (nestedNode != null) {
        return nestedNode;
      }
    }
    return null;
  }

  List<_Node<T>> getParents(_Node<T> node) {
    final List<_Node<T>> parents = [];
    _Node<T>? parent = node.parent;
    while (parent != null) {
      parents.add(parent);
      parent = parent.parent;
    }
    return parents;
  }
}

class _SelectedValue<T extends Object> {
  final T selected;
  final int id;

  _SelectedValue(this.selected, this.id);
}

class _Node<T extends Object> {
  final int id;
  final _Node<T>? parent;
  final FormeExpansionListTileItem<T> item;
  final List<_Node<T>> children;
  final int level;

  bool get hasData => data != null;

  T? get data => isDataNode
      ? (item as _DataItem<T>).control.data
      : isExpansionNode
          ? (item as _ExpansionItem<T>).control?.data
          : null;

  bool get isDataNode => item is _DataItem<T>;
  bool get isExpansionNode => item is _ExpansionItem<T>;

  _Node({
    required this.id,
    required this.parent,
    required this.item,
    required this.children,
    required this.level,
  });

  List<_Node<T>> get allChildren {
    if (this.children.isEmpty) {
      return List.empty();
    }
    final List<_Node<T>> children = [];

    for (final _Node<T> child in this.children) {
      children.add(child);
      children.addAll(child.allChildren);
    }

    return children;
  }
}
