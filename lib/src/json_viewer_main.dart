// Copyright (c) 2022, the json_tree_viewer project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';

class JsonTreeViewer extends StatefulWidget {
  const JsonTreeViewer(
      {Key? key,
      required this.data,
      this.expandedAll = false,
      this.expandableIcon,
      this.keyStyle,
      this.defaultValueStyle,
      this.stringValueStyle,
      this.numberValueStyle,
      this.trueValueStyle,
      this.falseValueStyle})
      : assert(data is Map || data is Iterable),
        super(key: key);

  final dynamic data;
  final bool expandedAll;
  final Widget? expandableIcon;
  final TextStyle? keyStyle;
  final TextStyle? defaultValueStyle;
  final TextStyle? stringValueStyle;
  final TextStyle? trueValueStyle;
  final TextStyle? falseValueStyle;
  final TextStyle? numberValueStyle;

  @override
  _JsonTreeViewerState createState() => _JsonTreeViewerState();
}

class _JsonTreeViewerState extends State<JsonTreeViewer> {
  final _jsonNodes = <TreeNode<JsonElement>>[];

  @override
  void initState() {
    _initNodes();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant JsonTreeViewer oldWidget) {
    _initNodes();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FlexibleTreeView<JsonElement>(
          nodes: _jsonNodes,
          nodeWidth: constraints.constrainWidth(),
          nodeItemBuilder: (context, node) {
            return _nodeWidget(context, node);
          },
        );
      },
    );
  }

  Widget _nodeWidget(BuildContext context, TreeNode<JsonElement> jsonNode) {
    var jsonElement = jsonNode.data;
    return Ink(
      child: Row(
        children: [
          Visibility(
            visible: jsonNode.hasNodes,
            child: ExpandableIcon(
              child: widget.expandableIcon ?? const Icon(Icons.arrow_right),
              expanded: jsonNode.expanded,
              onExpandChanged: (b) {
                jsonNode.expanded = b;
              },
            ),
            maintainAnimation: true,
            maintainState: true,
            maintainSize: true,
          ),
          if (jsonNode.parent?.data.type == JsonType.array)
            Text(
              '${jsonNode.parent!.children.indexOf(jsonNode)}: ',
              style: TextStyle(
                  fontSize: 12,
                  color: jsonElement.selected
                      ? Theme.of(context).colorScheme.secondary
                      : null),
            ),
          if (jsonElement.key != null)
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 30,
              ),
              child: Tooltip(
                message: jsonElement.key!.length > 12 ? jsonElement.key! : '',
                child: SelectableText(
                  jsonElement.key!,
                  maxLines: 1,
                  style: widget.keyStyle ??
                      const TextStyle(
                        fontSize: 12,
                      ),
                ),
              ),
            ),
          if (jsonElement.key != null)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_forward,
                size: 14,
                color: Colors.grey,
              ),
            ),
          if (jsonElement.type == JsonType.array ||
              jsonElement.type == JsonType.object)
            Text(
              '${jsonElement.type == JsonType.array ? 'Array' : jsonElement.type == JsonType.object ? 'Object' : ''} [${jsonElement.value.length}]',
              style: widget.defaultValueStyle ??
                  const TextStyle(
                    fontSize: 12,
                  ),
            ),
          if (!jsonNode.expanded)
            Expanded(
              child: Tooltip(
                message: jsonElement.type == JsonType.string &&
                        jsonElement.toString().length > 16
                    ? jsonElement.toString()
                    : '',
                child: SelectableText(
                  ' ${jsonElement.toString()}',
                  maxLines: 1,
                  style: jsonElement.type == JsonType.string
                      ? (widget.stringValueStyle ??
                          TextStyle(fontSize: 12, color: Colors.brown.shade200))
                      : (jsonElement.type == JsonType.double ||
                              jsonElement.type == JsonType.int)
                          ? (widget.numberValueStyle ??
                              TextStyle(
                                  fontSize: 12, color: Colors.green.shade600))
                          : jsonElement.type == JsonType.boolean
                              ? (jsonElement.value == true
                                  ? (widget.trueValueStyle ??
                                      TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade600))
                                  : (widget.falseValueStyle ??
                                      const TextStyle(
                                          fontSize: 12, color: Colors.red)))
                              : (jsonElement.type == JsonType.array ||
                                      jsonElement.type == JsonType.object)
                                  ? const TextStyle(
                                      fontSize: 12, color: Colors.grey)
                                  : (widget.defaultValueStyle ??
                                      const TextStyle(
                                        fontSize: 12,
                                      )),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _initNodes() {
    _jsonNodes.clear();
    if (widget.data is Map) {
      var mapData = widget.data as Map;
      var json = JsonElement(value: mapData, type: JsonType.object);
      var rootNode = TreeNode<JsonElement>(
          data: json,
          expanded: widget.expandedAll,
          children: _buildChildrenNodes(mapData.entries.toList()));
      _jsonNodes.add(rootNode);
    } else if (widget.data is Iterable) {
      var listData = widget.data as Iterable;

      for (var ele in listData) {
        _jsonNodes.add(_buildNode(ele));
      }
    }
  }

  List<TreeNode<JsonElement>> _buildChildrenNodes(List elements) {
    var nodes = <TreeNode<JsonElement>>[];
    for (var ele in elements) {
      TreeNode<JsonElement> node = _buildNode(ele);
      nodes.add(node);
    }
    return nodes;
  }

  TreeNode<JsonElement> _buildNode(dynamic ele) {
    if (ele is MapEntry) {
      var json = JsonElement(
          key: ele.key, value: ele.value, type: _valueType(ele.value));
      if (ele.value is List) {
        return TreeNode<JsonElement>(
            data: json,
            expanded: (ele.value as List).isNotEmpty && widget.expandedAll,
            children: _buildChildrenNodes(ele.value));
      } else if (ele.value is Map) {
        return TreeNode<JsonElement>(
            data: json,
            expanded: (ele.value as Map).isNotEmpty && widget.expandedAll,
            children: _buildChildrenNodes((ele.value as Map).entries.toList()));
      } else {
        return TreeNode<JsonElement>(data: json);
      }
    } else {
      var json = JsonElement(value: ele, type: _valueType(ele));

      if (ele is List) {
        return TreeNode<JsonElement>(
            data: json,
            expanded: ele.isNotEmpty && widget.expandedAll,
            children: _buildChildrenNodes(ele));
      } else if (ele is Map) {
        return TreeNode<JsonElement>(
            data: json,
            expanded: ele.isNotEmpty && widget.expandedAll,
            children: _buildChildrenNodes(ele.entries.toList()));
      } else {
        return TreeNode<JsonElement>(data: json);
      }
    }
  }

  JsonType _valueType(dynamic value) {
    if (value is String) {
      return JsonType.string;
    } else if (value is int) {
      return JsonType.int;
    } else if (value is double) {
      return JsonType.double;
    } else if (value is bool) {
      return JsonType.boolean;
    } else if (value is List) {
      return JsonType.array;
    } else if (value is Map) {
      return JsonType.object;
    }
    return JsonType.string;
  }
}

class ExpandableIcon extends StatefulWidget {
  const ExpandableIcon(
      {Key? key, required this.child, this.expanded, this.onExpandChanged})
      : super(key: key);
  final Widget child;
  final bool? expanded;
  final ValueChanged<bool>? onExpandChanged;

  @override
  _ExpandableIconState createState() => _ExpandableIconState();
}

class _ExpandableIconState extends State<ExpandableIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotate;
  late Animation<double> _turnAnim;

  bool _currentExpand = false;

  @override
  void initState() {
    if (widget.expanded != null) {
      _currentExpand = widget.expanded!;
    }
    _rotate = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _turnAnim = Tween<double>(begin: 0, end: 0.25)
        .animate(CurvedAnimation(parent: _rotate, curve: Curves.easeInOut));
    if (_currentExpand) {
      _rotate.forward(from: 0.5);
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ExpandableIcon oldWidget) {
    if (widget.expanded != null && widget.expanded != _currentExpand) {
      if (widget.expanded!) {
        _rotate.forward();
      } else {
        _rotate.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _rotate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _turnAnim,
      child: IconButton(
        iconSize: 18,
        icon: widget.child,
        color: Colors.grey.shade700,
        constraints: BoxConstraints.tight(Size(30, 30)),
        padding: EdgeInsets.zero,
        splashRadius: 18,
        onPressed: () {
          _currentExpand = !_currentExpand;
          if (_currentExpand) {
            _rotate.forward();
          } else {
            _rotate.reverse();
          }
          widget.onExpandChanged?.call(_currentExpand);
        },
      ),
    );
  }
}

class JsonElement {
  JsonElement({
    this.key,
    this.value,
    required this.type,
    this.selected = false,
  });

  final String? key;
  final dynamic value;
  final JsonType type;
  bool selected;

  @override
  String toString() {
    if (type == JsonType.object) {
      return '{...}';
    } else if (type == JsonType.array) {
      return '[...]';
    } else if (type == JsonType.string) {
      return '"${value.toString()}"';
    } else {
      return value.toString();
    }
  }
}

enum JsonType {
  string,
  int,
  double,
  boolean,
  array,
  object,
}
