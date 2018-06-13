require 'drb'

require 'foxtails'

include Fox
include FoxTails

DRb.start_service

class ChatMainWindow < FXMainWindow
  def initialize(*args)
    super
    @message = DRbObject.new(nil, 'druby://localhost:9200')
    text_field = FTTextField.new(self, 20, @message, :text)
    text_field.dynamic = true # ok for small data size
  end
  
  def create
    super
    show
  end
end

class ChatApp < FTApp
  def initialize
    super("Chat", "TEST")
    ChatMainWindow.new(self, "Chat")
  end
end

ChatApp.new.run
