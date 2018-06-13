require 'observable'

# Represents the "model" part of a model-view-control tree GUI. All operations
# on the nodes of the tree, such as inserting and deleting roots or children, or
# changing the node's displayed text, must go through the
# Treelike object, so that changes can be propagated to observers.
#
# Note that the "tree" may actually be a directed acyclic graph (which is
# kind of "tree-like" ;). It cannot be cyclic.
#
# This module provides methods that make simplistic assumptions about the nodes.
# The resulting methods may not be the most efficient possible.
# More specific node classes can be accomodated by overriding these methods,
# possibly more efficiently.
#
# The default methods assume that the node_children method returns the actual
# array that hold the children, and so operating destructively on it will
# change the structure of the tree.
# 
# The children of a node can be sparse. A child which is nil is ignored.
# This allows "sparse" arrays to be displayed compactly. It also allows
# add_node to be called in random order, if you provide the indices. See
# examples/tree.rb for an example of sparse indices.
#
# Also, the index values of a nodes children can be floats,
# so you can always insert between two children without even
# changing their indices.
#
# See ArrayTree in array-tree.rb for an example of mixing this class in.
#
# The methods that a class should at least consider overriding are all
# the methods in Treelike of the form "node_*". Also, it may be efficient to
# provide a custom #each.
#
module Treelike
  include Enumerable
  extend Observable
  
  # These signals are meant for FTTreeList to observe and to use
  # to manipulate its tree list items. They do not have to be used directly
  # by applications.
  
  # Argument is +node+, as in <tt>tree.node_changes = node</tt>.
  # The signal means that the text of the node has changed or the item needs
  # to be redisplayed for some other reason (such as changed icon set).
  #
  signal :node_changes
  
  # Argument is <tt>[child, parent, index]</tt>, where +index+ specifies the
  # item before which +child+ is to be inserted.
  signal :child_joins_parent
  
  # Argument is <tt>[child, parent]</tt>
  signal :child_leaves_parent
  
  # Argument is <tt>[root, index]</tt>
  signal :tree_adds_root
  
  # Argument is <tt>root</tt>.
  signal :tree_deletes_root
  
  def initialize
    @roots = []
  end
  
  #== Tree methods
  
  # Accesses the root objects that have been added with +add_root+.
  attr_reader :roots
  
  # Add a root object to the tree.
  def add_root(root, index = nil)
    unless roots.include?(root)
      index ||= roots.size
      roots[index, 0] = root
      self.tree_adds_root = [root, index]
    end
    root
  end
  
  # Delete a root object from the tree, if it is one. Otherwise do nothing.
  def delete_root(root)
    if roots.include?(root)
      roots.delete(root)
      self.tree_deletes_root = root
    end
    root
  end
  
  # The tree module brings with it all the Enumerable functionality,
  # as an added bonus. The #each method visits nodes in the order they are
  # displayed in a tree browser when fully expanded.
  #
  # A node that has more than one parents is visited under the first parent.
  #
  # Naturally, a class which includes this module may provide its
  # own, more efficient, implementation of #each.
  def each
    visited = {}
    
    iterate = proc do |node|
      next if not node or visited[node]
      visited[node] = true
      
      yield node
      
      nodes = node_children(node)
      if nodes
        nodes.each do |child|
          iterate[child]
        end
      end
    end
    
    roots.each do |root|
      iterate[root]
    end
  end

  # Broadcast all signals needed to rebuild the entire tree in the client
  # widgets. This is more complicated than just iterating over all (parent,
  # child) pairs and sending #child_joins_parent, because of multiple
  # parentage. We need to force all of the items representing a parent to
  # be constructed before we can construct any items for the child.
  # 
  # This is not usually called directly, but only in observers like FTTreeList
  # to rebuild the visual tree when the tree model is replaced with a different
  # one.
  #
  def resignal_all
    roots.each_with_index do |root, index|
      self.tree_adds_root = [root, index]
    end
    
    item_map_completed_for = {}
    
    iterate = proc do |node|
      parents = node_parents(node)  ## might be inefficient. cache?
      
      parents.each do |parent|
        iterate[parent] unless item_map_completed_for[parent]
        index = node_child_index(parent, node)
        self.child_joins_parent = [node, parent, index]
      end
      
      item_map_completed_for[node] = true
    end
    
    each do |node|
      next if node_children(node)   # start with leaves
      iterate[node]
    end
  end
  
  #== Node methods: queries
  
  # The default implementation is <tt>node.to_s</tt>
  def node_text(node); node.to_s; end

  # Can return +nil+ or <tt>[]</tt> when there are no children: +nil+
  # signifies a leaf whereas <tt>[]</tt> signifies a non-leaf that happens to
  # have no children.
  # 
  # The default implementation is <tt>node.to_a</tt>
  def node_children(node); node.to_a; end
  
  # The default implementation is <tt>node_children(parent).index(node)</tt>.
  # It should be overridden if specialized indices are used (e.g., sparse
  # indices, or some other set of comparables than integers).
  def node_child_index(parent, child); node_children(parent).index(child); end
  
  # The default implementation is to select all nodes that are parents
  # of +node+. Very inefficient... If destructive operations seem slow,
  # be sure to define a more specific version of this method for your class.
  def node_parents(node)
    select { |par| ch = node_children(par); ch && ch.include?(node) }
  end
  
  # Override this to change the open icon from the defaults.
  def node_open_icon(node)
    node_children(node) ? FOLDER_OPEN_ICON : DOC_ICON
  rescue NameError
    retry unless FoxTails.get_standard_icons
  end
  
  # Override this to change the closed icon from the defaults.
  def node_closed_icon(node)
    node_children(node) ? FOLDER_CLOSED_ICON : DOC_ICON
  rescue NameError
    retry unless FoxTails.get_standard_icons
  end
  
  #== Node methods: destructive operators
  
  # Descendant classes should super this method.
  def node_set_text(node, text)
    unless node_text(node) == text
      raise Uminplemented,
        "Need to define #node_set_text in #{self.class} " +
        "and call super at the end of the definition."
    end
    self.node_changes = node
  end
  
  # Default implementation assumes parent array is not stored, and does nothing.
  def node_join_parent(node, parent); end

  # Default implementation assumes parent array is not stored, and does nothing.
  def node_leave_parent(node, parent); end
  
  # Default implementation assumes children array is mutable. If the array is
  # sparse and there is room for the child at the index, just put it there,
  # otherwise, insert before the node at +index+.
  def node_join_child(node, child, index)
    node_can_have_children!(node)
    children = node_children(node)
    if children[index] == nil # sparse?
      children[index] = child
    else
      children[index, 0] = child
    end
  end

  # Default implementation assumes children array is mutable.
  def node_leave_child(node, child)
    node_children(node).delete(child)
  end
  
  # Raised when a node is added as a child of a parent, but it was already one.
  class DuplicateChildError < StandardError; end
  
  # Default implementation assumes that #node_children returns a mutable array.
  # Safe to call if +node+ already has +parent+.
  # Default index is at end of existing list of children (default is allowed
  # only if using numerical indices).
  # Returns +node+.
  def add_node(node, parent, index = nil)
    ## default for index?
    ## what if parent isn't in tree?
    siblings = node_children(parent)
    if siblings and siblings.include? node
      raise DuplicateChildError,
        "Node #{node.text} already occurs under #{parent.text}"
    else
      index ||= siblings ? siblings.size : 0

      node_join_child(parent, node, index)
      node_join_parent(node, parent)

      self.child_joins_parent = [node, parent, index]
    end
    node
  end
  
  # Default implementation assumes that #node_children returns a mutable array.
  # Safe to call if +node+ doesn't have some of the +parents+.
  def delete_node(node, parents = node_parents(node))
    parents.each do |parent|
      if node_children(parent) and node_children(parent).include?(node)
        node_leave_child(parent, node)
        node_leave_parent(node, parent)

        self.child_leaves_parent = [node, parent]
      end
    end
  end
  
  ## Need: node_sort_children.
  
  ## improve API (arg ordering)
  
end
