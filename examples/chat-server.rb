require 'drb'
require 'observable'

class DRb::DRbServer::InvokeMethod
  def handle_observer_exception(*args)
    @obj.handle_observer_exception(*args)
  end
end

class Message
  extend Observable
  
  observable :text

  def handle_observer_exception(exception, var, pattern)
    if DRb::DRbConnError === exception
      $stderr.puts "A client disconnected."
      false # let the observer be disconnected
    else
      $stderr.puts "A client had an unhandled exception in a when_ clause."
      # handle any app-specific exceptions
      true # Stay connected if handled. Otherwise, return false.
    end
  end
end

DRb.start_service('druby://localhost:9200', Message.new)

if /win/ =~ RUBY_PLATFORM or ARGV.delete('--gui')

  require 'fox'
  require 'foxtails'

  include Fox
  include FoxTails
  
  class ChatServerMainWindow < FXMainWindow
    def initialize(*args)
      super
      FXLabel.new(self, "Chat Server")
      FXButton.new(self, "&Quit").connect(SEL_COMMAND) {exit}
    end

    def create
      super
      show
    end
  end

  class ChatServerApp < FTApp
    def initialize
      super("Chat", "TEST")
      ChatServerMainWindow.new(self, "Chat")
    end
  end

  ChatServerApp.new.run
  

else

  puts '[interrupt] to exit.'
  sleep

end

