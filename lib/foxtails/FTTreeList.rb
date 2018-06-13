require 'foxtails/FTTargeted'

module FoxTails

  class FTTreeItem < Fox::FXTreeItem
    # The "index" of this item in the list. Allows for sparse lists, and lists
    # indexed by non-integer Comparable values.
    # For instance, the actual data structure may have only 2 entries,
    # at 0 and at 100, but you don't want to show blank entries between them.
    # The extra information in #index remembers where the item came from in
    # the data structure.
    attr_accessor :index
  end

  # Goals:
  #
  # - Given a bunch of objects with some kind of tree structure,
  #   it should be possible to browse/edit it as a tree with minimal
  #   set up effort. User doensn't have to work directly with FXTreeItems.
  #
  # - User doesn't have to subclass FXTreeItem. Can use
  #   own node classes and specify an interface to them that
  #   defines tree structure.
  #
  # - By specifying the interface dynamically, can have
  #   top-down and bottom-up views of the hierarchy.
  #
  # - FTTreeList observes changes to tree
  #   and updates itself, if you follow the interface.
  #
  # - By decoupling FXTreeItem from the actual nodes, can
  #   have multiple views.
  #
  # - Operations on the tree that are initiated by the user
  #   are propagated to the decoupled node objects and then,
  #   by the observer mechanism, back to the view.
  #
  # - Some simple tree/node classes are provided.
  #
  # - Works with directed acyclic graphs as well as trees. In other words
  #   you can have many roots and nodes can have more than one parent. A root
  #   can also occur as a child of some other part of the dag.
  #
  # - Selection is broadcast via the usual FTTargeted mechanism,
  #   so treelist can be used as a control that is synced with
  #   a variable. Actually, it can be synced with two variables, one for the
  #   tree and one for the currently selected node.
  #
  # - Note that selecting an item that represents a node with more than
  #   one parent results in multiple selection of all items that represent
  #   the node.
  # 
  # - Use with a tree clas based on the Treelike mixin in treelike.rb.
  #
  # Warning:
  #
  # - Do not call sortItems and the like. This should be done at the
  #   model level.
  #
  # - Cicular references are not allowed.
  #
  # - A child cannot occur more than once as a child of a single parent.
  #
  # - Because of the way FTTargeted works, you cannot changing the state of
  #   the current selection until after create has been called.
  #
  class FTTreeList < Fox::FXTreeList
    include FTTreeStateTargeted
    
    def target_arg_range  # :nodoc:
      1..3
    end
    
    # The inverse of FXTreeItem#data.
    # Maps <data_object> => [<FXTreeItem>, ...]
    attr_reader :item_map
    
    alias :tree :get_target_tree
    alias :when_current_node :when_target_state

    # Arguments are as for FXTreeList, except that the <tt>tgt,sel</tt>
    # arguments are replaced with 3 arguments:
    #
    # +target+::  a object (or proc/method returning an object) 
    #
    # +tree+::    symbol denoting an observable variable in the target which
    #             client code must assign a Treelike object to
    #
    # +node+::    symbol denoting an observable variable in the target can be
    #             used to access the currently selected node in the tree
    #
    def initialize(*args) # :yields: tree_list
      super
      @item_map = {}
    end

    ### might be better to use close event handler to disconnect
    ### (but that's not DRb-friendly)
    def handle_observer_exception exception, var, pattern
      exception.message =~ /This FXTreeList \* already released/
    end

    def connect_to_target # :nodoc:
      connect(SEL_COMMAND) do |sender, sel, item|
        set_target_state(item.data) ## mult selection?
      end

      when_current_node CHANGES do |node|
        killSelection
        if node and item_map[node]
          item_map[node].each do |item|
            selectItem(item)
          end
        end
      end
      
      when_target_tree CHANGES do |new_tree, old_tree|
        if old_tree
          disconnect_from_tree(old_tree)
        end
        if new_tree
          connect_to_tree
          ### need a way to rebuild just this FTTreeList
          rebuild_tree # Do this after connect_to_tree, since it sends signals.
        else
          clearItems
        end
      end
    end
    
    def disconnect_from_tree tree  # :nodoc:
      remove_observer_node_changes(tree)
      remove_observer_child_joins_parent(tree)
      remove_observer_child_leaves_parent(tree)
      remove_observer_tree_adds_root(tree)
      remove_observer_tree_deletes_root(tree)
    end
    
    def connect_to_tree  # :nodoc:
      tree.when_node_changes do |node|
        item_map[node].each do |item|
          refresh_item(item, node)
        end
      end
      
      tree.when_child_joins_parent do |args| child, parent, index = args
        item_map[parent].each do |parent_item|
          child_item = make_item(child)
          add_item_at_index(parent_item, child_item, index)
          (item_map[child] ||= []) << child_item
        end
      end
      
      tree.when_child_leaves_parent do |args| child, parent = args
        item_map[child].delete_if do |child_item|
          if child_item.parent.data == parent
            removeItem(child_item)
            true
          end
        end
      end
      
      tree.when_tree_adds_root do |args| root, index = args
        root_item = make_item(root)
        add_item_at_index(nil, root_item, index)
        (item_map[root] ||= []) << root_item
      end

      tree.when_tree_deletes_root do |root|
        item_map[root].delete_if do |root_item|
          if root_item.parent == nil
            removeItem(root_item)
              # A root can be a child in another part of the tree.
            true
          end
        end
      end
    end
    
    def add_item_at_index parent_item, child_item, index   # :nodoc:
      child_item.index = index
      sibling_item = parent_item ? parent_item.first : firstItem
      
      ## should use rbtrees to avoid linear search?
      while sibling_item and index > sibling_item.index
#puts "#{index} > #{sibling_item.index} = #{index > sibling_item.index}"
        sibling_item = sibling_item.next
      end
      
      if sibling_item
        addItemBefore(sibling_item, child_item)
      else
        addItemLast(parent_item, child_item)
      end
    end
    
    def make_item(node)  # :nodoc:
      item = FTTreeItem.new("")
      refresh_item(item, node)
      item
    end
    
    def refresh_item(item, node)  # :nodoc:
      item.text = tree.node_text(node)
      item.openIcon = tree.node_open_icon(node)
      item.closedIcon = tree.node_closed_icon(node)
      item.data = node
      item.openIcon.create
      item.closedIcon.create
    end
    
    def rebuild_tree  # :nodoc:
      clearItems
      tree.resignal_all
    end
    
    undef sortItems
  
  end
end
