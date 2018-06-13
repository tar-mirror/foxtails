#!/usr/bin/env ruby

require 'foxtails'

include Fox
include FoxTails

class OptMenuWindow < FXMainWindow
  observable :items, :selected
  
  def initialize(*args)
    super
    
    self.items = [:foo, "Bar", String, 3, ["a", "b"], 1.23]
    self.selected = items[3]
    
    FXStatusBar.new(self,
       LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X|STATUSBAR_WITH_DRAGCORNER)      
    
    mb = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)
    
    file_menu = FXMenuPane.new(self)
    FXMenuTitle.new(mb, "&File", nil, file_menu)

    FXMenuCommand.new(file_menu, "&Quit\tCtl-Q\tQuit the application.").
      connect(SEL_COMMAND) { getApp().exit }
    
    opt_menu = FTOptionMenu.new(self, self, :items, :selected,
                   FRAME_RAISED|FRAME_THICK|JUSTIFY_HZ_APART|ICON_BEFORE_TEXT)
    def opt_menu.display(item); item.inspect; end

    label = FXLabel.new(self, "")
    
    when_selected CHANGES do
      label.setText("Class of item is #{selected.class}")
    end

  end
  
  def create
    super
    show
  end
end

class OptMenuApp < FTApp
  def initialize
    super("OptMenu", "TEST")
    FoxTails.get_standard_icons
    OptMenuWindow.new(self, "OptMenu")
  end
end

OptMenuApp.new.run
