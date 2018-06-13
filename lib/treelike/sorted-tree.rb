require 'rbtree'
require 'set'

# Treelike class which uses a RBTree to hold the children and a
# Set to hold the parent(s) of each node.
class SortedTree
  include Treelike

  class Node
    attr_accessor :text, :parents, :children
    
    attr_reader :index
    
    attr_accessor :tree
    
    def index=(new_index)
      old_parents = @parents.dup
      old_tree = @tree
      
### how to do this elegantly?
if new_index.is_a? String and @index.is_a? Numeric
  new_index = eval(new_index)
end
      if @parents.empty? # root?
        @tree.delete_root(self)
        @index = new_index
        old_tree.add_root(self, new_index.to_i) ### roots must be int indexed
        ### must re-add children?
      
      else
        @tree.delete_node(self)
        @index = new_index
        old_parents.each do |parent|
          old_tree.add_node(self, parent)
        end
        ### must re-add children?
      end
    end
    
    def initialize text, index
      @text = text
      @index = index
      @parents = Set.new
      @children = nil
    end
  end
  
  # Just for convenience.
  def make_node(text, index)
    Node.new(text, index)
  end
  
  def node_set_text(node, text)
    node.text = text
    super
  end

  def node_text(node); node.text; end
  def node_parents(node); node.parents; end
  
  def node_children(node)
    ch = node.children
    ch && ch.values ## kinda inefficient when used in node_open_icon...
  end

  # Needs to be redefined because #parents is stored in state of Node.
  def node_join_parent(node, parent)
    node.parents << parent
  end

  # Needs to be redefined because #parents is stored in state of Node.
  def node_leave_parent(node, parent)
    node.parents.delete(parent)
  end

  def node_can_have_children!(node)
    unless node.children
      node.children = RBTree.new
      self.node_changes = node
    end
  end

  def node_child_index(parent, child)
    child.index
  end
  
  def node_join_child(node, child, index)
    node_can_have_children!(node)
    raise unless child.index == index ## does this make sense?
    if node.children[index]
      raise "Node #{node.text} already has a child at #{index}"
    end
    node.children[index] = child
  end

  def node_leave_child(node, child)
    raise unless node.children[child.index] == child
    node.children.delete(child.index)
  end
  
  def add_root(root, index = nil)
    root.tree = self
    super
  end

  def delete_root(root)
    root.tree = nil
    super
  end
  
  def delete_node(node)
    node.tree = nil
    super
  end
  
  def add_node node, parent
    node.tree = self
    super node, parent, node.index
  end
end
