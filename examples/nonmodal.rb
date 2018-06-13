#!/usr/bin/env ruby

require 'foxtails'

include Fox
include FoxTails

class TestDialog < FXDialogBox
  include FTNonModal
  
  def initialize(*args)
    super
    
    buttons = FXHorizontalFrame.new(self,
      LAYOUT_SIDE_BOTTOM|FRAME_NONE|LAYOUT_FILL_X|PACK_UNIFORM_WIDTH)

    FXButton.new(buttons, "&Accept", nil, self, ID_ACCEPT,
      FRAME_RAISED|FRAME_THICK|LAYOUT_RIGHT|LAYOUT_CENTER_Y)
  
    FXButton.new(buttons, "&Cancel", nil, self, ID_CANCEL,
      FRAME_RAISED|FRAME_THICK|LAYOUT_RIGHT|LAYOUT_CENTER_Y)
  end
end

class MainWindow < FXMainWindow
  def initialize(app)
    super(app, "NonModal test", nil, nil, DECOR_ALL)
    
    frame = FXHorizontalFrame.new(self)

    nonModalButton = FXButton.new(frame, "&Non-Modal Dialog...", nil, nil, 0,
      FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X|LAYOUT_CENTER_Y)
    
    nonModalButton.connect(SEL_COMMAND) do
      @dialog.execute_nonmodal do |accepted|
        @label.text = accepted ? "Dialog accepted" : "Dialog cancelled"
      end
    end
  
    @label = FXLabel.new(frame, "Dialog not invoked yet")
    
    @dialog = TestDialog.new(getApp(), "NonModal Dialog",
      DECOR_TITLE|DECOR_BORDER)
    
    show
  end

end

if __FILE__ == $0
  application = FTApp.new("NonModal", "FoxTailsTest")
  window = MainWindow.new(application)
  application.create
  application.run
end
