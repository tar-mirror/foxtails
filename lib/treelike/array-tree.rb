# Treelike class which simply uses an array to hold the children and another
# array to hold the parent(s) of each node.
class ArrayTree
  include Treelike

  # In this example, children is a mutable array, so we have to define
  # just a few overrides, and they are pretty trivial.
  class Node
    attr_accessor :text, :parents, :children
    def initialize text
      @text = text
      @parents = []
      @children = nil
    end
  end
  
  # Just for convenience.
  def make_node(text)
    Node.new(text)
  end
  
  def node_set_text(node, text)
    node.text = text
    super
  end

  def node_text(node); node.text; end
  def node_parents(node); node.parents; end
  
  def node_children(node)
    node.children
  end

  # Needs to be redefined because #parents is stored in state of Node.
  def node_join_parent(node, parent)
    node.parents << parent
    node.parents.uniq!
  end

  # Needs to be redefined because #parents is stored in state of Node.
  def node_leave_parent(node, parent)
    node.parents.delete(parent)
  end

  # Set up the node for having children.
  #
  # Also serves as a hint, for the purposes of icon selection, that this
  # node can have children. This need not be called directly by the user,
  # though you may want to if you have a node without children and want it
  # to be displayed as if it can have children (like an empty folder). It is
  # called internally as a result of a child joining a parent.
  # 
  def node_can_have_children!(node)
    unless node.children
      node.children = []
      self.node_changes = node
    end
  end
  
end
