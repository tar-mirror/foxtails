#!/usr/bin/env ruby

require 'foxtails'

include Fox
include FoxTails

class FieldsWindow < FXMainWindow
  include FTField
  
  observable :items, :selected
  observable :check, :x, :y, :radio
  observable :choices, :cur_choice
  observable :str1, :str2, :flt1, :chk1, :chk2
  
  def initialize(*args)
    super
    
    self.items = [:foo, "Bar", String, 3, ["a", "b"], 1.23]
    self.selected = items[3]
    
    FXToolTip.new(getApp(), TOOLTIP_NORMAL)
    
    FXStatusBar.new(self,
       LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X|STATUSBAR_WITH_DRAGCORNER)      
    
    mb = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)
    
    file_menu = FXMenuPane.new(self)
    FXMenuTitle.new(mb, "&File", nil, file_menu)

    FXMenuCommand.new(file_menu, "&Quit\tCtl-Q\tQuit the application.").
      connect(SEL_COMMAND) { getApp().exit }
    
    self.check = true
    self.x = 5
    self.y = 1
    f = field("%v require that %6.2f > %6.2f", :check, :x, :y)
    f.valid(:x) {|x| not check or x > y}
    f.valid(:y) {|y| not check or x > y}
    
    self.radio = 2
    field("%r radio one %r radio two %r radio three",
      [:radio, 1], [:radio, 2], [:radio, 3])
    
    self.choices = [String, Integer, Float]
    self.cur_choice = Integer
    field("choose %m", [:choices, :cur_choice])
    
    matrix = FXMatrix.new(self, 4,
      MATRIX_BY_COLUMNS|FRAME_THICK|LAYOUT_FILL_X)
    matrix.padTop = matrix.padBottom = 0
    matrix.padLeft = matrix.padRight = 0
    
    # The %| character separates fields into different cells of the matrix.
    field(matrix, "Foo %s %| bar %s %f bar %| %| %v baz",
      :str1, :str2, :flt1, :chk1)
    field(matrix, "%v check %| blah %| %| zap", :chk2)
    
    # Without a matrix, the %| character just adds the fields separately to
    # the parent container. In the current case, they appear on separate lines.
    field("First line %| second line")
    
    # We can use another object (in this case, the app as the target).
    # Note that the methods must be observable-see the FieldsApp class below.
    field("App's menu pause: %5d milliseconds", [getApp(), :menuPause])
    field("App's tooltip pause: %5d ms, time: %5d ms",
      [getApp(), :tooltipPause], [getApp(), :tooltipTime])
    
    f = field("Test tip here")
    f.each do |var, w|
      w.tipText = w.helpText = "This is a test tip"
    end

  end
  
  def create
    super
    show
  end
end

class FieldsApp < FTApp
  observable :menuPause, :tooltipPause, :tooltipTime
  
  def initialize
    super("Fields", "TEST")
    FoxTails.get_standard_icons
    FieldsWindow.new(self, "Fields")
  end
end

FieldsApp.new.run
