#!/usr/bin/env ruby

require 'foxtails'

include Fox
include FoxTails

class LabelWindow < FXMainWindow
  include Observable
  
  observable :foo

  def initialize(app)
    super(app, "Label", nil, nil, DECOR_ALL)

    self.foo = "this text labels itself"
      # NOTE: "@foo = ..." will not trigger updates

    vframe = FXVerticalFrame.new(self)
    frame = FXHorizontalFrame.new(vframe)

    l = FXLabel.new(frame,"B")
    tf = FTTextField.new(frame,50,self,:foo)
    
    tf.dynamic = true # assuming you want foo updated while you are editing
    
    when_foo CHANGES do
      l.text = foo
    end

    FXButton.new(vframe,"puts").connect(SEL_COMMAND) do
      puts foo 
    end
    
    show
  end
end

if __FILE__ == $0
  application = FTApp.new("Label", "FoxTailsTest")
  window = LabelWindow.new(application)
  application.create
  application.run
end


