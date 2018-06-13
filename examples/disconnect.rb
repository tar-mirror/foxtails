#!/usr/bin/env ruby

require 'foxtails'

include Fox
include FoxTails

class MainWindow < FXMainWindow
  observable :data, :t2, :t3
  
  def initialize(*args)
    super
    
    self.t2 = true
    self.t3 = true
    
    frame = FXVerticalFrame.new(self)
    
    f1 = FXHorizontalFrame.new(self)
    FXLabel.new(f1, "One", nil, LAYOUT_FIX_WIDTH).width = 50
    @text1 = FTTextField.new(f1, 60, self, :data)
    @text1.dynamic = true

    f2 = FXHorizontalFrame.new(self)
    FXLabel.new(f2, "Two", nil, LAYOUT_FIX_WIDTH).width = 50
    @text2 = FTTextField.new(f2, 60, self, :data)
    @text2.dynamic = true
    @check2 = FTCheckButton.new(f2, "connected to One", self, :t2)
    when_t2 CHANGES do |val|
      @text2.retarget(val ? self : nil)
    end

    f3 = FXHorizontalFrame.new(self)
    FXLabel.new(f3, "Three", nil, LAYOUT_FIX_WIDTH).width = 50
    @text3 = FTTextField.new(f3, 60, self, :data)
    @text3.dynamic = true
    @check3 = FTCheckButton.new(f3, "connected to One", self, :t3)
    when_t3 CHANGES do |val|
      @text3.retarget(val ? self : nil)
    end

  end
  
  def create
    super
    show(PLACEMENT_OWNER)
  end
end

class TestApp < FTApp
  def initialize
    super("Test", "TEST")
    MainWindow.new(self, "Test")
  end
end

TestApp.new.run
