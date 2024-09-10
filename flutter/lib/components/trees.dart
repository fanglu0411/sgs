import 'dart:collection';
import 'dart:math';

class TreeNode<T extends TreeNode<T>> {
  TreeNode<T>? parent;

  final List<T> children = [];

  /// Index in [parent.children].
  int index = -1;

  /// Depth of this tree, including [this].
  ///
  /// We assume that TreeNodes are not modified after the first time [depth] is
  /// accessed. We would need to clear the cache before accessing, otherwise.
  int get depth {
    if (_depth != 0) {
      return _depth;
    }
    for (T child in children) {
      _depth = max(_depth, child.depth);
    }
    return _depth = _depth + 1;
  }

  int _depth = 0;

  bool get isRoot => parent == null;

  TreeNode<T> get root {
    if (_root != null) {
      return _root!;
    }

    // Store nodes we have visited so we can cache the root value for each one
    // once we find the root.
    final visited = <TreeNode<T>>{this};

    TreeNode<T> root = this ;
    while (root.parent != null) {
      visited.add(root);
      root = root.parent!;
    }

    // Set [_root] for all nodes we visited.
    for (TreeNode<T> node in visited) {
      node._root = root;
    }

    return root;
  }

  TreeNode<T>? _root;

  /// The level (0-based) of this tree node in the tree.
  int get level {
    if (_level != null) {
      return _level!;
    }
    int level = 0;
    TreeNode<T> current = this;
    while (current.parent != null) {
      current = current.parent!;
      level++;
    }
    return _level = level;
  }

  int? _level;

  /// Whether the tree table node is expandable.
  bool get isExpandable => children.isNotEmpty;

  /// Whether the node is currently expanded in the tree table.
  bool get isExpanded => _isExpanded;
  bool _isExpanded = false;

  // TODO(gmoothart): expand does not check isExpandable, which can lead to
  // inconsistent state, particular in combination with expandCascading. We
  // should clean this up.
  void expand() {
    _isExpanded = true;
  }

  // TODO(jacobr): cache the value of whether the node should be shown
  // so that lookups on this class are O(1) invalidating the cache when nodes
  // up the tree are expanded and collapsed.
  /// Whether this node should be shown in the tree.
  ///
  /// When using this, consider caching the value. It is O([level]) to compute.
  bool shouldShow() {
    return parent == null || (parent!.isExpanded && parent!.shouldShow());
  }

  void collapse() {
    _isExpanded = false;
  }

  void toggleExpansion() {
    _isExpanded = !_isExpanded;
  }

  /// Override to handle pressing on a Leaf node.
  void leaf() {}

  void addChild(T child) {
    children.add(child);
    child.parent = this;
    child.index = children.length - 1;
  }

  void clearChildren() {
    children.forEach((c) {
      c.parent = null;
    });
    children.clear();
  }

  void addAllChildren(List<T> children) {
    children.forEach(addChild);
  }

  /// Expands this node and all of its children (cascading).
  void expandCascading() {
    breadthFirstTraversal<T>(this, action: (TreeNode<T> node) {
      node.expand();
    });
  }

  /// Collapses this node and all of its children (cascading).
  void collapseCascading() {
    breadthFirstTraversal<T>(this, action: (TreeNode<T> node) {
      node.collapse();
    });
  }

  void removeLastChild() {
    children.removeLast();
  }

  bool subtreeHasNodeWithCondition(bool condition(TreeNode<T> node)) {
    final TreeNode<T>? childWithCondition = firstChildWithCondition(condition);
    return childWithCondition != null;
  }

  TreeNode<T>? firstChildWithCondition(bool condition(TreeNode<T> node)) {
    return breadthFirstTraversal<T>(
      this,
      returnCondition: condition,
    );
  }

  /// Locates the first sub-node in the tree at level [level].
  ///
  /// [level] is relative to the subtree root [this].
  ///
  /// For example:
  ///
  /// [level 0]                A
  ///                        /   \
  /// [level 1]             B     E
  ///                      /    /  \
  /// [level 2]           C    F    G
  ///                    /
  /// [level 3]         D
  ///
  /// E.firstSubNodeAtLevel(1) => F
  TreeNode<T>? firstChildNodeAtLevel(int level) {
    return _childNodeAtLevelWithCondition(
      level,
      // When this condition is called, we have already ensured that
      // [level] < [depth], so at least one child is guaranteed to meet the
      // firstWhere condition.
      (currentNode, levelWithOffset) => currentNode.children.firstWhere((n) => n.depth + n.level > levelWithOffset),
    );
  }

  /// Locates the last sub-node in the tree at level [level].
  ///
  /// [level] is relative to the subtree root [this].
  ///
  /// For example:
  ///
  /// [level 0]                A
  ///                        /   \
  /// [level 1]             B     E
  ///                      /    /  \
  /// [level 2]           C    F    G
  ///                    /
  /// [level 3]         D
  ///
  /// E.lastSubNodeAtLevel(1) => G
  TreeNode<T>? lastChildNodeAtLevel(int level) {
    return _childNodeAtLevelWithCondition(
        level,
        // When this condition is called, we have already ensured that
        // [level] < [depth], so at least one child is guaranteed to meet the
        // lastWhere condition.
        (currentNode, levelWithOffset) => currentNode.children.lastWhere((n) => n.depth + n.level > levelWithOffset));
  }

  // TODO(kenz): We should audit this method with a very large tree:
  // https://github.com/flutter/devtools/issues/1480.
  /// Finds a child node at [level] where traversal order is determined by
  /// [traversalCondition].
  ///
  /// The runtime of this method is O(level * tree width). The worst case
  /// scenario is searching for a very deep level in a very wide tree.
  TreeNode<T>? _childNodeAtLevelWithCondition(
    int level,
      TreeNode<T> traversalCondition(TreeNode<T> currentNode, int levelWithOffset),
  ) {
    if (level >= depth) return null;
    // The current node [this] is not guaranteed to be at level 0, so we need
    // to account for the level offset of [this].
    final levelWithOffset = level + this.level;
    var currentNode = this;
    while (currentNode.level < levelWithOffset) {
      // Walk down the tree until we find the node at [level].
      if (currentNode.children.isNotEmpty) {
        currentNode = traversalCondition(currentNode, levelWithOffset);
      }
    }
    return currentNode;
  }
}

/// Traverses a tree in breadth-first order.
///
/// [returnCondition] specifies the condition for which we should stop
/// traversing the tree. For example, if we are calling this method to perform
/// BFS, [returnCondition] would specify when we have found the node we are
/// searching for. [action] specifies an action that we will execute on each
/// node. For example, if we need to traverse a tree and change a property on
/// every single node, we would do this through the [action] param.
TreeNode<T>? breadthFirstTraversal<T extends TreeNode<T>>(TreeNode<T> root, {
  bool returnCondition(TreeNode<T> node)?,
  void action(TreeNode<T> node)?,
}) {
  final queue = Queue.of([root]);
  while (queue.isNotEmpty) {
    final TreeNode<T> node = queue.removeFirst();
    if (returnCondition != null && returnCondition(node)) {
      return node;
    }
    if (action != null) {
      action(node);
    }
    node.children.forEach(queue.add);
  }
  return null;
}