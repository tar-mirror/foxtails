#!/usr/bin/env ruby

# A fancier version of the tree.rb example, with item attributes, MDI windows,
# menu commands to add new items, switch to a different tree entirely,
# string and float indexed child arrays, etc...

require 'foxtails'
require 'foxtails/icons'
require 'foxtails/treelike/sorted-tree'

include Fox
include FoxTails

# Let's add an observable attribute to the node class, and make the text
# attr observable too, to simplify reconnecting.
class MyNode < SortedTree::Node
  extend Observable

  observable :text
  observable :index
  observable :marked # a boolean value represented by a check box
  observable :description
  
  def initialize(*args)
    @marked = false
    super
  end
end

class TreeWindow < FXMainWindow
  observable :current_node, :tree
  
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

    edit_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menubar, "&Edit", nil, edit_menu)

    view_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menubar, "&View", nil, view_menu)

    help_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menubar, "&Help", nil, help_menu, LAYOUT_RIGHT)

    splitter = FXSplitter.new(self, LAYOUT_SIDE_TOP|SPLITTER_HORIZONTAL|
      LAYOUT_FILL_X|LAYOUT_FILL_Y|SPLITTER_REVERSED|SPLITTER_TRACKING)

    f1 = FXVerticalFrame.new(splitter, FRAME_SUNKEN|FRAME_THICK,
           0,0,0,0, 0,0,0,0)
           
    FTTreeList.new(f1, self, :tree, :current_node,
     (FRAME_SUNKEN|FRAME_THICK|
      LAYOUT_FILL_X|LAYOUT_FILL_Y|TREELIST_EXTENDEDSELECT|
      TREELIST_SHOWS_LINES|TREELIST_SHOWS_BOXES|TREELIST_ROOT_BOXES))

    f2 = FXVerticalFrame.new(splitter, FRAME_SUNKEN|FRAME_THICK)
    matrix = FXMatrix.new(f2, 2, MATRIX_BY_COLUMNS)
    
    targeted_widgets = []
    
    FXLabel.new(matrix, "index")
    targeted_widgets << FTTextField.new(matrix, 20, nil, :index)
    
    FXLabel.new(matrix, "item text")
    targeted_widgets << FTTextField.new(matrix, 50, nil, :text)

    FXLabel.new(matrix, "description")
    targeted_widgets << FTTextField.new(matrix, 50, nil, :description)

    targeted_widgets << FTCheckButton.new(f2, "Marked", nil, :marked)
    
    # connect the item name text field to the tree widget
    
    when_current_node CHANGES do |node|
      if node
        targeted_widgets.each do |widget|
          widget.retarget(node)
          widget.enable
        end
        
        node.when_text CHANGES do |text|
          tree.node_set_text(node, text)
          ### why doesn't this propagate when leaving field?
        end
        
        ### how to update current_node when index changes?

      else
        targeted_widgets.each do |widget|
          widget.retarget(nil)
          widget.disable
        end
      end
    end
    
    # make the tree itself
    
    make_tree
  end
  
  def make_tree    
    self.tree = SortedTree.new
    
    strings = tree.add_root(MyNode.new("strings", nil))
    numbers = tree.add_root(MyNode.new("numbers", nil))
    
    [
      "z", "s", "a", "d"
    ].each do |idx|
      tree.add_node(MyNode.new("at index #{idx}", idx), strings)
    end
    
    [
      2.40, 0.75, 1.35, 0.76
    ].each do |idx|
      tree.add_node(MyNode.new("at index #{idx}", idx), numbers)
    end
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
