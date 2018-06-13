#!/usr/bin/env ruby

require 'foxtails'

include Fox
include FoxTails

class ScrollWindow < FXMainWindow
  def initialize(*args)
    super
    
    resize 400, 400

    status = FXStatusBar.new(self,
      LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X|STATUSBAR_WITH_DRAGCORNER)

    mb = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)

    file_menu = FXMenuPane.new(self)
    FXMenuTitle.new(mb, "&File", nil, file_menu)
    
    FXMenuCommand.new(file_menu, "&Quit\tCtl-Q\tQuit the application.").
      connect(SEL_COMMAND) { getApp().exit }

    scroll_window = FXScrollWindow.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y)

    matrix = FXMatrix.new(scroll_window, 2, MATRIX_BY_COLUMNS)
    100.times do |i|
      field = nil # create the variable *inside* the loop, so we get a
                  # different binding each time thru
      b = FTCheckButton.new(matrix, "Field #{i}", proc {field}, :enabled)
      field = FTTextField.new(matrix, 60) # same as FXTextField, here
      field.text = "Default text in field #{i}"
      field.enabled = false
#      if i == 3
#        rslt = b.setTextColor(FXColor::MediumAquamarine)
#        p rslt
#      end
#      if i == 5
#        rslt = b.textColor = FXColor::MediumOrchid3
#        p rslt
#      end
    end
    
  end
  
  def create
    super
    show
  end
end

class ScrollApp < FTApp
  def initialize
    super("Scroll", "TEST")
    ScrollWindow.new(self, "Scroll")
  end
end

ScrollApp.new.run
