#!/usr/bin/env ruby

# A simple example showing use of foxtails/FTTreeList.rb
# and foxtails/tree-mixin.rb and foxtails/treelike/array-tree.rb.

require 'foxtails'

include Fox
include FoxTails

class TreeWindow < FXMainWindow
  observable :current_node, :tree, :item_name
  
  def initialize(*args)
    super
    
    resize 800, 600

    status = FXStatusBar.new(self,
      LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X|STATUSBAR_WITH_DRAGCORNER)

    menubar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)

    file_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menubar, "&File", nil, file_menu)
    
    FXMenuCommand.new(file_menu, "&Quit\tCtl-Q\tQuit the application.").
      connect(SEL_COMMAND) { getApp().exit }

    splitter = FXSplitter.new(self, LAYOUT_SIDE_TOP|SPLITTER_HORIZONTAL|
      LAYOUT_FILL_X|LAYOUT_FILL_Y|SPLITTER_REVERSED|SPLITTER_TRACKING)

    # make the tree list and its frame

    f1 = FXVerticalFrame.new(splitter, FRAME_SUNKEN|FRAME_THICK,
           0,0,0,0, 0,0,0,0)
           
    FTTreeList.new(f1, self, :tree, :current_node,
     (FRAME_SUNKEN|FRAME_THICK|
      LAYOUT_FILL_X|LAYOUT_FILL_Y|TREELIST_EXTENDEDSELECT|
      TREELIST_SHOWS_LINES|TREELIST_SHOWS_BOXES|TREELIST_ROOT_BOXES))

    # make the frame and text field for editing the name of the item

    f2 = FXVerticalFrame.new(splitter, FRAME_SUNKEN|FRAME_THICK)
    field = FTTextField.new(f2,50,self,:item_name)
    
    # connect the item name text field to the tree widget
    
    when_current_node CHANGES do |node|
      if node
        self.item_name = node.text
        field.enable
      else
        self.item_name = ""
        field.disable
      end
    end
    
    when_item_name CHANGES do |text|
      if current_node
        tree.node_set_text(current_node, text)
#        2.times do
#          getApp.flush
#          getApp.forceRefresh
#          getApp.repaint
#          recalc
#          update
#        end
        ### doesn't propagate to other representations of the same
        ### item until you move selection.
      end
    end
    
    # make the tree itself
    
    make_tree
  end
  
  def make_tree
    self.tree = ArrayTree.new
    
    r1 = tree.add_root(tree.make_node("root 1"))
    r2 = tree.add_root(tree.make_node("root 2"))
    
    two_parent_node = tree.make_node("two parent node")
    
    tree.add_node(tree.make_node("child 1"), r1)
    tree.add_node(tree.make_node("child 2"), r1)
    tree.add_node(tree.make_node("child 3"), r1)
    tree.add_node(two_parent_node, r1)
    
    tree.add_node(a = tree.make_node("child a"), r2)
    tree.add_node(b = tree.make_node("child b"), r2)
    tree.add_node(tree.make_node("child c"), r2)
    tree.add_node(two_parent_node, r2)
    
    tree.add_node(tree.make_node("child y"), two_parent_node)
    tree.add_node(tree.make_node("child z"), two_parent_node)
    tree.add_node(tree.make_node("child x"), two_parent_node, 0) # insert!
    
    u = tree.make_node("u")
    v = tree.make_node("v")
    
    tree.add_node(u, a)
    tree.add_node(v, a)
    
    tree.add_node(u, b, 1) # Note: sparse array is OK!
    tree.add_node(v, b, 0) # Can add in any order, as you like!
    
    sparse = tree.add_root(tree.make_node("sparse indices"))
    tree.add_node(tree.make_node("at index 50"), sparse, 50)
    tree.add_node(tree.make_node("at index 20"), sparse, 20)
    tree.add_node(tree.make_node("at index 40"), sparse, 40)
    tree.add_node(tree.make_node("at index 30"), sparse, 30)
    tree.add_node(tree.make_node("at index 10"), sparse, 10)
    
  end
  
  def create
    super
    show
  end
end

class TreeApp < FTApp
  def initialize
    super("Tree", "TEST")
    FoxTails.get_standard_icons
    TreeWindow.new(self, "Tree")
  end
end

TreeApp.new.run
