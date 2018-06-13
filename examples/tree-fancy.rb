#!/usr/bin/env ruby

# A fancier version of the tree.rb example, with item attributes, MDI windows,
# menu commands to add new items, switch to a different tree entirely,
# string and float indexed child arrays, etc...

require 'foxtails'
require 'foxtails/icons'
require 'treelike/sorted-tree'

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

class TreeBrowser < FXMDIChild
  observable :current_node, :tree
  
  def initialize(main_window, tree, x=10, y=10, w=500, h=300)
    @@count ||= 0
    @@count += 1
    
    super(main_window.mdiclient, "#{self.class} ##{@@count}", PENGUIN_ICON,
      main_window.mdimenu, 0, x, y, w, h)
    
    self.tree = tree
    self.current_node = nil
    
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
    targeted_widgets << FTTextField.new(matrix, 30, nil, :text)

    FXLabel.new(matrix, "description")
    targeted_widgets << FTTextField.new(matrix, 30, nil, :description)

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
  end
end

class TreeWindow < FXMainWindow
  attr_reader :mdiclient, :mdimenu
  
  attr_reader :tree
  
  def initialize(*args)
    super
    
    # make the tree model itself
    make_tree

    resize 800, 600

    status = FXStatusBar.new(self,
      LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X|STATUSBAR_WITH_DRAGCORNER)

    menubar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)

    @mdiclient = FXMDIClient.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y)
    @mdimenu = FXMDIMenu.new(self, @mdiclient)

    file_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menubar, "&File", nil, file_menu)
    
    FXMenuCommand.new(file_menu, "&New\tCtl-N\tCreate new document.").
      connect(SEL_COMMAND) do
        tb = TreeBrowser.new(self, tree, 100, 200)
        tb.create
        @mdiclient.setActiveChild(tb)
      end

    FXMenuCommand.new(file_menu, "&Quit\tCtl-Q\tQuit the application.").
      connect(SEL_COMMAND) { getApp().exit }

    edit_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menubar, "&Edit", nil, edit_menu)

    view_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menubar, "&View", nil, view_menu)

    windowmenu = FXMenuPane.new(self)
    FXMenuCommand.new(windowmenu, "Tile &Horizontally", nil,
      @mdiclient, FXMDIClient::ID_MDI_TILEHORIZONTAL)
    FXMenuCommand.new(windowmenu, "Tile &Vertically", nil,
      @mdiclient, FXMDIClient::ID_MDI_TILEVERTICAL)
    FXMenuCommand.new(windowmenu, "C&ascade", nil,
      @mdiclient, FXMDIClient::ID_MDI_CASCADE)
    FXMenuCommand.new(windowmenu, "&Close", nil,
      @mdiclient, FXMDIClient::ID_MDI_CLOSE)
###    FXMenuCommand.new(windowmenu, "Close &All", nil,
###      @mdiclient, FXMDIClient::ID_CLOSE_ALL_DOCUMENTS)
    sep1 = FXMenuSeparator.new(windowmenu)
    sep1.setTarget(@mdiclient)
    sep1.setSelector(FXMDIClient::ID_MDI_ANY)
    FXMenuCommand.new(windowmenu, nil, nil, @mdiclient, FXMDIClient::ID_MDI_1)
    FXMenuCommand.new(windowmenu, nil, nil, @mdiclient, FXMDIClient::ID_MDI_2)
    FXMenuCommand.new(windowmenu, nil, nil, @mdiclient, FXMDIClient::ID_MDI_3)
    FXMenuCommand.new(windowmenu, nil, nil, @mdiclient, FXMDIClient::ID_MDI_4)
    ### this doesn't work very well: only 4, and slow update
    FXMenuTitle.new(menubar,"&Window", nil, windowmenu)

    help_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menubar, "&Help", nil, help_menu, LAYOUT_RIGHT)

    # MDI buttons in menu:- note the message ID's!!!!!
    # Normally, MDI commands are simply sensitized or desensitized;
    # Under the menubar, however, they're hidden if the MDI Client is
    # not maximized.  To do this, they must have different ID's.
    FXMDIWindowButton.new(menubar, @mdiclient, FXMDIClient::ID_MDI_MENUWINDOW,
      LAYOUT_LEFT)
    FXMDIDeleteButton.new(menubar, @mdiclient, FXMDIClient::ID_MDI_MENUCLOSE,
      FRAME_RAISED|LAYOUT_RIGHT)
    FXMDIRestoreButton.new(menubar, @mdiclient, FXMDIClient::ID_MDI_MENURESTORE,
      FRAME_RAISED|LAYOUT_RIGHT)
    FXMDIMinimizeButton.new(menubar, @mdiclient,
      FXMDIClient::ID_MDI_MENUMINIMIZE, FRAME_RAISED|LAYOUT_RIGHT)

    mdichild = TreeBrowser.new(self, tree)
    @mdiclient.setActiveChild(mdichild)
  end
  
  def make_tree    
    @tree = SortedTree.new
    
    strings = @tree.add_root(MyNode.new("strings", nil))
    numbers = @tree.add_root(MyNode.new("numbers", nil))
    
    [
      "z", "s", "a", "d"
    ].each do |idx|
      @tree.add_node(MyNode.new("at index #{idx}", idx), strings)
    end
    
    [
      2.40, 0.75, 1.35, 0.76
    ].each do |idx|
      @tree.add_node(MyNode.new("at index #{idx}", idx), numbers)
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
