#!/usr/bin/env ruby

require 'foxtails'

include Fox
include FoxTails

class InputOutputWindow < FXDialogBox
  def initialize(main_window)
    super(main_window, "")
    
    @text = FTTextField.new(self, 60, main_window, :data)
    @text.dynamic = true
  end
  
  def create
    super
    show(PLACEMENT_OWNER)
  end
end

class OutputWindow < InputOutputWindow
  def initialize(*args)
    super
    self.title = "Output"
    @text.enabled = false
  end
end

class InputWindow < InputOutputWindow
  def initialize(*args)
    super
    self.title = "Input"
  end
end

class ReverseOutputWindow < FXDialogBox
  observable :reversed_data
  extend Observable::Match
  
  def initialize(main_window)
    super(main_window, "Reverse")
    
    main_window.when_data /^reverse me$/i do |data|
      self.reversed_data = data.reverse
    end
    
    main_window.when_data NOT_MATCH[/^reverse me$/i] do |data|
      self.reversed_data = \
        "Try typing 'reverse me' in an input window, case insensitive."
    end
    
    @text = FTTextField.new(self, 60, self, :reversed_data)
    @text.dynamic = true
    @text.enabled = false
  end
  
  def create
    super
    show(PLACEMENT_OWNER)
  end
end

class MainWindow < FXMainWindow
  observable :data

  def initialize(*args)
    super
    
    input_btn = FXButton.new(self, "New Input Window")
    input_btn.connect(SEL_COMMAND) do
      InputWindow.new(self).create
    end
    
    output_btn = FXButton.new(self, "New Output Window")
    output_btn.connect(SEL_COMMAND) do
      OutputWindow.new(self).create
    end
    
    reverse_output_btn = FXButton.new(self, "New Reverse Output Window")
    reverse_output_btn.connect(SEL_COMMAND) do
      ReverseOutputWindow.new(self).create
    end
  end
  
  def create
    super
    show
  end
end

class TestApp < FTApp
  def initialize
    super("Test", "TEST")
    MainWindow.new(self, "Test")
  end
end

TestApp.new.run
